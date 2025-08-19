# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository builds and packages statically linked Kubernetes CLI tools as system packages (.deb and .rpm). All tools are built from their upstream sources and linked statically for maximum portability across Linux distributions.

## Build Commands

### Local Build
```bash
# Build all static binaries locally
./build_static_tools.sh
```

### Package Creation (requires Ruby and FPM)
```bash
# Install FPM
sudo apt install -y ruby ruby-dev build-essential
sudo gem install fpm

# Create .deb package (using -C to change directory)
fpm -s dir -t deb -n k8s-tools -v "YY.MM.patch" --iteration 1 --architecture amd64 \
  --maintainer "Martin Stadler <martin@sansnom.co>" \
  --prefix /usr/local/bin -C static_binaries .

# Create .rpm package (using -C to change directory)
fpm -s dir -t rpm -n k8s-tools -v "YY.MM.patch" --iteration 1 --architecture x86_64 \
  --maintainer "Martin Stadler <martin@sansnom.co>" \
  --prefix /usr/local/bin -C static_binaries .
```

### Verification
```bash
# Verify static linking (should show "not a dynamic executable" or similar)
ldd static_binaries/kubectl
ldd static_binaries/jq  # musl-linked, may show error
```

## Architecture & Key Components

### Build Script (`build_static_tools.sh`)
- Creates isolated build environment in temporary directory
- Builds each tool from source with static linking flags
- Special handling for jq (uses musl-gcc for true static linking)
- Automatic cleanup on exit via trap

### CI/CD Pipeline (`.github/workflows/build-release.yml`)
- **Triggers**: Push to main (dev builds) and version tags (releases)
- **Versioning**: CalVer format (YY.MM.patch-tag)
  - Release versions: From git tags (e.g., v25.07.3)
  - Dev versions: YY.MM.RUN_NUMBER-dev
- **Jobs**:
  1. `build_binaries`: Compiles all static binaries
  2. `scan_binaries`: Security scanning with Trivy (HIGH/CRITICAL only)
  3. `package_binaries`: Creates .deb/.rpm packages with FPM
  4. `sign_packages`: GPG signing (release tags only)
  5. `release`: Publishes to GitHub Releases

### Included Tools
- **kubectl**: Built with `CGO_ENABLED=0` and static flags
- **helm**: Built with `CGO_ENABLED=0` and static flags
- **jq**: Built with musl-gcc for true static linking
- **skopeo**: Built with static flags, excludes btrfs driver
- **oras**: Built with `CGO_ENABLED=0` and static flags
- **cosign**: Built with `CGO_ENABLED=0` and static flags
- **flux**: Built via flux2 Makefile with static flags

### Package Metadata
- Maintainer: Martin Stadler <martin@sansnom.co>
- Vendor: sansnom-co
- License: Apache-2.0 (workflow), MIT (README)
- Dependencies: ca-certificates only
- Install path: /usr/local/bin/

## Release Information

### Release Patterns
- **Versioning**: CalVer format YY.MM.patch (e.g., v25.07.4)
- **Frequency**: Active development with frequent releases
- **Naming**: "K8s Tools vYY.MM.patch" in GitHub Releases
- **Artifacts**: 
  - `.deb` package for Debian/Ubuntu (amd64)
  - `.rpm` package for RHEL/Fedora (x86_64)
  - `.asc` GPG signature files for each package

### Download URLs
```bash
# Debian/Ubuntu package
https://github.com/sansnom-co/k8s-tools/releases/download/v{version}/k8s-tools_{version}-1_amd64.deb
https://github.com/sansnom-co/k8s-tools/releases/download/v{version}/k8s-tools_{version}-1_amd64.deb.asc

# RHEL/Fedora package
https://github.com/sansnom-co/k8s-tools/releases/download/v{version}/k8s-tools-{version}-1.x86_64.rpm
https://github.com/sansnom-co/k8s-tools/releases/download/v{version}/k8s-tools-{version}-1.x86_64.rpm.asc
```

### GPG Verification
- Signing Key: B24A23CCB7E16E36 (martin@sansnom.co)
- All release packages are GPG signed
- Verify with: `gpg --verify package.asc package`

## Repository Information

### GitHub Repository
- URL: https://github.com/sansnom-co/k8s-tools
- License: MIT
- Language: 100% Shell
- Stars: 1 (as of last check)
- Maintainer: Martin Stadler (@mestadler)

### Project Purpose
Provides statically linked Kubernetes CLI tools as portable, self-contained executables that work across different Linux distributions without dependency issues.

### Build Prerequisites
```bash
# Required packages for building
sudo apt update
sudo apt install -y git golang build-essential pkg-config \
  libc6-dev libgpgme-dev libdevmapper-dev libbtrfs-dev \
  libseccomp-dev libassuan-dev libgpg-error-dev \
  libpcsclite-dev musl-tools musl-dev
```

## Release Information

### Release Patterns
- **Versioning**: CalVer format YY.MM.patch (e.g., 24.12.2, 24.12.3)
- **Release Frequency**: Active development with frequent releases
- **Package Naming**:
  - .deb: `k8s-tools_VERSION-1_amd64.deb`
  - .rpm: `k8s-tools-VERSION-1.x86_64.rpm`

### Download URLs
```bash
# .deb package
https://github.com/sansnom-co/k8s-tools/releases/download/vVERSION/k8s-tools_VERSION-1_amd64.deb

# .rpm package  
https://github.com/sansnom-co/k8s-tools/releases/download/vVERSION/k8s-tools-VERSION-1.x86_64.rpm

# GPG signatures (.asc files)
https://github.com/sansnom-co/k8s-tools/releases/download/vVERSION/k8s-tools_VERSION-1_amd64.deb.asc
https://github.com/sansnom-co/k8s-tools/releases/download/vVERSION/k8s-tools-VERSION-1.x86_64.rpm.asc
```

### GPG Verification
- **Key ID**: B24A23CCB7E16E36
- **Key Owner**: martin@sansnom.co
- All release packages are GPG signed

## Repository Information

- **GitHub**: https://github.com/sansnom-co/k8s-tools
- **License**: MIT
- **Language**: Shell (build scripts) and Go (tool sources)
- **Purpose**: Provide portable, statically-linked Kubernetes CLI tools as system packages

### Build Prerequisites (from workflow)
```bash
sudo apt update
sudo apt install -y git golang build-essential pkg-config libc6-dev \
  libgpgme-dev libdevmapper-dev libbtrfs-dev libseccomp-dev \
  libassuan-dev libgpg-error-dev libpcsclite-dev musl-tools musl-dev
```

## Important Notes

1. **Build Environment**: Requires Debian-based system with extensive dev libraries
2. **Static Verification**: Use `ldd` to confirm static linking
3. **FPM Commands**: Must be single-line in GitHub Actions (use sh -c wrapper)
4. **GPG Signing**: Requires GPG_PRIVATE_KEY and GPG_PASSPHRASE secrets
5. **No Testing Framework**: Currently no unit/integration tests
6. **No Linting**: No shellcheck or code quality tools configured
7. **Release Workflow**: Full CI/CD takes approximately 12-20 minutes
8. **Development Builds**: Main branch builds use format YY.MM.GITHUB_RUN_NUMBER-dev