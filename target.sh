#!/usr/bin/env bash
# Picks the C toolchain of a Go target. Reads GOOS, GOARCH and GOARM and
# writes kind, triple and variant to GITHUB_OUTPUT. The Linux triples follow
# the musl cross compilers Nginx UI builds with.
set -euo pipefail

kind="" triple="" variant="richfelker/musl-cross-make"
case "${GOOS}" in
  linux)
    kind=linux
    case "${GOARCH}" in
      386) triple=i686-linux-musl ;;
      amd64) triple=x86_64-linux-musl ;;
      arm64) triple=aarch64-linux-musl ;;
      arm)
        case "${GOARM:-7}" in
          5) triple=arm-linux-musleabi ;;
          6) triple=armv5l-linux-musleabihf ;;
          7) triple=armv7l-linux-musleabihf ;;
          *) echo "::error::GOARM ${GOARM} is not supported, use 5, 6 or 7" >&2; exit 1 ;;
        esac ;;
      riscv64) triple=riscv64-linux-musl ;;
      loong64) triple=loongarch64-linux-musl; variant=userdocs/qbt-musl-cross-make ;;
      mips) triple=mips-linux-musl ;;
      mipsle) triple=mipsel-linux-musl ;;
      mips64) triple=mips64-linux-musl ;;
      mips64le) triple=mips64el-linux-musl ;;
    esac ;;
  windows)
    kind=windows
    case "${GOARCH}" in
      386) triple=i686-w64-mingw32 ;;
      amd64) triple=x86_64-w64-mingw32 ;;
      arm64) triple=aarch64-w64-mingw32 ;;
    esac ;;
  darwin)
    kind=darwin
    case "${GOARCH}" in
      amd64 | arm64) triple="${GOARCH}-apple-darwin" ;;
    esac ;;
esac

if [[ -z "${triple}" ]]; then
  echo "::error::${GOOS}/${GOARCH} is not a target setup-cgo knows" >&2
  exit 1
fi
if [[ "${kind}" == darwin && "${RUNNER_OS}" != macOS ]]; then
  echo "::error::darwin targets build on a macOS runner, its clang has the SDK" >&2
  exit 1
fi
if [[ "${kind}" != darwin && ( "${RUNNER_OS}" != Linux || "${RUNNER_ARCH}" != X64 ) ]]; then
  echo "::error::${GOOS} targets build on an x64 Linux runner" >&2
  exit 1
fi

{
  echo "kind=${kind}"
  echo "triple=${triple}"
  echo "variant=${variant}"
} >> "${GITHUB_OUTPUT}"
