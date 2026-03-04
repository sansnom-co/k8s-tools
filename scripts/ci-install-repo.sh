#!/bin/bash
# CI script to install k8s-tools repository
# Usage: ./ci-install-repo.sh [--deb822]

set -e

USE_DEB822=false
if [ "$1" = "--deb822" ]; then
    USE_DEB822=true
fi

echo "Installing K8s Tools repository..."

# Download GPG key
echo "Adding GPG key..."
curl -fsSL https://sansnom-co.github.io/k8s-tools/public_key.asc -o /tmp/k8s-tools.asc

if [ "$USE_DEB822" = true ]; then
    # APT 3.0+ (Debian trixie/forky): use .asc directly (sqv compatible)
    echo "Using deb822 format..."
    sudo cp /tmp/k8s-tools.asc /usr/share/keyrings/k8s-tools-archive-keyring.asc
    sudo tee /etc/apt/sources.list.d/k8s-tools.sources > /dev/null <<EOF
Types: deb
URIs: https://sansnom-co.github.io/k8s-tools
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/k8s-tools-archive-keyring.asc
EOF
else
    # APT 2.x: dearmor to binary format for older systems
    echo "Using traditional APT format..."
    sudo gpg --dearmor -o /usr/share/keyrings/k8s-tools-archive-keyring.gpg < /tmp/k8s-tools.asc
    echo "deb [signed-by=/usr/share/keyrings/k8s-tools-archive-keyring.gpg] https://sansnom-co.github.io/k8s-tools stable main" | \
        sudo tee /etc/apt/sources.list.d/k8s-tools.list > /dev/null
fi
rm -f /tmp/k8s-tools.asc

echo "Updating package list..."
sudo apt-get update -qq

echo "Repository added successfully!"