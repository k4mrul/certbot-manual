Provides an automated solution for managing SSL/TLS certificates using Certbot in a Kubernetes environment. It is designed to simplify the process of issuing, renewing, and deploying certificates for multiple domains across different clusters. It is an alternative of cert-manager, designed for multi-cluster environment

### Features

- **Automated Certificate Issuance:**
  - Uses Certbot with manual HTTP challenge hooks to issue certificates for specified domains.
  - Custom scripts (`certbot.sh` and `cleanup-host.sh`) handle the authentication and cleanup steps required by Certbot's manual challenge process.

- **Easy Certificate Renewal:**
  - A cron job is set up to automatically run `certbot renew` every 7 days, ensuring certificates remain valid.
  - Renewal events trigger a deploy hook (`deploy-hook.sh`) that applies the renewed certificates as Kubernetes secrets to multiple clusters.

- **Multi-Cluster Deployment:**
  - After renewal, the deploy hook script updates secrets in all configured clusters (EU, SG, US) using their respective kubeconfig files.

- **Simple Domain Management:**
  - The `certbot-wrapper.sh` and `get-cert` command allow you to request certificates for any domain with a single command inside the pod.

- **Nginx Integration:**
  - Nginx runs in the foreground, serving HTTP challenges and keeping the pod alive for certificate operations.

### Pre-requisite
- Make sure to set `ssl-redirect` [false in ingress nginx](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#ssl-redirect) globally
-  Point the [ExternalName](https://github.com/k4mrul/certbot-manual/blob/main/certbot.sh#L21) domain to the IP address of your main cluster. You need to re-build the docker image

### How It Works
 - Create a directory for saving certificates: `mkdir -p /home/ubuntu/ssl-certs` in main/SG cluster.
 - In your main cluster, create a secret for each region's kubeconfig file (`kube-eu.yaml`, `kube-sg.yaml`, `kube-us.yaml`):
   `kubectl create secret generic kube-sg --from-file=kube-sg.yaml -n default`
   (Apply similar steps for other regions.)
   Mount these secrets and the main deployment file (`main-deployment.yaml`) and apply only in the main/SG cluster. The kubeconfig files are used by the deploy hook to update secrets across all clusters.
 - The pod starts Nginx (serving HTTP challenges) and a cron daemon for scheduled certificate renewals.
 - To issue a certificate, exec into the pod and run `get-cert <your-domain>`, or use: `kubectl exec -it deploy/ssl-generation -- get-cert <domain>`
 - Certbot uses manual hooks to complete the HTTP challenge and obtain the certificate.
 - Every 7 days, the cron job runs `certbot renew`. If any certificates are renewed, the deploy hook script updates the secrets in all clusters using the mounted kubeconfig files.

