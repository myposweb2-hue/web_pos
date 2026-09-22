from flask import Blueprint, render_template, request, jsonify, flash, redirect, url_for, session
from flask_login import login_required, current_user
from sqlalchemy import or_, text
from app.models import (
    db, Company, User, Sale, SaleItem, SaleRequest, Return, Exchange, ExchangeItem, ReturnItem,
    Cheque, ChequeDeposit, Customer, Supplier, Product, Expense, Warehouse, Promotion,
    InventoryTransaction, CustomerFeedback, HeldBill, SerialNumber, CustomerPayment,
    AuditLog, CashierShift, Purchase, PurchaseItem, PurchaseReturn, PurchaseReturnItem,
    PurchaseOrder, PurchaseOrderItem, StockCountItem, Setting
)
from app import csrf
from app.utils.permissions import require_permission
from app.utils.company import get_current_company, get_user_companies, set_current_company
from app.utils.security import (
    require_super_admin, 
    require_company_admin,
    require_company_context,
    get_company_id,
    verify_resource_access
)
from datetime import datetime

companies_bp = Blueprint('companies', __name__, template_folder='../../templates')

@companies_bp.route('/')
@login_required
def companies():
    """List all companies - SUPER ADMIN ONLY."""
    # SECURITY: Only super admin can manage companies
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can manage companies'}), 403
    
    all_companies = Company.query.all()
    return render_template('companies/companies.html', companies=all_companies)

@companies_bp.route('/companies')
@login_required
def companies_legacy_alias():
    """Backward-compatible alias for the companies dashboard."""
    return companies()

@companies_bp.route('/api/companies')
@csrf.exempt
@login_required
def get_companies():
    """Get companies - SUPER ADMIN ONLY for management interface."""
    # SECURITY: Only super admin can manage companies
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can manage companies'}), 403
    
    all_companies = Company.query.all()
    
    result = []
    for company in all_companies:
        result.append({
            'id': company.id,
            'name': company.name,
            'business_name': company.business_name,
            'address': company.address,
            'phone': company.phone,
            'email': company.email,
            'is_active': company.is_active
        })
    
    return jsonify(result)

