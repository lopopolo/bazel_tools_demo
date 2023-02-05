load("@bazel_skylib//lib:shell.bzl", "shell")

def _flake8_test_attr_factory():
    attrs = {
        "config": attr.label(
            mandatory = True,
            doc = "path to a flake8 config file",
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = [".py", ".ipy"],
        ),
        "_flake8": attr.label(
            default = Label("//tools/flake8:entry"),
            executable = True,
            cfg = "exec",
        ),
    }

    return attrs

def _flake8_test_impl(ctx):
    args = [
        "--config",
        shell.quote(ctx.file.config.short_path),
        "--statistics",  # Verbose summary output
    ] + [shell.quote(src.short_path) for src in ctx.files.srcs]

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "%s %s" % (ctx.executable._flake8.short_path, " ".join(args)),
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = ctx.files.srcs + [ctx.file.config])
    runfiles = runfiles.merge(ctx.attr._flake8[DefaultInfo].default_runfiles)

    return [DefaultInfo(
        runfiles = runfiles,
        executable = ctx.outputs.executable,
    )]

flake8_test = rule(
    _flake8_test_impl,
    attrs = _flake8_test_attr_factory(),
    test = True,
)
