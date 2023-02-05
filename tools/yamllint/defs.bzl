load("//tools/yamllint/internal:factory.bzl", "yamllint_test")
load(":constants.bzl", "YAML_FILE_GLOB")

def yamllint_check_test(name = "yamllint_test", config = "//:.yamllint.yaml", size = "small", timeout = "short", exclude_patterns = [], **kwargs):
    yaml_files = native.glob(YAML_FILE_GLOB, exclude = exclude_patterns)

    if yaml_files:
        tags = kwargs.get("tags", [])
        if "yamllint" not in tags:
            tags.append("yamllint")
            kwargs["tags"] = tags

        yamllint_test(
            name = name,
            config = config,
            srcs = yaml_files,
            size = size,
            timeout = timeout,
            **kwargs
        )