@companies_bp.route('/api/companies/transfer-products', methods=['POST'])
@csrf.exempt
@login_required
def transfer_products_between_companies():
    """Copy products from one company to another, preserving image paths and key metadata."""
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can transfer products between companies'}), 403

    data = request.get_json(silent=True) or {}
    source_company_id = data.get('source_company_id')
    target_company_id = data.get('target_company_id')
    include_images = bool(data.get('include_images', True))
    overwrite_existing = bool(data.get('overwrite_existing', False))

    if not source_company_id or not target_company_id:
        return jsonify({'error': 'Source and target company IDs are required'}), 400

    try:
        source_company_id = int(source_company_id)
        target_company_id = int(target_company_id)
    except (TypeError, ValueError):
        return jsonify({'error': 'Company IDs must be valid integers'}), 400

    if source_company_id == target_company_id:
        return jsonify({'error': 'Source and target companies must be different'}), 400

    source_company = Company.query.get(source_company_id)
    target_company = Company.query.get(target_company_id)
    if not source_company or not target_company:
        return jsonify({'error': 'Source or target company not found'}), 404

    products = Product.query.filter(Product.company_id == source_company_id).order_by(Product.id).all()
    created_count = 0
    updated_count = 0
    skipped_count = 0

    for product in products:
        existing_product = Product.query.filter(
            Product.company_id == target_company_id,
            or_(Product.barcode == product.barcode, Product.name == product.name)
        ).first()

        if existing_product and not overwrite_existing:
            skipped_count += 1
            continue

        warehouse_id = None
        if product.warehouse_id and product.warehouse:
            target_warehouse = Warehouse.query.filter(
                Warehouse.company_id == target_company_id,
                Warehouse.name == product.warehouse.name
            ).first()
            if target_warehouse:
                warehouse_id = target_warehouse.id

        supplier_id = None
        if product.supplier_id and product.supplier:
            target_supplier = Supplier.query.filter(
                Supplier.company_id == target_company_id,
                Supplier.id == product.supplier_id
            ).first()
            if not target_supplier:
                target_supplier = Supplier.query.filter(
                    Supplier.company_id == target_company_id,
                    Supplier.name == product.supplier.name
                ).first()
            if target_supplier:
                supplier_id = target_supplier.id

        if existing_product:
            prev_stock = float(existing_product.stock or 0)
            existing_product.name = product.name
            existing_product.price = product.price
            existing_product.cost_price = product.cost_price
            existing_product.stock = product.stock
            existing_product.unit_type = product.unit_type
            existing_product.category = product.category
            existing_product.low_stock_threshold = product.low_stock_threshold
            existing_product.barcode = product.barcode
            existing_product.description = product.description
            existing_product.warehouse_id = warehouse_id
            existing_product.supplier_id = supplier_id
            existing_product.price_per_kg = product.price_per_kg
            existing_product.product_code = product.product_code
            if include_images:
                existing_product.image_path = product.image_path
            existing_product.last_updated = datetime.utcnow()
            updated_count += 1
            # Record inventory transaction for target company (transfer in)
            try:
                new_stock = float(existing_product.stock or 0)
                from app.models import InventoryTransaction
                tx = InventoryTransaction(
                    product_id=existing_product.id,
                    transaction_type='transfer_in',
                    quantity=max(0.0, new_stock - prev_stock),
                    previous_stock=prev_stock,
                    new_stock=new_stock,
                    reference_id=product.id,
                    notes=f'Transferred from company {source_company_id}',
                    company_id=target_company_id
                )
                db.session.add(tx)
            except Exception:
                # Don't fail the whole transfer if logging the transaction fails
                pass
            continue

        new_product = Product(
            name=product.name,
            price=product.price,
            cost_price=product.cost_price,
            stock=product.stock,
            unit_type=product.unit_type,
            category=product.category,
            low_stock_threshold=product.low_stock_threshold,
            barcode=product.barcode,
            description=product.description,
            image_path=product.image_path if include_images else None,
            warehouse_id=warehouse_id,
            supplier_id=supplier_id,
            company_id=target_company_id,
            price_per_kg=product.price_per_kg,
            product_code=product.product_code,
        )
        db.session.add(new_product)
        created_count += 1
        # Record inventory transaction for target (transfer in - new product)
        try:
            from app.models import InventoryTransaction
            tx = InventoryTransaction(
                product_id=new_product.id,
                transaction_type='transfer_in',
                quantity=float(product.stock or 0),
                previous_stock=0.0,
                new_stock=float(product.stock or 0),
                reference_id=product.id,
                notes=f'Transferred from company {source_company_id}',
                company_id=target_company_id
            )
            db.session.add(tx)
        except Exception:
            pass

    db.session.commit()
    return jsonify({
        'success': True,
        'message': f'Product transfer completed: {created_count} copied, {updated_count} updated, {skipped_count} skipped.',
        'copied_count': created_count,
        'updated_count': updated_count,
        'skipped_count': skipped_count,
        'include_images': include_images,
        'overwrite_existing': overwrite_existing,
    })


@companies_bp.route('/api/companies/<int:company_id>/transfer-history')
@csrf.exempt
@login_required
def company_transfer_history(company_id):
    """Return recent product transfer inventory transactions for a company."""
    # Only Super Admin may view cross-company transfers
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can view transfer history'}), 403

    # Query recent transfer-related inventory transactions
    from app.models import InventoryTransaction, Product
    txs = InventoryTransaction.query.filter(
        InventoryTransaction.company_id == company_id,
        InventoryTransaction.transaction_type.ilike('transfer%')
    ).order_by(InventoryTransaction.date.desc()).limit(100).all()

    result = []
    for t in txs:
        prod = Product.query.get(t.product_id)
        result.append({
            'id': t.id,
            'product_id': t.product_id,
            'product_name': prod.name if prod else None,
            'transaction_type': t.transaction_type,
            'quantity': float(t.quantity),
            'previous_stock': float(t.previous_stock),
            'new_stock': float(t.new_stock),
            'reference_id': t.reference_id,
            'date': t.date.isoformat() if t.date else None,
            'notes': t.notes,
            'company_id': t.company_id
        })

    return jsonify(result)


