#!/bin/bash

set -e

# Certbot-provided environment variables
TOKEN="${CERTBOT_TOKEN}"
WEBROOT="/var/www/html"
CHALLENGE_DIR="${WEBROOT}/.well-known/acme-challenge"
CHALLENGE_FILE="${CHALLENGE_DIR}/${TOKEN}"

if [ -f "$CHALLENGE_FILE" ]; then
    echo "[INFO] Deleting challenge file: $CHALLENGE_FILE"
    sudo rm -f "$CHALLENGE_FILE"
    echo "[INFO] Challenge file deleted."
else
    echo "[INFO] Challenge file does not exist: $CHALLENGE_FILE"
fi
