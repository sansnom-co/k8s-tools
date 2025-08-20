#!/bin/bash

# Manual script to fix the repository

echo "🔧 Manual Repository Fix"
echo "======================="
echo ""

# Check if we have releases to work with
echo "Checking for releases..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/sansnom-co/k8s-tools/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
echo "Latest release: $LATEST_RELEASE"

echo ""
echo "To manually fix the repository:"
echo ""
echo "1. Clone the gh-pages branch locally:"
echo "   git clone -b gh-pages https://github.com/sansnom-co/k8s-tools.git k8s-tools-pages"
echo "   cd k8s-tools-pages"
echo ""
echo "2. Check what's there:"
echo "   ls -la"
echo "   cat index.html | head -20"
echo ""
echo "3. The workflow should have:"
echo "   - Created .nojekyll"
echo "   - Created new index.html with hacker theme"
echo "   - Exported public_key.asc"
echo "   - Created APT repository structure"
echo ""
echo "4. Check the workflow run logs at:"
echo "   https://github.com/sansnom-co/k8s-tools/actions/workflows/publish-deb-repo.yml"
echo "   Look for any errors in the run"