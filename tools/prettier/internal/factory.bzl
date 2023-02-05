load("@bazel_skylib//lib:paths.bzl", "paths")

def _prettier_attr_factory():
    attrs = {
        "_chdir": attr.label(
            default = Label("//tools/bazelutil/chdir-workspace:chdir-workspace"),
            executable = True,
            cfg = "exec",
        ),
        "_node": attr.label(
            default = Label("@nodejs_host//:node"),
            doc = "nodejs runtime",
            allow_single_file = True,
        ),
        "_prettier_package": attr.label(
            default = Label("@npm_deps_tools_prettier//:node_modules/prettier"),
            doc = "path to a prettier npm package",
            allow_single_file = True,
        ),
    }

    return attrs

def _prettier_impl(ctx):
    runner = ctx.actions.declare_file(ctx.label.name)

    prettier_package = ctx.file._prettier_package.path
    prettier = paths.join(prettier_package, "bin-prettier.js")

    ctx.actions.write(
        output = runner,
        content = '''{chdir} -- {node} {prettier} --write "**/*"'''.format(
            chdir = ctx.executable._chdir.short_path,
            node = ctx.file._node.short_path,
            prettier = prettier,
        ),
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = [ctx.file._node, ctx.file._prettier_package])
    runfiles = runfiles.merge(ctx.attr._chdir[DefaultInfo].default_runfiles)

    return DefaultInfo(
        runfiles = runfiles,
        executable = runner,
    )

prettier = rule(
    _prettier_impl,
    attrs = _prettier_attr_factory(),
    executable = True,
)
