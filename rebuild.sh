#!/bin/bash
cd /home/appuser/web_pos
git pull origin main
docker-compose down -v
docker image rm web_pos_web -f
docker-compose build web --no-cache
docker-compose up -d
sleep 10
docker ps
docker logs pos_app 2>&1 | tail -20
