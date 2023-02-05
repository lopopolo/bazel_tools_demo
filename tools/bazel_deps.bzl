# Third-party dependencies fetched by Bazel
# Unlike WORKSPACE, the content of this file is unordered.
# We keep them separate to make the WORKSPACE file more maintainable.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def fetch_dependencies():
    fetch_go_dependencies()
    fetch_javascript_dependencies()
    fetch_python_dependencies()
    fetch_rust_dependencies()
    fetch_buildifier_dependencies()

def fetch_javascript_dependencies():
    # Install the nodejs "bootstrap" package
    # This provides the basic tools for running and packaging nodejs programs in Bazel
    #
    # Setup instructions:
    # - https://github.com/bazelbuild/rules_nodejs/releases/tag/5.8.0
    #
    # Latest releases:
    # - https://github.com/bazelbuild/rules_nodejs/releases
    http_archive(
        name = "build_bazel_rules_nodejs",
        sha256 = "dcc55f810142b6cf46a44d0180a5a7fb923c04a5061e2e8d8eb05ccccc60864b",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.8.0/rules_nodejs-5.8.0.tar.gz"],
    )

    # This ruleset is a high-performance and npm-compatible Bazel integration
    # for JavaScript.
    #
    # Setup instructions:
    # - https://github.com/aspect-build/rules_js/releases/tag/v1.17.1
    #
    # Latest releases:
    # - https://github.com/aspect-build/rules_js/releases
    http_archive(
        name = "aspect_rules_js",
        sha256 = "ad9fe29a083007fb1ae628f394220a0dae39da3a8d46c4430c920e8892d4ce38",
        strip_prefix = "rules_js-1.17.1",
        url = "https://github.com/aspect-build/rules_js/releases/download/v1.17.1/rules_js-v1.17.1.tar.gz",
    )

    # This is a Bazel rule which wraps the esbuild CLI.
    #
    # Setup instructions:
    # - https://github.com/aspect-build/rules_esbuild/releases/tag/v0.14.0
    #
    # Latest releases:
    # - https://github.com/aspect-build/rules_esbuild/releases
    http_archive(
        name = "aspect_rules_esbuild",
        sha256 = "f05e9a53ae4b394ca45742ac35f7e658a8ba32cba14b5d531b79466ae86dc7f0",
        strip_prefix = "rules_esbuild-0.14.0",
        url = "https://github.com/aspect-build/rules_esbuild/archive/refs/tags/v0.14.0.tar.gz",
    )

def fetch_go_dependencies():
    # Go rules for Bazel
    #
    # Setup instructions:
    # - https://github.com/bazelbuild/rules_go#initial-project-setup
    #
    # Latest releases:
    # - https://github.com/bazelbuild/rules_go/releases
    http_archive(
        name = "io_bazel_rules_go",
        sha256 = "dd926a88a564a9246713a9c00b35315f54cbd46b31a26d5d8fb264c07045f05d",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.38.1/rules_go-v0.38.1.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.38.1/rules_go-v0.38.1.zip",
        ],
    )

    # Gazelle is a Bazel build file generator for Bazel projects. It natively
    # supports Go and protobuf, and it may be extended to support new languages
    # and custom rule sets.
    #
    # Setup instructions:
    # - https://github.com/bazelbuild/bazel-gazelle#running-gazelle-with-bazel
    #
    # Latest releases:
    # - https://github.com/bazelbuild/bazel-gazelle/releases
    http_archive(
        name = "bazel_gazelle",
        sha256 = "ecba0f04f96b4960a5b250c8e8eeec42281035970aa8852dda73098274d14a1d",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.28.0/bazel-gazelle-v0.29.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.29.0/bazel-gazelle-v0.29.0.tar.gz",
        ],
    )

# https://github.com/bazelbuild/buildtools/tree/master/buildifier#setup-and-usage-via-bazel-not-supported-on-windows
def fetch_buildifier_dependencies():
    # buildifier is written in Go and hence needs rules_go to be built.
    # fetch_go_dependencies()

    # Protocol Buffers - Google's data interchange format
    #
    # Setup instructions:
    # - https://github.com/bazelbuild/rules_go#protobuf-and-grpc
    #
    # Latest releases:
    # - https://github.com/protocolbuffers/protobuf/releases
    http_archive(
        name = "com_google_protobuf",
        sha256 = "29b0f6b6d5714f212b8549cd0cb6fc531672630e41fb99d445421bc4d1bbb9cd",
        strip_prefix = "protobuf-21.12",
        urls = [
            "https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protobuf-all-21.12.zip",
        ],
        patch_args = ["-p1"],
        patches = ["//patches/protobuf:0026-remove-sprintf.patch"],
    )

    # This repository contains developer tools for working with Google's `bazel`
    # buildtool.
    #
    # Setup instructions:
    # - https://github.com/bazelbuild/buildtools/tree/master/buildifier#setup-and-usage-via-bazel-not-supported-on-windows
    #
    # Latest releases:
    # - https://github.com/bazelbuild/buildtools/releases
    http_archive(
        name = "com_github_bazelbuild_buildtools",
        sha256 = "ca524d4df8c91838b9e80543832cf54d945e8045f6a2b9db1a1d02eec20e8b8c",
        strip_prefix = "buildtools-6.0.1",
        url = "https://github.com/bazelbuild/buildtools/archive/6.0.1.tar.gz",
    )

def fetch_python_dependencies():
    # This repository is the home of the core Python rules -- `py_library`,
    # `py_binary`, `py_test`, and related symbols that provide the basis for
    # Python support in Bazel.
    #
    # Setup instructions:
    # - https://github.com/bazelbuild/rules_python/releases/tag/0.17.3
    #
    # Latest releases:
    # - https://github.com/bazelbuild/rules_python/releases
    http_archive(
        name = "rules_python",
        sha256 = "8c15896f6686beb5c631a4459a3aa8392daccaab805ea899c9d14215074b60ef",
        strip_prefix = "rules_python-0.17.3",
        url = "https://github.com/bazelbuild/rules_python/archive/refs/tags/0.17.3.tar.gz",
    )

def fetch_rust_dependencies():
    # This repository provides rules for building Rust projects with Bazel.
    #
    # Setup instructions:
    # - https://github.com/bazelbuild/rules_rust/releases/tag/0.17.0
    #
    # Latest releases:
    # - https://github.com/bazelbuild/rules_rust/releases
    http_archive(
        name = "rules_rust",
        sha256 = "d125fb75432dc3b20e9b5a19347b45ec607fabe75f98c6c4ba9badaab9c193ce",
        urls = ["https://github.com/bazelbuild/rules_rust/releases/download/0.17.0/rules_rust-v0.17.0.tar.gz"],
    )
