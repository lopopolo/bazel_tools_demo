load("@bazel_skylib//lib:shell.bzl", "shell")

def _isort_attr_factory():
    attrs = {
        "_chdir": attr.label(
            default = Label("//tools/bazelutil/chdir-workspace:chdir-workspace"),
            executable = True,
            cfg = "exec",
        ),
        "_isort": attr.label(
            default = Label("//tools/isort:entry"),
            executable = True,
            cfg = "exec",
        ),
    }

    return attrs

def _isort_impl(ctx):
    runner = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.write(
        output = runner,
        content = "{chdir} -- {isort} .".format(
            chdir = ctx.executable._chdir.short_path,
            isort = ctx.executable._isort.short_path,
        ),
        is_executable = True,
    )
    runfiles = ctx.runfiles()
    runfiles = runfiles.merge(ctx.attr._chdir[DefaultInfo].default_runfiles)
    runfiles = runfiles.merge(ctx.attr._isort[DefaultInfo].default_runfiles)

    return DefaultInfo(
        runfiles = runfiles,
        executable = runner,
    )

isort = rule(
    _isort_impl,
    attrs = _isort_attr_factory(),
    executable = True,
)

def _isort_test_attr_factory():
    attrs = {
        "config": attr.label(
            mandatory = True,
            doc = "path to a pyproject.toml config file",
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = [".py", ".ipy"],
        ),
        "_isort": attr.label(
            default = Label("//tools/isort:entry"),
            executable = True,
            cfg = "exec",
        ),
    }

    return attrs

def _isort_test_impl(ctx):
    if len(ctx.attr.srcs) == 0:
        fail("No Python files specified.")

    args = ["--check", "--diff", "--settings-file", ctx.file.config.short_path] + [shell.quote(src.short_path) for src in ctx.files.srcs]
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "%s %s" % (ctx.executable._isort.short_path, " ".join(args)),
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = ctx.files.srcs)
    runfiles = runfiles.merge(ctx.runfiles(files = [ctx.file.config]))
    runfiles = runfiles.merge(ctx.attr._isort[DefaultInfo].default_runfiles)

    return [DefaultInfo(
        runfiles = runfiles,
        executable = ctx.outputs.executable,
    )]

isort_test = rule(
    _isort_test_impl,
    attrs = _isort_test_attr_factory(),
    test = True,
)
