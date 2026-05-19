# Receipt Settings Integration - Fix Documentation

## Problem
Receipt settings saved in the Settings page were not appearing in printed receipts/invoices. The infrastructure was in place, but settings weren't displaying dynamically in the output.

## Root Causes Identified & Fixed

### 1. **Template Hardcoding Issue**
- **Problem**: All three invoice/receipt templates (thermal_receipt_80mm.html, invoice_a4.html, invoice_a5.html) had hardcoded sample data instead of Jinja2 variables
- **Impact**: Settings from database were never displayed, templates always showed "YOUR STORE", "123 Main Street", etc.
- **Solution**: Replaced all hardcoded values with Jinja2 `{{ variable }}` placeholders

### 2. **Database Settings Retrieval Issue**
- **Problem**: Settings in database use key `business_name`, but code was looking for `company_name`
- **Problem**: Function didn't properly merge global settings (company_id=None) with company-specific settings
- **Impact**: Even if settings were passed to template, they had wrong keys or were empty
- **Solution**: 
  - Added mapping from `business_name` → `company_name` in `get_receipt_settings()`
  - Implemented proper layered retrieval: global settings first, then overlay with company-specific values

### 3. **Settings Form-Database Key Mismatch**
- **Problem**: Form sends data with keys like `company_name`, but database stores them as `business_name`
- **Solution**: Added key mapping in `save_settings_api()` to convert form keys to database keys

## Implementation Details

### A. Updated `get_receipt_settings()` Function
**Location**: `/app/routes/invoices.py` (lines 17-75)

**Key Changes**:
1. First retrieves all global settings (company_id = NULL)
2. Then overlays company-specific settings if available
3. Maps `business_name` from database to `company_name` for templates
4. Includes enhanced logging for debugging

**Flow**:
```python
# Start with global settings
settings_query = Setting.query.filter_by(
    setting_category='receipt',
    company_id=None
).all()

# Overlay company-specific values
if company_id:
    company_query = Setting.query.filter_by(
        setting_category='receipt',
        company_id=company_id
    ).all()
```

### B. Updated `save_settings_api()` Function
**Location**: `/app/routes/invoices.py` (lines 313-387)

**Key Changes**:
1. Maps form keys to database keys:
   - `company_name` → `business_name` (for DB storage)
   - All other keys remain the same

2. Saves both to existing company_id and creates company-specific overrides

**Form Key to Database Key Mapping**:
```python
key_mapping = {
    'company_name': 'business_name',
    'business_address': 'business_address',
    'business_phone': 'business_phone',
    'business_email': 'business_email',
    'business_gst': 'business_gst',
    'thank_you_message': 'thank_you_message',
    'warranty_info': 'warranty_info',
    'footer_text': 'footer_text',
    # ... etc
}
```

### C. Updated Receipt Templates

#### Thermal Receipt (80mm)
**File**: `/app/templates/invoices/thermal_receipt_80mm.html`

**Changes**:
- `{{ company_name }}` - Business name from settings
- `{{ company_address }}` - Business address from settings
- `{{ company_phone }}` - Business phone from settings
- `{{ thank_you_message }}` - Custom thank you message
- `{{ warranty_info }}` - Warranty information
- `{{ footer_text }}` - Custom footer text

**Removed Hardcoding**:
- ❌ "YOUR STORE" → ✅ `{{ company_name }}`
- ❌ "Professional POS System" → ✅ `{{ company_name }}`
- ❌ "123 Main Street, Suite 100" → ✅ `{{ company_address }}`
- ❌ Hardcoded phone → ✅ `{{ company_phone }}`

#### A4 Invoice
**File**: `/app/templates/invoices/invoice_a4.html`

**Changes**:
- `{{ company.name }}` - Company name
- `{{ company.address }}` - Company address
- `{{ company.city }}` - Company city
- `{{ company.phone }}` - Company phone
- `{{ company.email }}` - Company email
- `{{ company.tax_id }}` - Tax ID/GST
- `{{ invoice_number }}`, `{{ invoice_date }}`, `{{ due_date }}`, `{{ status }}` - Invoice details

#### A5 Invoice
**File**: `/app/templates/invoices/invoice_a5.html`

Similar to A4, using same variable structure

### D. Updated Preview Routes

**A4 Preview** - Added `status` field:
```python
'status': 'UNPAID'
```

All preview routes now call `get_receipt_settings()` to populate dynamic values.

## Data Flow Verification

### Settings Save Flow
1. User updates form in Settings → Receipt Settings tab
2. JavaScript sends POST to `/invoices/api/settings`
3. `save_settings_api()`:
   - Maps form keys to database keys
   - Gets current company_id
   - Creates/updates Setting records in database
   - Commits transaction
4. Returns success with updated settings

### Settings Display Flow
1. User navigates to invoice preview (e.g., `/invoices/preview/receipt`)
2. `preview_thermal_receipt()` route executes:
   - Calls `get_receipt_settings()` to retrieve from database
   - Merges with defaults
   - Passes to template via render_template context
3. Jinja2 template renders with `{{ variable }}` replacements
4. HTML displays actual company data from database

## Testing the Integration

### Test 1: Verify Settings Retrieval
```bash
python -c "
from app import create_app
from app.routes.invoices import get_receipt_settings

app = create_app()
with app.app_context():
    settings = get_receipt_settings()
    print(f'Company Name: {settings[\"company_name\"]}')
    print(f'Address: {settings[\"business_address\"]}')
    print(f'Phone: {settings[\"business_phone\"]}')
"
```

### Test 2: Verify Database Content
```bash
sql
SELECT setting_key, setting_value, company_id 
FROM setting 
WHERE setting_category='receipt' 
ORDER BY company_id, setting_key;
```

### Test 3: Manual Label Testing
1. Go to Settings → Receipt Settings
2. Change Business Name to "Test Company"
3. Change Thank You Message to "Thanks for your business!"
4. Click Save Receipt Settings
5. View `/invoices/preview/receipt` in browser
6. Check that "Test Company" and "Thanks for your business!" appear

## Configuration Summary

**Setting Keys in Database**:
- `business_name` (rendered as company_name)
- `business_address` (rendered as company_address)
- `business_city` (rendered as company_city)
- `business_phone` (rendered as company_phone)
- `business_email` (rendered as company_email)
- `business_gst` (rendered as tax_id)
- `thank_you_message`
- `warranty_info`
- `footer_text`
- `receipt_logo`
- `default_receipt_format`
- `show_qr_code`
- `receipt_type`

**All stored with**:
- `setting_category='receipt'`
- `company_id=NULL` for global defaults OR
- `company_id=<company_id>` for company-specific overrides

## Files Modified
1. ✅ `/app/routes/invoices.py` - Fixed get_receipt_settings() and save_settings_api()
2. ✅ `/app/templates/invoices/thermal_receipt_80mm.html` - Added Jinja2 variables
3. ✅ `/app/templates/invoices/invoice_a4.html` - Added Jinja2 variables
4. ✅ `/app/templates/invoices/invoice_a5.html` - Added Jinja2 variables

## Result
✅ Settings saved in database now display in receipt previews
✅ Changes to Receipt Settings form appear immediately in previews
✅ Multi-company support works (global + company-specific overrides)
✅ Proper fallbacks to defaults when settings missing
✅ Full logging for debugging

