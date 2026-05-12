# Sidebar Toggle - Debugging & Fix Guide

## Issues Identified & Fixed

### 1. **CSS Formatting Issue (Mobile < 480px)**
- **Problem**: Mobile breakpoint had malformed CSS with missing newline
- **Location**: `app/static/css/responsive.css` line 277
- **Impact**: Mobile devices weren't applying sidebar drawer styles correctly

**Before:**
```css
@media (max-width: 480px) {    .sidebar-toggle {
```

**After:**
```css
@media (max-width: 480px) {
    :root {
        --header-height: var(--header-height-mobile);
    }
    
    .sidebar-toggle {
```

### 2. **Missing Header Height Variable (Mobile)**
- **Problem**: Mobile (< 480px) breakpoint didn't set the 48px header height
- **Fix**: Added `:root { --header-height: var(--header-height-mobile); }` rule
- **Impact**: Sidebar height calculations were incorrect on small phones

### 3. **Overlay Z-Index Positioning**
- **Problem**: `sidebar-overlay` had `top: 0;` instead of `top: var(--header-height);`
- **Fix**: Updated to match sidebar top positioning
- **Impact**: Overlay didn't align properly below header

## CSS Cascade Check

### Desktop (≥ 990px) - Always Visible
```css
.sidebar {
    position: static;     /* From style.css */
    left: auto;          /* Responsive CSS */
    top: auto;           /* Responsive CSS */
    width: 260px;
    z-index: 1050;
}
```
✅ Sidebar is visible alongside content

### Tablet/Mobile (< 990px) - Drawer Mode
```css
/* Base state */
.sidebar {
    position: fixed;
    top: 56px;           /* var(--header-height-tablet) */
    left: -280px;        /* Hidden off-screen */
    width: 280px;
    z-index: 1050;
    transition: left 0.3s ease;
}

/* When toggle clicked, JavaScript adds 'show' class */
.sidebar.show {
    left: 0;             /* Slides in from left */
}
```

### Mobile (< 480px) - Small Phone
```css
.sidebar {
    position: fixed;
    top: 48px;           /* var(--header-height-mobile) */
    left: -280px;        /* Hidden off-screen */
    height: calc(100vh - 48px);   /* Full height minus header */
}

.sidebar.show {
    left: 0;             /* Slides in from left */
}
```

## JavaScript Toggle Flow

1. **User clicks hamburger button** (.sidebar-toggle)
2. **Event listener fires** → `toggleSidebar()`
3. **Class toggled** → `.sidebar { add 'show' class }`
4. **CSS animation triggers** → `left: -280px → left: 0`
5. **Sidebar slides in** from left side

## Debugging Instructions

### Step 1: Open Developer Tools
- **Windows/Linux**: Press `F12`
- **Mac**: Press `Cmd + Option + I`

### Step 2: Open Console Tab
- Click "Console" in DevTools

### Step 3: Click Hamburger Icon
- Look for the ≡ (three-line) button in the header
- Should see console output:

```
🔧 Toggle button clicked
📍 Sidebar before toggle: sidebar show
📍 Sidebar position: 0px
📍 Sidebar after toggle: sidebar
📍 Sidebar position after: -280px
📍 Overlay has show class: false
```

### Expected Console Output

**First Click (to open sidebar):**
```
🔧 Toggle button clicked
📍 Sidebar before toggle: sidebar
📍 Sidebar position: -280px
📍 Sidebar after toggle: sidebar show
📍 Sidebar position after: 0px
📍 Overlay has show class: true
```

**Second Click (to close sidebar):**
```
🔧 Toggle button clicked
📍 Sidebar before toggle: sidebar show
📍 Sidebar position: 0px
📍 Sidebar after toggle: sidebar
📍 Sidebar position after: -280px
📍 Overlay has show class: false
```

## Troubleshooting

### Problem: Icon changes but sidebar doesn't move

**Check Console Output:**

1. **If position stays -280px after toggle:**
   - CSS `.sidebar.show { left: 0 }` not applying
   - Run: `document.querySelector('.sidebar').className` → should show "sidebar show"

