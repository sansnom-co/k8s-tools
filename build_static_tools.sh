#!/bin/bash

# This script builds statically linked binaries for various Kubernetes tools.
# It is designed to be run on a Debian-based system (like Debian Sid).
# The resulting binaries will be placed in a 'static_binaries' directory.

set -euo pipefail # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
BUILD_ROOT="${GITHUB_WORKSPACE}/tmp/k8s-static-build-$(date +%Y%m%d%H%M%S)" # Unique temporary build directory
INSTALL_DIR="${GITHUB_WORKSPACE}/static_binaries" # Where to put the final binaries

# --- Functions ---
log_step() {
    echo "
--- $1 ---
"
}

cleanup() {
    log_step "Cleaning up temporary build directory: $BUILD_ROOT"
    rm -rf "$BUILD_ROOT"
}

trap cleanup EXIT # Ensure cleanup runs on exit, even if errors occur

# --- Main Script ---

log_step "Installing build prerequisites..."
sudo apt update
sudo apt install -y \
    git \
    golang \
    build-essential \
    pkg-config \
    libc6-dev \
    libgpgme-dev \
    libdevmapper-dev \
    libbtrfs-dev \
    libseccomp-dev \
    libassuan-dev \
    libgpg-error-dev \
    libpcsclite-dev \
    musl-tools \
    musl-dev

log_step "Setting up build environment in $BUILD_ROOT..."
mkdir -p "$BUILD_ROOT"
mkdir -p "$INSTALL_DIR"
cd "$BUILD_ROOT"

# --- Build kubectl ---
log_step "Building kubectl..."
git clone https://github.com/kubernetes/kubernetes.git
cd kubernetes
go mod tidy
CGO_ENABLED=0 go build -ldflags '-s -w -extldflags "-static"' -o kubectl ./cmd/kubectl
cp kubectl "$INSTALL_DIR/kubectl"
cd "$BUILD_ROOT"

# --- Build helm ---
log_step "Building helm..."
git clone https://github.com/helm/helm.git
cd helm
go mod tidy
CGO_ENABLED=0 go build -ldflags '-s -w -extldflags "-static"' -o helm ./cmd/helm
cp helm "$INSTALL_DIR/helm"
cd "$BUILD_ROOT"

# --- Build jq (using musl) ---
log_step "Building jq (statically linked with musl)..."
git clone https://github.com/jqlang/jq.git
cd jq
git submodule update --init --recursive
autoreconf -fi
./configure --host=x86_64-linux-musl --disable-shared CC=musl-gcc LDFLAGS="-static -static-libgcc"
make
cp jq "$INSTALL_DIR/jq"
cd "$BUILD_ROOT"

# --- Build skopeo ---
log_step "Building skopeo..."
git clone https://github.com/containers/skopeo.git
cd skopeo
go mod tidy
go build -ldflags '-s -w -extldflags "-static -lgpg-error -lassuan"' -tags "exclude_graphdriver_btrfs" -o skopeo ./cmd/skopeo
cp skopeo "$INSTALL_DIR/skopeo"
cd "$BUILD_ROOT"

# --- Build oras ---
log_step "Building oras..."
git clone https://github.com/oras-project/oras.git
cd oras
go mod tidy
CGO_ENABLED=0 go build -ldflags '-s -w -extldflags "-static"' -o oras ./cmd/oras
cp oras "$INSTALL_DIR/oras"
cd "$BUILD_ROOT"

# --- Build cosign ---
log_step "Building cosign..."
git clone https://github.com/sigstore/cosign.git
cd cosign
go mod tidy
CGO_ENABLED=0 go build -ldflags '-s -w -extldflags "-static"' -o cosign ./cmd/cosign
cp cosign "$INSTALL_DIR/cosign"
cd "$BUILD_ROOT"

# --- Build flux-cli ---
log_step "Building flux-cli..."
git clone https://github.com/fluxcd/flux2.git
cd flux2
go mod tidy
CGO_ENABLED=0 LDFLAGS='-s -w -extldflags "-static"' make build
cp bin/flux "$INSTALL_DIR/flux"
cd "$BUILD_ROOT"

# --- Verification ---
log_step "Verifying static binaries in $INSTALL_DIR..."

for tool in kubectl helm jq skopeo oras cosign flux; do
    echo "
Checking $tool:"
    ls -lh "$INSTALL_DIR/$tool"
    # For musl-linked binaries, ldd will report an error, which is expected.
    # For glibc-linked binaries, it will show dynamic dependencies.
    # The goal is to ensure no *unexpected* dynamic dependencies.
    ldd "$INSTALL_DIR/$tool" || true 
done

log_step "All specified tools built and verified. Binaries are in $INSTALL_DIR"
