load("//tools/flake8/internal:factory.bzl", "flake8_test")
load(":constants.bzl", "PYTHON_FILE_GLOB")

def flake8_check_test(name = "flake8_test", config = "//:.flake8", size = "small", timeout = "short", exclude_patterns = [], **kwargs):
    python_files = native.glob(PYTHON_FILE_GLOB, exclude = exclude_patterns)

    if python_files:
        tags = kwargs.get("tags", [])
        if "flake8" not in tags:
            tags.append("flake8")
            kwargs["tags"] = tags

        flake8_test(
            name = name,
            config = config,
            srcs = python_files,
            size = size,
            timeout = timeout,
            **kwargs
        )
