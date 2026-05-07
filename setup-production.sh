#!/bin/bash
# POS Application - Production Deployment Setup Script
# Run this on your production server to set everything up

set -e

echo "🚀 POS Application Production Setup"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# 1. Update System
echo -e "\n${YELLOW}1. Updating system packages...${NC}"
apt-get update
apt-get upgrade -y

# 2. Install Dependencies
echo -e "\n${YELLOW}2. Installing dependencies...${NC}"
apt-get install -y \
    python3-pip \
    python3-venv \
    postgresql \
    postgresql-contrib \
    nginx \
    curl \
    git \
    supervisor

# 3. Create App User
echo -e "\n${YELLOW}3. Creating application user...${NC}"
if ! id "appuser" &>/dev/null; then
    useradd -m -s /bin/bash appuser
    echo -e "${GREEN}✓ User 'appuser' created${NC}"
else
    echo -e "${GREEN}✓ User 'appuser' already exists${NC}"
fi

# 4. Setup Application Directory
echo -e "\n${YELLOW}4. Setting up application directory...${NC}"
APP_DIR=/home/appuser/web_pos
mkdir -p $APP_DIR
chown -R appuser:appuser $APP_DIR

# 5. Clone Repository (if needed)
echo -e "\n${YELLOW}5. Preparing application files...${NC}"
if [ ! -d "$APP_DIR/.git" ]; then
    read -p "Enter your Git repository URL (or press Enter to skip): " GIT_URL
    if [ ! -z "$GIT_URL" ]; then
        sudo -u appuser git clone $GIT_URL $APP_DIR
        echo -e "${GREEN}✓ Repository cloned${NC}"
    fi
else
    echo -e "${GREEN}✓ Repository already exists${NC}"
fi

# 6. Create Virtual Environment
echo -e "\n${YELLOW}6. Creating Python virtual environment...${NC}"
cd $APP_DIR
sudo -u appuser python3 -m venv .venv
echo -e "${GREEN}✓ Virtual environment created${NC}"

# 7. Install Python Dependencies
echo -e "\n${YELLOW}7. Installing Python dependencies...${NC}"
sudo -u appuser ./.venv/bin/pip install --upgrade pip
sudo -u appuser ./.venv/bin/pip install -r requirements.txt
echo -e "${GREEN}✓ Dependencies installed${NC}"

# 8. Create Environment File
echo -e "\n${YELLOW}8. Creating environment configuration...${NC}"
if [ ! -f "$APP_DIR/.env" ]; then
    echo "Creating .env file..."
    cat > $APP_DIR/.env << EOF
FLASK_ENV=production
DEBUG=False
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
DATABASE_URL=postgresql://pos_user:pos_password@localhost:5432/pos_db
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
SESSION_COOKIE_SECURE=True
SESSION_COOKIE_HTTPONLY=True
EOF
    chown appuser:appuser $APP_DIR/.env
    chmod 600 $APP_DIR/.env
    echo -e "${YELLOW}⚠ Edit .env file with your secret values:${NC}"
    echo "  nano $APP_DIR/.env"
else
    echo -e "${GREEN}✓ .env file exists${NC}"
fi

# 9. Setup PostgreSQL
echo -e "\n${YELLOW}9. Setting up PostgreSQL database...${NC}"
sudo -u postgres psql << EOF
CREATE ROLE pos_user WITH LOGIN PASSWORD 'pos_password';
CREATE DATABASE pos_db OWNER pos_user;
GRANT ALL PRIVILEGES ON DATABASE pos_db TO pos_user;
ALTER ROLE pos_user WITH PASSWORD 'secure_password_here';
EOF
echo -e "${GREEN}✓ Database and user created${NC}"
echo -e "${YELLOW}⚠ Change 'secure_password_here' in PostgreSQL!${NC}"

# 10. Initialize Database
echo -e "\n${YELLOW}10. Initializing application database...${NC}"
cd $APP_DIR
sudo -u appuser ./.venv/bin/python << EOF
from app import create_app, db
app = create_app()
with app.app_context():
    db.create_all()
    print("Database initialized successfully!")
