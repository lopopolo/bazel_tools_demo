load("//tools/black/internal:factory.bzl", "black_test", _black = "black")
load(":constants.bzl", "PYTHON_FILE_GLOB")

def black(name = "black", **kwargs):
    tags = kwargs.get("tags", [])
    if "manual" not in tags:
        tags.append("manual")
        kwargs["tags"] = tags
    if "black" not in tags:
        tags.append("black")
        kwargs["tags"] = tags

    _black(
        name = name,
        **kwargs
    )

def black_check_test(name = "black_test", config = "//:pyproject.toml", size = "small", timeout = "short", exclude_patterns = [], **kwargs):
    python_files = native.glob(PYTHON_FILE_GLOB, exclude = exclude_patterns)

    if python_files:
        tags = kwargs.get("tags", [])
        if "black" not in tags:
            tags.append("black")
            kwargs["tags"] = tags

        black_test(
            name = name,
            config = config,
            srcs = python_files,
            size = size,
            timeout = timeout,
            **kwargs
        )
