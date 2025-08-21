#!/bin/bash

# Method 1: Traditional APT format
echo "Installing K8s Tools repository (traditional format)..."
curl -fsSL https://sansnom-co.github.io/k8s-tools/public_key.asc | sudo gpg --dearmor -o /usr/share/keyrings/k8s-tools-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/k8s-tools-archive-keyring.gpg] https://sansnom-co.github.io/k8s-tools stable main" | sudo tee /etc/apt/sources.list.d/k8s-tools.list

# Method 2: New deb822 format (APT 3.0+)
echo "Or use the new deb822 format:"
sudo tee /etc/apt/sources.list.d/k8s-tools.sources <<EOF
Types: deb
URIs: https://sansnom-co.github.io/k8s-tools
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/k8s-tools-archive-keyring.gpg
EOF

echo "Updating package list..."
sudo apt update