"""
Invoice and Receipt Routes
Provides endpoints for generating and viewing professional invoices
"""

from flask import Blueprint, render_template, jsonify, request, send_file
from datetime import datetime, timedelta
from io import BytesIO
import json

# Create blueprint
invoices_bp = Blueprint('invoices', __name__, url_prefix='/invoices', template_folder='templates')


@invoices_bp.route('/preview/a4', methods=['GET'])
def preview_a4_invoice():
    """Preview A4 invoice template with sample data"""
    sample_data = {
        'invoice_number': 'INV-2026-001234',
        'invoice_date': datetime.now().strftime('%m/%d/%Y'),
        'due_date': (datetime.now() + timedelta(days=30)).strftime('%m/%d/%Y'),
        'company': {
            'logo': 'LOGO',
            'name': 'Your Company Name',
            'address': '123 Business Street, Suite 100',
            'city': 'New York, NY 10001',
            'phone': '+1 (555) 123-4567',
            'email': 'billing@company.com',
            'website': 'www.company.com',
            'tax_id': '12-3456789'
        },
        'customer': {
            'name': 'John Anderson',
            'company': 'Anderson Industries Corp',
            'address': '456 Commerce Avenue',
            'city': 'New York, NY 10002',
            'phone': '+1 (555) 987-6543',
            'email': 'john@anderson.com'
        },
        'items': [
            {
                'code': 'SKU-001',
                'description': 'Professional Business Services - Annual Package',
                'qty': 1,
                'unit_price': '$2,500.00',
                'discount': '$0.00',
                'tax': '$200.00',
                'total': '$2,700.00'
            },
            {
                'code': 'SKU-002',
                'description': 'Premium Software License - 12 Months',
                'qty': 3,
                'unit_price': '$450.00',
                'discount': '-$135.00',
                'tax': '$94.50',
                'total': '$1,409.50'
            }
        ],
        'subtotal': '$5,150.00',
        'discount': '-$315.00',
        'tax': '$386.80',
        'total': '$5,221.80',
        'paid_amount': '$0.00',
        'balance_due': '$5,221.80'
    }
    
    return render_template('invoices/invoice_a4.html', **sample_data)


@invoices_bp.route('/preview/a5', methods=['GET'])
def preview_a5_invoice():
    """Preview A5 invoice template with sample data"""
    sample_data = {
        'invoice_number': 'INV-26-1234',
        'invoice_date': datetime.now().strftime('%m/%d/%y'),
        'due_date': (datetime.now() + timedelta(days=30)).strftime('%m/%d/%y'),
        'company': {
            'logo': 'LOGO',
            'name': 'Your Company',
            'address': '123 Business St, Suite 100',
            'city': 'New York, NY 10001',
            'phone': '+1 (555) 123-4567',
            'tax_id': '12-3456789'
        },
        'customer': {
            'name': 'John Anderson',
            'company': 'Anderson Industries',
            'address': '456 Commerce Ave',
            'city': 'New York, NY 10002'
        },
        'items': [
            {
                'code': 'SKU-001',
                'description': 'Professional Business Services',
                'qty': 1,
                'amount': '$2,500.00',
                'total': '$2,700.00'
            },
            {
                'code': 'SKU-002',
                'description': 'Software License - 12 Months',
                'qty': 3,
                'amount': '$450.00',
                'total': '$1,409.50'
            }
        ],
        'subtotal': '$5,150.00',
        'discount': '-$315.00',
        'tax': '$386.80',
        'total_due': '$5,221.80',
        'balance_due': '$5,221.80'
    }
    
    return render_template('invoices/invoice_a5.html', **sample_data)


@invoices_bp.route('/preview/receipt', methods=['GET'])
def preview_thermal_receipt():
    """Preview 80mm thermal receipt template with sample data"""
    sample_data = {
        'receipt_number': '0001234',
        'receipt_date': datetime.now().strftime('%m/%d/%Y'),
        'receipt_time': datetime.now().strftime('%H:%M:%S'),
        'cashier': 'John Smith',
        'company_name': 'YOUR STORE',
        'company_subline': 'Professional POS System',
        'company_address': '123 Main Street | Suite 100',
        'company_city': 'New York, NY 10001',
        'company_phone': 'Tel: (555) 123-4567',
        'customer_name': 'Walk-In Customer',
        'invoice_number': 'INV-2026-4567',
        'items': [
            {
                'qty': '2',
                'description': 'Premium Item #1',
                'code': 'SKU-001',
                'price': '$25.00',
                'total': '$50.00'
            },
            {
                'qty': '1',
                'description': 'Service Package',
                'code': 'SVC-002',
                'price': '$75.00',
                'total': '$75.00'
            },
            {
                'qty': '3',
                'description': 'Retail Product',
                'code': 'SKU-003',
                'price': '$10.50',
                'total': '$31.50'
            },
            {
                'qty': '1',
                'description': 'Professional Service',
                'code': 'SVC-004',
                'price': '$45.00',
                'total': '$45.00'
            }
        ],
        'subtotal': '$201.50',
        'discount': '-$10.08',
        'tax': '$15.31',
        'delivery_fee': '$5.00',
        'total': '$211.73',
        'paid': '$211.73',
        'change': '$0.00',
        'payment_method': 'CARD',
        'reference': '123456789012',
        'authorization': 'APPROVED',
        'thank_you': 'THANK YOU!',
        'thank_you_msg': 'For your patronage and support'
    }
    
    return render_template('invoices/thermal_receipt_80mm.html', **sample_data)


