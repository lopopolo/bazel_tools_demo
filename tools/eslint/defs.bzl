load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_test")
load(":constants.bzl", "ESLINT_FILE_GLOB")

def eslint_check_test(name = "eslint_test", config = "//:.eslintrc.yaml", size = "small", timeout = "short", exclude_patterns = [], **kwargs):
    eslint_files = native.glob(ESLINT_FILE_GLOB, exclude = exclude_patterns)

    if eslint_files:
        existing_rules = native.existing_rules().keys()
        if "eslint_files" not in existing_rules:
            native.filegroup(
                name = "eslint_files",
                srcs = eslint_files,
            )

        tags = kwargs.get("tags", [])
        if "eslint" not in tags:
            tags.append("eslint")
            kwargs["tags"] = tags

        templated_args = [
            "--report-unused-disable-directives",
            "--ext",
            ".js,.jsx,.mjs,.ts,.tsx",
            "--config",
            "$(execpath %s)" % config,
            "$(execpaths :eslint_files)",
        ]
        lint_data = [
            "@npm_deps_tools_eslint//eslint",
            ":eslint_files",
            config,
        ]

        nodejs_test(
            name = name,
            data = lint_data,
            entry_point = {"@npm_deps_tools_eslint//:node_modules/eslint": "bin/eslint.js"},
            templated_args = templated_args,
            size = size,
            timeout = timeout,
            **kwargs
        )
