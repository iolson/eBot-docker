# eBot Docker

## Overview

Containerized eBot CS2 match server — a full managed server-bot with easy match creation and detailed player/match statistics. Orchestrates:

- **eBot CS2 Web** — Laravel 12 / PHP 8.4 web admin panel
- **eBot Socket** — Node.js + PHP match control server
- **eBot Log Receiver** — Node.js UDP log receiver
- MySQL 8.4, Redis 7, Nginx

## Setup

```bash
cp .env.sample .env
chmod a+x setup.sh configure.sh
./setup.sh
docker compose build
docker compose up
```

`setup.sh` walks you through configuring `.env` (IPs, passwords, admin account).
`configure.sh` generates `etc/eBotWeb/.env` and patches `etc/eBotSocket/config.ini`.

If you change `.env` later, re-run `./configure.sh` before restarting containers.

## Configuration

All settings live in `.env`. Key variables:

| Variable | Description |
|---|---|
| `EBOT_IP` | Public/LAN IP of this server |
| `EBOT_WEBSOCKET_URL` | WebSocket URL for the browser (e.g. `http://IP:12360`) |
| `EBOT_WEBSOCKET_SECRET_KEY` | Shared JWT secret (web ↔ socket) |
| `LOG_ADDRESS_SERVER` | UDP address CS2 servers send logs to (e.g. `udp://IP:12345`) |
| `EBOT_ADMIN_*` | Admin account created on first run |
| `MYSQL_*` | Database credentials |

## Ports

| Port | Protocol | Service |
|---|---|---|
| 80, 443 | TCP | Nginx (web UI) |
| 12360 | TCP | eBot Socket (WebSocket) |
| 12345 | UDP | Log Receiver (CS2 server logs) |

## Security

Set strong unique values for `EBOT_WEBSOCKET_SECRET_KEY`, `MYSQL_PASSWORD`, and `MYSQL_ROOT_PASSWORD` in `.env`. The setup script can generate these randomly.

## SSL

SSL termination is handled externally. Configure a reverse proxy (e.g. Nginx + Let's Encrypt) in front of the web UI and the WebSocket server. Set `EBOT_WEBSOCKET_URL` to your `wss://` or `https://` address during setup.
