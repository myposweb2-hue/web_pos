# Quick Reference: Multi-Company Architecture Changes

## What Changed

### 1. UserRole Enum Added
```python
from app.models import UserRole

# Available roles:
UserRole.SUPER_ADMIN   # Can manage all companies
UserRole.ADMIN         # Can manage one company
UserRole.MANAGER       # Manager role
UserRole.CASHIER       # Regular user role
```

### 2. User Model Enhanced
```python
user = User.query.get(1)

# New methods:
user.is_super_admin()      # Returns True/False
user.is_admin()            # Returns True/False (includes super admin)
user.get_role_enum()       # Returns UserRole enum
```

### 3. Company Access Validation
```python
# Old: just returns session value
get_company_id()  # ← Simple, no validation

# New: validates user has access
from app.utils.security import get_company_id
get_company_id()  # ← Checks user can access this company
```

### 4. Security Middleware Enhanced
```python
# Before-request now validates:
✓ Company exists and is active
✓ User has access to company
✓ Detects multi-company assignments
✓ Auto-selects if user has one company
✓ Logs all security events
```

### 5. Decorators Ready to Use
```python
from app.utils.security import require_super_admin, require_company_admin, require_company_context

@require_super_admin         # Only Super Admin
@require_company_admin       # Admin or Super Admin
@require_company_context     # Must have company selected
```

---

## How to Use

### Check User's Role
```python
# OLD (unreliable)
if current_user.role == 'admin':
    # ← Doesn't handle capitalization, no enum checking
    pass

# NEW (reliable)
if current_user.is_super_admin():
    # ← Proper role checking
    pass

# Or with enum
if current_user.get_role_enum() == UserRole.SUPER_ADMIN:
    pass
```

### Protect Routes
```python
# OLD (scattered checks)
@app.route('/admin')
def admin_panel():
    if current_user.role.lower() != 'admin':
        abort(403)
    # ← Manual check, easy to bypass

# NEW (decorator)
@app.route('/admin')
@require_super_admin        # ← Automatic enforcement
def admin_panel():
    # ← Super Admin already validated by decorator
    pass
```

### Create Super Admin User
```bash
python -c "
from app import create_app
from app.models import db, User, UserRole

app = create_app()
with app.app_context():
    admin = User(
        username='superadmin',
        email='superadmin@example.com',
        role=str(UserRole.SUPER_ADMIN)
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
    print('Super Admin created successfully')
"
```

---

## What's Backward Compatible

✓ Database schema - No changes
✓ Role values - Still stored as strings
✓ Authentication - Still works same way
✓ Session management - Still works same way
✓ Company filtering - Still works same way
✓ Permission fields - Still works same way
✓ Existing routes - All still functional

---

## What Needs Work (PHASE 2)

❌ Decorators not yet applied to routes (40+)
❌ Single-company enforcement not yet enabled
❌ Super Admin role not yet integrated into UI
❌ Database constraints not yet added

See [ARCHITECTURE_IMPLEMENTATION_GUIDE.md](ARCHITECTURE_IMPLEMENTATION_GUIDE.md) for next steps.

---

## Testing

### Quick Test
```python
from app import create_app
from app.models import UserRole, User

app = create_app()
with app.app_context():
    # Check enum exists
    print([r.value for r in UserRole])
    
    # Check User methods work
    user = User(role=str(UserRole.SUPER_ADMIN))
    print(f"is_super_admin: {user.is_super_admin()}")
    print(f"is_admin: {user.is_admin()}")
```

---

## Key Files Updated

| File | Changes |
|------|---------|
| app/models.py | Added UserRole enum, User methods |
| app/utils/security.py | Enhanced before_request |
| app/utils/company.py | Consolidated get_company_id |
| app/__init__.py | Already registers middleware |

---

## Contact Points for Questions

### Architecture Overview
→ See [MULTI_COMPANY_ARCHITECTURE_AUDIT.md](MULTI_COMPANY_ARCHITECTURE_AUDIT.md)

### Implementation Steps
→ See [ARCHITECTURE_IMPLEMENTATION_GUIDE.md](ARCHITECTURE_IMPLEMENTATION_GUIDE.md)

### Summary Assessment
→ See [MULTI_COMPANY_ARCHITECTURE_ASSESSMENT_SUMMARY.md](MULTI_COMPANY_ARCHITECTURE_ASSESSMENT_SUMMARY.md)

