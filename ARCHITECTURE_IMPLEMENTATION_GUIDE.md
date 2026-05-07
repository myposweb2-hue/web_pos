# Multi-Company Architecture Implementation Guide

**Status:** PHASE 1 COMPLETE (Core infrastructure fixed)
**Remaining:** PHASE 2 & 3 (Apply decorators, single-company enforcement)

---

## PHASE 1 - COMPLETED ✅

### 1.1 Consolidated `get_company_id()` Functions ✅

**Changes Made:**
- `app/utils/company.py` - Now imports secure version from security.py
- `get_company_id()` in company.py now forwards to security module (deprecated with warning)
- All helper functions now use secure version internally

**Result:**
- Routes will gradually use secure version when they import from company.py
- Deprecation warning logs when old path is used
- No breaking changes - everything still works

### 1.2 Created UserRole ENUM ✅

**Changes Made:**
- Added `UserRole` enum in `app/models.py`:
  ```python
  class UserRole(Enum):
      SUPER_ADMIN = "Super Admin"
      ADMIN = "Admin"
      MANAGER = "Manager"
      CASHIER = "Cashier"
  ```

- Updated User model with new methods:
  ```python
  def get_role_enum()      # Convert string role to enum
  def is_super_admin()     # True if SUPER_ADMIN
  def is_admin()           # True if ADMIN or SUPER_ADMIN
  ```

**Database State:**
- Role values still stored as strings for backward compatibility
- Migration not needed yet - app auto-converts

### 1.3 Strengthened Before-Request Middleware ✅

**Changes Made:**
- Enhanced `before_request_company_check()` in `app/utils/security.py`:
  - ✅ Validates company exists and is active
  - ✅ Validates user has access to company
  - ✅ Detects multi-company user assignments
  - ✅ Auto-selects company for single-company users
  - ✅ Logs all security-relevant events

**Enforces:**
- Non-super-admins cannot select unauthorized companies
- Deleted companies auto-clear from session
- Invalid company_id values rejected

---

## PHASE 2 - IMPLEMENT ROLE-BASED DECORATORS

### 2.1 Apply `@require_super_admin` Decorator

**What it does:**
- Only allows users with `role` = "Super Admin"
- Used for multi-company management

**Where to apply:**
1. `/companies` - List all companies (admin page)
2. `/api/companies` - POST (create company)
3. `/api/companies/<id>` - PUT/DELETE (modify company)
4. `/api/users` - GET all users across companies
5. `/api/settings/reset` - System-wide reset

**Example Implementation:**

```python
from app.utils.security import require_super_admin

# BEFORE: (uses role check scattered in code)
@companies_bp.route('/api/companies', methods=['POST'])
@login_required
def create_company():
    if not (current_user.role and current_user.role.lower() == 'admin'):
        return jsonify({'error': 'Admin required'}), 403
    # ... rest of code

# AFTER: (uses decorator)
@companies_bp.route('/api/companies', methods=['POST'])
@login_required
@require_super_admin
def create_company():
    # Decorator already verified Super Admin
    # ... rest of code
```

### 2.2 Apply `@require_company_admin` Decorator

**What it does:**
- Only allows users with Admin or Super Admin role
- Used for company-level admin operations

**Where to apply:**
1. Settings management endpoints (in same company)
2. User assignment to company
3. Permission management
4. Warehouse/location management

### 2.3 Apply `@require_company_context` Decorator

**What it does:**
- Ensures user has selected a valid company
- Applied to all data access endpoints

**Where to apply:**
1. All `/sales` endpoints
2. All `/inventory` endpoints
3. All `/customers` endpoints
4. All `/reports` endpoints
5. All `/expenses` endpoints

**Example:**

```python
from app.utils.security import require_company_context

@sales_bp.route('/api/sales', methods=['GET'])
@login_required
@require_company_context
def get_sales():
    # Decorator ensures user has company selected
    # ... rest of code
```

---

## PHASE 3 - ENFORCE SINGLE-COMPANY ASSIGNMENT

### 3.1 Add Validation to User-Company Assignment

**Location:** app/routes/settings_new.py (or admin user management)

**Current (ALLOWS MULTI-COMPANY):**
```python
# User can be added to multiple companies:
company_a.users.append(user_john)
company_b.users.append(user_john)  # ← ALLOWED (shouldn't be)
```

