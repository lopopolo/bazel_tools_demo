# Update Golang deps tool

```shell
bazel run //tools/update-go-deps
```

Gazelle does not support version management for multiple `go.mod` files
([bazelbuild/buld-gazelle#634][bazel-issue]) for every module in the repository.

[bazel-issue]: https://github.com/bazelbuild/bazel-gazelle/issues/634

This tool solves the problem by implementing the following algorithm:

1. Find all modules in the repository
2. Merge their require sections, while always picking the latest version, and
   write them to the root `go.mod` file
3. Install the packages using `go get` and run `update-repo` on the root
   `go.mod`
4. To ensure that all packages use root version of each dependency merge the
   require statements back and update the modules

To make this work you have to add an empty `main.go` at the root of the
repository so that `go get` recognizes it as a package.

The `//:static` target is the dummy package at the workspace root that allows
`//tools/update-go-deps` succeed.

## License

The `//tools/update-go-deps` package was forked from the following repository:

**Repository**: <https://github.com/airyhq/airy>  
**SHA**: [8e5b06947d906f470e7507c9dca93e1934d5a349][airy-sha]  
**License**: [Apache-2.0][airy-license]

[airy-sha]:
  https://github.com/airyhq/airy/commit/8e5b06947d906f470e7507c9dca93e1934d5a349
[airy-license]:
  https://github.com/airyhq/airy/blob/8e5b06947d906f470e7507c9dca93e1934d5a349/LICENSE
