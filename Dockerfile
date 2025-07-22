
FROM nginx:alpine


# Install dependencies
RUN apk add --no-cache curl bash vim
# Install crond for scheduled tasks
RUN apk add --no-cache cronie


# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl


# Install certbot
RUN apk add --no-cache certbot

# Copy scripts into the container
# certbot.sh: Used as manual auth hook for certbot
COPY certbot.sh /certbot.sh
# cleanup-host.sh: Used as manual cleanup hook for certbot
COPY cleanup-host.sh /cleanup-host.sh
# certbot-wrapper.sh: Simplifies certbot command for domain issuance
COPY certbot-wrapper.sh /certbot-wrapper.sh
# deploy-hook.sh: Runs after certbot successfully renews a certificate
COPY deploy-hook.sh /deploy-hook.sh
# start.sh: Entrypoint script to start cron and nginx
COPY start.sh /start.sh
# Make scripts executable
RUN chmod +x /certbot.sh /cleanup-host.sh /certbot-wrapper.sh /start.sh /deploy-hook.sh

# Create a symlink for easier access
RUN ln -s /certbot-wrapper.sh /usr/local/bin/get-cert

# Start both cron and nginx
CMD ["/start.sh"]