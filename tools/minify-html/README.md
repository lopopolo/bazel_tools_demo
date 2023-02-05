# minify-html

`//tools/minify-html` is a Bazel-packaged minimal CLI for the [minify-html
crate].

[minify-html crate]: https://crates.io/crates/minify-html

## Rationale

The minify-html crate is a library crate that is distributed as a library for
many package ecosystems such as [npm]. `//tools/minify-html` chooses to build a
Rust CLI around the library crate for the following reasons:

- Avoid depending on pre-compiled binaries.
- Upstream does not ship aarch64-apple-darwin binaries.

[npm]: https://www.npmjs.com/package/@minify-html/node

## Usage

`//tools/minify-html` can be invoked with `bazel run`. The tool will set its
working directory to the [`BUILD_WORKSPACE_DIRECTORY`]. It accepts a set of
(relative) paths to format in-place as positional arguments and can be invoked
with:

```shell
bazel run //tools/minify-html -- dist/**/*.html
```

[`build_workspace_directory`]:
  https://bazel.build/docs/user-manual#running-executables

## Upgrading dependencies

`//tools/minify-html` has two direct dependencies:

- [minify-html]
- [rayon]

[minify-html]: https://crates.io/crates/minify-html
[rayon]: https://crates.io/crates/rayon

These dependencies are specified directly in this package's
[`BUILD.bazel`](BUILD.bazel) file.

After optionally updating the version constaints in the `crates_vendor` rule,
repin dependencies by running:

```shell
bazel run //tools/minify-html:crates_vendor -- --repin
```
