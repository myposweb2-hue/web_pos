# Multi-Company Architecture Audit

**Status:** 🔴 CRITICAL GAPS IDENTIFIED
**Date:** 2024
**Assessment:** System has database-level company isolation but lacks proper authentication & authorization middleware

---

## Executive Summary

Your system has implemented company_id filtering at the database query level across 50+ endpoints, which addresses **data leakage**. However, the architectural specification you provided for role-based access control (**Super Admin vs Company Admin**) and **single-company user assignment** is **NOT FULLY IMPLEMENTED**.

**Critical Gaps:**
1. ❌ **Super Admin vs Company Admin distinction exists in code but NOT ENFORCED**
   - Decorators defined but not used on routes
   - Role checks are inconsistent (sometimes 'admin', sometimes 'Admin')
   - Super Admin role concept not integrated into actual enforcement

2. ❌ **Users can be assigned to MULTIPLE companies**
   - No database constraint preventing this
   - No API validation rejecting multi-company assignment
   - Authentication flow allows multi-company access

3. ❌ **Function duplication & inconsistency**
   - TWO `get_company_id()` functions in different modules
   - Routes use simple version (no role checks)
   - Security module has advanced version (with role checks) but unused

4. ❌ **Before-request middleware is insufficient**
   - Validates company exists but doesn't enforce user assignment
   - Doesn't validate that selected company belongs to user
   - Silent failures (just clears session) rather than rejecting requests

5. ❌ **Decorators defined but not applied**
   - `@require_super_admin` - defined in security.py, NEVER USED
   - `@require_company_admin` - defined in security.py, NEVER USED  
   - `@require_company_context` - defined in security.py, NEVER USED

---

## Detailed Findings

### 1. Role System Issues

**Current State:**
- User.role field stores: 'Cashier', 'Manager', 'Admin' (sometimes 'admin' lowercase)
- No 'Super Admin' users exist in database (role never set to 'Super Admin')
- Role checks scattered across codebase:
  - `/settings_new.py`: 7 inconsistent role checks
  - `/sales.py`: Checks `current_user.role != 'admin'` (insecure string comparison)
  - `/companies.py`: Tries to use role but inconsistently

**Problem:**
```python
# INCONSISTENT ROLE VALUE STORAGE
user.role = 'admin'  # sometimes lowercase
user.role = 'Admin'  # sometimes titlecase
user.role = 'ADMIN'  # sometimes uppercase

# MISSING SUPER ADMIN IMPLEMENTATION
# The security.py file checks for 'super admin' role but:
# - No migration creates Super Admin users
# - No factory/fixture creates Super Admin
# - Impossible to set user to Super Admin via UI
# - Role is inconsistently capitalized everywhere
```

**Expected Architecture:**
```
Role Hierarchy:
├── Super Admin (can manage all companies & users)
├── Company Admin (manages single assigned company & its users)
└── Cashier/User (operates within assigned company only)
```

**Current Architecture:**
```
Role Enum (NOT A REAL ENUM, just strings):
├── 'Cashier' 
├── 'Manager'
└── 'Admin' (no distinction of scope)
```

---

### 2. Function Duplication Problem

**Location 1: `app/utils/company.py`**
```python
def get_company_id():
    """Get current company ID from session, returns None if not set."""
    return session.get('company_id')  # ← SIMPLE, NO ROLE CHECKS
```

**Location 2: `app/utils/security.py`**
```python
def get_company_id():
    """Get current company ID from session with validation."""
    if not current_user.is_authenticated:
        return None
    
    company_id = session.get('company_id')
    
    if company_id:
        is_super_admin = current_user.role and current_user.role.lower() == 'super admin'
        
        if is_super_admin:
            # Super Admin can access any company
            return company_id
        
        # Regular Admin/Cashier can only access their assigned companies
        user_company_ids = [c.id for c in current_user.companies if c.is_active]
        if company_id in user_company_ids:
            return company_id
        else:
            # Unauthorized company access attempt
            return None
    
    return None
```

**Problem:**
- Routes import from `company.py` (simple version) NOT `security.py` (safe version)
- 20+ route imports use: `from app.utils.company import get_company_id`
- 0 route imports use: `from app.utils.security import get_company_id`
- **Result:** Role-based access control is COMPLETELY BYPASSED

---

### 3. Multi-Company User Assignment Issue

**Current Data Model:**
```python
# user_companies ASSOCIATION TABLE
user_companies = db.Table('user_companies',
    db.Column('user_id', db.Integer, db.ForeignKey('users.id'), primary_key=True),
    db.Column('company_id', db.Integer, db.ForeignKey('companies.id'), primary_key=True),
    db.Column('is_admin', db.Boolean, default=False),
    db.Column('created_at', db.DateTime, default=datetime.utcnow)
)
```

**Problem:**
- A user CAN be assigned to multiple companies
- Example: User John can belong to Company A AND Company B
- No constraint prevents this
- Architecture requires: **User assigned to ONLY ONE company**

