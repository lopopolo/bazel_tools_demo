load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_test")
load("//tools/prettier/internal:factory.bzl", _prettier = "prettier")
load(":constants.bzl", "PRETTIER_FILE_GLOB")

def prettier(name = "prettier", **kwargs):
    tags = kwargs.get("tags", [])
    if "manual" not in tags:
        tags.append("manual")
        kwargs["tags"] = tags

    _prettier(
        name = name,
        **kwargs
    )

def prettier_check_test(name = "prettier_test", config = "//:.prettierrc.yaml", size = "small", timeout = "short", exclude_patterns = [], **kwargs):
    prettier_files = native.glob(PRETTIER_FILE_GLOB, exclude = exclude_patterns)

    if prettier_files:
        existing_rules = native.existing_rules().keys()
        if "prettier_files" not in existing_rules:
            native.filegroup(
                name = "prettier_files",
                srcs = prettier_files,
            )

        tags = kwargs.get("tags", [])
        if "prettier" not in tags:
            tags.append("prettier")
            kwargs["tags"] = tags

        templated_args = [
            "--config",
            "$(execpath %s)" % config,
            "$(execpaths :prettier_files)",
        ]
        lint_data = [
            "@npm_deps_tools_prettier//prettier",
            ":prettier_files",
            config,
        ]

        nodejs_test(
            name = name,
            data = lint_data,
            entry_point = {"@npm_deps_tools_prettier//:node_modules/prettier": "bin-prettier.js"},
            templated_args = ["--check"] + templated_args,
            size = size,
            timeout = timeout,
            **kwargs
        )
