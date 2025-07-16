#!/bin/bash

set -e

# Certbot-provided environment variables
DOMAIN="${CERTBOT_DOMAIN}"
VALIDATION="${CERTBOT_VALIDATION}"
TOKEN="${CERTBOT_TOKEN}"

# Paths
NGINX_CONF="/etc/nginx/sites-available/${DOMAIN}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${DOMAIN}"
WEBROOT="/var/www/html"
CHALLENGE_DIR="${WEBROOT}/.well-known/acme-challenge"
CHALLENGE_FILE="${CHALLENGE_DIR}/${TOKEN}"  # Changed: file name is now the token

echo "[INFO] Starting Certbot manual-auth-hook for domain: $DOMAIN"

# Step 1: Create NGINX config if it doesn't exist
if [ ! -f "$NGINX_CONF" ]; then
    echo "[INFO] Creating NGINX config at $NGINX_CONF"
    sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    root ${WEBROOT};
    index index.html;
}
EOF
fi

# Step 2: Enable the site if not yet linked
if [ ! -L "$NGINX_ENABLED" ]; then
    echo "[INFO] Enabling site by linking config"
    sudo ln -s "$NGINX_CONF" "$NGINX_ENABLED"
    echo "[INFO] Reloading NGINX"
    sudo systemctl reload nginx
fi

# Step 3: Create challenge directory and file
echo "[INFO] Creating challenge directory: $CHALLENGE_DIR"
sudo mkdir -p "$CHALLENGE_DIR"

# Debug output
echo "[DEBUG] CERTBOT_VALIDATION = ${VALIDATION}"
echo "[DEBUG] CERTBOT_TOKEN      = ${TOKEN}"
echo "[INFO] Writing challenge file:"
echo "[INFO]   Filename: $CHALLENGE_FILE"
echo "[INFO]   Content : ${VALIDATION}"
echo "${VALIDATION}" | sudo tee "$CHALLENGE_FILE" > /dev/null

echo "[INFO] Manual auth hook complete."
