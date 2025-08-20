#!/bin/bash

# Script to set up the initial GitHub Pages branch for the Debian repository

echo "🚀 Setting up Debian Repository on GitHub Pages"
echo "=============================================="
echo ""

REPO="sansnom-co/k8s-tools"

# Check if gh-pages branch exists
echo "Checking for gh-pages branch..."
if git ls-remote --heads origin gh-pages | grep -q gh-pages; then
    echo "✓ gh-pages branch already exists"
else
    echo "Creating gh-pages branch..."
    
    # Create orphan branch
    git checkout --orphan gh-pages
    
    # Remove all files
    git rm -rf .
    
    # Create initial structure
    mkdir -p pool/main/k/k8s-tools
    mkdir -p dists/stable/main/binary-amd64
    
    # Create .nojekyll to serve raw files
    touch .nojekyll
    
    # Create placeholder index
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>K8s Tools Debian Repository</title>
    <style>
        body { 
            background-color: #0d1117; 
            color: #58a6ff; 
            font-family: monospace; 
            padding: 40px;
            text-align: center;
        }
    </style>
</head>
<body>
    <h1>K8s Tools Debian Repository</h1>
    <p>Repository is being set up...</p>
    <p>Please check back soon!</p>
</body>
</html>
EOF
    
    # Commit and push
    git add .
    git commit -m "Initial gh-pages branch"
    git push origin gh-pages
    
    # Switch back to main
    git checkout main
    
    echo "✓ gh-pages branch created"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Go to: https://github.com/$REPO/settings/pages"
echo "2. Set Source to: Deploy from a branch"
echo "3. Set Branch to: gh-pages"
echo "4. Set Folder to: / (root)"
echo "5. Click Save"
echo ""
echo "6. The repository will be available at:"
echo "   https://sansnom-co.github.io/k8s-tools/"
echo ""
echo "7. Run the publish workflow to populate the repository:"
echo "   gh workflow run publish-deb-repo.yml --repo $REPO"
echo ""
echo "Note: It may take a few minutes for GitHub Pages to activate."