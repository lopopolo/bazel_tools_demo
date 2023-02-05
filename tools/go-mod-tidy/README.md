# `go mod tidy` for Bazel Monorepo

```shell
bazel run //tools/go-mod-tidy
```

This tool works together with Gazelle and `//tools/update-go-deps` to run
`go mod tidy` on all packages with go code in this Bazel workspace.

This tool ensures all `go.mod` files have the workspace-defined go version,
prunes unused deps with `go mod tidy`, ensures the dummy package at the root of
this workspace properly declares all deps, and that Gazelle generates
`go_repository` declarations for all deps.

This tool should be invoked directly instead of `//tools/update-go-deps`.
