#!/bin/bash

# This script builds statically linked binaries for various Kubernetes tools.
# It is designed to be run on a Debian-based system (like Debian Sid).
# The resulting binaries will be placed in a 'static_binaries' directory.

set -euo pipefail # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
BUILD_ROOT="${GITHUB_WORKSPACE}/tmp/k8s-static-build-$(date +%Y%m%d%H%M%S)" # Unique temporary build directory
INSTALL_DIR="${GITHUB_WORKSPACE}/static_binaries" # Where to put the final binaries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Load pinned versions from .last_known_versions ---
declare -A TOOL_VERSIONS
if [[ -f "${SCRIPT_DIR}/.last_known_versions" ]]; then
    while IFS='=' read -r tool version; do
        [[ -n "$tool" && -n "$version" ]] && TOOL_VERSIONS["$tool"]="$version"
    done < "${SCRIPT_DIR}/.last_known_versions"
fi

get_version() {
    local tool="$1"
    echo "${TOOL_VERSIONS[$tool]:-}"
}

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
    libpcsclite-dev

log_step "Setting up build environment in $BUILD_ROOT..."
mkdir -p "$BUILD_ROOT"
mkdir -p "$INSTALL_DIR"
cd "$BUILD_ROOT"

# --- Build kubectl ---
KUBECTL_VERSION="$(get_version kubectl)"
log_step "Building kubectl ${KUBECTL_VERSION}..."
git clone --depth 1 --branch "${KUBECTL_VERSION}" https://github.com/kubernetes/kubernetes.git
cd kubernetes
KUBE_GIT_COMMIT="$(git rev-parse HEAD)"
KUBE_GIT_TREE_STATE="clean"
KUBE_BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
KUBE_GIT_MAJOR="${KUBECTL_VERSION%%.*}"
KUBE_GIT_MAJOR="${KUBE_GIT_MAJOR#v}"
KUBE_GIT_MINOR="${KUBECTL_VERSION#*.}"
KUBE_GIT_MINOR="${KUBE_GIT_MINOR%%.*}"
go mod tidy
CGO_ENABLED=0 go build \
    -ldflags "-s -w -extldflags '-static' \
    -X k8s.io/component-base/version.gitVersion=${KUBECTL_VERSION} \
    -X k8s.io/component-base/version.gitCommit=${KUBE_GIT_COMMIT} \
    -X k8s.io/component-base/version.gitTreeState=${KUBE_GIT_TREE_STATE} \
    -X k8s.io/component-base/version.buildDate=${KUBE_BUILD_DATE} \
    -X k8s.io/component-base/version.gitMajor=${KUBE_GIT_MAJOR} \
    -X k8s.io/component-base/version.gitMinor=${KUBE_GIT_MINOR}" \
    -o kubectl ./cmd/kubectl
cp kubectl "$INSTALL_DIR/kubectl"
cd "$BUILD_ROOT"

# --- Build helm ---
HELM_VERSION="$(get_version helm)"
log_step "Building helm ${HELM_VERSION}..."
git clone --depth 1 --branch "${HELM_VERSION}" https://github.com/helm/helm.git
cd helm
HELM_GIT_COMMIT="$(git rev-parse --short HEAD)"
go mod tidy
CGO_ENABLED=0 go build \
    -ldflags "-s -w -extldflags '-static' \
    -X helm.sh/helm/v4/internal/version.version=${HELM_VERSION} \
    -X helm.sh/helm/v4/internal/version.gitCommit=${HELM_GIT_COMMIT} \
    -X helm.sh/helm/v4/internal/version.buildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    -o helm ./cmd/helm
cp helm "$INSTALL_DIR/helm"
cd "$BUILD_ROOT"

# --- Download jq (pre-built static binary from upstream) ---
JQ_VERSION="$(get_version jq)"
log_step "Downloading jq ${JQ_VERSION} static binary..."
curl -fSL -o "$INSTALL_DIR/jq" \
    "https://github.com/jqlang/jq/releases/download/${JQ_VERSION}/jq-linux-amd64"

# --- Build skopeo ---
SKOPEO_VERSION="$(get_version skopeo)"
log_step "Building skopeo ${SKOPEO_VERSION}..."
git clone --depth 1 --branch "${SKOPEO_VERSION}" https://github.com/containers/skopeo.git
cd skopeo
go mod tidy
go build -ldflags "-s -w -extldflags '-static -lgpg-error -lassuan' \
    -X main.gitCommit=$(git rev-parse --short HEAD)" \
    -tags "exclude_graphdriver_btrfs" -o skopeo ./cmd/skopeo
cp skopeo "$INSTALL_DIR/skopeo"
cd "$BUILD_ROOT"

# --- Build oras ---
ORAS_VERSION="$(get_version oras)"
log_step "Building oras ${ORAS_VERSION}..."
git clone --depth 1 --branch "${ORAS_VERSION}" https://github.com/oras-project/oras.git
cd oras
go mod tidy
CGO_ENABLED=0 go build \
    -ldflags "-s -w -extldflags '-static' \
    -X oras.land/oras/internal/version.Version=${ORAS_VERSION#v} \
    -X oras.land/oras/internal/version.BuildMetadata= \
    -X oras.land/oras/internal/version.GitCommit=$(git rev-parse --short HEAD) \
    -X oras.land/oras/internal/version.GitTreeState=clean" \
    -o oras ./cmd/oras
cp oras "$INSTALL_DIR/oras"
cd "$BUILD_ROOT"

# --- Build cosign ---
COSIGN_VERSION="$(get_version cosign)"
log_step "Building cosign ${COSIGN_VERSION}..."
git clone --depth 1 --branch "${COSIGN_VERSION}" https://github.com/sigstore/cosign.git
cd cosign
go mod tidy
CGO_ENABLED=0 go build \
    -ldflags "-s -w -extldflags '-static' \
    -X sigs.k8s.io/release-utils/version.gitVersion=${COSIGN_VERSION} \
    -X sigs.k8s.io/release-utils/version.gitCommit=$(git rev-parse HEAD) \
    -X sigs.k8s.io/release-utils/version.gitTreeState=clean \
    -X sigs.k8s.io/release-utils/version.buildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    -o cosign ./cmd/cosign
cp cosign "$INSTALL_DIR/cosign"
cd "$BUILD_ROOT"

# --- Build flux-cli ---
FLUX_VERSION="$(get_version flux)"
log_step "Building flux-cli ${FLUX_VERSION}..."
git clone --depth 1 --branch "${FLUX_VERSION}" https://github.com/fluxcd/flux2.git
cd flux2
go mod tidy
CGO_ENABLED=0 VERSION="${FLUX_VERSION}" LDFLAGS='-s -w -extldflags "-static"' make build
cp bin/flux "$INSTALL_DIR/flux"
cd "$BUILD_ROOT"

# --- Set executable permissions ---
log_step "Setting executable permissions..."
chmod +x "$INSTALL_DIR"/*

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