EOF
echo -e "${GREEN}✓ Database initialized${NC}"

# 11. Create Systemd Service
echo -e "\n${YELLOW}11. Creating systemd service...${NC}"
cat > /etc/systemd/system/pos.service << EOF
[Unit]
Description=POS Web Application
After=network.target postgresql.service

[Service]
Type=notify
User=appuser
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/.venv/bin"
ExecStart=$APP_DIR/.venv/bin/gunicorn \\
    --workers 4 \\
    --worker-class sync \\
    --bind 127.0.0.1:8000 \\
    --timeout 60 \\
    --access-logfile /var/log/pos/access.log \\
    --error-logfile /var/log/pos/error.log \\
    "app:create_app()"
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create log directory
mkdir -p /var/log/pos
chown appuser:appuser /var/log/pos

# Reload systemd
systemctl daemon-reload
systemctl enable pos.service
echo -e "${GREEN}✓ Systemd service created${NC}"

# 12. Configure Nginx
echo -e "\n${YELLOW}12. Configuring Nginx reverse proxy...${NC}"
cat > /etc/nginx/sites-available/pos << 'EOF'
server {
    listen 80;
    server_name _;
    client_max_body_size 20M;

    access_log /var/log/nginx/pos_access.log;
    error_log /var/log/nginx/pos_error.log;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /static/ {
        alias /home/appuser/web_pos/app/static/;
        expires 30d;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/pos /etc/nginx/sites-enabled/pos
rm -f /etc/nginx/sites-enabled/default

# Test Nginx config
nginx -t
systemctl enable nginx
systemctl restart nginx
echo -e "${GREEN}✓ Nginx configured${NC}"

# 13. Start Services
echo -e "\n${YELLOW}13. Starting services...${NC}"
systemctl start postgresql
systemctl start pos
systemctl start nginx
echo -e "${GREEN}✓ Services started${NC}"

# 14. Setup SSL (Optional Let's Encrypt)
echo -e "\n${YELLOW}14. Installing Certbot for SSL...${NC}"
apt-get install -y certbot python3-certbot-nginx
echo -e "${YELLOW}To setup SSL, run:${NC}"
echo "  certbot --nginx -d your-domain.com"

# 15. Create Backup Script
echo -e "\n${YELLOW}15. Creating backup script...${NC}"
cat > /home/appuser/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=/home/appuser/backups
mkdir -p $BACKUP_DIR
FILENAME="pos_backup_$(date +%Y%m%d_%H%M%S).sql"
pg_dump -U pos_user pos_db > $BACKUP_DIR/$FILENAME
gzip $BACKUP_DIR/$FILENAME
echo "Backup created: $BACKUP_DIR/${FILENAME}.gz"
EOF
chmod +x /home/appuser/backup.sh
echo -e "${GREEN}✓ Backup script created${NC}"

# Final Summary
echo -e "\n${GREEN}==================================${NC}"
echo -e "${GREEN}✅ Production Setup Complete!${NC}"
echo -e "${GREEN}==================================${NC}"

echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Edit configuration:"
echo "   nano $APP_DIR/.env"
echo ""
echo "2. Update PostgreSQL password:"
echo "   sudo -u postgres psql -c \"ALTER ROLE pos_user WITH PASSWORD 'your-secure-password';\""
echo ""
echo "3. Configure Nginx domain:"
echo "   nano /etc/nginx/sites-available/pos"
echo ""
echo "4. Setup SSL certificate:"
echo "   certbot --nginx -d your-domain.com"
echo ""
echo "5. Check status:"
echo "   systemctl status pos"
echo "   systemctl status nginx"
echo ""
echo "6. View logs:"
echo "   tail -f /var/log/pos/error.log"
echo "   tail -f /var/log/nginx/pos_error.log"
echo ""
echo "7. Run backups daily:"
echo "   sudo -u appuser crontab -e"
echo "   # Add: 0 2 * * * /home/appuser/backup.sh"

echo -e "\n${GREEN}Your application will be available at http://your-server-ip${NC}"
