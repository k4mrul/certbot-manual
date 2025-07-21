#!/bin/bash

#set -e

# Certbot-provided environment variables
DOMAIN="${CERTBOT_DOMAIN}"
TOKEN="${CERTBOT_TOKEN}"
WEBROOT="/usr/share/nginx/html"
CHALLENGE_DIR="${WEBROOT}/.well-known/acme-challenge"
CHALLENGE_FILE="${CHALLENGE_DIR}/${TOKEN}"
RESOURCE_NAME=$(echo "$DOMAIN" | tr '.' '-')


if [ -f "$CHALLENGE_FILE" ]; then
    echo "[INFO] Deleting challenge file: $CHALLENGE_FILE"
    rm -f "$CHALLENGE_FILE"
    echo "[INFO] Challenge file deleted."
else
    echo "[INFO] Challenge file does not exist: $CHALLENGE_FILE"
fi

# Loop through kubeconfig files and delete resources
for KUBECONFIG in kube-eu.yaml kube-us.yaml; do
  CLUSTER_NAME=$(echo "$KUBECONFIG" | sed 's/\.yaml$//' | sed 's/kube-//')
  echo "[INFO] Deleting resources from remote cluster ($CLUSTER_NAME)..."
  kubectl delete service ${RESOURCE_NAME}-verify  -n default --kubeconfig="$KUBECONFIG" || true
  kubectl delete ingress ${RESOURCE_NAME}-verify-ingress -n default --kubeconfig="$KUBECONFIG" || true
  echo "[INFO] Resources deleted from remote cluster ($CLUSTER_NAME)."
done