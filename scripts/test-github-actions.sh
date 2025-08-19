#!/bin/bash

# Script to test GitHub Actions setup

echo "🧪 Testing GitHub Actions Setup for k8s-tools"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO="sansnom-co/k8s-tools"

# Test 1: Check if gh CLI is authenticated
echo -n "1. GitHub CLI authentication... "
if gh auth status &>/dev/null; then
    echo -e "${GREEN}✓ Authenticated${NC}"
else
    echo -e "${RED}✗ Not authenticated${NC}"
    echo "   Run: gh auth login"
fi

# Test 2: Check repository access
echo -n "2. Repository access... "
if gh repo view $REPO &>/dev/null; then
    echo -e "${GREEN}✓ Accessible${NC}"
else
    echo -e "${RED}✗ Cannot access repository${NC}"
fi

# Test 3: Check Actions status
echo -n "3. GitHub Actions status... "
if gh api repos/$REPO/actions/permissions --jq '.enabled' | grep -q true; then
    echo -e "${GREEN}✓ Enabled${NC}"
else
    echo -e "${RED}✗ Not enabled or cannot check${NC}"
    echo "   Enable at: https://github.com/$REPO/settings/actions"
fi

# Test 4: Check for required secrets
echo -n "4. Checking secrets... "
SECRETS=$(gh secret list --repo $REPO 2>/dev/null || echo "")
if echo "$SECRETS" | grep -q "GPG_PRIVATE_KEY" && echo "$SECRETS" | grep -q "GPG_PASSPHRASE"; then
    echo -e "${GREEN}✓ GPG secrets configured${NC}"
else
    echo -e "${YELLOW}⚠ GPG secrets not found${NC}"
    echo "   Required for signed releases (optional for testing)"
    echo "   Add at: https://github.com/$REPO/settings/secrets/actions"
fi

# Test 5: Check for labels
echo -n "5. Checking labels... "
LABELS=$(gh label list --repo $REPO 2>/dev/null || echo "")
MISSING_LABELS=()
if ! echo "$LABELS" | grep -q "upstream-update"; then
    MISSING_LABELS+=("upstream-update")
fi
if ! echo "$LABELS" | grep -q "automated"; then
    MISSING_LABELS+=("automated")
fi

if [ ${#MISSING_LABELS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All labels exist${NC}"
else
    echo -e "${YELLOW}⚠ Missing labels: ${MISSING_LABELS[*]}${NC}"
    echo "   Create at: https://github.com/$REPO/issues/labels"
fi

# Test 6: Check workflows
echo -n "6. Checking workflows... "
WORKFLOWS=$(gh workflow list --repo $REPO 2>/dev/null || echo "")
FOUND_WORKFLOWS=0
if echo "$WORKFLOWS" | grep -q "Check Upstream Releases"; then
    ((FOUND_WORKFLOWS++))
fi
if echo "$WORKFLOWS" | grep -q "Build.*Release"; then
    ((FOUND_WORKFLOWS++))
fi
if echo "$WORKFLOWS" | grep -q "Watch Build Status"; then
    ((FOUND_WORKFLOWS++))
fi

if [ $FOUND_WORKFLOWS -eq 3 ]; then
    echo -e "${GREEN}✓ All workflows found${NC}"
else
    echo -e "${YELLOW}⚠ Found $FOUND_WORKFLOWS/3 workflows${NC}"
    echo "   Push may still be pending"
fi

echo ""
echo "📋 Quick Test Commands:"
echo "------------------------"
echo "# Trigger upstream check manually:"
echo "gh workflow run check-upstream-releases.yml --repo $REPO"
echo ""
echo "# Watch workflow runs:"
echo "gh run list --repo $REPO --limit 5"
echo ""
echo "# View specific workflow status:"
echo "gh workflow view check-upstream-releases.yml --repo $REPO"
echo ""

# Test 7: Try to trigger a test run
echo "🚀 Would you like to trigger a test run of the upstream checker? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Triggering upstream check..."
    if gh workflow run check-upstream-releases.yml --repo $REPO; then
        echo -e "${GREEN}✓ Workflow triggered successfully!${NC}"
        echo "Watch it at: https://github.com/$REPO/actions"
    else
        echo -e "${RED}✗ Failed to trigger workflow${NC}"
    fi
fi