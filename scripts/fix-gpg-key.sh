#!/bin/bash

echo "🔑 GPG Key Fix Script"
echo "===================="
echo ""

# Check if we can get the GPG key from a signed release
echo "1. Checking for GPG signatures in releases..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/sansnom-co/k8s-tools/releases/latest | jq -r '.tag_name')
echo "Latest release: $LATEST_RELEASE"

# Try to download a signature file
SIGNATURE_URL=$(curl -s https://api.github.com/repos/sansnom-co/k8s-tools/releases/latest | jq -r '.assets[] | select(.name | endswith(".asc")) | .browser_download_url' | head -1)

if [ -n "$SIGNATURE_URL" ] && [ "$SIGNATURE_URL" != "null" ]; then
    echo ""
    echo "Found signature file: $SIGNATURE_URL"
    echo "Downloading..."
    wget -q "$SIGNATURE_URL" -O /tmp/k8s-tools.asc
    
    echo ""
    echo "2. Extracting public key from signature..."
    # Import the signature to extract the key
    gpg --import /tmp/k8s-tools.asc 2>&1 | grep -E "key|imported" || true
    
    # Export the public key
    KEY_ID=$(gpg --list-packets /tmp/k8s-tools.asc 2>/dev/null | grep -E "keyid" | head -1 | awk '{print $NF}')
    if [ -n "$KEY_ID" ]; then
        echo "Key ID found: $KEY_ID"
        gpg --armor --export "$KEY_ID" > /tmp/public_key.asc
        echo "Public key exported to /tmp/public_key.asc"
    fi
else
    echo "No signature files found in releases."
fi

echo ""
echo "3. Manual steps to fix:"
echo ""
echo "Option A: If you have the GPG key locally:"
echo "  gpg --armor --export B24A23CCB7E16E36 > public_key.asc"
echo ""
echo "Option B: Clone and manually add the key:"
echo "  git clone -b gh-pages https://github.com/sansnom-co/k8s-tools.git k8s-tools-pages"
echo "  cd k8s-tools-pages"
echo "  # Add your public_key.asc file here"
echo "  git add public_key.asc"
echo "  git commit -m 'Add GPG public key'"
echo "  git push origin gh-pages"
echo ""
echo "Option C: Re-run the publish workflow:"
echo "  Make sure GPG_PRIVATE_KEY and GPG_PASSPHRASE secrets are set correctly"
echo "  Then trigger: https://github.com/sansnom-co/k8s-tools/actions/workflows/publish-deb-repo.yml"