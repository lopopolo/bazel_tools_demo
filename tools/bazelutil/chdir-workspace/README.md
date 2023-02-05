# chdir-workspace

This is a small binary which will chdir to the Bazel workspace directory before
executing the command given as trailing CLI arguments.

This binary can be used to build executable rules that operate in the workspace
source directory.

This binary must be invoked via `bazel run` or else it will terminate with an
error.
