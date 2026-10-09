#!/usr/bin/env bash
set -euo pipefail

python3 -m venv /opt/python-venv
pip install --no-cache-dir --upgrade pip==26.1.2 \
  molecule==26.6.0 \
  ansible==14.2.0 \
  kubernetes==36.0.3 \
  httpx==0.28.1 \
  pytest \
  testinfra \
  yamllint \
  "molecule-plugins[podman]==26.7.15"