2. **If class shows 'show' but position is -280px:**
   - CSS rule conflict or specificity issue
   - Run: `getComputedStyle(document.querySelector('.sidebar')).left`

3. **If no console output appears:**
   - Event listener not attached
   - Run: `document.getElementById('sidebarToggle') !== null` → should be true

### Problem: Sidebar appears in wrong position

**Check applied height:**
```javascript
// Should return header height (48px, 56px, or 64px depending on device)
getComputedStyle(document.querySelector('.sidebar')).top

// Should show viewport height minus header
getComputedStyle(document.querySelector('.sidebar')).height
```

### Problem: Overlay doesn't appear with sidebar

**Check overlay state:**
```javascript
// Should show overlay element
document.querySelector('.sidebar-overlay')

// Should have 'show' class when sidebar is open
document.querySelector('.sidebar-overlay').classList.contains('show')
```

## Quick Test Commands (in Console)

### Verify Button Exists
```javascript
console.log('Button:', document.getElementById('sidebarToggle'));
console.log('Sidebar:', document.getElementById('sidebar'));
```

### Manually Toggle (if automatic isn't working)
```javascript
document.querySelector('.sidebar').classList.toggle('show');
document.querySelector('.sidebar-overlay').classList.toggle('show');
```

### Check Current State
```javascript
const sb = document.querySelector('.sidebar');
console.log('Classes:', sb.className);
console.log('Position:', getComputedStyle(sb).left);
console.log('Top:', getComputedStyle(sb).top);
console.log('Height:', getComputedStyle(sb).height);
console.log('Z-index:', getComputedStyle(sb).zIndex);
```

## CSS Specificity Check

If toggle isn't working, verify CSS cascade with:
```javascript
// Get all CSS rules for .sidebar
const rules = document.styleSheets;
for (let i = 0; i < rules.length; i++) {
    try {
        const sheet = rules[i];
        for (let j = 0; j < sheet.cssRules.length; j++) {
            const rule = sheet.cssRules[j];
            if (rule.selectorText === '.sidebar') {
                console.log(rule.style.left);
            }
        }
    } catch(e) {}
}
```

## Files Modified

1. **app/static/css/responsive.css** (v32.0.0)
   - Fixed mobile < 480px breakpoint formatting
   - Added missing :root variable
   - Fixed sidebar-overlay positioning

2. **app/static/js/app.js** (with debug logging)
   - Added console.log for debugging toggle logic
   - Shows click events and class changes

3. **app/templates/base.html**
   - Updated cache versions for force refresh

## Cache Clear Instructions

If sidebar toggle still doesn't work after deployment:

1. **Hard Refresh Cache (Windows/Mac)**
   - Windows: `Ctrl + Shift + R`
   - Mac: `Cmd + Shift + R`
   - Chrome: Force empty cache and hard reload in DevTools

2. **Or Clear Browser Cache Entirely**
   - Settings → Clear browsing data
   - Select "Cached images and files"
   - Click Clear data

3. **Server Cache (if using nginx)**
   - Restart Docker container: `docker compose restart web`

## Expected Timeline

- **Local changes**: Committed to git ✅
- **Pushed to GitHub**: fffa467 → 07b740d ✅
- **Cache version bumped**: v31.0.0 → v32.0.0 ✅
- **Server deployment**: Pending
- **Browser cache refresh**: User must refresh (Ctrl+Shift+R)

## Contact/Issues

If the sidebar toggle is still not working after these fixes:

1. **Check Console Output** (F12 → Console)
   - Report what you see when clicking the hamburger icon
   
2. **Verify Device Type**
   - Desktop (> 990px): Sidebar always visible, no toggle shown
   - Tablet (768-989px): Hamburger should appear, toggle sidebar
   - Mobile (< 768px): Hamburger should appear, toggle sidebar

3. **Report Details**
   - Device type and screen width
   - What happens when clicking hamburger
   - Console output from our debug logging
