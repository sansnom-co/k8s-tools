#!/bin/bash

echo "🚀 Triggering Upstream Check"
echo "==========================="
echo ""

# Method 1: Via GitHub UI
echo "Method 1: Via GitHub Web UI (Recommended)"
echo "-----------------------------------------"
echo "1. Go to: https://github.com/sansnom-co/k8s-tools/actions/workflows/check-upstream-releases.yml"
echo "2. Click 'Run workflow' button"
echo "3. Select 'main' branch"
echo "4. Click 'Run workflow'"
echo ""

# Method 2: Force refresh by making a small change
echo "Method 2: Force GitHub to recognize the workflow"
echo "-----------------------------------------------"
echo "If the workflow still shows errors, try:"
echo "1. Make a small change to the workflow file"
echo "2. Commit and push"
echo "3. This forces GitHub to re-parse the workflow"
echo ""

# Method 3: Direct API call
echo "Method 3: Direct API call (requires valid token)"
echo "------------------------------------------------"
cat << 'EOF'
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  https://api.github.com/repos/sansnom-co/k8s-tools/actions/workflows/check-upstream-releases.yml/dispatches \
  -d '{"ref":"main"}'
EOF

echo ""
echo "Current workflow status:"
echo "------------------------"
(unset GITHUB_TOKEN && gh workflow view 182421360 --repo sansnom-co/k8s-tools 2>&1 | head -20)