def _gofmt_attr_factory():
    attrs = {
        "_chdir": attr.label(
            default = Label("//tools/bazelutil/chdir-workspace:chdir-workspace"),
            executable = True,
            cfg = "exec",
        ),
        "_gofmt_tool": attr.label(
            default = Label("@go_sdk//:bin/gofmt"),
            doc = "path to a gofmt tool binary",
            allow_single_file = True,
        ),
    }

    return attrs

def _gofmt_impl(ctx):
    runner = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.write(
        output = runner,
        content = "{chdir} -- {gofmt} -l -s -w .".format(
            chdir = ctx.executable._chdir.short_path,
            gofmt = ctx.file._gofmt_tool.short_path,
        ),
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = [ctx.file._gofmt_tool])
    runfiles = runfiles.merge(ctx.attr._chdir[DefaultInfo].default_runfiles)

    return DefaultInfo(
        runfiles = runfiles,
        executable = runner,
    )

gofmt = rule(
    _gofmt_impl,
    attrs = _gofmt_attr_factory(),
    executable = True,
)

def _gofmt_test_attr_factory():
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".go"],
        ),
        "_gofmt_tool": attr.label(
            default = Label("@go_sdk//:bin/gofmt"),
            doc = "path to a gofmt tool binary",
            allow_single_file = True,
        ),
        "_runner": attr.label(
            default = Label("//tools/gofmt/check:check"),
            executable = True,
            cfg = "exec",
        ),
    }

    return attrs

def _gofmt_test_impl(ctx):
    # `sourcesfile` is expected by the `_runner` to be a newline delimited list
    # where all non-empty lines are paths to go source files to check for invalid
    # formatting.
    sourcesfile = ctx.actions.declare_file("%s.sourcesfile" % ctx.label.name)
    args = ""
    for src in ctx.files.srcs:
        args = "{previous}{src}\n".format(previous = args, src = src.short_path)
    ctx.actions.write(output = sourcesfile, content = args)

    runner = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = runner,
        content = "{check} -gofmt={gofmt} -sourcesfile={sourcesfile}".format(
            check = ctx.executable._runner.short_path,
            gofmt = ctx.file._gofmt_tool.short_path,
            sourcesfile = sourcesfile.short_path,
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = ctx.files.srcs + [ctx.file._gofmt_tool, sourcesfile])
    runfiles = runfiles.merge(ctx.attr._runner[DefaultInfo].default_runfiles)

    return DefaultInfo(
        runfiles = runfiles,
        executable = runner,
    )

gofmt_test = rule(
    _gofmt_test_impl,
    attrs = _gofmt_test_attr_factory(),
    test = True,
)
