# Build reverse proxy using NGINX
FROM nginx:latest

# Update repository list
RUN apt-get update

# Install Nano to debug
# RUN apt-get install -y nano

# Install Certbot dependencies and Certbot itself
RUN apt-get install -y certbot

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Recursively create directories for ACME challenge
RUN mkdir -p /var/www/html

# Copy NGINX configuration files over to image
COPY ./Conf/nginx.init.conf ./Conf/nginx.conf /usr/share/nginx

# Entrypoint script to start NGINX and Certbot
COPY ./Scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# Make script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose HTTP and HTTPS ports
EXPOSE 80
EXPOSE 443

# Execute it
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]