#!/usr/bin/env python
"""Add missing status column to sales table directly."""
from app import create_app, db
from sqlalchemy import text

if __name__ == '__main__':
    app = create_app()
    with app.app_context():
        print("Checking if 'status' column exists in sales table...")
        try:
            # Check if column exists
            result = db.session.execute(
                text("PRAGMA table_info(sales)")
            ).fetchall()
            columns = {row[1] for row in result}
            
            if 'status' not in columns:
                print("✓ Column 'status' not found, adding it...")
                db.session.execute(
                    text("ALTER TABLE sales ADD COLUMN status VARCHAR(20) DEFAULT 'Pending'")
                )
                db.session.commit()
                print("✓ Column 'status' added successfully!")
            else:
                print("✓ Column 'status' already exists.")
                
        except Exception as e:
            print(f"✗ Error: {e}")
            import sys
            sys.exit(1)
