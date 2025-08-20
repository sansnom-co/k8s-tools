#!/bin/bash

# Create a notice file explaining the repository structure

cat > REPO_NOTICE.md << 'EOF'
# K8s Tools APT Repository Structure

This APT repository uses a **redirect approach** to avoid GitHub's file size limitations:

## How it works:

1. **Metadata only**: The repository contains only APT metadata (Packages, Release files)
2. **Package downloads**: Actual .deb files are downloaded directly from GitHub Releases
3. **Transparent to users**: APT handles the redirects automatically

## Benefits:

- No file size limitations
- Always serves the latest releases
- Reduces repository size
- Faster GitHub Pages deployment

## Structure:

```
/
├── dists/stable/           # APT metadata only
│   ├── Release            # Repository info
│   ├── Release.gpg        # GPG signature
│   ├── InRelease          # Signed repository info
│   └── main/binary-amd64/
│       ├── Packages       # Package listings with URLs
│       └── Packages.gz    # Compressed package listings
├── public_key.asc         # GPG public key
└── index.html             # Landing page
```

Note: The `pool/` directory is not needed since packages are served from GitHub Releases.
EOF