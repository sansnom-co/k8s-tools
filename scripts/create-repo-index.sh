#!/bin/bash

# Create the index.html file for the GitHub Pages repository

cat > index.html << 'ENDHTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>K8s Tools - Debian Repository</title>
    <style>
        :root {
            --bg-color: #0d1117;
            --text-color: #58a6ff;
            --code-bg: #161b22;
            --border-color: #30363d;
        }
        body {
            background-color: var(--bg-color);
            color: var(--text-color);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        h1, h2, h3 {
            color: #58a6ff;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 0.3em;
        }
        code {
            background-color: var(--code-bg);
            padding: 0.2em 0.4em;
            border-radius: 3px;
            font-size: 85%;
        }
        pre {
            background-color: var(--code-bg);
            padding: 16px;
            overflow-x: auto;
            border-radius: 6px;
            border: 1px solid var(--border-color);
        }
        pre code {
            background-color: transparent;
            padding: 0;
        }
        a {
            color: #58a6ff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 1em 0;
        }
        th, td {
            border: 1px solid var(--border-color);
            padding: 0.6em 1em;
            text-align: left;
        }
        th {
            background-color: var(--code-bg);
        }
        .highlight {
            color: #7ee83f;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 K8s Tools Debian Repository</h1>
        
        <p>This repository provides Debian packages for statically linked Kubernetes CLI tools. All tools are built from source and statically linked for maximum portability.</p>
        
        <h2>📦 Quick Installation</h2>
        
        <p>Add this repository to your Debian/Ubuntu system:</p>
        
        <pre><code># Add the GPG key
wget -O- <a href="/k8s-tools/public_key.asc">https://sansnom-co.github.io/k8s-tools/public_key.asc</a> | \
  sudo gpg --dearmor -o /usr/share/keyrings/sansnom-k8s-tools.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/sansnom-k8s-tools.gpg] \
  https://sansnom-co.github.io/k8s-tools stable main" | \
  sudo tee /etc/apt/sources.list.d/sansnom-k8s-tools.list

# Update and install
sudo apt update
sudo apt install k8s-tools</code></pre>
        
        <h2>🛠️ Included Tools</h2>
        
        <table>
            <thead>
                <tr>
                    <th>Tool</th>
                    <th>Description</th>
                    <th>Version</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>kubectl</strong></td>
                    <td>Kubernetes command-line tool</td>
                    <td>Latest</td>
                </tr>
                <tr>
                    <td><strong>helm</strong></td>
                    <td>Kubernetes package manager</td>
                    <td>Latest</td>
                </tr>
                <tr>
                    <td><strong>jq</strong></td>
                    <td>Command-line JSON processor</td>
                    <td>Latest</td>
                </tr>
                <tr>
                    <td><strong>skopeo</strong></td>
                    <td>Container image inspection and copying</td>
                    <td>Latest</td>
                </tr>
                <tr>
                    <td><strong>oras</strong></td>
                    <td>OCI Registry As Storage CLI</td>
                    <td>Latest</td>
                </tr>
                <tr>
                    <td><strong>cosign</strong></td>
                    <td>Container signing and verification</td>
                    <td>Latest</td>
                </tr>
                <tr>
                    <td><strong>flux</strong></td>
                    <td>GitOps toolkit for Kubernetes</td>
                    <td>Latest</td>
                </tr>
            </tbody>
        </table>
        
        <h2>🔐 Security</h2>
        
        <ul>
            <li>All packages are GPG signed</li>
            <li>Binaries are statically linked</li>
            <li>Built from official upstream sources</li>
            <li>Automated security scanning with Trivy</li>
        </ul>
        
        <h2>📝 Repository Details</h2>
        
        <ul>
            <li><strong>Suite</strong>: stable</li>
            <li><strong>Component</strong>: main</li>
            <li><strong>Architecture</strong>: amd64</li>
            <li><strong>GPG Key ID</strong>: B24A23CCB7E16E36</li>
        </ul>
        
        <h2>🔗 Links</h2>
        
        <ul>
            <li><a href="https://github.com/sansnom-co/k8s-tools">GitHub Repository</a></li>
            <li><a href="https://github.com/sansnom-co/k8s-tools/releases">Releases</a></li>
            <li><a href="/k8s-tools/public_key.asc">GPG Public Key</a></li>
        </ul>
        
        <h2>📊 Repository Structure</h2>
        
        <pre><code>/
├── <a href="/k8s-tools/dists/">dists/stable/</a>         # APT metadata
│   └── main/
│       └── binary-amd64/
├── <a href="/k8s-tools/pool/">pool/main/k/k8s-tools/</a>  # Package files
└── <a href="/k8s-tools/public_key.asc">public_key.asc</a>          # GPG public key</code></pre>
        
        <hr>
        
        <p><small>Updated automatically via GitHub Actions</small></p>
    </div>
</body>
</html>
ENDHTML