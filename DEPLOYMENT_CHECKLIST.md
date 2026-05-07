# DigitalOcean Deployment Checklist

Complete these steps to deploy your POS to DigitalOcean. Use this as a checklist as you progress.

---

## ✅ Phase 1: Preparation (Before DigitalOcean)

- [ ] **Domain Registration**
  - [ ] Register domain on register.lk or other registrar
  - [ ] Save domain name: `_________________`
  - [ ] Save registrar username/password
  - [ ] Cost: ~Rs 1,500-2,500/year

- [ ] **Code Preparation**
  - [ ] Push code to GitHub/GitLab
  - [ ] Save repository URL: `_________________`
  - [ ] Create `.env.production.example` ✓ (Already done)
  - [ ] Have production config ready

- [ ] **Email Setup**
  - [ ] Gmail account ready (or other SMTP)
  - [ ] Gmail: Create App Password (not regular password)
  - [ ] Saved SMTP credentials:
    - [ ] MAIL_SERVER: `_________________`
    - [ ] MAIL_USERNAME: `_________________`
    - [ ] MAIL_PASSWORD: `_________________`

- [ ] **Generate Secrets**
  - [ ] Generate SECRET_KEY: 
    ```bash
    python -c "import secrets; print(secrets.token_hex(32))"
    ```
  - [ ] Saved SECRET_KEY: `_________________`
  - [ ] Generate DB password: `_________________`

---

## ✅ Phase 2: DigitalOcean Setup

### Create Account
- [ ] Go to digitalocean.com
- [ ] Sign up with email/password
- [ ] Add credit card verification ($5 test charge)
- [ ] Verify email
- [ ] Save account login

### Create Droplet
- [ ] In Dashboard: Click "Create" → "Droplets"
- [ ] Select Image: Ubuntu 22.04 LTS
- [ ] Select Size: $6/month (2GB RAM, 50GB SSD)
- [ ] Select Region: Singapore
- [ ] Authentication: Set strong password
- [ ] Hostname: `pos-app-server`
- [ ] Create Droplet
- [ ] **Wait 2-3 minutes** for droplet to initialize
- [ ] Save Droplet IP: `_________________`

---

## ✅ Phase 3: Initial Server Setup

### SSH Access
- [ ] Windows: Download & open PuTTY
  - [ ] Host: `your-ip-address`
  - [ ] Port: `22`
  - [ ] Username: `root`
  - [ ] Password: (from Phase 2)
- [ ] Mac/Linux: `ssh root@your-ip-address`

### Run Setup Script
```bash
# Download setup script (or create manually)
bash setup.sh

# Wait for completion (5-10 minutes)
# Should see: "✓ Setup Complete!"
```

- [ ] System updated
- [ ] TimeZone set to Asia/Colombo
- [ ] Application user created
- [ ] Docker installed
- [ ] Docker Compose installed
- [ ] SSL tools installed
- [ ] Firewall configured

### Switch to Application User
```bash
su - appuser
# Or login again as appuser
```

---

## ✅ Phase 4: Deploy Application

### Clone Repository
```bash
cd /home/appuser
git clone https://github.com/yourusername/web_pos.git
cd web_pos
```

- [ ] Repository cloned successfully

### Create Production Environment
```bash
# Copy example env
cp .env.production.example .env

# Edit with your values
nano .env
```

- [ ] FLASK_ENV=production
- [ ] SECRET_KEY is set (from prep phase)
- [ ] Database credentials set
- [ ] MAIL_SERVER configured
- [ ] MAIL_USERNAME configured
- [ ] MAIL_PASSWORD configured
- [ ] MAIL_DEFAULT_SENDER set
- [ ] File saved (Ctrl+O, Enter, Ctrl+X)

### Start Docker Containers
```bash
docker-compose -f docker-compose.production.yml up -d
```

- [ ] Verify containers running: `docker ps`
  - [ ] pos_db (PostgreSQL)
  - [ ] pos_app (Flask application)
  - [ ] pos_nginx (Reverse proxy)
- [ ] Check logs: `docker logs pos_app` (should show no errors)

### Initialize Database
```bash
docker exec pos_app flask db upgrade
```

- [ ] Database migrations completed

### Create Admin User
```bash
docker exec -it pos_app flask shell
```

In Flask shell:
```python
from app.models import User
from app import db
admin = User(email='admin@yourdomain.lk', username='admin')
admin.set_password('your-secure-admin-password')
db.session.add(admin)
db.session.commit()
exit()
```

