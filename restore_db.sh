#!/bin/bash
# Database Restore Script
# Usage: bash restore_db.sh backup_20260408_120000.sql.gz

BACKUP_FILE=$1
DB_NAME=${DB_NAME:-pos_db}
DB_USER=${DB_USER:-pos_user}

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: bash restore_db.sh <backup_file>"
    echo ""
    echo "Available backups:"
    ls -lh backups/backup_*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "=========================================="
echo "Database Restore"
echo "=========================================="
echo "Restoring from: $BACKUP_FILE"
echo ""

# Confirm before proceeding
read -p "WARNING: This will overwrite the current database. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 1
fi

# Decompress if needed
if [[ $BACKUP_FILE == *.gz ]]; then
    echo "Decompressing backup..."
    TMP_FILE="${BACKUP_FILE%.gz}"
    gunzip -c "$BACKUP_FILE" > "$TMP_FILE"
    RESTORE_FILE="$TMP_FILE"
else
    RESTORE_FILE="$BACKUP_FILE"
fi

echo "Stopping application..."
docker stop pos_app pos_nginx

echo "Dropping existing database..."
docker exec -it pos_db psql -U $DB_USER -c "DROP DATABASE IF EXISTS $DB_NAME;"

echo "Creating new database..."
docker exec -it pos_db psql -U $DB_USER -c "CREATE DATABASE $DB_NAME;"

echo "Restoring database from backup..."
cat "$RESTORE_FILE" | docker exec -i pos_db psql -U $DB_USER $DB_NAME

echo "Starting application..."
docker start pos_app pos_nginx

# Clean up temp file
if [[ $BACKUP_FILE == *.gz ]]; then
    rm -f "$RESTORE_FILE"
fi

echo ""
echo "=========================================="
echo "✓ Database restore completed!"
echo "=========================================="
echo ""
echo "Your POS database has been restored."
echo "Please verify the data in your application."
echo ""
