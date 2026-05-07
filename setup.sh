#!/bin/bash
# Quick Deployment Script for DigitalOcean
# Run this after SSH into your droplet: bash setup.sh

set -e

echo "=========================================="
echo "POS System - DigitalOcean Setup Script"
echo "=========================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Update System
echo -e "${YELLOW}[1/7] Updating system...${NC}"
apt update && apt upgrade -y

# 2. Set Timezone
echo -e "${YELLOW}[2/7] Setting timezone to Asia/Colombo...${NC}"
timedatectl set-timezone Asia/Colombo

# 3. Create Application User
echo -e "${YELLOW}[3/7] Creating application user...${NC}"
if id "appuser" >/dev/null 2>&1; then
    echo "appuser already exists"
else
    useradd -m -s /bin/bash appuser
    usermod -aG sudo appuser
fi

# 4. Install Docker
echo -e "${YELLOW}[4/7] Installing Docker...${NC}"
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# 5. Install Docker Compose
echo -e "${YELLOW}[5/7] Installing Docker Compose...${NC}"
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 6. Add appuser to docker group
echo -e "${YELLOW}[6/7] Configuring Docker permissions...${NC}"
usermod -aG docker appuser

# 7. Install SSL Tools
echo -e "${YELLOW}[7/7] Installing SSL certificate tools...${NC}"
apt install -y certbot python3-certbot-nginx git

echo ""
echo -e "${GREEN}=========================================="
echo "✓ Setup Complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Switch to appuser: su - appuser"
echo "2. Clone your repository: git clone <your-repo-url>"
echo "3. Create .env file with configuration"
echo "4. Run: docker-compose -f docker-compose.production.yml up -d"
echo "5. Configure DNS: Point your domain to $(hostname -I | awk '{print $1}')"
echo ""
