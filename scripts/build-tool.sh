#!/usr/bin/env bash
# Builds a single statically linked binary for the specified tool.
# Usage: build-tool.sh <tool-name>
# Override version: VERSION=v1.36.0 build-tool.sh kubectl

set -euo pipefail

TOOL="${1:?Usage: build-tool.sh <tool-name>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="${GITHUB_WORKSPACE:-$(cd "$SCRIPT_DIR/.." && pwd)}"
INSTALL_DIR="${WORKSPACE}/static_binaries"
BUILD_ROOT="$(mktemp -d /tmp/build-XXXXXX)"

log_step() { echo ""; echo "--- $1 ---"; echo ""; }

cleanup() { log_step "Cleaning up $BUILD_ROOT"; rm -rf "$BUILD_ROOT"; }
trap cleanup EXIT

# Load versions from .last_known_versions (VERSION env var overrides)
declare -A TOOL_VERSIONS
VERSIONS_FILE="${SCRIPT_DIR}/../.last_known_versions"
if [[ -f "$VERSIONS_FILE" ]]; then
    while IFS='=' read -r key val; do
        [[ -n "$key" && -n "$val" ]] && TOOL_VERSIONS["$key"]="$val"
    done < "$VERSIONS_FILE"
fi
VERSION="${VERSION:-${TOOL_VERSIONS[$TOOL]:?Version for '$TOOL' not found in .last_known_versions}}"

mkdir -p "$INSTALL_DIR" "$BUILD_ROOT"

# Install Go only if not already available (CI uses actions/setup-go; local installs via apt)
install_go() {
    if ! command -v go &>/dev/null; then
        sudo apt-get install -y golang
    fi
}

