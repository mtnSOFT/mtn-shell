#!/usr/bin/env bash
set -euo pipefail

# Install OS packages, node, podman CLI and npm tools.
apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates \
  curl wget \
  less \
  gnupg \
  neovim \
  git git-lfs \
  dnsutils mtr iputils-ping ncat \
  podman podman-compose slirp4netns fuse-overlayfs uidmap \
  shellcheck shfmt \
  qrencode \
  jq \
  bash-completion \
  ssh \
  sudo \
  lsb-release \
  python3 python3-pip python3-venv build-essential

# NodeJS 24
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
apt-get install -y --no-install-recommends nodejs

# npm global tools
npm install -g prettier

# Install Bitwarden CLI
npm install -g @bitwarden/cli

# Install latest kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl kubectl.sha256

# Install latest Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# cleanup to reduce image size
apt-get clean
rm -rf /var/lib/apt/lists/*