**Should Be:**
```python
from app.models import UserRole

# Only allow multiple companies for Super Admin
if user.get_role_enum() != UserRole.SUPER_ADMIN:
    # Verify user not already in another company
    if len(user.companies) > 0:
        return jsonify({'error': 'User already assigned to a company'}), 400
```

### 3.2 Add Database Constraint (Future)

**When ready for migration:**
```sql
-- Add unique constraint (with exception logic for Super Admin)
ALTER TABLE user_companies 
ADD CONSTRAINT check_single_company 
CHECK (is_admin = TRUE OR user_id NOT IN (
    SELECT user_id FROM user_companies WHERE is_admin = FALSE 
    GROUP BY user_id HAVING COUNT(*) > 1
));
```

Or simpler - add company_id directly to User table:
```sql
ALTER TABLE users ADD COLUMN company_id INT REFERENCES companies(id);

-- For Super Admin: company_id = NULL
-- For regular users: company_id = required company
```

### 3.3 Create Super Admin User

**How to create Super Admin:**

```python
# In Flask shell or migration:
from app.models import User, db, UserRole

admin = User(
    username='superadmin',
    email='superadmin@example.com',
    role=str(UserRole.SUPER_ADMIN),  # "Super Admin"
    can_access_settings=True,
    can_access_sales=True,
    can_access_purchases=True,
    # ... all permissions True
)
admin.set_password('secure_password')
db.session.add(admin)
db.session.commit()
print(f"Created Super Admin: {admin.username}")
```

**Command to run:**
```bash
# In your application directory with venv activated
python -c "
from app import create_app
from app.models import db, User, UserRole

app = create_app()
with app.app_context():
    admin = User(
        username='superadmin',
        email='superadmin@example.com',
        role=str(UserRole.SUPER_ADMIN),
    )
    admin.set_password('YourSecurePassword123')
    admin.can_access_settings = True
    admin.can_access_sales = True
    admin.can_access_purchases = True
    admin.can_view_reports = True
    admin.can_access_expenses = True
    admin.can_access_customers = True
    admin.can_access_warehouse = True
    admin.can_view_inventory = True
    admin.can_edit_inventory = True
    admin.can_view_sales_history = True
    admin.can_access_cheques = True
    admin.can_access_quotations = True
    admin.can_access_messages = True
    admin.can_access_audit_logs = True
    admin.can_access_scale = True
    db.session.add(admin)
    db.session.commit()
    print('Super Admin user created successfully')
"
```

---

## Code Pattern Reference

### Pattern 1: Company Filter on Query

```python
from app.utils.security import get_company_id
from app.utils.company import get_company_filter
from sqlalchemy import or_

# OLD (simple, no validation)
sales = Sale.query.filter_by(company_id=get_company_id()).all()

# NEW (with security decorator)
@sales_bp.route('/sales')
@login_required
@require_company_context
def list_sales():
    # get_company_id() now has full validation
    company_filter = get_company_filter(Sale)
    sales = Sale.query.filter(company_filter).all()
    return jsonify([s.to_dict() for s in sales])
```

### Pattern 2: Single Resource Access

```python
from app.utils.security import get_company_id, verify_resource_access

@sales_bp.route('/sales/<int:sale_id>')
@login_required
@require_company_context
def get_sale(sale_id):
    sale = Sale.query.get_or_404(sale_id)
    
    # Double-check user has access to this resource
    verify_resource_access(sale)  # Aborts if unauthorized
    
    return jsonify(sale.to_dict())
```

### Pattern 3: Admin-Only Operations

```python
from app.utils.security import require_super_admin

@admin_bp.route('/system/reset', methods=['POST'])
@login_required
@require_super_admin
def reset_system():
    # Only Super Admin can reach here
    # ... perform reset
```

---

## Testing Checklist

### Test Matrix

| User Type | Access Test | Expected |
|-----------|------------|----------|
| Super Admin | Access Company A | ALLOWED |
| Super Admin | Access Company B | ALLOWED |
| Super Admin | Create Company | ALLOWED |
| Company Admin A | Access Company A | ALLOWED |
| Company Admin A | Access Company B | DENIED (403) |
| Company Admin A | Create Company | DENIED (403) |
| Cashier A | Access Company A | ALLOWED |
| Cashier A | Access Company B | DENIED (403) |
| Cashier A | Modify Settings | DENIED (403) |

