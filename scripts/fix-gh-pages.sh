#!/bin/bash

echo "🔧 Fixing gh-pages branch"
echo "========================"
echo ""
echo "This will reset the gh-pages branch to contain only the APT repository files."
echo ""

# Clone the repository
echo "1. Cloning gh-pages branch..."
rm -rf temp_fix_gh_pages
git clone -b gh-pages https://github.com/sansnom-co/k8s-tools.git temp_fix_gh_pages
cd temp_fix_gh_pages

# Clean everything except .git
echo "2. Cleaning branch..."
find . -mindepth 1 -maxdepth 1 -name '.git' -prune -o -exec rm -rf {} +

# Create the proper structure
echo "3. Creating APT repository structure..."
mkdir -p dists/stable/main/binary-amd64

# Create .nojekyll
touch .nojekyll

# Create a placeholder index
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>K8s Tools APT Repository</title>
</head>
<body>
    <h1>K8s Tools APT Repository</h1>
    <p>Repository is being rebuilt. Please check back in a few minutes.</p>
</body>
</html>
EOF

# Commit and push
echo "4. Committing changes..."
git add -A
git commit -m "Reset gh-pages branch for APT repository only"
git push origin gh-pages --force

echo ""
echo "✅ Done! Now run the publish workflow to populate the repository:"
echo "https://github.com/sansnom-co/k8s-tools/actions/workflows/publish-deb-repo.yml"

cd ..
rm -rf temp_fix_gh_pages