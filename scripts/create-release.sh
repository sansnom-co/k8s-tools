#!/bin/bash

# Script to create a new release tag and trigger the full build workflow

echo "🚀 Create New Release for k8s-tools"
echo "=================================="
echo ""

# Get current date for CalVer
DATE_VERSION=$(date +'%y.%m')

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Latest tag: $LATEST_TAG"

# Calculate next version
if [[ $LATEST_TAG =~ ^v${DATE_VERSION}\.([0-9]+)$ ]]; then
    PATCH="${BASH_REMATCH[1]}"
    NEXT_PATCH=$((PATCH + 1))
else
    NEXT_PATCH=0
fi

NEW_TAG="v${DATE_VERSION}.${NEXT_PATCH}"
echo "New tag will be: $NEW_TAG"
echo ""

# Confirm
read -p "Create and push tag $NEW_TAG? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Creating tag $NEW_TAG..."
    git tag -a "$NEW_TAG" -m "Release $NEW_TAG"
    
    echo "Pushing tag to GitHub..."
    git push origin "$NEW_TAG"
    
    echo ""
    echo "✅ Tag created and pushed!"
    echo ""
    echo "The full workflow will now run, including:"
    echo "1. Build static binaries"
    echo "2. Scan with Trivy"
    echo "3. Package as .deb and .rpm"
    echo "4. Sign packages with GPG"
    echo "5. Create GitHub release"
    echo ""
    echo "Watch progress at: https://github.com/sansnom-co/k8s-tools/actions"
else
    echo "Cancelled."
fi