# DigitalOcean Deployment Guide - Complete Step-by-Step

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: Register Domain](#step-1-register-domain)
3. [Step 2: Create DigitalOcean Account](#step-2-create-digitalocean-account)
4. [Step 3: Create Droplet](#step-3-create-droplet)
5. [Step 4: Initial Droplet Setup](#step-4-initial-droplet-setup)
6. [Step 5: Install Docker & Docker Compose](#step-5-install-docker--docker-compose)
7. [Step 6: Configure DNS](#step-6-configure-dns)
8. [Step 7: Deploy Application](#step-7-deploy-application)
9. [Step 8: Setup SSL/HTTPS](#step-8-setupsslhttps)
10. [Step 9: Database Backup](#step-9-database-backup)
11. [Step 10: Monitoring & Maintenance](#step-10-monitoring--maintenance)

---

## Prerequisites

Before starting, you need:
- ✅ POS application code (you have it)
- ✅ GitHub account (to host your code)
- ✅ A domain name (register on register.lk or similar)
- ✅ Credit card for DigitalOcean ($5-10 test charge)
- ✅ SSH client (Windows: PuTTY, Mac/Linux: Terminal)

---

## Step 1: Register Domain

### Option A: Register on register.lk (Recommended - Sri Lanka based)
1. Go to **register.lk**
2. Search for your domain name (e.g., `mypos.lk`, `mypossystem.lk`)
3. Add to cart and register
4. Cost: ~Rs 1,500-2,500/year
5. **Keep the domain provider dashboard open** - you'll need it later

### Option B: Other registrars
- **Namecheap** (namecheap.com)
- **GoDaddy** (godaddy.com)
- **AWS Route53** (aws.amazon.com/route53)

**✅ Remember your domain name: `yourdomain.lk`**

---

## Step 2: Create DigitalOcean Account

1. Go to **digitalocean.com**
2. Click "Sign Up" → Enter email/password
3. Choose "Business" as use case
4. Add credit card (they'll charge $5 to verify, then credit it back)
5. Complete verification
6. You're ready! DigitalOcean dashboard opens

**Bookmark: https://cloud.digitalocean.com**

---

## Step 3: Create Droplet

### In DigitalOcean Dashboard:

1. **Click "Create" → Select "Droplets"**

2. **Choose Image:**
   - Select "Ubuntu"
   - Version: **22.04 LTS** ✅

3. **Choose Size:**
   - Select: **$6/month (2GB RAM, 50GB SSD)** ✅
   - (Sufficient for POS application)

4. **Choose Region:**
   - Select closest to Sri Lanka: **Singapore** or **India**
   - Recommended: **Singapore** (best latency for SL)

5. **Authentication:**
   - Select "Password" (simpler)
   - Set strong password (save it!)
   - OR Add SSH Key (advanced)

6. **Hostname:**
   - Name: `pos-app-server` or `pos-prod`

7. **Click "Create Droplet"**
   - Wait 2-3 minutes for activation
   - You'll see Droplet IP address (e.g., `123.45.67.89`)

**✅ Save your IP address: `123.45.67.89`**

---

## Step 4: Initial Droplet Setup

### Connect via SSH:

**Windows (PuTTY):**
1. Download PuTTY
2. Hostname: `123.45.67.89` (your Droplet IP)
3. Port: `22`
4. Username: `root`
5. Password: (from Step 3)
6. Click "Open"

**Mac/Linux (Terminal):**
```bash
ssh root@123.45.67.89
# Enter password when prompted
```

### Once Connected, Run These Commands:

```bash
# Update system
apt update && apt upgrade -y

# Set timezone
timedatectl set-timezone Asia/Colombo

# Create application user
useradd -m -s /bin/bash appuser
usermod -aG sudo appuser

# Set up SSH key for future logins (recommended)
mkdir -p /home/appuser/.ssh
chmod 700 /home/appuser/.ssh

# Switch to app user
su - appuser

# Verify
whoami  # Should output: appuser
```

---

## Step 5: Install Docker & Docker Compose

**Still SSH'd as `appuser`:**

```bash
# Install Docker prerequisites
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add appuser to docker group
sudo usermod -aG docker appuser

# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker-compose --version

# Exit and login again for group changes
exit
# SSH back in
ssh appuser@123.45.67.89
```

---

## Step 6: Configure DNS

**In your Domain Registrar (register.lk):**

1. Login to **register.lk** dashboard
2. Find your domain → **Manage DNS** / **Nameservers**
3. Add **A Record:**
   - Type: `A`
   - Name: `@` or leave blank
   - Value: `123.45.67.89` (your Droplet IP)
   - TTL: `3600` (1 hour)
4. **Save**

**Wait 15-30 minutes for DNS propagation**

Test with:
```bash
# In your computer terminal
nslookup yourdomain.lk
# Should show: 123.45.67.89
```

---

## Step 7: Deploy Application

**SSH back into Droplet:**

```bash
ssh appuser@123.45.67.89

# Clone your repository (assuming it's on GitHub)
cd /home/appuser
git clone https://github.com/yourusername/web_pos.git
cd web_pos

# Create production .env file
nano .env

# Paste this and edit:
```

**In `.env` file:**
```bash
FLASK_ENV=production
SECRET_KEY=generate-random-string-with-python-secrets
DB_NAME=pos_db
DB_USER=pos_user
DB_PASSWORD=very-secure-password-here
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=your-gmail@gmail.com
MAIL_PASSWORD=your-gmail-app-password
MAIL_DEFAULT_SENDER=noreply@yourdomain.lk
```

**To generate SECRET_KEY, run on your computer:**
```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

**Save file (Ctrl+O, Enter, Ctrl+X)**

---

## Step 8: Start Docker Containers

Still in `/home/appuser/web_pos`:

```bash
# Use production docker-compose
docker-compose -f docker-compose.production.yml up -d

# Verify containers running
docker ps
# Should show: pos_db, pos_app, pos_nginx

# Check logs
docker logs pos_app
docker logs pos_nginx

# Initialize database (first time only)
docker exec pos_app flask db upgrade

# Create first admin user
docker exec -it pos_app flask shell
# In Flask shell:
# >>> from app.models import User
# >>> admin = User(email='admin@yourdomain.lk', username='admin')
# >>> admin.set_password('secure_password_here')
# >>> db.session.add(admin)
# >>> db.session.commit()
# >>> exit()
```

**Test app:**
```bash
curl http://yourdomain.lk
# Should return HTML (no "Connection refused")
```

---

## Step 9: Setup SSL/HTTPS

**Install Certbot:**

```bash
sudo apt install -y certbot python3-certbot-nginx

# Stop nginx temporarily
docker exec pos_nginx nginx -s stop

# Get SSL certificate
sudo certbot certonly --standalone -d yourdomain.lk -d www.yourdomain.lk
# Enter email: your-email@gmail.com
# Agree to terms

# Update nginx config
nano nginx.production.conf
# Find these lines and uncomment + update:
# ssl_certificate /etc/letsencrypt/live/yourdomain.lk/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/yourdomain.lk/privkey.pem;

# Restart containers
docker restart pos_nginx

# Verify HTTPS
curl -I https://yourdomain.lk
# Should show: 200 OK
```

**Auto-renew SSL (every 90 days):**
```bash
sudo crontab -e
# Add line:
0 3 1 * * certbot renew --quiet && docker restart pos_nginx
```

---

## Step 10: Database Backup

**Daily Backup Script:**

```bash
# Create backup script
nano /home/appuser/backup_db.sh
```

**Paste:**
```bash
#!/bin/bash
BACKUP_DIR="/home/appuser/web_pos/backups"
mkdir -p $BACKUP_DIR
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
docker exec pos_db pg_dump -U pos_user pos_db > $BACKUP_DIR/backup_$TIMESTAMP.sql
# Keep only last 7 days
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
```

**Make executable:**
```bash
chmod +x /home/appuser/backup_db.sh

# Run daily at 2 AM
crontab -e
# Add:
0 2 * * * /home/appuser/backup_db.sh
```

---

## Step 11: Monitoring & Maintenance

### Check app status:
```bash
ssh appuser@yourdomain.lk
docker ps
docker logs -f pos_app  # Real-time logs
docker stats             # CPU/Memory usage
```

### Update application:
```bash
cd /home/appuser/web_pos
git pull origin main
docker-compose -f docker-compose.production.yml up -d
docker exec pos_app flask db upgrade
```

### View DigitalOcean metrics:
- CPU usage
- Memory usage
- Network activity
- Go to: https://cloud.digitalocean.com → Your Droplet

### Security checklist:
- ✅ Use strong passwords
- ✅ Enable firewall (UFW)
- ✅ Update regularly
- ✅ Monitor logs
- ✅ Backup database weekly

---

## Troubleshooting

### Application not responding:
```bash
docker logs pos_app
docker restart pos_app
```

### SSL certificate issues:
```bash
sudo certbot renew --dry-run
```

### Database connection errors:
```bash
docker exec pos_db psql -U pos_user -d pos_db -c "SELECT 1"
```

### Out of disk space:
```bash
docker system prune -a
docker volume prune
```

---

## Summary

| What | Cost/Month | Status |
|------|-----------|--------|
| Droplet (2GB RAM) | $6 | ✅ Running |
| Domain | Rs 1,500-2,500/year | ✅ Registered |
| SSL Certificate | FREE | ✅ Active |
| Backups | FREE | ✅ Daily |
| **Total** | **~$6-8/month** | **$40-60/year** |

Your POS is now **live on yourdomain.lk** 🎉

---

## Next Steps

1. Access your app: `https://yourdomain.lk`
2. Login with admin account
3. Add companies & start selling
4. Monitor daily via DigitalOcean dashboard
5. Backup database weekly

**Email support: appuser@yourdomain.lk**

Need help? Check `/home/appuser/web_pos/logs/` for error details.
