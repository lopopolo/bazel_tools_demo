# gofmt check

This binary is a test runner for the `gofmt_test` Bazel rule which runs `gofmt`
over the given source files and checks for invalid formatting.

This wrapper script exists because `gofmt` does not have a CI-friendly mode
which exits non-zero when it detects formatting changes. Instead, this script
must detect non-empty output from `gofmt`.

## Usage

```console
$ bazel run //tools/gofmt/check -- -help
Usage of .../bin/tools/gofmt/check/check_/check:
  -gofmt string
        path to gofmt binary
  -sourcesfile string
        path to list of go sources to check
```
