# k8s-tools: Statically Linked Kubernetes CLI Tools

This repository provides a collection of essential Kubernetes command-line interface (CLI) tools, built as statically linked binaries. The primary goal is to offer highly portable, self-contained executables that can be easily distributed and run on various Linux distributions (such as Debian, Ubuntu, and RHEL-based systems) without requiring complex dependency management on the target machines.  These staticly linked binaries are pulled directly for their projects repos, built, scanned and released.

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

This project uses a CalVer (Calendar Versioning) scheme for releases, in the format `YY.MM.patch-tag` (e.g., `24.07.0-alpha`).

## Installation

### Using Pre-built Packages (Recommended)

The deb and rpm packages can be grabbed from the release (left hand side of this readme).

Coming soon, the easiest way to install these tools is by adding our package repositories to your system. Packages are automatically built and published via GitHub Actions.

**1. Add the GPG Key:**

First, import the public GPG key used to sign the repository and packages. This ensures the authenticity and integrity of the packages.

```bash
wget -O- https://sansnom.github.io/k8s-tools/public_key.asc | sudo gpg --dearmor -o /usr/share/keyrings/sansnom-k8s-tools.gpg
```

**2. Add the Repository:**

Choose your distribution type below:

#### For Debian/Ubuntu-based Systems (APT)

Create a new file `/etc/apt/sources.list.d/sansnom-k8s-tools.list` with the following content:

```
deb [signed-by=/usr/share/keyrings/sansnom-k8s-tools.gpg] https://sansnom.github.io/k8s-tools stable main
```

Then, update your package list and install:

```bash
sudo apt update
sudo apt install k8s-tools
```

#### For RHEL/CentOS-based Systems (RPM)

Create a new file `/etc/yum.repos.d/sansnom-k8s-tools.repo` with the following content:

```
[sansnom-k8s-tools]
name=Sansnom K8s Tools
baseurl=https://sansnom.github.io/k8s-tools/rpm
enabled=1
gpgcheck=0 # Set to 1 if you implement RPM signing and import the key
```

Then, install the package:

```bash
sudo yum install k8s-tools # or dnf install k8s-tools
```

### Building from Source

If you prefer to build the tools yourself, or if you need a specific version not yet released, you can use the provided build script.

**Prerequisites:**

Ensure you have `git`, `golang`, `build-essential`, `pkg-config`, and various development libraries (including `musl-tools` and `musl-dev` for `jq`) installed on your Debian-based system. The `build_static_tools.sh` script will attempt to install these for you.

```bash
# Clone the repository
git clone https://github.com/sansnom/k8s-tools.git
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

## Contributing

Contributions are welcome! Please refer to the `CONTRIBUTING.md` file for guidelines.

## License

This project is licensed under the [MIT License](LICENSE).
