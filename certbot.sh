#!/bin/bash


# Certbot-provided environment variables
DOMAIN="${CERTBOT_DOMAIN}"
VALIDATION="${CERTBOT_VALIDATION}"
TOKEN="${CERTBOT_TOKEN}"

# Sanitize domain for resource names
RESOURCE_NAME=$(echo "$DOMAIN" | tr '.' '-')

# Store the manifest in a heredoc variable for readability
read -r -d '' MANIFEST <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${RESOURCE_NAME}-verify
  namespace: default
spec:
  type: ExternalName
  externalName: sg.ondokan.com
  ports:
    - port: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${RESOURCE_NAME}-verify-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /.well-known/acme-challenge/\$2
spec:
  ingressClassName: nginx
  rules:
    - host: ${DOMAIN}
      http:
        paths:
          - path: /.well-known/acme-challenge(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${RESOURCE_NAME}-verify
                port:
                  number: 80
EOF

# Loop through kubeconfig files and apply manifest
for KUBECONFIG in kube-eu.yaml kube-us.yaml; do
  CLUSTER_NAME=$(echo "$KUBECONFIG" | sed 's/\.yaml$//' | sed 's/kube-//')
  echo "[INFO] Applying domain verification manifest to remote cluster ($CLUSTER_NAME)..."
  kubectl apply -n default --kubeconfig="$KUBECONFIG" -f <(echo "$MANIFEST") || true
  echo "[INFO] Manifest applied to remote cluster ($CLUSTER_NAME)."
done

sleep 20


# Paths
WEBROOT="/usr/share/nginx/html"
CHALLENGE_DIR="${WEBROOT}/.well-known/acme-challenge"
CHALLENGE_FILE="${CHALLENGE_DIR}/${TOKEN}" 

echo "[INFO] Starting Certbot manual-auth-hook for domain: $DOMAIN"


# Check if the webroot directory exists
echo "[INFO] Creating challenge directory: $CHALLENGE_DIR"
mkdir -p "$CHALLENGE_DIR"

# Debug output
echo "[DEBUG] CERTBOT_VALIDATION = ${VALIDATION}"
echo "[DEBUG] CERTBOT_TOKEN      = ${TOKEN}"
echo "[INFO] Writing challenge file:"
echo "[INFO]   Filename: $CHALLENGE_FILE"
echo "[INFO]   Content : ${VALIDATION}"
echo "${VALIDATION}" | tee "$CHALLENGE_FILE" > /dev/null

sleep 2
