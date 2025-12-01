#!/usr/bin/env bash
set -euo pipefail
ARCH=${1:-amd64}
# Build deb using dpkg-buildpackage in a Debian container
docker run --rm -v "$PWD":/src -w /src -e DEBEMAIL="you@example.com" -e DEBFULLNAME="You" debian:bookworm /bin/bash -lc "\
  apt-get update && apt-get install -y build-essential nodejs npm debhelper && \
  dpkg-buildpackage -us -uc -b -a ${ARCH}"