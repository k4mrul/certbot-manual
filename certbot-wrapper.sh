#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: certbot-wrapper.sh <domain>"
  exit 1
fi

DOMAIN="$1"

certbot certonly \
  --manual \
  --preferred-challenges http \
  --manual-auth-hook ./certbot.sh \
  --manual-cleanup-hook ./cleanup-host.sh \
  --agree-tos \
  --register-unsafely-without-email \
  --non-interactive \
  --deploy-hook true \
  -d "$DOMAIN"
