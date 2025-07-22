#!/bin/bash
set -e

echo "0 0 */7 * * certbot renew --quiet --deploy-hook /update-secrets.sh" > /etc/crontabs/root
crond
nginx -g 'daemon off;'
