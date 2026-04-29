#!/usr/bin/env bash

red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'

function yesNo() {
    while true; do
        read -p "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

function ask_with_default() {
    local prompt="$1"
    local default_value="$2"

    read -p "${prompt} [current: ${default_value}]: " input_value
    if [[ -z "$input_value" ]]; then
        echo "$default_value"
    else
        echo "$input_value"
    fi
}

function generatePassword() {
    openssl rand -hex 16
}

printf "$green" "eBot setup script"
printf "This script configures the .env file. Run ./configure.sh afterwards (or accept below).\r\n"

cp .env .env.bak

if yesNo "Generate a new random WebSocket secret key?"
then
    NEW_WEBSOCKET_SECRET_KEY=$(generatePassword)
    sed -i -e "s#EBOT_WEBSOCKET_SECRET_KEY=.*#EBOT_WEBSOCKET_SECRET_KEY=${NEW_WEBSOCKET_SECRET_KEY}#g" \
        "$(dirname "$0")/.env"
fi

if yesNo "Generate new random MySQL passwords?"
then
    NEW_MYSQL_ROOT_PASSWORD=$(generatePassword)
    NEW_MYSQL_PASSWORD=$(generatePassword)
    sed -i -e "s#MYSQL_ROOT_PASSWORD=.*#MYSQL_ROOT_PASSWORD=${NEW_MYSQL_ROOT_PASSWORD}#g" \
        -e "s#MYSQL_PASSWORD=.*#MYSQL_PASSWORD=${NEW_MYSQL_PASSWORD}#g" \
        "$(dirname "$0")/.env"
fi

source .env

printf "$green" "Configuring eBot Web admin account"

EBOT_ADMIN_LOGIN=$(ask_with_default "Admin username" $EBOT_ADMIN_LOGIN)
EBOT_ADMIN_PASSWORD=$(ask_with_default "Admin password" $EBOT_ADMIN_PASSWORD)
EBOT_ADMIN_EMAIL=$(ask_with_default "Admin email" $EBOT_ADMIN_EMAIL)

sed -i -e "s#EBOT_ADMIN_LOGIN=.*#EBOT_ADMIN_LOGIN=${EBOT_ADMIN_LOGIN}#g" \
    -e "s#EBOT_ADMIN_PASSWORD=.*#EBOT_ADMIN_PASSWORD=${EBOT_ADMIN_PASSWORD}#g" \
    -e "s#EBOT_ADMIN_EMAIL=.*#EBOT_ADMIN_EMAIL=${EBOT_ADMIN_EMAIL}#g" \
    "$(dirname "$0")/.env"

printf "$green" "Configuring network addresses"
echo "The CS2 server sends logs via UDP to the log receiver (port 12345 by default)."
echo "This address must be reachable from your CS2 game servers."
echo "Format: udp://PUBLIC_IP:12345  (e.g. udp://123.123.123.123:12345)"
LOG_ADDRESS_SERVER=$(ask_with_default "Log address server" $LOG_ADDRESS_SERVER)

sed -i -e "s#LOG_ADDRESS_SERVER=.*#LOG_ADDRESS_SERVER=${LOG_ADDRESS_SERVER}#g" \
    "$(dirname "$0")/.env"

echo ""
echo "Enter the IP address of this server (public or LAN) where eBot will run."
echo "This is used for the WebSocket connection from the browser to eBot Socket."
EBOT_IP=$(ask_with_default "Server IP" $EBOT_IP)
sed -i -e "s#EBOT_IP=.*#EBOT_IP=${EBOT_IP}#g" \
    "$(dirname "$0")/.env"

echo ""
echo "eBot supports SSL. Configure your SSL termination externally (e.g. Let's Encrypt + reverse proxy)."
if yesNo "Will you be using SSL for the WebSocket?"
then
    EBOT_WEBSOCKET_URL=$(ask_with_default "WebSocket URL (e.g. wss://yourdomain.com)" $EBOT_WEBSOCKET_URL)
    sed -i -e "s#EBOT_WEBSOCKET_URL=.*#EBOT_WEBSOCKET_URL=${EBOT_WEBSOCKET_URL}#g" \
        "$(dirname "$0")/.env"
    echo "Don't forget to create a reverse proxy for the WebSocket server (port 12360)."
    sleep 3
else
    NEW_WS_URL="http://${EBOT_IP}:12360"
    sed -i -e "s#EBOT_WEBSOCKET_URL=.*#EBOT_WEBSOCKET_URL=${NEW_WS_URL}#g" \
        "$(dirname "$0")/.env"
fi

if yesNo "Regenerate all configuration files now?"
then
    ./configure.sh
fi
