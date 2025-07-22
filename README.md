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

### How It Works
1. For multi-region secret deployment, make sure to include the kubeconfig files (`kube-eu.yaml`, `kube-sg.yaml`, `kube-us.yaml`) in the pod (see main-deployment.yaml file). These files are required by the deploy hook to update secrets in each cluster.
2. Create directory for saving certs `mkdir -p /home/ubuntu/live-certs`
3. Deploy the Kubernetes resources using `main-deployment.yaml` in your main region (exm: SG).
4. The pod starts Nginx and a cron daemon for scheduled certificate renewals.
5. To issue a certificate, exec into the pod and run `get-cert <your-domain>`. Or simply `kubectl exec -it deploy/ssl-generation -- get-cert <domain>`
6. Certbot uses manual hooks to complete the HTTP challenge and obtain the certificate.
7. Every 7 days, the cron job runs `certbot renew`. If any certificates are renewed, the deploy hook script updates the secrets in all clusters.