@companies_bp.route('/<int:company_id>/transfer-history-page')
@login_required
def transfer_history_page(company_id):
    """Render a simple page showing recent transfer history for a company (Super Admin only)."""
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can view transfer history'}), 403

    current_selected_company = get_current_company()
    if current_selected_company and current_selected_company.id != company_id:
        return redirect(url_for('companies.transfer_history_page', company_id=current_selected_company.id))

    company = Company.query.get_or_404(company_id)
    return render_template('companies/transfer_history.html', company=company)

@companies_bp.route('/api/companies/<int:company_id>/products')
@csrf.exempt
@login_required
def get_company_products(company_id):
    """Get products from a company for selection - SUPER ADMIN ONLY."""
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can access company products'}), 403
    
    company = Company.query.get_or_404(company_id)
    products = Product.query.filter(Product.company_id == company_id).order_by(Product.name).all()
    
    result = []
    for product in products:
        result.append({
            'id': product.id,
            'name': product.name,
            'barcode': product.barcode,
            'price': float(product.price) if product.price else 0,
            'cost_price': float(product.cost_price) if product.cost_price else 0,
            'stock': float(product.stock) if product.stock else 0,
            'unit_type': product.unit_type or 'unit',
            'category': product.category or '',
            'image_path': product.image_path or '',
        })
    
    return jsonify(result)

