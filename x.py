#!/usr/bin/env PYTHONUNBUFFERED=1 python3

import asyncio
import itertools
import os
import shutil
import signal
import stat
import sys
from contextlib import suppress
from pathlib import Path
from time import sleep


class Watcher:
    def __init__(self):
        self.stats = self._compute_stat(initial=True)

    def is_changed(self):
        # Routine inlined from `filecmp` in Python standard library:
        # See: https://github.com/python/cpython/blob/v3.10.4/Lib/filecmp.py
        def statcmp(s1, s2, *, shallow=True):
            if s1[0] != stat.S_IFREG or s2[0] != stat.S_IFREG:
                return False
            if shallow and s1 == s2:
                return True
            if s1[1] != s2[1]:
                return False
            return None

        old_stats = self.stats
        self.stats = self._compute_stat()
        for path, s1 in self.stats.items():
            s2 = old_stats[path]
            if s2 is None:
                print(f"Detected change in {path} ... rebuilding")
                return True
            if statcmp(s1, s2):
                continue
            print(f"Detected change in {path} ... rebuilding")
            return True
        return False

    def _compute_stat(self, *, initial=False):
        def _sig(st):
            return (
                stat.S_IFMT(st.st_mode),
                st.st_size,
                st.st_mtime,
            )

        watch_sources = itertools.chain(
            Path("content").rglob("*"),
            Path("src").rglob("*"),
            (Path(path) for path in ["package.json", "package-lock.json", "build.mjs"]),
        )
        stats = {}
        for path in watch_sources:
            if not path.is_file():
                continue
            if path.name == ".gitkeep":
                continue
            if initial:
                print(f"Watching {path}")
            stats[path] = _sig(os.stat(path))
        return stats


async def run(cmd):
    proc = await asyncio.create_subprocess_exec(*cmd)

    await proc.wait()
    return proc.returncode


async def run_serially(commands):
    for command in commands:
        ret = await run(command)
        if ret != 0:
            return ret
    return 0


async def black():
    command = ["bazelisk", "run", "//:black"]
    return await run(command)


async def build():
    return await run_serially(
        [
            ["bazelisk", "run", "@nodejs//:node", "--", "bin/generate.js", "site"],
            ["bazelisk", "run", "@nodejs//:node", "--", "build.mjs"],
        ]
    )


async def buildifier():
    command = ["bazelisk", "run", "//:buildifier"]
    return await run(command)


def clean():
    with suppress(FileNotFoundError):
        shutil.rmtree("dist")
    return 0


async def format():
    tasks = [
        black,
        buildifier,
        gofmt,
        isort,
        prettier,
        rustfmt,
    ]
    for task in tasks:
        ret = await task()
        if ret != 0:
            return ret
    return 0


async def gofmt():
    command = ["bazelisk", "run", "//:gofmt"]
    return await run(command)


async def isort():
    command = ["bazelisk", "run", "//:isort"]
    return await run(command)


async def prettier():
    command = ["bazelisk", "run", "//:prettier"]
    return await run(command)


async def rustfmt():
    command = ["bazelisk", "run", "//:rustfmt"]
    return await run(command)


async def watch():
    watcher = Watcher()
    await build()

    while True:
        if watcher.is_changed():
            await build()
        await asyncio.sleep(1)


async def amain(subcommand, _args):
    if subcommand == "black":
        return await black()
    if subcommand == "build":
        return await build()
    if subcommand == "buildifier":
        return await buildifier()
    if subcommand == "clean":
        return clean()
    if subcommand in ["format", "fmt"]:
        return await format()
    if subcommand == "gofmt":
        return await gofmt()
    if subcommand == "isort":
        return await isort()
    if subcommand == "prettier":
        return await prettier()
    if subcommand == "rustfmt":
        return await rustfmt()
    if subcommand == "watch":
        return await watch()

    print(f"Error: Unknown subcommand `{subcommand}`", file=sys.stderr)
    print("", file=sys.stderr)
    print(usage(), file=sys.stderr)
    return 1


def usage():
    return """\
Usage: ./x.py subcommand

SUBCOMMANDS

    black         Format Python sources with black
    build         Build web bundle
    buildifier    Format Bazel BUILD files
    clean         Remove build artifacts
    format        Run all source formatting tasks [aliases: fmt]
    fmt           Run all source formatting tasks [aliases: format]
    gofmt         Format Golang sources with gofmt
    isort         Format Python sources with isort
    prettier      Format sources with prettier
    rustfmt       Format Rust sources with rustfmt
    watch         Build the webapp and rebuild when sources change
"""


def main():
    # Create a process group to ensure we can send SIGINT to all child processes
    # spawned by `x.py`.
    #
    # `ibazel` is stubborn and requires two SIGINTs to shutdown.
    os.setpgrp()

    # Try to chdir to the workspace root so we can write to the workspace
    # sources in case this script is invoked with `bazel run ...`.
    workspace_root = os.getenv("BUILD_WORKSPACE_DIRECTORY")
    if workspace_root is not None:
        os.chdir(workspace_root)

    try:
        subcommand, *args = sys.argv[1:]
    except ValueError:
        print(usage(), file=sys.stderr)
        return 1

    # If the subcommand is "help"-ish, print usage.
    if subcommand in ["help", "--help", "-h"]:
        print(usage())
        return 0
    # If any subcommand gets "help"-ish args, print usage.
    if any(arg in ["help", "--help", "h"] for arg in args):
        print(usage())
        return 0
    # Subcommands don't accept any arguments or flags.
    if args:
        print(usage(), file=sys.stderr)
        return 1

    try:
        return asyncio.run(amain(subcommand, args))
    except KeyboardInterrupt as e:
        print(e, file=sys.stderr)

    # We got a SIGINT, so let's send another SIGINT to all of the spawned
    # processes we have created in case we need to shutdown `ibazel`.
    with suppress(KeyboardInterrupt, OSError):
        sleep(1)
        os.killpg(0, signal.SIGINT)
    return 0


if __name__ == "__main__":
    sys.exit(main())
