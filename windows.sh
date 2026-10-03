#!/usr/bin/env bash
# Installs the MinGW toolchain of a Windows target named by TRIPLE and writes
# cc and cxx to GITHUB_OUTPUT. Ubuntu packages MinGW for x86 only, arm64
# takes llvm-mingw, checked against its known digest.
set -euo pipefail

LLVM_MINGW_VERSION=20231128
LLVM_MINGW_SHA256=0f21ff3be90311092fe32e0e30878ef3ae9d9437b8d9ac25ef279e0d84e9bb8e

retry() {
  for pause in 10 30 0; do
    "$@" && return 0
    [[ "${pause}" -eq 0 ]] && return 1
    echo "retrying in ${pause}s: $*" >&2
    sleep "${pause}"
  done
}

case "${TRIPLE}" in
  x86_64-w64-mingw32 | i686-w64-mingw32)
    arch="${TRIPLE%%-*}"
    package="${arch//_/-}"
    retry sudo apt-get update -qq
    retry sudo apt-get install -y -qq "gcc-mingw-w64-${package}" "g++-mingw-w64-${package}"
    cc="${TRIPLE}-gcc" cxx="${TRIPLE}-g++" ;;
  aarch64-w64-mingw32)
    name="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-ubuntu-20.04-x86_64"
    archive="${RUNNER_TEMP}/${name}.tar.xz"
    retry curl -fsSL -o "${archive}" "https://github.com/mstorsjo/llvm-mingw/releases/download/${LLVM_MINGW_VERSION}/${name}.tar.xz"
    echo "${LLVM_MINGW_SHA256}  ${archive}" | sha256sum -c -
    dir="${RUNNER_TEMP}/llvm-mingw"
    mkdir -p "${dir}"
    tar xf "${archive}" -C "${dir}" --strip-components=1
    rm "${archive}"
    echo "${dir}/bin" >> "${GITHUB_PATH}"
    cc="${TRIPLE}-clang" cxx="${TRIPLE}-clang++" ;;
  *)
    echo "::error::no MinGW toolchain for ${TRIPLE}" >&2
    exit 1 ;;
esac

{
  echo "cc=${cc}"
  echo "cxx=${cxx}"
} >> "${GITHUB_OUTPUT}"
