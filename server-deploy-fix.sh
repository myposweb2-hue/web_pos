#!/bin/bash
# Deploy fix script - run on server to fix git merge and rebuild

set -e  # Exit on error

cd /home/appuser/web_pos

echo "=== Fixing git state ==="
# Remove any untracked requirements.txt
rm -f requirements.txt

# Hard reset to known good state 
git reset --hard HEAD

# Clean any other untracked files
git clean -fd

echo "=== Pulling latest code ==="
git pull origin main

echo "=== Stopping old containers ==="
docker-compose down --remove-orphans

echo "=== Building and starting containers ==="
docker-compose up -d --build

echo "=== Waiting for app to start ==="
sleep 15

echo "=== Checking container status ==="
docker-compose ps

echo "=== Getting recent import endpoint logs ==="
docker logs pos_app 2>&1 | grep -A 5 "Products import error" | tail -20 || echo "(No previous import error logs yet)"

echo "=== Testing health ==="
curl -s http://localhost:5000/ 2>&1 | head -c 200 && echo "" || echo "Health check not ready"

echo "=== DONE ==="
echo "Deploy URL: http://104.248.156.207"
