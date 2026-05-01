# k8s-tools: Statically Linked Kubernetes CLI Tools

Statically linked, independently versioned packages for essential Kubernetes CLI tools. Each tool is built directly from its upstream source, security-scanned, GPG-signed, and published as its own package to an APT repository.

## Included Tools

| Package | Description |
|---------|-------------|
| `kubectl` | Run commands against Kubernetes clusters |
| `helm` | The Kubernetes package manager |
| `jq` | Command-line JSON processor |
| `skopeo` | Inspect and copy container images across registries |
| `oras` | Push and pull artifacts to and from OCI registries |
| `cosign` | Sign and verify container images |
| `flux` | Manage GitOps deployments with Flux CD |

## Installation

### APT Repository (Debian/Ubuntu)

**1. Add the GPG key:**

```bash
wget -O- https://sansnom-co.github.io/k8s-tools/public_key.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/sansnom-k8s-tools.gpg
```

**2. Add the repository:**

```bash
# APT 2.x (traditional format)
echo "deb [signed-by=/usr/share/keyrings/sansnom-k8s-tools.gpg] \
  https://sansnom-co.github.io/k8s-tools stable main" | \
  sudo tee /etc/apt/sources.list.d/sansnom-k8s-tools.list

# APT 3.0+ (deb822 format)
sudo tee /etc/apt/sources.list.d/sansnom-k8s-tools.sources << 'EOF'
Types: deb
URIs: https://sansnom-co.github.io/k8s-tools
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/sansnom-k8s-tools.gpg
EOF
```

**3. Install:**

```bash
sudo apt update

# Install all tools at once (recommended)
sudo apt install kube-essential

# Or install individual tools
sudo apt install kubectl
sudo apt install helm jq
```

`kube-essential` is a meta-package — like `build-essential` but for Kubernetes. It has no files of its own; it just declares dependencies on each individual tool package, so you get everything with a single `apt install` and each tool upgrades independently as new versions are released.

### Direct Download (RPM / offline)

Each tool is released under its own tag (`kubectl-v1.36.0`, `helm-v4.1.4`, etc.) on the [releases page](https://github.com/sansnom-co/k8s-tools/releases).

```bash
# Example: download and install kubectl directly
wget https://github.com/sansnom-co/k8s-tools/releases/download/kubectl-v1.36.0/kubectl_1.36.0-1_amd64.deb
sudo dpkg -i kubectl_1.36.0-1_amd64.deb

# RPM (RHEL/Fedora)
wget https://github.com/sansnom-co/k8s-tools/releases/download/kubectl-v1.36.0/kubectl-1.36.0-1.x86_64.rpm
sudo rpm -ivh kubectl-1.36.0-1.x86_64.rpm
```

> **Migrating from `k8s-tools`?** If you had the old bundled package installed, running `apt upgrade` will automatically transition you to the new per-tool packages via `kube-essential`.

## Versioning

Each tool package tracks its own upstream version — `kubectl_1.36.0`, `helm_4.1.4`, etc. — so you can see exactly what's installed. The `kube-essential` meta-package uses CalVer (`YY.MM.patch`) and is updated whenever any tool changes.

Upstream versions are monitored automatically every 6 hours. When a new release is detected, only the affected tool rebuilds; the others are untouched.

## Building from Source

```bash
git clone https://github.com/sansnom-co/k8s-tools.git
cd k8s-tools

# Build a single tool (version read from .last_known_versions)
bash scripts/build-tool.sh kubectl

# Override the version
VERSION=v1.36.0 bash scripts/build-tool.sh kubectl
```

Binaries are written to `static_binaries/`. The script installs only the prerequisites needed for the requested tool.

## Why Static?

Statically linked binaries carry all their dependencies inside the executable. No shared library mismatches, no runtime surprises — the same binary works on Debian, Ubuntu, RHEL, and Alpine without modification.

## Security

- All packages are GPG signed (key ID: `B24A23CCB7E16E36`)
- Every build is scanned for HIGH/CRITICAL CVEs with [Trivy](https://trivy.dev)
- Binaries are built from official upstream source tags with verified commits

## Repository Links

- **APT repository**: https://sansnom-co.github.io/k8s-tools
- **GitHub releases**: https://github.com/sansnom-co/k8s-tools/releases
- **GPG public key**: https://sansnom-co.github.io/k8s-tools/public_key.asc

## License

[MIT License](LICENSE)

<p align="center">Made with ❤️ and ☕ in London</p>
