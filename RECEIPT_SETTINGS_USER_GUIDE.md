# Receipt Settings User Guide

## Overview
The Receipt Settings feature allows you to customize how receipts and invoices are printed by your POS system. Any changes you make will appear on all future receipts.

## Accessing Receipt Settings

1. Go to **Settings** (gear icon in sidebar)
2. Scroll down to **Receipt Settings** tab (in the "Receipt Terminal Configuration" section)
3. You'll see a form with various receipt customization options

## Settings Fields

### Business Information
These details will appear at the top of every receipt:

- **Business Name** - Your company/store name (e.g., "Codilight")
- **Business Address** - Street address (e.g., "Anderson road, dehiwala")
- **Business Phone** - Contact phone number (e.g., "77 411 6702")
- **Email** - Business email address
- **GST/Tax Number** - Your tax ID (appears on professional invoices)

### Receipt Messages

- **Thank You Message** - Appears at the bottom of receipts (e.g., " Thank You" - avoid adding ! as it's auto-added)
- **Warranty Information** - Warranty terms to display (e.g., "API Test Warranty")
- **Footer Text** - Additional text at bottom of receipt (e.g., "API Test Footer")

### Receipt Format Options

- **Default Receipt Format** - Choose between:
  - Thermal (80mm POS Receipt) - for thermal printers (default)
  - A4 (Professional Invoice) - full-size invoices
  - A5 (Compact Invoice) - half-size invoices
  
- **Show QR Code on Receipt** - Toggle checkbox to include/exclude QR codes

## How to Update Receipt Settings

### Step-by-Step

1. Navigate to Settings → Receipt Settings
2. Update any fields you want to change:
   - Business Name → "Your Company Name"
   - Business Address → "123 Main Street"
   - Business Phone → "555-1234567"
   - Thank You Message → "Thank you for your purchase!"
   - Warranty Info → "1 Year Warranty Included"
   - Footer Text → "Thank you for your business"

3. Click **"Save Receipt Settings"** button at the bottom
4. Wait for success message: "Receipt settings saved successfully!"

### Viewing Changes

After saving:
1. Go to **Invoices** section (or click Invoices preview link)
2. Click **"Preview Receipt"** to see the 80mm thermal receipt
3. You should see your updated company information at the top
4. Your thank you message and warranty info at the bottom
5. Footer text should match what you entered

## What Changes in Receipts

Once you save new settings, all receipts generated after that will include:

✓ Your actual company name (not "YOUR STORE")
✓ Your actual address
✓ Your actual phone number
✓ Your custom thank you message
✓ Your warranty information
✓ Your footer message

## Common Settings Examples

### For A Retail Store
```
Business Name: "ABC Retail Store"
Business Address: "456 Shopping Mall, Suite 100"
Business Phone: "555-9876543"
Email: "store@abcretail.com"
Thank You Message: "Thank you for shopping with us!"
Warranty Info: "30-day return policy. Keep receipt for exchanges."
Footer Text: "Visit us again!"
```

### For A Service Business
```
Business Name: "Professional Services Ltd"
Business Address: "789 Business Plaza"
Business Phone: "555-1111111"
Email: "info@professervices.com"
Thank You Message: "Thank you for your business!"
Warranty Info: "Service warranty valid for 1 year"
Footer Text: "www.professervices.com | Call 555-1111111"
```

### For A Restaurant
```
Business Name: "Delicious Kitchen"
Business Address: "123 Food Street, Downtown"
Business Phone: "555-2222222"
Email: "hello@delicious.com"
Thank You Message: "Thank you! Please visit again soon"
Warranty Info: "Food freshness guaranteed"
Footer Text: "Follow us on social media!"
```

## Print Preview

### Accessing Print Preview
- **Thermal Receipt (80mm)**: `/invoices/preview/receipt`
- **A4 Invoice**: `/invoices/preview/a4`
- **A5 Compact Invoice**: `/invoices/preview/a5`

## Troubleshooting

### Changes Not Appearing
1. Check that you clicked "Save Receipt Settings" (not just updating the form)
2. Look for the green success message
3. Clear your browser cache (Ctrl+Shift+Delete) and reload
4. Try a different browser or incognito window

### Settings Showing Default Values
1. Verify you entered the information correctly in all fields
2. Check that the settings were actually saved (look for success notification)
3. Go to Database to check if settings were stored

### Some Fields Still Show Sample Data
- Not all templates support all customization yet
- Items table (Qty, Description, Price) are still template samples
- Future updates will make these fully dynamic

## Settings Apply To

✓ Receipt printing
✓ Invoice generation
✓ Email receipts
✓ PDF exports
✓ Future receipt formats

## Database Storage

Settings are stored in the `setting` table with:
- `setting_category='receipt'` - Identifies as receipt settings
- `company_id=NULL` - Global defaults (apply to all companies)
- `company_id=<number>` - Company-specific override (only that company)

This allows multi-company POS systems to have different receipt formats per company.

## Tips & Best Practices

1. **Keep it Professional** - Use proper business names and contact info
2. **Test Before Printing** - Always preview changes before doing bulk printing
3. **Update Regularly** - If business details change, update settings immediately
4. **Mobile Friendly** - Thermal receipts are optimized for small printers
5. **Backup Settings** - Use Settings → Backup to save your configuration

## Need Help?

If receipts still don't show your settings:
1. Check browser console for JS errors (F12)
2. Check Flask logs for API errors
3. Verify database has your settings saved
4. Try clearing cache and refreshing

Contact your system administrator if issues persist.

