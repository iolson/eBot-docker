#!/usr/bin/env bash

red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'

printf "$green" "eBot configuration script"

source .env

# ── eBot Web (Laravel .env) ───────────────────────────────────────────────────
echo "Generating ./etc/eBotWeb/.env"
[ -f ./etc/eBotWeb/.env ] && cp ./etc/eBotWeb/.env ./etc/eBotWeb/.env.bak

cat > ./etc/eBotWeb/.env << WEBENV
APP_NAME="eBot CS2 Web"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://${EBOT_IP}
APP_INSTALLED=false

LOG_CHANNEL=stack
LOG_LEVEL=warning

DB_CONNECTION=mysql
DB_HOST=mysqldb
DB_PORT=3306
DB_DATABASE=${MYSQL_DATABASE}
DB_USERNAME=${MYSQL_USER}
DB_PASSWORD=${MYSQL_PASSWORD}

SESSION_DRIVER=database
SESSION_LIFETIME=120
QUEUE_CONNECTION=database
CACHE_STORE=database

REDIS_CLIENT=phpredis
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

EBOT_IP=${EBOT_IP}
EBOT_PORT=12360
EBOT_WEBSOCKET_URL=${EBOT_WEBSOCKET_URL}
EBOT_WEBSOCKET_SECRET_KEY=${EBOT_WEBSOCKET_SECRET_KEY}

EBOT_LOG_MATCH_PATH=/app/ebot-logs/log_match
EBOT_LOG_MATCH_ADMIN_PATH=/app/ebot-logs/log_match_admin
EBOT_DEMO_PATH=/app/ebot-demos

EBOT_MODE=${EBOT_MODE:-net}
EBOT_DEMO_DOWNLOAD=${EBOT_DEMO_DOWNLOAD:-true}
EBOT_REFRESH_TIME=${EBOT_REFRESH_TIME:-30}
WEBENV

# ── eBot Socket (config.ini) ──────────────────────────────────────────────────
echo "Patching ./etc/eBotSocket/config.ini"
cp ./etc/eBotSocket/config.ini ./etc/eBotSocket/config.ini.bak
sed -i "s/MYSQL_IP =.*/MYSQL_IP = \"mysqldb\"/g" ./etc/eBotSocket/config.ini
sed -i "s/MYSQL_PASS =.*/MYSQL_PASS = \"$MYSQL_PASSWORD\"/g" ./etc/eBotSocket/config.ini
sed -i "s/MYSQL_BASE =.*/MYSQL_BASE = \"$MYSQL_DATABASE\"/g" ./etc/eBotSocket/config.ini
sed -i "s/COMMAND_STOP_DISABLED =.*/COMMAND_STOP_DISABLED = $COMMAND_STOP_DISABLED/g" ./etc/eBotSocket/config.ini
sed -i "s#LOG_ADDRESS_SERVER =.*#LOG_ADDRESS_SERVER = \"$LOG_ADDRESS_SERVER\"#g" ./etc/eBotSocket/config.ini
sed -i "s/WEBSOCKET_SECRET_KEY =.*/WEBSOCKET_SECRET_KEY = \"$EBOT_WEBSOCKET_SECRET_KEY\"/g" ./etc/eBotSocket/config.ini
sed -i "s/REDIS_HOST =.*/REDIS_HOST = \"redis\"/g" ./etc/eBotSocket/config.ini
sed -i "s/BOT_IP =.*/BOT_IP = \"0.0.0.0\"/g" ./etc/eBotSocket/config.ini
