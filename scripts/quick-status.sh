#!/bin/bash

echo "🔍 Quick GitHub Actions Status Check"
echo "===================================="
echo ""

# Direct URLs to check
echo "📌 Important URLs:"
echo "1. Actions tab: https://github.com/sansnom-co/k8s-tools/actions"
echo "2. Create labels: https://github.com/sansnom-co/k8s-tools/issues/labels"
echo "3. Add secrets: https://github.com/sansnom-co/k8s-tools/settings/secrets/actions"
echo ""

echo "🏷️  Required Labels to Create:"
echo "- upstream-update (green #0E8A16)"
echo "- automated (purple #7057FF)"
echo ""

echo "🔐 Required Secrets (for signed releases):"
echo "- GPG_PRIVATE_KEY"
echo "- GPG_PASSPHRASE"
echo ""

echo "⏰ The upstream checker will:"
echo "- Run every 6 hours automatically"
echo "- Check all 7 tools for new releases"
echo "- Create a new release tag if updates found"
echo "- Create an issue documenting the changes"
echo ""

echo "🚀 Once labels are created, try:"
echo "gh workflow run 'Check Upstream Releases' --repo sansnom-co/k8s-tools"
echo ""
echo "Or trigger from the web UI at:"
echo "https://github.com/sansnom-co/k8s-tools/actions/workflows/check-upstream-releases.yml"