**Current Behavior:**
```sql
-- This is ALLOWED (violates spec):
INSERT INTO user_companies (user_id, company_id) VALUES (1, 1);
INSERT INTO user_companies (user_id, company_id) VALUES (1, 2);  -- Same user, different company!

-- This should ONLY BE ALLOWED:
INSERT INTO user_companies (user_id, company_id) VALUES (1, 1);
-- REJECT: User already assigned to company
INSERT INTO user_companies (user_id, company_id) VALUES (1, 2);  -- ERROR
```

**Exception:** Super Admin can access ALL companies (no assignment needed)

---

### 4. Before-Request Middleware Gap

**Current Implementation:**
```python
def before_request_company_check():
    """Flask before_request handler. Validates company context on every request."""
    if not current_user.is_authenticated:
        return
    
    # Validate company session if present
    company_id = session.get('company_id')
    if company_id:
        company = Company.query.get(company_id)
        
        # Company not found or inactive
        if not company or not company.is_active:
            session.pop('company_id', None)  # ← Silent cleanup
            current_app.logger.warning(f"Invalid/inactive company {company_id}...")
            # ← NO REJECTION, just clears session
```

**Missing Validations:**
1. ❌ No check that selected company belongs to user
2. ❌ No validation of company_id format/type
3. ❌ No logging of access attempts
4. ❌ No enforcement that user has ONLY ONE company
5. ❌ No enforcement that user must set a company for protected operations

**Should Be:**
```python
def before_request_company_check():
    """Validate company context on every request."""
    if not current_user.is_authenticated:
        return
    
    company_id = session.get('company_id')
    
    if company_id:
        # 1. Validate company exists and is active
        company = Company.query.get(company_id)
        if not company or not company.is_active:
            session.pop('company_id', None)
            return  # Redirect to company selector
        
        # 2. Validate user has access to this company
        is_super_admin = current_user.role.lower() == 'super admin' if current_user.role else False
        user_company_ids = [c.id for c in current_user.companies]
        
        if not is_super_admin and company_id not in user_company_ids:
            # ✅ REJECT unauthorized access
            abort(403, "Unauthorized: Company access denied")
        
        # 3. Verify user has ONLY ONE company (except super admin)
        if not is_super_admin and len(user_company_ids) > 1:
            # ✅ REJECT: User should have only one company
            abort(400, "User assigned to multiple companies: invalid state")
    else:
        # 4. Enforce company selection for protected routes
        if should_require_company(request):
            return redirect(url_for('select_company'))
```

---

### 5. Unused Security Decorators

**Defined in `app/utils/security.py` but NEVER USED:**

1. **`@require_super_admin`** - Requires Super Admin role
   - Defined at line 45
   - Referenced/imported in: 0 routes
   - Should be applied to: `/companies/*`, `/api/reset-system`, user management endpoints

2. **`@require_company_admin`** - Requires Company Admin role
   - Defined at line 64
   - Referenced/imported in: 0 routes
   - Should be applied to: Company-specific admin operations

3. **`@require_company_context`** - Ensures company selected
   - Defined at line 83
   - Referenced/imported in: 0 routes
   - Should be applied to: All data access endpoints

**Result:** Authorization checks are entirely missing from API endpoints that should have them.

---

### 6. Database-Level Enforcement Gaps

**What's IMPLEMENTED ✅:**
- 50+ query points filtered by company_id
- Products, Sales, Customers, Expenses all company-scoped

**What's MISSING ❌:**

1. **No unique constraints on user-company assignment:**
   ```sql
   -- NOT ENFORCED: Should be UNIQUE
   ALTER TABLE user_companies ADD CONSTRAINT unique_user_company 
   UNIQUE(user_id, company_id);
   -- But also should reject multi-company for non-super-admins
   ```

2. **Users table has no company_id reference:**
   ```python
   # Users are NOT directly tied to company
   class User(db.Model):
       id = db.Column(db.Integer, primary_key=True)
       # ← NO company_id field
       companies = db.relationship(...)  # ← Must go through association table
   ```
   
   **Should be:**
   ```python
   class User(db.Model):
       id = db.Column(db.Integer, primary_key=True)
       company_id = db.Column(db.Integer, db.ForeignKey('companies.id'), nullable=True)
       # Set for non-Super Admin users
   ```

3. **User.role is not an ENUM:**
   ```python
   # PROBLEM: String storage allows any value
   role = db.Column(db.String(20), default='Cashier')
   
   # Should be:
   # Create UserRole ENUM in database
   # role = db.Column(UserRole, default=UserRole.CASHIER)
   ```

---

## Recommended Fixes (Priority Order)

### PHASE 1: Consolidate Company Context (Day 1)

**Task 1.1:** Merge `get_company_id()` functions
- Delete company.py version
- Update security.py version for edge cases
- Update all 20 route imports to use security.py version

**Task 1.2:** Fix role capitalization
- Create UserRole ENUM
- Migrate existing 'admin'/'Admin' → consistent value
- Create migration for consistent storage

**Task 1.3:** Strengthen before_request
- Add per-user company verification
- Add multi-company detection
- Add proper error responses (not silent clears)