@companies_bp.route('/api/companies/transfer-products-selective', methods=['POST'])
@csrf.exempt
@login_required
def transfer_products_selective():
    """Transfer selected products with specific quantities between companies."""
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can transfer products between companies'}), 403

    data = request.get_json(silent=True) or {}
    source_company_id = data.get('source_company_id')
    target_company_id = data.get('target_company_id')
    include_images = bool(data.get('include_images', True))
    overwrite_existing = bool(data.get('overwrite_existing', False))
    selected_products = data.get('products', [])  # List of {product_id, quantity}

    if not source_company_id or not target_company_id:
        return jsonify({'error': 'Source and target company IDs are required'}), 400
    
    if not selected_products:
        return jsonify({'error': 'At least one product must be selected'}), 400

    try:
        source_company_id = int(source_company_id)
        target_company_id = int(target_company_id)
    except (TypeError, ValueError):
        return jsonify({'error': 'Company IDs must be valid integers'}), 400

    if source_company_id == target_company_id:
        return jsonify({'error': 'Source and target companies must be different'}), 400

    source_company = Company.query.get(source_company_id)
    target_company = Company.query.get(target_company_id)
    if not source_company or not target_company:
        return jsonify({'error': 'Source or target company not found'}), 404

    created_count = 0
    updated_count = 0
    skipped_count = 0
    errors = []

    for item in selected_products:
        try:
            product_id = int(item.get('product_id'))
            quantity = float(item.get('quantity', 0))
        except (TypeError, ValueError):
            errors.append(f"Invalid product_id or quantity format")
            continue

        if quantity <= 0:
            errors.append(f"Quantity must be greater than 0")
            continue

        product = Product.query.filter(
            Product.id == product_id,
            Product.company_id == source_company_id
        ).first()

        if not product:
            errors.append(f"Product {product_id} not found in source company")
            continue

        current_stock = float(product.stock or 0)
        # Allow catalog/product sync transfers to proceed even when source stock is zero.
        # Ensure the UI defaults selected quantities to 1 instead of 0 when max stock is zero.
        """
        if current_stock > 0 and current_stock < quantity:
            errors.append(f"Product '{product.name}': insufficient stock (have {current_stock}, need {quantity})")
            continue
        """

        # Find or create in target company
        existing_product = Product.query.filter(
            Product.company_id == target_company_id,
            or_(Product.barcode == product.barcode, Product.name == product.name)
        ).first()

        warehouse_id = None
        if product.warehouse_id and product.warehouse:
            target_warehouse = Warehouse.query.filter(
                Warehouse.company_id == target_company_id,
                Warehouse.name == product.warehouse.name
            ).first()
            if target_warehouse:
                warehouse_id = target_warehouse.id

        supplier_id = None
        if product.supplier_id and product.supplier:
            target_supplier = Supplier.query.filter(
                Supplier.company_id == target_company_id,
                Supplier.id == product.supplier_id
            ).first()
            if not target_supplier:
                target_supplier = Supplier.query.filter(
                    Supplier.company_id == target_company_id,
                    Supplier.name == product.supplier.name
                ).first()
            if target_supplier:
                supplier_id = target_supplier.id

        if existing_product:
            if not overwrite_existing:
                skipped_count += 1
                continue

            prev_stock = float(existing_product.stock or 0)
            existing_product.stock = (float(existing_product.stock or 0) + float(quantity))
            existing_product.last_updated = datetime.utcnow()
            updated_count += 1
            # Record inventory transaction for target (transfer in)
            try:
                from app.models import InventoryTransaction
                new_stock = float(existing_product.stock or 0)
                tx_in = InventoryTransaction(
                    product_id=existing_product.id,
                    transaction_type='transfer_in',
                    quantity=float(quantity),
                    previous_stock=prev_stock,
                    new_stock=new_stock,
                    reference_id=product.id,
                    notes=f'Transferred from company {source_company_id}',
                    company_id=target_company_id
                )
                db.session.add(tx_in)
            except Exception:
                pass
        else:
            # Create new product with specified quantity
            new_product = Product(
                name=product.name,
                price=product.price,
                cost_price=product.cost_price,
                stock=quantity,
                unit_type=product.unit_type,
                category=product.category,
                low_stock_threshold=product.low_stock_threshold,
                barcode=product.barcode,
                description=product.description,
                image_path=product.image_path if include_images else None,
                warehouse_id=warehouse_id,
                supplier_id=supplier_id,
                company_id=target_company_id,
                price_per_kg=product.price_per_kg,
                product_code=product.product_code,
            )
            db.session.add(new_product)
            created_count += 1
            # Record inventory transaction for target (transfer in - new product)
            try:
                from app.models import InventoryTransaction
                tx_in = InventoryTransaction(
                    product_id=new_product.id,
                    transaction_type='transfer_in',
                    quantity=float(quantity),
                    previous_stock=0.0,
                    new_stock=float(quantity),
                    reference_id=product.id,
                    notes=f'Transferred from company {source_company_id}',
                    company_id=target_company_id
                )
                db.session.add(tx_in)
            except Exception:
                pass

        # Actual transfer: reduce source stock after the target has been updated
        if current_stock > 0:
            prev_src = float(product.stock or 0)
            product.stock = max(0.0, float(product.stock or 0) - float(quantity))
            product.last_updated = datetime.utcnow()
            # Record inventory transaction for source (transfer out)
            try:
                from app.models import InventoryTransaction
                tx_out = InventoryTransaction(
                    product_id=product.id,
                    transaction_type='transfer_out',
                    quantity=float(quantity),
                    previous_stock=prev_src,
                    new_stock=float(product.stock or 0),
                    reference_id=None,
                    notes=f'Transferred to company {target_company_id}',
                    company_id=source_company_id
                )
                db.session.add(tx_out)
            except Exception:
                pass

    db.session.commit()
    return jsonify({
        'success': True,
        'message': f'Product transfer completed: {created_count} copied, {updated_count} updated, {skipped_count} skipped.',
        'copied_count': created_count,
        'updated_count': updated_count,
        'skipped_count': skipped_count,
        'errors': errors if errors else None,
    })

@companies_bp.route('/api/companies/<int:company_id>')
@csrf.exempt
@login_required
def get_company(company_id):
    """Get single company details - SUPER ADMIN ONLY."""
    # SECURITY: Only super admin can manage companies
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can manage companies'}), 403
    
    company = Company.query.get_or_404(company_id)
    
    return jsonify({
        'id': company.id,
        'name': company.name,
        'business_name': company.business_name,
        'address': company.address,
        'phone': company.phone,
        'email': company.email,
        'tax_id': company.tax_id,
        'is_active': company.is_active,
        'default_currency': company.default_currency,
        'timezone': company.timezone
    })

