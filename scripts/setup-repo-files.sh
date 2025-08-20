#!/bin/bash

# Script to set up all repository files

# Create .nojekyll to serve raw files
touch .nojekyll

# Create the index.html
./create-repo-index.sh

# Create README.md
cat > README.md << 'EOF'
# K8s Tools Debian Repository

This is the APT repository for k8s-tools. 

For installation instructions, visit: https://sansnom-co.github.io/k8s-tools/
EOF