- [ ] Admin user created
- [ ] Saved admin credentials:
  - [ ] Email: `_________________`
  - [ ] Password: `_________________`

---

## ✅ Phase 5: Configure Domain

### Point DNS to Droplet
In your domain registrar (register.lk):
- [ ] Login to registrar
- [ ] Find your domain
- [ ] Go to DNS/Nameserver settings
- [ ] Add A Record:
  - [ ] Type: A
  - [ ] Name: @ (or blank)
  - [ ] Value: `your-droplet-ip`
  - [ ] TTL: 3600
- [ ] Save

### Verify DNS Propagation
```bash
nslookup yourdomain.lk
# Should show your Droplet IP
```

- [ ] DNS is resolving correctly
- [ ] **Wait 15-30 minutes for full propagation**

### Test HTTP Access
```bash
curl http://yourdomain.lk
# Should return HTML (no errors)
```

- [ ] HTTP access working

---

## ✅ Phase 6: Setup SSL/HTTPS

### Get SSL Certificate
```bash
bash setup_ssl.sh yourdomain.lk appuser
```

- [ ] SSL certificate obtained
- [ ] Nginx restarted with SSL

### Verify HTTPS
```bash
curl -I https://yourdomain.lk
# Should show: 200 OK
```

- [ ] HTTPS working
- [ ] SSL certificate valid

---

## ✅ Phase 7: Setup Backups

### Create Backup Script
```bash
bash -c 'chmod +x backup_db.sh'
crontab -e
# Add: 0 2 * * * /home/appuser/web_pos/backup_db.sh
```

- [ ] Backup script created
- [ ] Cron job configured (daily at 2 AM)
- [ ] First backup test: `bash backup_db.sh`

---

## ✅ Phase 8: Final Verification

### Access Your POS Application
- [ ] Open browser
- [ ] Go to: `https://yourdomain.lk`
- [ ] Login with admin credentials
- [ ] Test basic operations:
  - [ ] Create a company/shop
  - [ ] Add a product
  - [ ] Create a sale
  - [ ] View reports

### Check Monitoring
- [ ] DigitalOcean Dashboard → Your Droplet
  - [ ] CPU usage normal
  - [ ] Memory usage normal
  - [ ] Network activity normal

---

## ✅ Phase 9: Post-Deployment

### Security Setup
- [ ] Change root password
- [ ] Disable root SSH login
- [ ] Enable UFW firewall
- [ ] Configure fail2ban
- [ ] Regular security updates

### Monitoring
- [ ] Set up uptime monitoring (optional: UptimeRobot)
- [ ] Monitor disk space regularly
- [ ] Check logs weekly
- [ ] Review DigitalOcean metrics

### Backups
- [ ] Verify daily backups are running
- [ ] Test restore process monthly
- [ ] Keep backups synced to external storage (S3, etc.)

### Updates
- [ ] Update system: `sudo apt update && sudo apt upgrade`
- [ ] Update Docker images: `docker pull image-name`
- [ ] Update application code: `git pull`

---

## 🎉 SUCCESS!

Your POS System is now live at: `https://yourdomain.lk`

**Key Information:**
- **Domain:** `_________________`
- **Server IP:** `_________________`
- **Admin Email:** `_________________`
- **Backup Location:** `/home/appuser/web_pos/backups/`
- **Logs Location:** `/home/appuser/web_pos/logs/`

---

## 📞 Support & Troubleshooting

**Common Issues:**

1. **"Connection refused"**
   - Check if containers are running: `docker ps`
   - Restart: `docker restart pos_app`

2. **"SSL certificate error"**
   - Renew certificate: `sudo certbot renew`
   - Restart: `docker restart pos_nginx`

3. **"Database connection error"**
   - Check database container: `docker logs pos_db`
   - Verify .env credentials

4. **"Out of disk space"**
   - Check: `df -h`
   - Clean Docker: `docker system prune -a`

**Get Help:**
- Check logs: `docker logs pos_app`
- SSH into droplet and investigate
- Check DigitalOcean status page
- Contact DigitalOcean support (24/7)

---

## 📊 Monthly Maintenance

- [ ] Review DigitalOcean billing
- [ ] Check backup integrity
- [ ] Update application code
- [ ] Review security logs
- [ ] Test disaster recovery
- [ ] Upgrade Droplet if needed

---

**Happy selling! 🎊**