@companies_bp.route('/api/companies', methods=['POST'])
@login_required
@require_super_admin
def create_company():
    """Create a new company. Super Admin only."""
    data = request.get_json()
    
    if not data or 'name' not in data:
        return jsonify({'error': 'Company name is required'}), 400
    
    # Check if company name already exists
    existing = Company.query.filter_by(name=data['name']).first()
    if existing:
        return jsonify({'error': 'Company with this name already exists'}), 400
    
    try:
        company = Company(
            name=data['name'],
            business_name=data.get('business_name'),
            address=data.get('address'),
            phone=data.get('phone'),
            email=data.get('email'),
            tax_id=data.get('tax_id'),
            default_currency=data.get('default_currency', 'LKR'),
            timezone=data.get('timezone', 'Asia/Colombo')
        )
        
        db.session.add(company)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'company_id': company.id,
            'message': 'Company created successfully'
        })
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@companies_bp.route('/api/companies/<int:company_id>', methods=['PUT'])
@login_required
@require_super_admin
def update_company(company_id):
    """Update an existing company. Super Admin only."""
    company = Company.query.get_or_404(company_id)
    data = request.get_json()
    
    try:
        if 'name' in data:
            # Check uniqueness
            existing = Company.query.filter(Company.name == data['name'], Company.id != company_id).first()
            if existing:
                return jsonify({'error': 'Company name already exists'}), 400
            company.name = data['name']
        
        company.business_name = data.get('business_name', company.business_name)
        company.address = data.get('address', company.address)
        company.phone = data.get('phone', company.phone)
        company.email = data.get('email', company.email)
        company.tax_id = data.get('tax_id', company.tax_id)
        company.default_currency = data.get('default_currency', company.default_currency)
        company.timezone = data.get('timezone', company.timezone)
        
        if 'is_active' in data:
            company.is_active = data['is_active']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Company updated successfully'
        })
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@companies_bp.route('/api/companies/<int:company_id>', methods=['DELETE'])
@csrf.exempt
@login_required
@require_super_admin
def delete_company(company_id):
    """Delete a company. Super Admin only. 
    
    Options:
    - Soft delete (default): Deactivates company, keeps all data
    - Hard delete: Permanently removes company and all related data
    
    Hard delete requires admin password verification.
    """
    company = Company.query.get_or_404(company_id)
    
    # Check if hard delete is requested
    data = request.get_json(silent=True) or {}
    hard_delete = data.get('hard_delete', False)
    password = data.get('password', '')
    
    try:
        if hard_delete:
            # Hard delete requires password verification
            if not password:
                return jsonify({
                    'error': 'Password required for hard delete',
                    'requires_verification': True
                }), 400
            
            # Verify admin password
            if not current_user.check_password(password):
                return jsonify({
                    'error': 'Invalid password',
                    'requires_verification': True
                }), 401
            
            # Hard delete - remove company and all related data
            # This is irreversible
            
            # Get company data IDs
            company_id_val = company.id
            sales_ids = [s[0] for s in db.session.query(Sale.id).filter(Sale.company_id == company_id_val).all()]
            saleitem_ids = [s[0] for s in db.session.query(SaleItem.id).filter(SaleItem.company_id == company_id_val).all()]
            
            # Delete in proper FK order (same as reset function)
            if saleitem_ids:
                db.session.query(ReturnItem).filter(
                    ReturnItem.original_sale_item_id.in_(saleitem_ids)
                ).delete(synchronize_session=False)
                db.session.flush()
            
            if sales_ids:
                db.session.query(Return).filter(
                    or_(
                        Return.original_sale_id.in_(sales_ids),
                        Return.company_id == company_id_val
                    )
                ).delete(synchronize_session=False)
                db.session.flush()
            
            if sales_ids:
                db.session.query(Exchange).filter(
                    or_(
                        Exchange.original_sale_id.in_(sales_ids),
                        Exchange.new_sale_id.in_(sales_ids),
                        Exchange.company_id == company_id_val
                    )
                ).delete(synchronize_session=False)
                db.session.flush()
            
            # Delete ALL cheques for this company
            # Cheques can be linked through:
            # 1. Direct company_id
            # 2. sale_id (sale.company_id)
            # 3. purchase_id (purchase.company_id)
            # 4. customer_id (customer.company_id)
            # 5. supplier_id (supplier.company_id)
            
            # Get IDs for all data in this company
            customer_ids = [c[0] for c in db.session.query(Customer.id).filter(Customer.company_id == company_id_val).all()]
            supplier_ids = [s[0] for s in db.session.query(Supplier.id).filter(Supplier.company_id == company_id_val).all()]
            purchase_ids = [p[0] for p in db.session.query(Purchase.id).filter(Purchase.company_id == company_id_val).all()]
            product_ids = [p[0] for p in db.session.query(Product.id).filter(Product.company_id == company_id_val).all()]
            
            # Delete cheques linked through any of these relationships
            cheques_to_delete = db.session.query(Cheque.id).filter(
                or_(
                    Cheque.company_id == company_id_val,
                    Cheque.sale_id.in_(sales_ids) if sales_ids else False,
                    Cheque.purchase_id.in_(purchase_ids) if purchase_ids else False,
                    Cheque.customer_id.in_(customer_ids) if customer_ids else False,
                    Cheque.supplier_id.in_(supplier_ids) if supplier_ids else False,
                )
            ).all()
            
            # Delete cheques one by one to avoid FK constraint issues
            for cheque_id in cheques_to_delete:
                db.session.query(Cheque).filter(Cheque.id == cheque_id[0]).delete(synchronize_session=False)
            
            if cheques_to_delete:
                db.session.flush()
            
            db.session.query(ChequeDeposit).filter(
                ChequeDeposit.company_id == company_id_val
            ).delete(synchronize_session='fetch')
            db.session.flush()
            
            if saleitem_ids:
                db.session.query(ExchangeItem).filter(
                    ExchangeItem.company_id == company_id_val
                ).delete(synchronize_session=False)
                db.session.flush()
            
            if saleitem_ids:
                db.session.query(SaleItem).filter(
                    SaleItem.company_id == company_id_val
                ).delete(synchronize_session=False)
                db.session.flush()
            
            if sales_ids:
                db.session.query(SaleRequest).filter(
                    SaleRequest.sale_id.in_(sales_ids)
                ).delete(synchronize_session=False)
                db.session.query(CustomerPayment).filter(
                    CustomerPayment.sale_id.in_(sales_ids)
                ).delete(synchronize_session=False)
                db.session.flush()
                db.session.query(Sale).filter(
                    Sale.company_id == company_id_val
                ).delete(synchronize_session=False)
                db.session.flush()
            
            # Delete other company data
            
            # Delete product dependents by product_id before the Product rows.
            if product_ids:
                for dependent_model in (StockCountItem, InventoryTransaction, ReturnItem,
                                        ExchangeItem, SerialNumber, SaleItem, PurchaseItem):
                    db.session.query(dependent_model).filter(
                        dependent_model.product_id.in_(product_ids)
                    ).delete(synchronize_session=False)
                    db.session.flush()

            tables_to_delete = [
                (PurchaseReturnItem, 'PurchaseReturnItem'),
                (PurchaseOrderItem, 'PurchaseOrderItem'),
                (PurchaseItem, 'PurchaseItem'),
                (PurchaseReturn, 'PurchaseReturn'),
                (PurchaseOrder, 'PurchaseOrder'),
                (Purchase, 'Purchase'),
                (InventoryTransaction, 'InventoryTransaction'),
                (CustomerFeedback, 'CustomerFeedback'),
                (HeldBill, 'HeldBill'),
                (Expense, 'Expense'),
                (SerialNumber, 'SerialNumber'),
                (CustomerPayment, 'CustomerPayment'),
                (CashierShift, 'CashierShift'),
                (AuditLog, 'AuditLog'),
                (Promotion, 'Promotion'),
                (Product, 'Product'),
                (Customer, 'Customer'),
                (Supplier, 'Supplier'),
                (Warehouse, 'Warehouse'),
                (Setting, 'Setting'),
            ]
            
            for model_class, table_name in tables_to_delete:
                if hasattr(model_class, 'company_id'):
                    db.session.query(model_class).filter(
                        model_class.company_id == company_id_val
                    ).delete(synchronize_session=False)
                    db.session.flush()
            
            # Finally delete the company itself
            db.session.delete(company)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': f'Company "{company.name}" has been permanently deleted with all its data'
            })
        
        else:
            # Soft delete - just deactivate
            company.is_active = False
            db.session.commit()
            
            return jsonify({
                'success': True,
                'message': f'Company "{company.name}" has been deactivated'
            })
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@companies_bp.route('/api/companies/switch', methods=['POST'])
@csrf.exempt
@login_required
def switch_company():
    """Switch to a different company."""
    data = request.get_json()
    company_id = data.get('company_id')
    
    if not company_id:
        return jsonify({'error': 'Company ID is required'}), 400
    
    # Check if user has access to this company
    user_companies = get_user_companies(current_user.id)
    company_ids = [c.id for c in user_companies]
    
    # Admin and super admin can access any company
    if not (current_user.role and current_user.role.lower() in ['admin', 'super admin']) and company_id not in company_ids:
        return jsonify({'error': 'Access denied to this company'}), 403
    
    # Set the current company in session
    set_current_company(company_id)
    
    company = Company.query.get(company_id)
    
    return jsonify({
        'success': True,
        'message': f'Switched to {company.name}',
        'company': {
            'id': company.id,
            'name': company.name,
            'business_name': company.business_name
        }
    })

