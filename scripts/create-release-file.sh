#!/bin/bash

# Script to create a properly formatted APT Release file

cd "$1" || exit 1

cat > Release << EOF
Origin: sansnom-co
Label: K8s Tools
Suite: stable
Codename: stable
Version: 1.0
Architectures: amd64
Components: main
Description: Statically linked Kubernetes CLI tools
Date: $(date -Ru)
EOF

# Add MD5Sum with proper format: checksum size path
echo "MD5Sum:" >> Release
find main -type f -name "Packages*" | sort | while read -r file; do
    size=$(stat -c%s "$file")
    checksum=$(md5sum "$file" | cut -d' ' -f1)
    # Remove leading ./ and format properly
    filepath=$(echo "$file" | sed 's|^\./||')
    printf " %s %16d %s\n" "$checksum" "$size" "$filepath" >> Release
done

# Add SHA1
echo "SHA1:" >> Release
find main -type f -name "Packages*" | sort | while read -r file; do
    size=$(stat -c%s "$file")
    checksum=$(sha1sum "$file" | cut -d' ' -f1)
    filepath=$(echo "$file" | sed 's|^\./||')
    printf " %s %16d %s\n" "$checksum" "$size" "$filepath" >> Release
done

# Add SHA256
echo "SHA256:" >> Release
find main -type f -name "Packages*" | sort | while read -r file; do
    size=$(stat -c%s "$file")
    checksum=$(sha256sum "$file" | cut -d' ' -f1)
    filepath=$(echo "$file" | sed 's|^\./||')
    printf " %s %16d %s\n" "$checksum" "$size" "$filepath" >> Release
done

echo "Release file created successfully"