# bazelutil

A go library with helpers for writing tools meant to be invoked with
`bazel run`.

## Bazel Workspace

`bazel run` is not hermetic. Executables invoked with `bazel run` have access to
a `BUILD_WORKSPACE_DIRECTORY` environment variable which points to the real
working directory of the project workspace (i.e. not in the sandbox).

`bazelutil` includes several helpers for accessing this information which can be
used to [write to the source folder].

[write to the source folder]:
  https://www.aspect.dev/blog/bazel-can-write-to-the-source-folder

## `bazel run`

Invoking executables with `bazel run` in a go code can be tedious, especially if
setting UI output filters. Several convenience functions are defined which make
invoking a command with Bazel readable and concise.
