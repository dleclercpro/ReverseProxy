#!/bin/bash

# Get the directory containing the script
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define image variables
user="dleclercpro"
app="ssl-reverse-proxy"
release="v1.0.0"

# Build a cross-platform image and push it to Dockerhub
docker buildx build --platform linux/amd64,linux/arm64 -t $user/$app:$release -f ./Dockerfile . --push