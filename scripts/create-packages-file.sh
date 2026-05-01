#!/bin/bash

# Creates the APT Packages file by collecting .deb assets from all
# per-tool and kube-essential GitHub releases.
# Downloads each .deb, copies it into POOL_DIR, and uses a relative
# Filename: path so APT constructs the correct download URL.
#
# Version, Architecture, and Depends are read directly from each .deb
# control file (via dpkg-deb --field) to guarantee they match what dpkg
# records on install — preventing the apt upgrade re-install loop.

REPO="${1:-sansnom-co/k8s-tools}"
OUTPUT_FILE="${2:-Packages}"
POOL_DIR="${3:-pool}"    # physical path where .deb files are written
POOL_URL="${4:-$POOL_DIR}"  # URL-relative path used in Filename: (no checkout prefix)

echo "Creating Packages file for $REPO..."
> "$OUTPUT_FILE"

TOOLS="kubectl helm jq skopeo oras cosign flux kube-essential k8s-tools"
TMPFILE=$(mktemp /tmp/apt-deb-XXXXXX.deb)
trap 'rm -f "$TMPFILE"' EXIT

# Fetch all releases once
echo "Fetching all releases from GitHub API..."
ALL_RELEASES=$(curl -s "https://api.github.com/repos/$REPO/releases?per_page=100")

for TOOL in $TOOLS; do
  echo "Processing releases for $TOOL..."

  # Find .deb assets from releases whose tag starts with "<tool>-"
  echo "$ALL_RELEASES" | jq -r \
    --arg prefix "${TOOL}-" \
    '.[] | select(.tag_name | startswith($prefix)) | .assets[] | select(.name | endswith(".deb")) | "\(.name)|\(.browser_download_url)"' \
  | while IFS='|' read -r name url; do
    [[ -z "$name" || -z "$url" ]] && continue

    echo "  Downloading $name..."
    if ! curl -fsSL -o "$TMPFILE" "$url"; then
      echo "  Warning: Failed to download $name, skipping"
      continue
    fi

    # Read metadata directly from the .deb control — this is the authoritative
    # source and guarantees the Packages file matches what dpkg records on install.
    VERSION=$(dpkg-deb --field "$TMPFILE" Version 2>/dev/null)
    ARCH=$(dpkg-deb --field "$TMPFILE" Architecture 2>/dev/null)
    DEPS=$(dpkg-deb --field "$TMPFILE" Depends 2>/dev/null || true)
    MAINTAINER=$(dpkg-deb --field "$TMPFILE" Maintainer 2>/dev/null)
    DESCRIPTION=$(dpkg-deb --field "$TMPFILE" Description 2>/dev/null | head -1)

    if [[ -z "$VERSION" || -z "$ARCH" ]]; then
      echo "  Warning: Could not read control fields from $name, skipping"
      continue
    fi

    # Compute hashes
    SIZE=$(stat -c%s "$TMPFILE")
    MD5=$(md5sum    "$TMPFILE" | cut -d' ' -f1)
    SHA1=$(sha1sum  "$TMPFILE" | cut -d' ' -f1)
    SHA256=$(sha256sum "$TMPFILE" | cut -d' ' -f1)

    # Copy into pool using standard Debian layout
    FIRST="${TOOL:0:1}"
    DEST_DIR="${POOL_DIR}/main/${FIRST}/${TOOL}"
    mkdir -p "$DEST_DIR"
    cp "$TMPFILE" "${DEST_DIR}/${name}"
    RELATIVE_PATH="${POOL_URL}/main/${FIRST}/${TOOL}/${name}"

    {
      echo "Package: $TOOL"
      echo "Version: $VERSION"
      echo "Architecture: $ARCH"
      echo "Maintainer: $MAINTAINER"
      [[ -n "$DEPS" ]] && echo "Depends: $DEPS"
      echo "Section: utils"
      echo "Priority: optional"
      echo "Size: $SIZE"
      echo "MD5sum: $MD5"
      echo "SHA1: $SHA1"
      echo "SHA256: $SHA256"
      echo "Filename: $RELATIVE_PATH"
      echo "Description: ${DESCRIPTION:-Kubernetes tool}"
      echo ""
    } >> "$OUTPUT_FILE"

    echo "  Added $name (v${VERSION} ${ARCH}) → $RELATIVE_PATH"
  done
done

echo "Created Packages file with $(grep -c "^Package:" "$OUTPUT_FILE" 2>/dev/null || echo 0) entries"
