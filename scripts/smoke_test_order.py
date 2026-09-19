"""
Smoke test: login, create an order, fetch order list and detail, and verify `date_ts` fields.
Usage:
  pip install requests bs4
  python scripts/smoke_test_order.py

Configure BASE_URL, USERNAME, PASSWORD in the script or via environment variables.
"""
import os
import re
import json
import requests
from bs4 import BeautifulSoup

BASE_URL = os.environ.get('BASE_URL', 'http://localhost:5000')
USERNAME = os.environ.get('SMOKE_USER', 'admin')
PASSWORD = os.environ.get('SMOKE_PASS', 'password')

s = requests.Session()

print('Getting login page to extract CSRF...')
r = s.get(f'{BASE_URL}/login')
if r.status_code != 200:
    print('Unable to reach login page', r.status_code)
    raise SystemExit(1)

soup = BeautifulSoup(r.text, 'html.parser')
csrf_input = soup.find('input', {'name': 'csrf_token'})
if not csrf_input:
    print('CSRF token input not found on login page')
    raise SystemExit(1)
login_csrf = csrf_input.get('value')
print('Login CSRF token:', login_csrf[:8] + '...')

print('Posting login form...')
login_data = {
    'username': USERNAME,
    'password': PASSWORD,
    'csrf_token': login_csrf
}
resp = s.post(f'{BASE_URL}/login', data=login_data, allow_redirects=True)
if resp.status_code not in (200, 302):
    print('Login failed, status:', resp.status_code)
    print(resp.text[:400])
    raise SystemExit(1)

# Get customers page to extract meta CSRF token used by JS
print('Loading customers page to get JS CSRF token...')
r2 = s.get(f'{BASE_URL}/customers')
if r2.status_code != 200:
    print('Unable to load /customers, got', r2.status_code)
    # continue anyway

soup2 = BeautifulSoup(r2.text, 'html.parser')
meta = soup2.find('meta', {'name': 'csrf-token'})
csrf_token = meta['content'] if meta and meta.get('content') else None
print('JS CSRF token:', (csrf_token[:8] + '...') if csrf_token else 'NOT FOUND')

headers = {'Content-Type': 'application/json'}
if csrf_token:
    headers['X-CSRFToken'] = csrf_token

# Create a test order
payload = {
    'customer_id': None,
    'customer_name': 'Smoke Test Customer',
    'payment_method': 'Cash',
    'status': 'Pending',
    'date': None,  # let server default if you prefer; otherwise set 'YYYY-MM-DD'
    'total': 100.0,
    'balance': 0,
    'notes': 'Smoke test order',
    'items': [
        {'product_id': 1, 'product_name': 'Test Product', 'quantity': 1, 'price': 100}
    ]
}

print('Creating order...')
cr = s.post(f'{BASE_URL}/customers/api/orders', headers=headers, data=json.dumps(payload))
print('Create status:', cr.status_code)
try:
    print('Create response:', cr.json())
except Exception:
    print('Create response body:', cr.text[:400])
    raise

if cr.status_code not in (200,201) or not cr.json().get('success'):
    print('Order creation may have failed; stopping test')
    raise SystemExit(1)

order_id = cr.json().get('order_id')
if not order_id:
    print('No order_id returned; fetching latest orders to find it')

# Fetch orders list
print('Fetching orders list...')
ol = s.get(f'{BASE_URL}/customers/api/orders')
print('Orders list status:', ol.status_code)
try:
    data = ol.json()
    print('Orders list keys:', list(data.keys()))
    first_order = data.get('orders', [])[0] if data.get('orders') else None
    if first_order:
        print('First order sample keys:', list(first_order.keys()))
        print('First order date (ISO):', first_order.get('date'))
    else:
        print('No orders returned')
except Exception:
    print('Orders list body:', ol.text[:800])

# Fetch order detail if we have an id
if order_id:
    print('Fetching order detail for', order_id)
    od = s.get(f'{BASE_URL}/customers/api/orders/{order_id}')
    print('Detail status:', od.status_code)
    try:
        j = od.json()
        print('Detail keys:', list(j.keys()))
        print('detail.date (YYYY-MM-DD):', j.get('date'))
        print('detail.date_ts (ISO UTC):', j.get('date_ts'))
    except Exception:
        print('Order detail body:', od.text[:800])

print('Smoke test completed.')
