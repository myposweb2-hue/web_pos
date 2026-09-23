#!/usr/bin/env python
"""Run database migrations."""
from flask_migrate import upgrade
from app import create_app, db

if __name__ == '__main__':
    app = create_app()
    with app.app_context():
        print("Running database migrations...")
        try:
            upgrade()
            print("✓ Database migrations applied successfully!")
        except Exception as e:
            print(f"✗ Migration failed: {e}")
            import sys
            sys.exit(1)
