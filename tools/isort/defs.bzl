load("//tools/isort/internal:factory.bzl", "isort_test", _isort = "isort")
load(":constants.bzl", "PYTHON_FILE_GLOB")

def isort(name = "isort", **kwargs):
    tags = kwargs.get("tags", [])
    if "manual" not in tags:
        tags.append("manual")
        kwargs["tags"] = tags
    if "isort" not in tags:
        tags.append("isort")
        kwargs["tags"] = tags

    _isort(
        name = name,
        **kwargs
    )

def isort_check_test(name = "isort_test", config = "//:pyproject.toml", size = "small", timeout = "short", exclude_patterns = [], **kwargs):
    python_files = native.glob(PYTHON_FILE_GLOB, exclude = exclude_patterns)

    if python_files:
        tags = kwargs.get("tags", [])
        if "isort" not in tags:
            tags.append("isort")
            kwargs["tags"] = tags

        isort_test(
            name = name,
            config = config,
            srcs = python_files,
            size = size,
            timeout = timeout,
            **kwargs
        )
