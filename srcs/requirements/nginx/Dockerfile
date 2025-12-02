FROM debian:bullseye

# Install NGINX and OpenSSL from Debian repositories
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create directory for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=wil.42.fr/UID=ayoub"

# Copy NGINX configuration
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Expose 443 (HTTPS)
EXPOSE 443

# Start NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]
