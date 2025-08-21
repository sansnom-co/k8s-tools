# k8s-tools: Statically Linked Kubernetes CLI Tools

This repository provides a collection of essential Kubernetes command-line interface (CLI) tools, built as statically linked binaries. The primary goal is to offer highly portable, self-contained executables that can be easily distributed and run on various Linux distributions (such as Debian, Ubuntu, and RHEL-based systems) without requiring complex dependency management on the target machines. These statically linked binaries are pulled directly from their projects' repos, built, scanned and released.

## Included Tools

This project currently builds and packages the following tools:

*   `kubectl`: The Kubernetes command-line tool for running commands against Kubernetes clusters.
*   `helm`: The package manager for Kubernetes.
*   `jq`: A lightweight and flexible command-line JSON processor.
*   `skopeo`: A command-line utility for working with container images and image repositories.
*   `oras`: OCI Registry As Storage, a tool for managing artifacts in OCI registries.
*   `cosign`: A tool for signing, verifying, and storing signatures for container images and other artifacts.
*   `flux`: The Flux CLI, for managing GitOps deployments with Flux CD.

## Why Statically Linked?

Statically linked binaries include all their necessary libraries and dependencies directly within the executable file. This eliminates the need for the target system to have specific versions of those libraries installed, greatly simplifying deployment and ensuring consistent behavior across different environments.

## Versioning

This project uses a CalVer (Calendar Versioning) scheme for releases, in the format `YY.MM.patch` (e.g., `25.08.1`).

## Installation

### Using Pre-built Packages (Recommended)

#### Option 1: Install from APT Repository (Debian/Ubuntu)

The easiest way to install these tools is by adding our APT repository to your system.

**Note**: The APT repository redirects to GitHub Releases for package downloads, so you'll need internet access during installation.

##### For APT 2.x (Traditional format)

**1. Add the GPG Key:**

```bash
wget -O- https://sansnom-co.github.io/k8s-tools/public_key.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/sansnom-k8s-tools.gpg
```

**2. Add the Repository:**

```bash
echo "deb [signed-by=/usr/share/keyrings/sansnom-k8s-tools.gpg] \
  https://sansnom-co.github.io/k8s-tools stable main" | \
  sudo tee /etc/apt/sources.list.d/sansnom-k8s-tools.list
```

**3. Install the Package:**

```bash
sudo apt update
sudo apt install k8s-tools
```

##### For APT 3.0+ (deb822 format)

**1. Add the GPG Key:**

```bash
wget -O- https://sansnom-co.github.io/k8s-tools/public_key.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/sansnom-k8s-tools.gpg
```

**2. Add the Repository:**

```bash
sudo tee /etc/apt/sources.list.d/sansnom-k8s-tools.sources << EOF
Types: deb
URIs: https://sansnom-co.github.io/k8s-tools
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/sansnom-k8s-tools.gpg
EOF
```

**3. Install the Package:**

```bash
sudo apt update
sudo apt install k8s-tools
```

#### Option 2: Direct Download

You can also download packages directly from the [releases page](https://github.com/sansnom-co/k8s-tools/releases).

```bash
# Download the latest .deb package
wget https://github.com/sansnom-co/k8s-tools/releases/latest/download/k8s-tools_*.deb

# Install the package
sudo dpkg -i k8s-tools_*.deb
```

#### For RHEL/CentOS-based Systems (RPM)

**Note**: RPM packages are available in the releases but not yet served via a YUM repository.

```bash
# Download the latest .rpm package
wget https://github.com/sansnom-co/k8s-tools/releases/latest/download/k8s-tools-*.rpm

# Install the package
sudo rpm -ivh k8s-tools-*.rpm
```

### Building from Source

If you prefer to build the tools yourself, or if you need a specific version not yet released, you can use the provided build script.

**Prerequisites:**

Ensure you have `git`, `golang`, `build-essential`, `pkg-config`, and various development libraries (including `musl-tools` and `musl-dev` for `jq`) installed on your Debian-based system. The `build_static_tools.sh` script will attempt to install these for you.

```bash
# Clone the repository
git clone https://github.com/sansnom-co/k8s-tools.git
cd k8s-tools

# Make the build script executable
chmod +x build_static_tools.sh

# Run the build script
./build_static_tools.sh
```

Upon successful completion, the statically linked binaries will be located in the `static_binaries/` directory within your repository clone.

## Verification

To verify that a binary is statically linked, you can use the `ldd` command. For truly static binaries, `ldd` will report "not a dynamic executable" or, for `musl`-linked binaries like `jq`, it might show an error when trying to load `glibc` shared libraries (which is expected and confirms its static nature).

```bash
ls -lh static_binaries/kubectl
ldd static_binaries/kubectl

ls -lh static_binaries/jq
ldd static_binaries/jq
```

## Security

- All packages are GPG signed with key ID: `B24A23CCB7E16E36`
- Binaries are statically linked for security and portability
- Built from official upstream sources
- Automated security scanning with Trivy on every build
- Automated upstream release monitoring

## Repository Information

- **APT Repository**: https://sansnom-co.github.io/k8s-tools
- **GitHub Repository**: https://github.com/sansnom-co/k8s-tools
- **Releases**: https://github.com/sansnom-co/k8s-tools/releases
- **GPG Public Key**: https://sansnom-co.github.io/k8s-tools/public_key.asc

## Contributing

Contributions are welcome! Please refer to the `CONTRIBUTING.md` file for guidelines.

## License

This project is licensed under the [MIT License](LICENSE).
