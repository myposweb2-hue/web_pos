#!/bin/bash

# SSL Setup Script for Let's Encrypt on DigitalOcean
# Usage: bash setup-ssl.sh yourdomain.lk

set -e

DOMAIN=${1:-"104.248.156.207"}
EMAIL=${2:-"admin@yourdomain.lk"}

echo "=== Installing Certbot and dependencies ==="
apt-get update
apt-get install -y certbot python3-certbot-nginx

echo "=== Obtaining SSL certificate for $DOMAIN ==="
certbot certonly --standalone -d $DOMAIN --email $EMAIL --agree-tos --non-interactive --force-renewal

echo "=== Certificate obtained at: /etc/letsencrypt/live/$DOMAIN/ ==="

echo "=== Updating nginx configuration for HTTPS ==="
# Backup original nginx.conf
cp /home/appuser/web_pos/nginx.conf /home/appuser/web_pos/nginx.conf.bak

# Create new nginx.conf with SSL support
cat > /home/appuser/web_pos/nginx.conf << 'EOF'
events { worker_connections 1024; }

http {
  # HTTP redirect to HTTPS
  server {
    listen 80;
    server_name _;
    return 301 https://$host$request_uri;
  }

  # HTTPS server
  server {
    listen 443 ssl http2;
    server_name _;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/DOMAIN/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Static files
    location /static/ {
      alias /app/app/static/;
      expires 30d;
      add_header Cache-Control "public, immutable";
    }

    # Proxy to Flask app
    location / {
      proxy_pass http://web:5000;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_redirect off;
    }
  }
}
EOF

# Replace DOMAIN placeholder
sed -i "s|DOMAIN|$DOMAIN|g" /home/appuser/web_pos/nginx.conf

echo "=== Nginx configuration updated ==="
echo "=== Restarting nginx container ==="
cd /home/appuser/web_pos
docker-compose restart nginx

echo ""
echo "=== SSL Setup Complete! ==="
echo "Your application is now available at:"
echo "  https://$DOMAIN"
echo ""
echo "Certificate details:"
echo "  Issuer: Let's Encrypt"
echo "  Certificate path: /etc/letsencrypt/live/$DOMAIN/fullchain.pem"
echo "  Key path: /etc/letsencrypt/live/$DOMAIN/privkey.pem"
echo ""
echo "Certificate will auto-renew. To manually renew:"
echo "  certbot renew"
echo ""
