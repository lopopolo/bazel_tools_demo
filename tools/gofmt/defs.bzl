load("//tools/gofmt/internal:factory.bzl", "gofmt_test", _gofmt = "gofmt")
load(":constants.bzl", "GO_FILE_GLOB")

def gofmt(name = "gofmt", **kwargs):
    tags = kwargs.get("tags", [])
    if "manual" not in tags:
        tags.append("manual")
        kwargs["tags"] = tags
    if "gofmt" not in tags:
        tags.append("gofmt")
        kwargs["tags"] = tags

    _gofmt(
        name = name,
        **kwargs
    )

def gofmt_check_test(name = "gofmt_test", size = "small", timeout = "short", exclude_patterns = [], **kwargs):
    go_files = native.glob(GO_FILE_GLOB, exclude = exclude_patterns)

    if go_files:
        tags = kwargs.get("tags", [])
        if "gofmt" not in tags:
            tags.append("gofmt")
            kwargs["tags"] = tags

        gofmt_test(
            name = name,
            srcs = go_files,
            size = size,
            timeout = timeout,
            **kwargs
        )
