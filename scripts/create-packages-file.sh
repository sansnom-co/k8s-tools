#!/bin/bash

# Creates the APT Packages file by collecting .deb assets from all
# per-tool and kube-essential GitHub releases.

REPO="${1:-sansnom-co/k8s-tools}"
OUTPUT_FILE="${2:-Packages}"

# Per-tool package metadata (matches packaging/*.yaml)
declare -A TOOL_DEPENDS=(
  [kubectl]="ca-certificates"
  [helm]="ca-certificates"
  [jq]=""
  [skopeo]="ca-certificates"
  [oras]="ca-certificates"
  [cosign]="ca-certificates"
  [flux]="ca-certificates"
  [kube-essential]="kubectl, helm, jq, skopeo, oras, cosign, flux"
  [k8s-tools]="kube-essential"
)

declare -A TOOL_DESC=(
  [kubectl]="Kubernetes command-line tool (statically linked)"
  [helm]="The Kubernetes Package Manager (statically linked)"
  [jq]="Command-line JSON processor (statically linked)"
  [skopeo]="Container image inspection and copying tool (statically linked)"
  [oras]="OCI Registry As Storage CLI (statically linked)"
  [cosign]="Container signing and verification tool (statically linked)"
  [flux]="GitOps toolkit for Kubernetes (statically linked)"
  [kube-essential]="Meta-package: installs all essential Kubernetes CLI tools"
  [k8s-tools]="DEPRECATED: Replaced by kube-essential"
)

declare -A TOOL_ARCH=(
  [kubectl]="amd64"
  [helm]="amd64"
  [jq]="amd64"
  [skopeo]="amd64"
  [oras]="amd64"
  [cosign]="amd64"
  [flux]="amd64"
  [kube-essential]="all"
  [k8s-tools]="all"
)

echo "Creating Packages file for $REPO..."
> "$OUTPUT_FILE"

MAINTAINER="Martin Stadler <martin@sansnom.co>"
TOOLS="kubectl helm jq skopeo oras cosign flux kube-essential k8s-tools"

# Fetch all releases once
echo "Fetching all releases from GitHub API..."
ALL_RELEASES=$(curl -s "https://api.github.com/repos/$REPO/releases?per_page=100")

for TOOL in $TOOLS; do
  echo "Processing releases for $TOOL..."

  # Find .deb assets from releases whose tag starts with "<tool>-"
  echo "$ALL_RELEASES" | jq -r \
    --arg prefix "${TOOL}-" \
    '.[] | select(.tag_name | startswith($prefix)) | .assets[] | select(.name | endswith(".deb")) | "\(.name)|\(.browser_download_url)|\(.size)"' \
  | while IFS='|' read -r name url size; do
    [[ -z "$name" || -z "$url" || -z "$size" ]] && continue
    echo "  Adding: $name"

    # Extract version from filename: tool_version_arch.deb
    # e.g. kubectl_1.36.0-1_amd64.deb -> 1.36.0-1
    version=$(echo "$name" | sed -n "s/${TOOL}_\(.*\)_${TOOL_ARCH[$TOOL]:-amd64}\.deb/\1/p")
    if [ -z "$version" ]; then
      # Try 'all' arch for meta-packages
      version=$(echo "$name" | sed -n "s/${TOOL}_\(.*\)_all\.deb/\1/p")
    fi
    if [ -z "$version" ]; then
      echo "  Warning: Could not extract version from $name, skipping"
      continue
    fi

    {
      echo "Package: $TOOL"
      echo "Version: $version"
      echo "Architecture: ${TOOL_ARCH[$TOOL]:-amd64}"
      echo "Maintainer: $MAINTAINER"
      [[ -n "${TOOL_DEPENDS[$TOOL]:-}" ]] && echo "Depends: ${TOOL_DEPENDS[$TOOL]}"
      echo "Section: utils"
      echo "Priority: optional"
      echo "Size: $size"
      echo "Filename: $url"
      echo "Description: ${TOOL_DESC[$TOOL]:-Kubernetes tool}"
      echo ""
    } >> "$OUTPUT_FILE"
  done
done

echo "Created Packages file with $(grep -c "^Package:" "$OUTPUT_FILE" 2>/dev/null || echo 0) entries"
