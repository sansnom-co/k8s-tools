# K8s Tools Debian Repository

This repository provides Debian packages for statically linked Kubernetes CLI tools. All tools are built from source and statically linked for maximum portability.

## 🚀 Quick Installation

Add this repository to your Debian/Ubuntu system:

```bash
# Add the GPG key
wget -O- https://sansnom-co.github.io/k8s-tools/public_key.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/sansnom-k8s-tools.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/sansnom-k8s-tools.gpg] \
  https://sansnom-co.github.io/k8s-tools stable main" | \
  sudo tee /etc/apt/sources.list.d/sansnom-k8s-tools.list

# Update and install
sudo apt update
sudo apt install k8s-tools
```

## 📦 Included Tools

| Tool | Description | Version |
|------|-------------|---------|
| **kubectl** | Kubernetes command-line tool | Latest |
| **helm** | Kubernetes package manager | Latest |
| **jq** | Command-line JSON processor | Latest |
| **skopeo** | Container image inspection and copying | Latest |
| **oras** | OCI Registry As Storage CLI | Latest |
| **cosign** | Container signing and verification | Latest |
| **flux** | GitOps toolkit for Kubernetes | Latest |

## 🔐 Security

- All packages are GPG signed
- Binaries are statically linked
- Built from official upstream sources
- Automated security scanning with Trivy

## 📝 Repository Details

- **Suite**: stable
- **Component**: main
- **Architecture**: amd64
- **GPG Key ID**: B24A23CCB7E16E36

## 🔗 Links

- [GitHub Repository](https://github.com/sansnom-co/k8s-tools)
- [Releases](https://github.com/sansnom-co/k8s-tools/releases)
- [GPG Public Key](https://sansnom-co.github.io/k8s-tools/public_key.asc)

## 📊 Repository Structure

```
/
├── dists/stable/         # APT metadata
│   └── main/
│       └── binary-amd64/
├── pool/main/k/k8s-tools/  # Package files
└── public_key.asc          # GPG public key
```

---

<small>Updated automatically via GitHub Actions</small>
