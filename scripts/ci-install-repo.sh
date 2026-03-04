#!/bin/bash
# CI script to install k8s-tools repository
# Usage: ./ci-install-repo.sh [--deb822]

set -e

USE_DEB822=false
if [ "$1" = "--deb822" ]; then
    USE_DEB822=true
fi

echo "Installing K8s Tools repository..."

# Add GPG key (store as ASCII-armored for APT 2.4+ and sqv/APT 3.0+ compatibility)
echo "Adding GPG key..."
curl -fsSL https://sansnom-co.github.io/k8s-tools/public_key.asc | sudo tee /usr/share/keyrings/k8s-tools-archive-keyring.asc > /dev/null

if [ "$USE_DEB822" = true ]; then
    echo "Using deb822 format..."
    sudo tee /etc/apt/sources.list.d/k8s-tools.sources > /dev/null <<EOF
Types: deb
URIs: https://sansnom-co.github.io/k8s-tools
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/k8s-tools-archive-keyring.asc
EOF
else
    echo "Using traditional APT format..."
    echo "deb [signed-by=/usr/share/keyrings/k8s-tools-archive-keyring.asc] https://sansnom-co.github.io/k8s-tools stable main" | \
        sudo tee /etc/apt/sources.list.d/k8s-tools.list > /dev/null
fi

echo "Updating package list..."
sudo apt-get update -qq

echo "Repository added successfully!"