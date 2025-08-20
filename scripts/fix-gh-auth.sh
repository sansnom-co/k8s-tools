#!/bin/bash

# Script to fix gh CLI authentication issues

echo "🔧 Fixing GitHub CLI Authentication"
echo "==================================="
echo ""

# Check current status
echo "Current authentication status:"
gh auth status 2>&1 | grep -E "(Logged in|Token:|Failed)" || true
echo ""

# Option 1: Use gh without GITHUB_TOKEN
echo "Option 1: Run gh commands without GITHUB_TOKEN"
echo "-----------------------------------------------"
echo "Run this command:"
echo "  unset GITHUB_TOKEN && gh workflow run 'Check Upstream Releases' --repo sansnom-co/k8s-tools"
echo ""

# Option 2: Re-authenticate with gh
echo "Option 2: Re-authenticate gh CLI"
echo "--------------------------------"
echo "1. First unset GITHUB_TOKEN:"
echo "   unset GITHUB_TOKEN"
echo ""
echo "2. Then re-authenticate:"
echo "   gh auth login"
echo ""
echo "3. Choose:"
echo "   - GitHub.com"
echo "   - SSH"
echo "   - Login with web browser (or paste token)"
echo ""

# Option 3: Use different token
echo "Option 3: Update .bashrc to use GH_TOKEN instead"
echo "------------------------------------------------"
echo "Edit ~/.bashrc and change:"
echo "  export GITHUB_TOKEN=\"\$(< ~/.tokens/.github_token)\""
echo "To:"
echo "  export GH_TOKEN=\"\$(< ~/.tokens/.github_token)\""
echo ""
echo "The gh CLI respects GH_TOKEN but prioritizes its own auth."
echo ""

# Test command
echo "📝 Test command (run after fixing):"
echo "unset GITHUB_TOKEN && gh workflow list --repo sansnom-co/k8s-tools"