# NGINX Reverse Proxy with SSL Setup

## Summary
This repository contains a Dockerized NGINX setup designed for secure web applications. It features an NGINX reverse proxy with SSL/TLS certificate management via Let's Encrypt and Certbot, ensuring encrypted HTTPS connections. Ideal for applications that require secure and efficient handling of web traffic, it also offers robust security configurations and ease of deployment.

## Features
- **NGINX Reverse Proxy**: Forwards requests to other servers or services efficiently.
- **Automatic SSL/TLS Certificates**: Utilizes Certbot for Let's Encrypt certificate management.
- **HTTP to HTTPS Redirection**: Redirects all HTTP traffic to secure HTTPS.
- **Enhanced Security**: Implements HSTS, OCSP Stapling, and strong SSL configurations.
- **Docker and Docker Compose Support**: Containerized for consistency and ease of deployment.

## How to Run
1. **Clone the Repository**:
```
git clone [repository-url]
```

2. **Set Environment Variables**:
Set the following environment variables in a `.env` file:
- `DOMAIN`: Your domain name.
- `EMAIL`: Your email for Let's Encrypt notifications.
- `PROXY_URL`: The URL where NGINX will forward requests.

3. **Using Docker Compose**:
- **Docker Compose Setup**:
  Ensure Docker Compose is installed and use the provided `docker-compose.yml` file.
- **Running with Docker Compose**:
  ```
  docker-compose up -d
  ```

4. **Alternatively, Build and Run with Docker**:
- **Build Docker Image**:
  ```
  docker build -t nginx-reverse-proxy .
  ```
- **Run Docker Container**:
  ```
  docker run -d -p 80:80 -p 443:443 --env DOMAIN=[your-domain] --env EMAIL=[your-email] --env PROXY_URL=[your-proxy-url] nginx-reverse-proxy
  ```

5. **Verify Operation**:
Check the functioning of NGINX, automatic redirection to HTTPS, and proxy forwarding.

## Customizing Configuration
Modify NGINX configurations in `Conf` and update `Scripts/entrypoint.sh` for custom logic or certificate management.