case "$TOOL" in
  kubectl)
    log_step "Installing kubectl prerequisites..."
    sudo apt-get update -qq
    sudo apt-get install -y git build-essential
    install_go

    log_step "Building kubectl ${VERSION}..."
    cd "$BUILD_ROOT"
    git clone --depth 1 --branch "${VERSION}" https://github.com/kubernetes/kubernetes.git
    cd kubernetes
    KUBE_GIT_COMMIT="$(git rev-parse HEAD)"
    KUBE_BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    KUBE_GIT_MAJOR="${VERSION%%.*}"; KUBE_GIT_MAJOR="${KUBE_GIT_MAJOR#v}"
    KUBE_GIT_MINOR="${VERSION#*.}"; KUBE_GIT_MINOR="${KUBE_GIT_MINOR%%.*}"
    go mod tidy
    CGO_ENABLED=0 go build \
        -ldflags "-s -w -extldflags '-static' \
        -X k8s.io/component-base/version.gitVersion=${VERSION} \
        -X k8s.io/component-base/version.gitCommit=${KUBE_GIT_COMMIT} \
        -X k8s.io/component-base/version.gitTreeState=clean \
        -X k8s.io/component-base/version.buildDate=${KUBE_BUILD_DATE} \
        -X k8s.io/component-base/version.gitMajor=${KUBE_GIT_MAJOR} \
        -X k8s.io/component-base/version.gitMinor=${KUBE_GIT_MINOR}" \
        -o kubectl ./cmd/kubectl
    cp kubectl "$INSTALL_DIR/kubectl"
    ;;

  helm)
    log_step "Installing helm prerequisites..."
    sudo apt-get update -qq
    sudo apt-get install -y git build-essential
    install_go

    log_step "Building helm ${VERSION}..."
    cd "$BUILD_ROOT"
    git clone --depth 1 --branch "${VERSION}" https://github.com/helm/helm.git
    cd helm
    HELM_GIT_COMMIT="$(git rev-parse --short HEAD)"
    go mod tidy
    CGO_ENABLED=0 go build \
        -ldflags "-s -w -extldflags '-static' \
        -X helm.sh/helm/v4/internal/version.version=${VERSION} \
        -X helm.sh/helm/v4/internal/version.gitCommit=${HELM_GIT_COMMIT} \
        -X helm.sh/helm/v4/internal/version.buildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        -o helm ./cmd/helm
    cp helm "$INSTALL_DIR/helm"
    ;;

  jq)
    log_step "Downloading jq ${VERSION} static binary..."
    curl -fSL -o "$INSTALL_DIR/jq" \
        "https://github.com/jqlang/jq/releases/download/${VERSION}/jq-linux-amd64"
    ;;

  skopeo)
    log_step "Installing skopeo prerequisites..."
    sudo apt-get update -qq
    sudo apt-get install -y git build-essential pkg-config \
        libgpgme-dev libdevmapper-dev libbtrfs-dev libseccomp-dev \
        libassuan-dev libgpg-error-dev
    install_go

    log_step "Building skopeo ${VERSION}..."
    cd "$BUILD_ROOT"
    git clone --depth 1 --branch "${VERSION}" https://github.com/containers/skopeo.git
    cd skopeo
    go mod tidy
    go build \
        -ldflags "-s -w -extldflags '-static -lgpg-error -lassuan' \
        -X main.gitCommit=$(git rev-parse --short HEAD)" \
        -tags "exclude_graphdriver_btrfs" -o skopeo ./cmd/skopeo
    cp skopeo "$INSTALL_DIR/skopeo"
    ;;

  oras)
    log_step "Installing oras prerequisites..."
    sudo apt-get update -qq
    sudo apt-get install -y git build-essential
    install_go

    log_step "Building oras ${VERSION}..."
    cd "$BUILD_ROOT"
    git clone --depth 1 --branch "${VERSION}" https://github.com/oras-project/oras.git
    cd oras
    go mod tidy
    CGO_ENABLED=0 go build \
        -ldflags "-s -w -extldflags '-static' \
        -X oras.land/oras/internal/version.Version=${VERSION#v} \
        -X oras.land/oras/internal/version.BuildMetadata= \
        -X oras.land/oras/internal/version.GitCommit=$(git rev-parse --short HEAD) \
        -X oras.land/oras/internal/version.GitTreeState=clean" \
        -o oras ./cmd/oras
    cp oras "$INSTALL_DIR/oras"
    ;;

  cosign)
    log_step "Installing cosign prerequisites..."
    sudo apt-get update -qq
    sudo apt-get install -y git build-essential libpcsclite-dev
    install_go

    log_step "Building cosign ${VERSION}..."
    cd "$BUILD_ROOT"
    git clone --depth 1 --branch "${VERSION}" https://github.com/sigstore/cosign.git
    cd cosign
    go mod tidy
    CGO_ENABLED=0 go build \
        -ldflags "-s -w -extldflags '-static' \
        -X sigs.k8s.io/release-utils/version.gitVersion=${VERSION} \
        -X sigs.k8s.io/release-utils/version.gitCommit=$(git rev-parse HEAD) \
        -X sigs.k8s.io/release-utils/version.gitTreeState=clean \
        -X sigs.k8s.io/release-utils/version.buildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        -o cosign ./cmd/cosign
    cp cosign "$INSTALL_DIR/cosign"
    ;;

  flux)
    log_step "Installing flux prerequisites..."
    sudo apt-get update -qq
    sudo apt-get install -y git build-essential make
    install_go

    log_step "Building flux ${VERSION}..."
    cd "$BUILD_ROOT"
    git clone --depth 1 --branch "${VERSION}" https://github.com/fluxcd/flux2.git
    cd flux2
    go mod tidy
    CGO_ENABLED=0 VERSION="${VERSION}" LDFLAGS='-s -w -extldflags "-static"' make build
    cp bin/flux "$INSTALL_DIR/flux"
    ;;

  *)
    echo "Error: Unknown tool '$TOOL'. Valid tools: kubectl helm jq skopeo oras cosign flux" >&2
    exit 1
    ;;
esac

chmod +x "$INSTALL_DIR/$TOOL"
log_step "Verifying $TOOL..."
ldd "$INSTALL_DIR/$TOOL" || true
log_step "$TOOL built successfully → $INSTALL_DIR/$TOOL"
