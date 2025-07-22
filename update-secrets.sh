#!/bin/bash

# Loop through each renewed domain
for DOMAIN in $RENEWED_DOMAINS; do
  RESOURCE_NAME=$(echo "$DOMAIN" | tr '.' '-')
  
  # Loop through kubeconfig files and apply secrets for each domain
  for KUBECONFIG in kube-eu.yaml kube-sg.yaml kube-us.yaml; do
    CLUSTER_NAME=$(echo "$KUBECONFIG" | sed 's/\.yaml$//' | sed 's/kube-//')
    echo "[INFO] Applying ssl cert for $DOMAIN ($CLUSTER_NAME)..."
    kubectl apply -n default secret tls ${RESOURCE_NAME}-certificate3 --cert=/etc/letsencrypt/live/${DOMAIN}/fullchain.pem --key=/etc/letsencrypt/live/${DOMAIN}/privkey.pem --kubeconfig="$KUBECONFIG" || true
  done
done