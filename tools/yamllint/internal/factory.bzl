load("@bazel_skylib//lib:shell.bzl", "shell")

def _yamllint_test_attr_factory():
    attrs = {
        "config": attr.label(
            mandatory = True,
            doc = "path to a yamllint config file",
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = [".yaml", ".yml"],
        ),
        "_yamllint": attr.label(
            default = Label("//tools/yamllint:entry"),
            executable = True,
            cfg = "exec",
        ),
    }

    return attrs

def _yamllint_test_impl(ctx):
    if len(ctx.attr.srcs) == 0:
        fail("No YAML files specified.")

    args = [
        "--strict",
        "--config-file",
        shell.quote(ctx.file.config.short_path),
    ] + [shell.quote(src.short_path) for src in ctx.files.srcs]

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "%s %s" % (ctx.executable._yamllint.short_path, " ".join(args)),
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = ctx.files.srcs + [ctx.file.config])
    runfiles = runfiles.merge(ctx.attr._yamllint[DefaultInfo].default_runfiles)

    return [DefaultInfo(
        runfiles = runfiles,
        executable = ctx.outputs.executable,
    )]

yamllint_test = rule(
    _yamllint_test_impl,
    attrs = _yamllint_test_attr_factory(),
    test = True,
)
