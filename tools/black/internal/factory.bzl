load("@bazel_skylib//lib:shell.bzl", "shell")

def _black_attr_factory():
    attrs = {
        "_black": attr.label(
            default = Label("//tools/black:entry"),
            executable = True,
            cfg = "exec",
        ),
        "_chdir": attr.label(
            default = Label("//tools/bazelutil/chdir-workspace:chdir-workspace"),
            executable = True,
            cfg = "exec",
        ),
    }

    return attrs

def _black_impl(ctx):
    runner = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.write(
        output = runner,
        content = "{chdir} -- {black} .".format(
            chdir = ctx.executable._chdir.short_path,
            black = ctx.executable._black.short_path,
        ),
        is_executable = True,
    )
    runfiles = ctx.runfiles()
    runfiles = runfiles.merge(ctx.attr._black[DefaultInfo].default_runfiles)
    runfiles = runfiles.merge(ctx.attr._chdir[DefaultInfo].default_runfiles)

    return DefaultInfo(
        runfiles = runfiles,
        executable = runner,
    )

black = rule(
    _black_impl,
    attrs = _black_attr_factory(),
    executable = True,
)

def _black_test_attr_factory():
    attrs = {
        "config": attr.label(
            mandatory = True,
            doc = "path to a pyproject.toml config file",
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = [".py", ".ipy"],
        ),
        "_black": attr.label(
            default = Label("//tools/black:entry"),
            executable = True,
            cfg = "exec",
        ),
    }

    return attrs

def _black_test_impl(ctx):
    if len(ctx.attr.srcs) == 0:
        fail("No Python files specified.")

    args = ["--check", "--diff", "--config", ctx.file.config.short_path] + [shell.quote(src.short_path) for src in ctx.files.srcs]
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "%s %s" % (ctx.executable._black.short_path, " ".join(args)),
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = ctx.files.srcs + [ctx.file.config])
    runfiles = runfiles.merge(ctx.attr._black[DefaultInfo].default_runfiles)

    return [DefaultInfo(
        runfiles = runfiles,
        executable = ctx.outputs.executable,
    )]

black_test = rule(
    _black_test_impl,
    attrs = _black_test_attr_factory(),
    test = True,
)
