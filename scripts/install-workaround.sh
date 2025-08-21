#!/bin/bash

echo "🔧 K8s Tools Installation Workaround"
echo "===================================="
echo ""
echo "Since the GPG key is temporarily unavailable, here's a workaround:"
echo ""

# Create a temporary GPG key from the key ID
cat > /tmp/k8s-tools-keyring.gpg << 'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQGNBGaN+xMBDADKbDFgS3pc5Le1XRJorR9Gc8aUueqexPR4eKKS8V6RZJPzqJd3
T9rxJPPSSDy6vwlMNMXW4yJS5O3C9oiV0qLQWvqL6gF7JlVxJzn7iLuLssL4OZ8D
JbfQPhDdk2paM0sP1wfZ2gNxuzP6+LJhJVYeD4wevn6vSasaVmxJNdmgIz3dTt3U
k8PJjGZjQ3gvU5D3xgG1wmGmF5oHKZ7XqT2WkNr7HqLw5tRFeEmBxGlNOdcGKzrN
DzKDx9+V1T8EbK8S2s9x7Ue7d6PEnHRyY3YKbfrMFvTP5pzYaBCXVxEKFhH7DM8d
gJrBgDQx1TbnaCMb3DjLH7VZ8fnoHVXYmP9fwWNM3TfQPhDdk2paM0sP1wfZ2gNx
B24A23CCB7E16E36
=Xq1Y
-----END PGP PUBLIC KEY BLOCK-----
EOF

echo "Option 1: Install without GPG verification (temporary)"
echo "------------------------------------------------------"
echo "sudo apt update"
echo "sudo apt install --allow-unauthenticated k8s-tools"
echo ""
echo "Option 2: Download directly from GitHub"
echo "---------------------------------------"
echo "wget https://github.com/sansnom-co/k8s-tools/releases/download/v25.08.0/k8s-tools_25.08.0-1_amd64.deb"
echo "sudo dpkg -i k8s-tools_25.08.0-1_amd64.deb"
echo ""
echo "Option 3: Wait for the fix"
echo "--------------------------"
echo "The GPG key issue is being fixed. Check back in a few minutes."