### PHASE 2: Implement Role-Based Access Control (Day 2)

**Task 2.1:** Create Super Admin role type
- Add migration to support 'SUPER_ADMIN' role
- Create factory to generate super admin user
- Document super admin creation process

**Task 2.2:** Apply decorators to routes
- Add `@require_super_admin` to `/companies/*` endpoints
- Add `@require_company_admin` to company admin operations
- Add `@require_company_context` to all data endpoints

**Task 2.3:** Fix inconsistent role checks
- Replace all `role != 'admin'` checks with decorator
- Remove scattered role validation code
- Centralize via decorators

### PHASE 3: Enforce Single-Company Assignment (Day 3)

**Task 3.1:** Add database constraint
- Create migration adding unique/check constraint
- Prevent user from being in multiple companies (except super admin)

**Task 3.2:** Add API validation
- Reject POST attempts to add user to second company
- Verify user in user_companies endpoint

**Task 3.3:** Update User model
- Add optional company_id field (direct reference)
- Add validation logic

### PHASE 4: Comprehensive Testing (Day 4)

- Test super admin access to all companies
- Test company admin limited to one company
- Test cashier access restrictions
- Test session tampering detection
- Test multi-company rejection
- Test role enforcement on all protected endpoints

---

## Security Test Checklist

After fixes, verify:
- [ ] Super Admin can access all companies
- [ ] Company Admin can only access assigned company
- [ ] Cashier can only access assigned company
- [ ] Cannot manually set session to unauthorized company
- [ ] Cannot create user in multiple companies
- [ ] All role checks use centralized permission system
- [ ] All admin endpoints use decorators
- [ ] All data endpoints verify company_id
- [ ] Session cannot be manipulated to bypass company_id
- [ ] Super Admin creation/removal is audited

---

## Files Needing Changes

**Priority 1 (Must Fix):**
- [ ] `app/utils/security.py` - Enhance before_request_company_check
- [ ] `app/utils/company.py` - Remove or deprecate get_company_id
- [ ] `app/routes/auth.py` - Fix role capitalization
- [ ] `app/routes/companies.py` - Apply decorators, fix role checks
- [ ] `app/routes/settings_new.py` - Apply decorators, centralize permission checks
- [ ] `app/models.py` - Add UserRole ENUM, update User model

**Priority 2 (Should Fix):**
- [ ] All routes using role checks - Replace with decorators
- [ ] `app/__init__.py` - Update default user creation

**Priority 3 (Nice to Have):**
- [ ] Database migration - Add company_id to users  
- [ ] Database migration - Add unique constraint on user_companies
- [ ] Test fixtures - Create super admin factory
- [ ] Documentation - Update API auth spec

---

## Current vs Target State

### Login Flow

**CURRENT:**
```
User logs in
  ↓
LoginForm validates
  ↓
Flask-Login sets current_user
  ↓
set_current_company(first_company.id) - ANY first company
  ↓
Redirect to dashboard
```

**SHOULD BE:**
```
User logs in
  ↓
LoginForm validates
  ↓
Flask-Login sets current_user
  ↓
Verify user has EXACTLY ONE company assigned (or is super admin)
  ↓
If super admin: show company selector → set_current_company(selected)
If user: verify exactly one company → set_current_company(sole_company)
  ↓
Set role in session: session['user_role'] = normalize_role(user.role)
  ↓
Redirect to dashboard
```

### API Request Flow

**CURRENT:**
```
Request arrives
  ↓
before_request_company_check():
  - Validates company exists
  - Clears if inactive
  ↓
Route handler executes
  ↓
Uses get_company_id() from company.py
  ↓
Filters query by company_id (or None for backward compat)
```

**SHOULD BE:**
```
Request arrives
  ↓
before_request_company_check():
  - Validates company exists & is active ✅
  - Validates user has access to company ❌ (MISSING)
  - Validates user has only ONE company (except super admin) ❌ (MISSING)
  - Rejects if validation fails ❌ (just clears now)
  ↓
Route handler decorated with @require_company_context
  ↓
Uses get_company_id() from security.py (with role validation)
  ↓
Filters query by company_id
  ↓
verify_resource_access() double-checks on individual resources
```

---

## Risk Assessment

**HIGH RISK - Not Fixed:**
- ❌ Super Admin role not functional
- ❌ Users can access unauthorized companies
- ❌ Before-request doesn't validate user assignment
- ❌ Multi-company users not prevented
- ❌ Decorators not applied to routes

**MEDIUM RISK - Partially Fixed:**
- ⚠️ Role checks scattered (should be centralized)
- ⚠️ Role capitalization inconsistent

**LOW RISK - Addressed:**
- ✅ Database-level company filtering (50+ points fixed)
- ✅ Invalid/deleted companies cleared from session
- ✅ Company context set on login

---

## Next Steps

1. **Review this audit** with the team
2. **Prioritize PHASE 1 & 2** (high-security items)
3. **Begin implementing fixes** in the recommended order
4. **Create test suite** for multi-company authorization
5. **Deploy to staging** for comprehensive testing