@companies_bp.route('/api/companies/<int:company_id>/users')
@login_required
def get_company_users(company_id):
    """Get users associated with a company - SUPER ADMIN ONLY."""
    # SECURITY: Only super admin can manage company users
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can manage company users'}), 403
    
    try:
        company = Company.query.get_or_404(company_id)
        
        # Get users from association table
        result = []
        if company.users:
            for user in company.users:
                result.append({
                    'id': user.id,
                    'username': user.username,
                    'email': user.email,
                    'role': user.role,
                    'is_admin': True  # Users in the company are admins by association
                })
        
        return jsonify(result)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@companies_bp.route('/api/companies/<int:company_id>/users', methods=['POST'])
@login_required
def add_user_to_company(company_id):
    """Add a user to a company - SUPER ADMIN ONLY."""
    # SECURITY: Only super admin can manage company users
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can manage company users'}), 403
    
    try:
        company = Company.query.get_or_404(company_id)
        data = request.get_json()
        
        user_id = data.get('user_id')
        is_admin = data.get('is_admin', False)
        
        if not user_id:
            return jsonify({'error': 'User ID is required'}), 400
        
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # ✅ Super Admin can assign ANY user (including admins) to MULTIPLE companies
        # Users can switch between assigned companies
        if user not in company.users:
            company.users.append(user)
            db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f'User {user.username} added to {company.name}'
        })
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@companies_bp.route('/api/companies/<int:company_id>/users/<int:user_id>', methods=['DELETE'])
@login_required
def remove_user_from_company(company_id, user_id):
    """Remove a user from a company - SUPER ADMIN ONLY."""
    # SECURITY: Only super admin can manage company users
    if not (current_user.role and current_user.role.lower() == 'super admin'):
        return jsonify({'error': 'Only Super Admin can manage company users'}), 403
    
    try:
        company = Company.query.get_or_404(company_id)
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        if user in company.users:
            company.users.remove(user)
            db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f'User {user.username} removed from {company.name}'
        })
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@companies_bp.route('/api/company/current')
@login_required
def get_current_company_info():
    """Get current company info from session."""
    company = get_current_company()
    
    if not company:
        # Get first company user has access to
        user_companies = get_user_companies(current_user.id)
        if user_companies:
            company = user_companies[0]
            set_current_company(company.id)
        else:
            return jsonify({
                'company': None,
                'message': 'No company selected'
            })
    
    return jsonify({
        'company': {
            'id': company.id,
            'name': company.name,
            'business_name': company.business_name,
            'address': company.address,
            'phone': company.phone,
            'email': company.email,
            'default_currency': company.default_currency
        }
    })

