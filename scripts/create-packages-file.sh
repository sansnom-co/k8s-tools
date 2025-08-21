#!/bin/bash

# Script to create APT Packages file from GitHub releases

REPO="${1:-sansnom-co/k8s-tools}"
OUTPUT_FILE="${2:-Packages}"

echo "Creating Packages file for $REPO..."

# Clear output file
> "$OUTPUT_FILE"

# Get all releases and create package entries
gh api "repos/$REPO/releases" --paginate | jq -r '.[] | .assets[] | select(.name | endswith(".deb")) | {name, browser_download_url, size}' | while IFS= read -r line; do
    name=$(echo "$line" | jq -r '.name')
    url=$(echo "$line" | jq -r '.browser_download_url')
    size=$(echo "$line" | jq -r '.size')
    
    # Skip if any field is empty
    if [ -z "$name" ] || [ -z "$url" ] || [ -z "$size" ]; then
        continue
    fi
    
    # Extract version from filename (e.g., k8s-tools_25.08.0-1_amd64.deb -> 25.08.0-1)
    version=$(echo "$name" | sed -n 's/k8s-tools_\(.*\)_amd64\.deb/\1/p')
    
    if [ -z "$version" ]; then
        echo "Warning: Could not extract version from $name"
        continue
    fi
    
    # Create package entry
    {
        echo "Package: k8s-tools"
        echo "Version: $version"
        echo "Architecture: amd64"
        echo "Maintainer: Martin Stadler <martin@sansnom.co>"
        echo "Depends: ca-certificates"
        echo "Section: utils"
        echo "Priority: optional"
        echo "Size: $size"
        echo "Filename: $url"
        echo "Description: Statically linked Kubernetes CLI tools"
        echo " This package contains kubectl, helm, jq, skopeo, oras, cosign, and flux."
        echo " All binaries are statically linked for maximum compatibility."
        echo ""
    } >> "$OUTPUT_FILE"
done

echo "Created Packages file with $(grep -c "^Package:" "$OUTPUT_FILE") entries"