#!/usr/bin/env bash
# Usage: build_wheel.sh <workspace_root> <output_dir> <arch>
set -euo pipefail
WORKSPACE="${1:-/workspace}"
OUTDIR="${2:-/workspace/out}"
ARCH="${3:-aarch64}"

source "${WORKSPACE}/scripts/common_helpers.sh"

log "Starting wheel builds for arch=${ARCH}"
bootstrap_pip
install_build_deps

# export some env expected by some builds
export CFLAGS="-O2 -fPIC"
export LDFLAGS=""

# list of packages to build — adjust order (numpy first)
PKGS=( numpy scipy pandas scikit-learn cryptography lxml )

# PyTorch / TensorFlow are special-case (attempt CPU-only builds; may fail)
PKGS+=( pytorch tensorflow )

for pkg in "${PKGS[@]}"; do
  if [ -f "${WORKSPACE}/packages/${pkg}/build.sh" ]; then
    log "Building ${pkg}"
    bash "${WORKSPACE}/packages/${pkg}/build.sh" "${WORKSPACE}" "${OUTDIR}" "${ARCH}"
  else
    log "No build.sh for ${pkg}, attempting pip wheel"
    python3 -m pip wheel --no-deps --wheel-dir "${OUTDIR}" "${pkg}"
  fi
done

log "Done building. Wheels in: ${OUTDIR}"