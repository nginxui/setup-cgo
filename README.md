# setup-cgo

A GitHub Action that installs the C cross compiler for a Go target and sets
`CC`, `CXX` and `CGO_ENABLED=1`, so `go build` links cgo packages such as
SQLite for that target. It covers the targets Nginx UI is released for and
uses the same toolchains as its release builds.

```yaml
- uses: actions/setup-go@v7
  with:
    go-version: stable

- id: cgo
  uses: nginxui/setup-cgo@v1
  with:
    goos: linux
    goarch: arm
    goarm: '5'

- env:
    GOOS: linux
    GOARCH: arm
    GOARM: '5'
  run: go build -ldflags "-s -w -extldflags '${{ steps.cgo.outputs.extldflags }}'" .
```

## Targets

| GOOS | GOARCH | Toolchain | Runner |
| --- | --- | --- | --- |
| linux | 386, amd64, arm64, arm (GOARM 5, 6, 7), riscv64, loong64, mips, mipsle, mips64, mips64le | musl cross compilers from [musl-cross-compilers](https://github.com/nginxui/musl-cross-compilers), statically linked | x64 Linux |
| windows | 386, amd64 | MinGW-w64 from the Ubuntu packages | x64 Linux |
| windows | arm64 | [llvm-mingw](https://github.com/mstorsjo/llvm-mingw), checked against its digest | x64 Linux |
| darwin | amd64, arm64 | the clang of the runner | macOS |

An empty `goarm` means GOARM 7, Go's default. The musl toolchain download is
tried three times, it fails now and then.

## Outputs

| Output | Value |
| --- | --- |
| `cc`, `cxx` | The compilers, also exported as `CC` and `CXX`. |
| `extldflags` | Flags for the external linker: `-static` on Linux, empty elsewhere. |
| `triple` | The target triple of the toolchain. |

## License

MIT
