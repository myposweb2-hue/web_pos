#!/usr/bin/env python
"""
Find and fix records with NULL company_id.
Identifies which tables have orphaned records and suggests fixes.
"""

from app import create_app, db
from sqlalchemy import inspect, and_, or_

def find_null_company_ids():
    """Find all records with NULL company_id in multi-company tables."""
    app = create_app()
    
    with app.app_context():
        print("🔍 Scanning for NULL company_id records...")
        print("=" * 70)
        
        inspector = inspect(db.engine)
        tables = inspector.get_table_names()
        
        orphaned_records = {}
        
        for table_name in sorted(tables):
            # Skip system tables
            if table_name.startswith('sqlite_') or table_name.startswith('pg_'):
                continue
            
            columns = [col['name'] for col in inspector.get_columns(table_name)]
            
            # Check if table has company_id column
            if 'company_id' not in columns:
                continue
            
            try:
                # Count NULL company_id records
                result = db.session.execute(
                    f"SELECT COUNT(*) FROM {table_name} WHERE company_id IS NULL"
                )
                count = result.scalar()
                
                if count > 0:
                    orphaned_records[table_name] = count
                    print(f"  ⚠️  {table_name}: {count} records with NULL company_id")
                    
                    # Show sample
                    if table_name == 'settings':
                        result = db.session.execute(
                            f"SELECT id, setting_category, setting_key, company_id FROM {table_name} WHERE company_id IS NULL LIMIT 3"
                        )
                        for row in result:
                            print(f"      Sample: ID={row[0]}, category={row[1]}, key={row[2]}")
                    else:
                        result = db.session.execute(
                            f"SELECT id FROM {table_name} WHERE company_id IS NULL LIMIT 3"
                        )
                        ids = [row[0] for row in result]
                        print(f"      Sample IDs: {ids}")
            except Exception as e:
                print(f"  ! Error checking {table_name}: {e}")
        
        print("=" * 70)
        if orphaned_records:
            print(f"\n❌ Found {sum(orphaned_records.values())} orphaned records in {len(orphaned_records)} tables")
            return orphaned_records
        else:
            print("\n✅ No orphaned records found!")
            return {}

def fix_null_company_ids():
    """Assign orphaned records to the first active company."""
    app = create_app()
    
    with app.app_context():
        from app.models import Company
        
        # Find first active company
        company = Company.query.filter_by(is_active=True).first()
        
        if not company:
            print("❌ No active company found! Cannot fix orphaned records.")
            return
        
        print(f"\n🔧 Assigning orphaned records to Company ID: {company.id} ({company.name})")
        print("=" * 70)
        
        inspector = inspect(db.engine)
        tables = inspector.get_table_names()
        
        total_fixed = 0
        
        for table_name in sorted(tables):
            if table_name.startswith('sqlite_') or table_name.startswith('pg_'):
                continue
            
            columns = [col['name'] for col in inspector.get_columns(table_name)]
            
            if 'company_id' not in columns:
                continue
            
            try:
                # Update NULL company_id to the default company
                result = db.session.execute(
                    f"UPDATE {table_name} SET company_id = {company.id} WHERE company_id IS NULL"
                )
                affected = result.rowcount
                
                if affected > 0:
                    print(f"  ✓ {table_name}: {affected} records fixed")
                    total_fixed += affected
                    
            except Exception as e:
                print(f"  ! Error updating {table_name}: {e}")
        
        db.session.commit()
        
        print("=" * 70)
        if total_fixed > 0:
            print(f"\n✅ Fixed {total_fixed} orphaned records!")
        else:
            print("\n✅ No orphaned records to fix!")

if __name__ == '__main__':
    import sys
    
    print("\n🚀 NULL Company ID Cleanup Utility\n")
    
    # First scan
    orphaned = find_null_company_ids()
    
    if orphaned:
        response = input("\n⚠️  Fix these orphaned records? (yes/no): ").strip().lower()
        if response in ('yes', 'y'):
            fix_null_company_ids()
        else:
            print("Skipped fix.")
    
    print("\n✓ Done!\n")
