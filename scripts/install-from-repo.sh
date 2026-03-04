#!/bin/bash

# Script to install k8s-tools from the APT repository

echo "🚀 Installing k8s-tools from APT repository"
echo "=========================================="
echo ""

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run with sudo or as root"
        exit 1
    fi
}

# For non-root users, re-run with sudo
if [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

echo "📥 Downloading GPG key..."
# Try multiple methods to get the key
if ! wget -q -O /tmp/k8s-tools.asc https://sansnom-co.github.io/k8s-tools/public_key.asc; then
    echo "⚠️  Direct download failed, trying from GitHub releases..."
    # Get the GPG key from the latest release
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/sansnom-co/k8s-tools/releases/latest | grep -o '"browser_download_url": "[^"]*\.asc"' | head -1 | cut -d'"' -f4)
    if [ -n "$LATEST_RELEASE" ]; then
        wget -q -O /tmp/k8s-tools.asc "$LATEST_RELEASE"
    else
        echo "❌ Failed to download GPG key"
        echo "The repository might still be setting up. Please try again in a few minutes."
        exit 1
    fi
fi

echo "🔑 Installing GPG key..."
gpg --dearmor < /tmp/k8s-tools.asc > /usr/share/keyrings/sansnom-k8s-tools.gpg
rm -f /tmp/k8s-tools.asc

echo "📝 Adding repository..."
echo "deb [signed-by=/usr/share/keyrings/sansnom-k8s-tools.gpg] https://sansnom-co.github.io/k8s-tools stable main" > /etc/apt/sources.list.d/sansnom-k8s-tools.list

echo "🔄 Updating package list..."
apt-get update

echo "📦 Installing k8s-tools..."
apt-get install -y k8s-tools

echo ""
echo "✅ Installation complete!"
echo ""
echo "The following tools are now available:"
echo "  - kubectl"
echo "  - helm"
echo "  - jq"
echo "  - skopeo"
echo "  - oras"
echo "  - cosign"
echo "  - flux"
echo ""
echo "All tools are installed in /usr/local/bin/"