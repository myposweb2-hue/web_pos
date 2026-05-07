#!/bin/bash
# SSL Certificate Setup Script
# Run this after DNS is propagated (20-30 minutes after registering domain)
# Usage: bash setup_ssl.sh yourdomain.lk

DOMAIN=$1
APP_USER=${2:-appuser}

if [ -z "$DOMAIN" ]; then
    echo "Usage: bash setup_ssl.sh yourdomain.lk"
    exit 1
fi

echo "=========================================="
echo "Setting up SSL for $DOMAIN"
echo "=========================================="

# Verify DNS is set up
echo "Checking DNS resolution..."
if ! nslookup $DOMAIN >/dev/null 2>&1; then
    echo "ERROR: Domain $DOMAIN is not resolving"
    echo "Please configure DNS pointing to this server's IP"
    exit 1
fi

echo "✓ DNS is set up correctly"
echo ""

# Stop nginx
echo "Stopping Nginx..."
docker exec pos_nginx nginx -s stop || true

# Get SSL certificate
echo "Obtaining SSL certificate from Let's Encrypt..."
certbot certonly --standalone \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --non-interactive \
    --agree-tos \
    -m admin@$DOMAIN

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to get SSL certificate"
    exit 1
fi

echo ""
echo "✓ SSL Certificate obtained successfully"
echo ""

# Update nginx config with domain
echo "Updating Nginx configuration..."
cd /home/$APP_USER/web_pos

# Replace domain in nginx config
sed -i "s|yourdomain.lk|$DOMAIN|g" nginx.production.conf

echo "Configuration updated with domain: $DOMAIN"
echo ""

# Restart containers
echo "Restarting containers..."
docker restart pos_nginx pos_app

# Verify SSL
echo ""
echo "Verifying SSL setup..."
sleep 2

RESPONSE=$(curl -I https://$DOMAIN 2>/dev/null | head -n1)
if [[ $RESPONSE == *"200"* ]] || [[ $RESPONSE == *"301"* ]] || [[ $RESPONSE == *"302"* ]]; then
    echo -e "${GREEN}✓ SSL is working correctly!${NC}"
    echo ""
    echo "Your site is now available at: https://$DOMAIN"
else
    echo "WARNING: SSL response was: $RESPONSE"
fi

# Set up auto-renewal
echo ""
echo "Setting up automatic SSL renewal..."
(crontab -l 2>/dev/null | grep -v "certbot renew"; echo "0 3 1 * * certbot renew --quiet && docker restart pos_nginx") | crontab -

echo "✓ Auto-renewal configured (runs monthly)"
echo ""
echo "=========================================="
echo "SSL Setup Complete!"
echo "=========================================="
echo ""
echo "Your POS is now live at: https://$DOMAIN"
echo ""
