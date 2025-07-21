
FROM nginx:alpine


# Install dependencies
RUN apk add --no-cache curl bash vim


# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl


# Install certbot
RUN apk add --no-cache certbot


# Set default command to run nginx
CMD ["nginx", "-g", "daemon off;"]