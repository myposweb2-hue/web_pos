import sys
import os

# Ensure project root is on sys.path
proj_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if proj_root not in sys.path:
    sys.path.insert(0, proj_root)

from app import create_app
from app.models import Setting

app = create_app()
with app.app_context():
    s = Setting.query.filter_by(setting_category='orders', setting_key='show_all_orders').first()
    if s:
        print(s.setting_value)
    else:
        print('NOT_SET')
