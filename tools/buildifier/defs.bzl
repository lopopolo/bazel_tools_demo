load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier_test")
load(":constants.bzl", "STARLARK_FILE_GLOB")

# buildifier_test implementation reference https://github.com/bazelbuild/buildtools/pull/929
def buildifier_check_test(name = "buildifier_test", size = "small", timeout = "short", exclude_patterns = [], **kwargs):
    starlark_files = native.glob(STARLARK_FILE_GLOB, exclude = exclude_patterns)

    if starlark_files:
        tags = kwargs.get("tags", [])
        if "buildifier" not in tags:
            tags.append("buildifier")
            kwargs["tags"] = tags

        buildifier_test(
            name = name,
            srcs = starlark_files,
            mode = "diff",
            lint_mode = "warn",
            # https://github.com/bazelbuild/buildtools/blob/master/WARNINGS.md#buildifier-warnings
            lint_warnings = [
                "+native-android",
                "+native-cc",
                "+native-java",
                "+native-proto",
                "+native-py",
                "+out-of-order-load",
                "+unsorted-dict-items",
                "-module-docstring",
                "-function-docstring",
                "-function-docstring-header",
                "-function-docstring-args",
                "-function-docstring-return",
            ],
            size = size,
            timeout = timeout,
            **kwargs
        )
