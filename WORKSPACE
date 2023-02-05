# Bazel workspace created by @bazel/create 5.4.2

# Declares that this directory is the root of a Bazel workspace.
# See https://docs.bazel.build/versions/main/build-ref.html#workspace
workspace(name = "bazel_tools_demo")

load("//tools:bazel_deps.bzl", "fetch_dependencies")

fetch_dependencies()

# Rust toolchain setup

load("@rules_rust//rust:repositories.bzl", "rules_rust_dependencies", "rust_register_toolchains")

rules_rust_dependencies()

rust_register_toolchains(
    edition = "2021",
    versions = ["1.67.0"],
)

load("@rules_rust//crate_universe:repositories.bzl", "crate_universe_dependencies")

crate_universe_dependencies()

load(
    "//tools/minify-html/crates:crates.bzl",
    tools_minify_html_repositories = "crate_repositories",
)

tools_minify_html_repositories()

# Golang toolchain setup
# See https://github.com/bazelbuild/rules_go#initial-project-setup

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(
    # nogo = "@io_bazel_rules_go//:tools_nogo",
    version = "1.20",
)

# Gazelle setup
# https://github.com/bazelbuild/bazel-gazelle#running-gazelle-with-bazel

# gazelle:repo bazel_gazelle

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("//:go_repositories.bzl", "go_repositories")

# gazelle:repository_macro go_repositories.bzl%go_repositories
go_repositories()

gazelle_dependencies()

# Protobuf setup
# See https://github.com/bazelbuild/rules_go#protobuf-and-grpc

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

# Node.js toolchain setup

load("@build_bazel_rules_nodejs//:repositories.bzl", "build_bazel_rules_nodejs_dependencies")

build_bazel_rules_nodejs_dependencies()

load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

load("@aspect_rules_esbuild//esbuild:dependencies.bzl", "rules_esbuild_dependencies")

rules_esbuild_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "DEFAULT_NODE_VERSION", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = DEFAULT_NODE_VERSION,
)

# The npm_install rule runs yarn anytime the package.json or package-lock.json file changes.
# It also extracts any Bazel rules distributed in an npm package.
load("@rules_nodejs//nodejs:yarn_repositories.bzl", "yarn_repositories")

yarn_repositories(
    name = "yarn",
    yarn_version = "1.22.19",
)

load("@aspect_rules_js//npm:npm_import.bzl", "npm_translate_lock")

npm_translate_lock(
    name = "npm",
    npmrc = "//:.npmrc",
    pnpm_lock = "//:pnpm-lock.yaml",
    verify_node_modules_ignored = "//:.bazelignore",
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()

load("@build_bazel_rules_nodejs//:index.bzl", "npm_install")

npm_install(
    name = "npm_deps_tools_eslint",
    package_json = "//tools/eslint:package.json",
    package_lock_json = "//tools/eslint:package-lock.json",
)

npm_install(
    name = "npm_deps_tools_prettier",
    package_json = "//tools/prettier:package.json",
    package_lock_json = "//tools/prettier:package-lock.json",
)

load("@aspect_rules_esbuild//esbuild:repositories.bzl", "LATEST_VERSION", "esbuild_register_toolchains")

esbuild_register_toolchains(
    name = "esbuild",
    esbuild_version = LATEST_VERSION,
)

# Python toolchain setup
# See https://github.com/bazelbuild/rules_python#getting-started

load("@rules_python//python:repositories.bzl", "python_register_toolchains")

python_register_toolchains(
    name = "python3_10",
    # Available versions are listed in @rules_python//python:versions.bzl.
    # We recommend using the same version your team is already standardized on.
    python_version = "3.10",
)

load("@python3_10//:defs.bzl", py3_10_interpreter = "interpreter")
load("@rules_python//python:pip.bzl", "pip_parse")

pip_parse(
    name = "py_deps_tools_black",
    extra_pip_args = ["--require-hashes"],
    python_interpreter_target = py3_10_interpreter,
    requirements_lock = "//tools/black:requirements.txt",
)

load("@py_deps_tools_black//:requirements.bzl", black_install_deps = "install_deps")

black_install_deps()

pip_parse(
    name = "py_deps_tools_flake8",
    extra_pip_args = ["--require-hashes"],
    python_interpreter_target = py3_10_interpreter,
    requirements_lock = "//tools/flake8:requirements.txt",
)

load("@py_deps_tools_flake8//:requirements.bzl", flake8_install_deps = "install_deps")

flake8_install_deps()

pip_parse(
    name = "py_deps_tools_isort",
    extra_pip_args = ["--require-hashes"],
    python_interpreter_target = py3_10_interpreter,
    requirements_lock = "//tools/isort:requirements.txt",
)

load("@py_deps_tools_isort//:requirements.bzl", isort_install_deps = "install_deps")

isort_install_deps()

pip_parse(
    name = "py_deps_tools_yamllint",
    extra_pip_args = ["--require-hashes"],
    python_interpreter_target = py3_10_interpreter,
    requirements_lock = "//tools/yamllint:requirements.txt",
)

load("@py_deps_tools_yamllint//:requirements.bzl", yamllint_install_deps = "install_deps")

yamllint_install_deps()
