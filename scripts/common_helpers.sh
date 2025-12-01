#!/usr/bin/env bash
set -euo pipefail

log() { echo "==> $*"; }
export -f log

bootstrap_pip() {
  python3 -m pip install --upgrade pip setuptools wheel
}

install_build_deps() {
  # Install common build deps for Termux container (may be no-op in some images)
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y build-essential python3-dev python3-pip python3-setuptools python3-wheel pkg-config git cmake gfortran libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev
  fi
}