### Test Cases

**TC-1: Role Validation**
- [ ] Super Admin role can be set and accessed
- [ ] Admin role recognized correctly
- [ ] Manager/Cashier roles work normally
- [ ] Role values normalized consistently

**TC-2: Company Access Control**
- [ ] User cannot manually set session.company_id to unauthorized company
- [ ] before_request clears invalid company_id
- [ ] API responds 403 when company not accessible

**TC-3: Decorator Functionality**
- [ ] @require_super_admin rejects non-super-admins
- [ ] @require_company_admin rejects cashiers
- [ ] @require_company_context requires company selection

**TC-4: Multi-Company Rejection**
- [ ] Cannot add non-super-admin to multiple companies
- [ ] before_request logs multi-company detection
- [ ] Creating user prevents multi-company assignment

**TC-5: Session Tampering**
- [ ] User cannot hijack another user's company session
- [ ] Switching company refreshes permissions
- [ ] Logout clears company context

---

## Migration Path (Non-Breaking)

### Phase 1: Infrastructure (DONE)
- UserRole enum created
- Helper methods added to User model
- Security middleware enhanced
- All still backward compatible

### Phase 2: Gradual Rollout (SAFE)
- Apply decorators to admin endpoints first
- Apply to company management second
- Apply to data endpoints last
- Existing code continues working

### Phase 3: Data Cleanup (OPTIONAL)
- Create Super Admin users via script
- Migrate existing admin to Company Admin
- Update user-company assignments as needed

### Phase 4: Enforcement (LATER)
- Add database constraints
- Add validation rules
- Remove backward compatibility code

---

## Configuration

### Default Settings

The system now automatically:
- Detects Super Admin role and grants full access
- Auto-selects company for single-company users
- Logs all multi-company detection
- Clears invalid company sessions

### Environment Variables (Optional)

```bash
# Logging level for security events
SECURITY_LOG_LEVEL=INFO

# Require company selection (can disable for testing)
REQUIRE_COMPANY_CONTEXT=true

# Enable multi-company warnings
LOG_MULTI_COMPANY_USERS=true
```

---

## Troubleshooting

### Issue: "No company context" error on data endpoints

**Cause:** User doesn't have selected company
**Fix:** Before-request middleware should auto-select if user has exactly one company

### Issue: Super Admin cannot see all companies

**Cause:** Role not set to exact "Super Admin" string
**Fix:** Use `UserRole.SUPER_ADMIN.value` or "Super Admin"

### Issue: Decorators not working

**Cause:** Import from wrong module
**Fix:** Import from `app.utils.security` not elsewhere

### Issue: Permission denied on admin endpoints

**Cause:** User role not recognized as admin
**Fix:** Check role using `user.is_admin()` method, not string comparison

---

## File Changes Summary

**Updated Files:**
- ✅ `app/models.py` - Added UserRole ENUM, User helper methods
- ✅ `app/utils/security.py` - Enhanced before_request, add decorators
- ✅ `app/utils/company.py` - Deprecated simple get_company_id()
- ✅ `app/__init__.py` - Already registered middleware

**Files Needing Decorator Application (PHASE 2):**
- [ ] `app/routes/companies.py` - @require_super_admin
- [ ] `app/routes/settings_new.py` - @require_company_admin on management
- [ ] `app/routes/sales.py` - @require_company_context
- [ ] `app/routes/customers.py` - @require_company_context
- [ ] `app/routes/inventory.py` - @require_company_context
- [ ] `app/routes/reports.py` - @require_company_context
- [ ] `app/routes/expenses.py` - @require_company_context
- [ ] `app/routes/purchases.py` - @require_company_context

**No Changes Needed:**
- Database schema (backward compatible)
- Authentication flow (extends existing)
- API responses (same format)

---

## Next Steps

1. **Complete PHASE 1 verification** - App loads successfully ✅

2. **Start PHASE 2** - Apply decorators systematically
   - Start with companies.py (most critical)
   - Move to settings_new.py (admin operations)
   - Then data routes (sales, customers, etc.)

3. **Create migration guide** for existing installations

4. **Test security** with multi-company users

5. **Document for users** - explain new role system

