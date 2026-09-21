import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import create_app
from app.models import db, User
from app.routes.customers import list_orders
from flask_login import login_user

app = create_app()

with app.app_context():
    user = User.query.filter_by(username='admin').first()
    if not user:
        print('admin user not found')
    else:
        with app.test_request_context('/customers/api/orders'):
            try:
                login_user(user)
            except Exception as e:
                print('login_user failed:', e)
            resp = list_orders()
            print('list_orders response type:', type(resp))
            try:
                print(resp.get_data(as_text=True))
            except Exception:
                print(resp)
