#!/bin/bash

# Certbot-provided environment variables
DOMAIN="${RENEWED_LINEAGE##*/}"

# Sanitize domain for resource names
RESOURCE_NAME=$(echo "$DOMAIN" | tr '.' '-')

echo "[INFO] Certificate successfully issued for domain: $DOMAIN"
echo "[INFO] Deploying certificate to Kubernetes clusters..."

# Loop through kubeconfig files and apply secrets
for KUBECONFIG in kube-eu.yaml kube-sg.yaml kube-us.yaml; do
  if [ -f "$KUBECONFIG" ]; then
    CLUSTER_NAME=$(echo "$KUBECONFIG" | sed 's/\.yaml$//' | sed 's/kube-//')
    echo "[INFO] Applying ssl cert ($CLUSTER_NAME)..."
    kubectl create -n default secret tls ${RESOURCE_NAME}-certificate3 \
      --cert="${RENEWED_LINEAGE}/fullchain.pem" \
      --key="${RENEWED_LINEAGE}/privkey.pem" \
      --kubeconfig="$KUBECONFIG" || true      
  else
    echo "[WARN] Kubeconfig file not found: $KUBECONFIG"
  fi
done

echo "[INFO] Certificate deployment complete!"