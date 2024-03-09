#!/bin/bash

# Required environment variables
required_vars=("DOMAIN" "EMAIL" "PROXY_URL")

# Check if all required environment variables are set
echo "Ensuring environment variables exist..."

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Environment variable $var is not set."
        exit 1
    else
        echo "$var: ${!var}"
    fi
done

echo "All necessary environment variables exist."




# -------------------------------------------------- PARAMETERS ------------------------------------------------ #
# NGINX
NGINX_CONF_DIR="/etc/nginx"
NGINX_CONF_TEMPLATE_DIR="/usr/share/nginx"
NGINX_INIT_CONF_TEMPLATE_FILE="$NGINX_CONF_TEMPLATE_DIR/nginx.init.conf" # Initial NGINX config template
NGINX_FINAL_CONF_TEMPLATE_FILE="$NGINX_CONF_TEMPLATE_DIR/nginx.conf"     # Final NGINX config template
NGINX_CONF_FILE="$NGINX_CONF_DIR/nginx.conf"                             # Configuration file loaded by NGINX

# Let's Encrypt
LE_DIR="/etc/letsencrypt"
LE_WEBROOT_DIR="/var/www/html"                                           # ACME challenge directory
LE_CERTS_DIR="$LE_DIR/live/$DOMAIN"                                      # Live location of SSL certificates

# Diffie-Hellman parameters
DH_PARAMS_DIR="/usr/dhparams"                                            # Directory for storing DH parameters
DH_PARAMS_FILE="$DH_PARAMS_DIR/dhparam.pem"                              # DH parameters file path
DH_PARAMS_SIZE=2048                                                      # Key size (# of bits) - increased to 2048 for better security

# -------------------------------------------------------------------------------------------------------------- #




# Function to reload final NGINX conf (w/ HTTPS), if valid
reload_conf() {
    echo "Testing NGINX config..."
    if ! nginx -t -c "$NGINX_CONF_FILE"; then
        echo "Warning: NGINX config test failed, exiting..."
        exit 1
    fi

    echo "Re-loading NGINX config..."
    nginx -s reload
}



# Function to generate initial NGINX configuration file
generate_init_conf() {
    echo "Generating initial NGINX config file..."

    sed -e "s|{{DOMAIN}}|$DOMAIN|g" \
        -e "s|{{LE_WEBROOT_DIR}}|$LE_WEBROOT_DIR|g" \
        "$NGINX_INIT_CONF_TEMPLATE_FILE" > "$NGINX_CONF_FILE"

    echo "Initial NGINX config file generated."
}


# Function to generate final NGINX configuration file
generate_final_conf() {
    echo "Generating final NGINX config file..."

    sed -e "s|{{DOMAIN}}|$DOMAIN|g" \
        -e "s|{{PROXY_URL}}|$PROXY_URL|g" \
        -e "s|{{LE_WEBROOT_DIR}}|$LE_WEBROOT_DIR|g" \
        -e "s|{{LE_CERTS_DIR}}|$LE_CERTS_DIR|g" \
        -e "s|{{DH_PARAMS_DIR}}|$DH_PARAMS_DIR|g" \
        "$NGINX_FINAL_CONF_TEMPLATE_FILE" > "$NGINX_CONF_FILE"

    echo "Final NGINX config file generated."
}


# Function to check and generate Diffie-Hellman parameters
check_and_generate_dh_params() {
    if [ ! -f "$DH_PARAMS_FILE" ]; then
        echo "Diffie-Hellman parameters file does not exist, generating..."
        mkdir -p "$DH_PARAMS_DIR"
        openssl dhparam -out "$DH_PARAMS_FILE" $DH_PARAMS_SIZE
    else
        echo "Diffie-Hellman parameters file already exists, skipping generation."
    fi
}


# Function to renew certificates
renew_ssl_certs() {
    echo "Renewing SSL certificates..."

    certbot renew

    echo "SSL certificates renewed."
}


# Function to obtain an initial SSL certificate
generate_ssl_certs() {
    echo "Obtaining SSL certificates..."

    certbot certonly \
        --non-interactive --agree-tos \
        --webroot --webroot-path="$LE_WEBROOT_DIR" \
        -d "$DOMAIN" --email "$EMAIL"

    echo "SSL certificates obtained."
}


# Generate initial configuration
generate_init_conf

# Start NGINX with the initial configuration
nginx -g "daemon off;" -c "$NGINX_CONF_FILE" &

# Wait for a brief moment to ensure NGINX is up
sleep 5

# Check and generate Diffie-Hellman parameters
check_and_generate_dh_params

# Obtain SSL certificate
generate_ssl_certs

# Generate final NGINX configuration file and load it
generate_final_conf
reload_conf

# Schedule SSL certificate renewal every day
while :; do
    sleep 1d

    renew_ssl_certs
    reload_conf
done