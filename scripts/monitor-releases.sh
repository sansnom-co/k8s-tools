#!/bin/bash

# Script to monitor upstream releases and trigger builds
# This can be run locally or in CI/CD

set -euo pipefail

# Configuration
REPO="sansnom-co/k8s-tools"
TOOLS=(
    "kubectl:kubernetes/kubernetes"
    "helm:helm/helm"
    "jq:jqlang/jq"
    "skopeo:containers/skopeo"
    "oras:oras-project/oras"
    "cosign:sigstore/cosign"
    "flux:fluxcd/flux2"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to get latest release
get_latest_release() {
    local repo=$1
    gh api repos/$repo/releases/latest --jq '.tag_name' 2>/dev/null || echo "unknown"
}

# Function to get current version from our releases
get_our_version() {
    local tool=$1
    # This would need to be implemented based on how you track versions
    echo "unknown"
}

echo "🔍 Checking upstream releases..."
echo ""

for tool_info in "${TOOLS[@]}"; do
    IFS=':' read -r tool repo <<< "$tool_info"
    
    echo -n "Checking $tool... "
    latest=$(get_latest_release "$repo")
    
    if [ "$latest" = "unknown" ]; then
        echo -e "${RED}Failed to fetch${NC}"
    else
        echo -e "${GREEN}$latest${NC}"
    fi
done

echo ""
echo "📊 Current workflow status:"
gh run list --workflow=build-release.yml --repo $REPO --limit 3

echo ""
echo "🚀 To trigger a new build:"
echo "1. Create a new release: gh release create v$(date +%y.%m).<PATCH> --repo $REPO"
echo "2. Or run the upstream checker: gh workflow run check-upstream-releases.yml --repo $REPO"
echo ""
echo "👀 To watch builds: gh run watch --repo $REPO"