@invoices_bp.route('/template/a4', methods=['GET'])
def get_a4_template():
    """Get A4 invoice HTML template"""
    with open('app/templates/invoices/invoice_a4.html', 'r') as f:
        return f.read()


@invoices_bp.route('/template/a5', methods=['GET'])
def get_a5_template():
    """Get A5 invoice HTML template"""
    with open('app/templates/invoices/invoice_a5.html', 'r') as f:
        return f.read()


@invoices_bp.route('/template/receipt', methods=['GET'])
def get_receipt_template():
    """Get 80mm thermal receipt HTML template"""
    with open('app/templates/invoices/thermal_receipt_80mm.html', 'r') as f:
        return f.read()


@invoices_bp.route('/template/styles', methods=['GET'])
def get_print_styles():
    """Get print optimization CSS"""
    with open('app/templates/invoices/print_styles.css', 'r') as f:
        return f.read(), 200, {'Content-Type': 'text/css'}


@invoices_bp.route('/api/generate', methods=['POST'])
def generate_invoice_api():
    """
    API endpoint to generate invoice HTML
    
    Request body:
    {
        "format": "a4" | "a5" | "thermal",
        "invoice_data": { invoice object }
    }
    """
    try:
        data = request.get_json()
        format_type = data.get('format', 'a4').lower()
        invoice_data = data.get('invoice_data', {})
        
        if format_type == 'a4':
            html = render_template('invoices/invoice_a4.html', **invoice_data)
        elif format_type == 'a5':
            html = render_template('invoices/invoice_a5.html', **invoice_data)
        elif format_type == 'thermal':
            html = render_template('invoices/thermal_receipt_80mm.html', **invoice_data)
        else:
            return jsonify({'error': 'Invalid format. Use: a4, a5, or thermal'}), 400
        
        return jsonify({
            'success': True,
            'format': format_type,
            'html': html
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@invoices_bp.route('/api/sample/<format_type>', methods=['GET'])
def get_sample_data(format_type):
    """Get sample data for a given format"""
    
    samples = {
        'a4': {
            'invoice_number': 'INV-2026-001234',
            'invoice_date': datetime.now().strftime('%m/%d/%Y'),
            'due_date': (datetime.now() + timedelta(days=30)).strftime('%m/%d/%Y'),
            'company': {
                'name': 'Your Company Name',
                'address': '123 Business Street, Suite 100',
                'city': 'New York, NY 10001',
                'phone': '+1 (555) 123-4567',
                'email': 'billing@company.com',
                'tax_id': '12-3456789'
            },
            'customer': {
                'name': 'Customer Name',
                'company': 'Customer Company',
                'address': '456 Commerce Avenue',
                'city': 'New York, NY 10002'
            },
            'items': [
                {
                    'code': 'SKU-001',
                    'description': 'Product Description',
                    'qty': 1,
                    'unit_price': '$100.00',
                    'discount': '$0.00',
                    'tax': '$8.00',
                    'total': '$108.00'
                }
            ]
        },
        'a5': {
            'invoice_number': 'INV-26-1234',
            'invoice_date': datetime.now().strftime('%m/%d/%y'),
            'due_date': (datetime.now() + timedelta(days=30)).strftime('%m/%d/%y'),
            'company': {'name': 'Your Company'},
            'customer': {'name': 'Customer Name'},
            'items': [
                {
                    'code': 'SKU-001',
                    'description': 'Product',
                    'qty': 1,
                    'amount': '$100.00',
                    'total': '$108.00'
                }
            ]
        },
        'thermal': {
            'receipt_number': '0001234',
            'receipt_date': datetime.now().strftime('%m/%d/%Y'),
            'receipt_time': datetime.now().strftime('%H:%M:%S'),
            'company_name': 'YOUR STORE',
            'customer_name': 'Walk-In Customer',
            'items': [
                {
                    'code': 'SKU-001',
                    'description': 'Item',
                    'qty': 1,
                    'price': '$25.00',
                    'total': '$25.00'
                }
            ],
            'total': '$25.00'
        }
    }
    
    if format_type.lower() in samples:
        return jsonify(samples[format_type.lower()])
    else:
        return jsonify({'error': 'Invalid format'}), 404


@invoices_bp.route('/docs', methods=['GET'])
def documentation():
    """Display invoice template documentation"""
    with open('app/templates/invoices/README.md', 'r') as f:
        readme_content = f.read()
    
    return f"""
    <html>
        <head>
            <title>Invoice Templates Documentation</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }}
                h1, h2, h3 {{ color: #0051ba; }}
                code {{ background: #f5f5f5; padding: 2px 6px; border-radius: 3px; }}
                pre {{ background: #f5f5f5; padding: 10px; border-radius: 5px; overflow-x: auto; }}
                table {{ border-collapse: collapse; width: 100%; margin: 10px 0; }}
                td, th {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
                th {{ background-color: #f0f0f0; }}
            </style>
        </head>
        <body>
            {readme_content}
        </body>
    </html>
    """


# Error handlers

@invoices_bp.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({'error': 'Endpoint not found'}), 404


@invoices_bp.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    return jsonify({'error': 'Internal server error'}), 500


# Helper functions for integration with existing routes

def register_invoice_routes(app):
    """Register invoice blueprint with Flask app"""
    app.register_blueprint(invoices_bp)


# Export routes
__all__ = ['invoices_bp', 'register_invoice_routes']
