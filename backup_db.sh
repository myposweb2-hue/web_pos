#!/bin/bash
# Automated Database Backup Script
# Place in /home/appuser/backup_db.sh
# Run with crontab for automatic backups

BACKUP_DIR="/home/appuser/web_pos/backups"
LOG_FILE="/home/appuser/web_pos/logs/backup.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DB_NAME=${DB_NAME:-pos_db}
DB_USER=${DB_USER:-pos_user}
RETENTION_DAYS=30

# Create directories if they don't exist
mkdir -p $BACKUP_DIR
mkdir -p $(dirname $LOG_FILE)

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

log "Starting database backup..."

# Take backup
BACKUP_FILE="$BACKUP_DIR/backup_${TIMESTAMP}.sql"

if docker exec pos_db pg_dump -U $DB_USER $DB_NAME > "$BACKUP_FILE"; then
    FILESIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log "✓ Backup successful: $BACKUP_FILE ($FILESIZE)"
    echo "Backup created: $FILESIZE"
else
    log "✗ Backup failed for $DB_NAME"
    exit 1
fi

# Compress backup
gzip "$BACKUP_FILE"
BACKUP_FILE="${BACKUP_FILE}.gz"

log "✓ Backup compressed: $(du -h "$BACKUP_FILE" | cut -f1)"

# Delete old backups (older than RETENTION_DAYS)
log "Cleaning up old backups (older than $RETENTION_DAYS days)..."
DELETED_COUNT=$(find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)
log "✓ Deleted $DELETED_COUNT old backup(s)"

# Upload to cloud storage (optional - AWS S3, DigitalOcean Spaces, etc.)
# Example for AWS S3:
# aws s3 cp "$BACKUP_FILE" s3://your-bucket/pos-backups/

log "Backup process completed successfully"
log "---"

# Keep backup directory size under control (max 5GB)
TOTAL_SIZE=$(du -sb $BACKUP_DIR | cut -f1)
MAX_SIZE=$((5 * 1024 * 1024 * 1024))  # 5GB

if [ $TOTAL_SIZE -gt $MAX_SIZE ]; then
    log "⚠ Backup directory exceeds 5GB, removing oldest files"
    find $BACKUP_DIR -name "backup_*.sql.gz" | sort | head -n 5 | xargs rm -f
fi

exit 0
