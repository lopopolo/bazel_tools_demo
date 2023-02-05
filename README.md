# bazel_tools_demo

This repository is a complete Bazel workspace which demonstrates how to author
Bazel rules and tools.

Each tool in `//tools` is implemented with a custom Bazel rule and macro, which
can be found in each tool's `internal` package and `defs.bzl` Starlark config.

## Tools

To use these tools and automatically setup tests, add the following to all
`BUILD.bazel` files:

```bazel
load("//tools:linters.bzl", "lint_tests")

lint_tests()
```

The `//tools` directory also contains binaries for managing a Bazel monorepo,
such as consolidating `go.mod` files into a centralized location in the
workspace root, e.g. [`//tools/go-mod-tidy`].

[`//tools/go-mod-tidy`]: tools/go-mod-tidy

Tools that write to the workspace root may be invoked all at once with
`bazel run //:fmt`, which uses `./x.py fmt` under the hood.

### Formatters

#### `//tools/black`

Format Python code with [`black`]. This tool packages `black` for Bazel and
exposes a `black_check_test` rule which installs a Bazel test to check
formatting in each Bazel package. The tool also exposes a `black` macro which
will run `black` in the workspace root and rewrite source files with correct
formatting.

This rule takes the location of a `pyproject.toml` config as a parameter.

[`black`]: https://pypi.org/project/black/

#### `//tools/buildifier`

Format Bazel and Starlark code with [`buildifier`]. This tool packages
`buildifier` for Bazel and exposes a `buildifier_check_test` rule which installs
a Bazel test to check formatting in each Bazel package. The tool also exposes a
`buildifier` macro which will run `buildifier` in the workspace root and rewrite
source files with correct formatting.

[`buildifier`]: https://github.com/bazelbuild/buildtools

#### `//tools/gofmt`

Format go code with [`gofmt`]. This tool makes a runner for the gofmt tool
packaged with `rules_go` and exposes a `gofmt_check_test` which installs a Bazel
test to check formatting in each Bazel package. The tool also exposes a `gofmt`
macro which will run gofmt in the workspace root and rewrite source filrs with
correct formatting.

[`gofmt`]: https://pkg.go.dev/cmd/gofmt

#### `//tools/isort`

Format Python code with [`isort`]. This tool packages `isort` for Bazel and
exposes an `isort_check_test` rule which installs a Bazel test to check
formatting in each Bazel package. The tool also exposes an `isort` macro which
will run `isort` in the workspace root and rewrite source files with correct
formatting.

This rule takes the location of a `pyproject.toml` config as a parameter.

[`black`]: https://pycqa.github.io/isort/

#### `//tools/prettier`

Format many filetypes with [`prettier`]. This tool packages `prettier` for Bazel
and exposes a `prettier_check_test` rule which installs a Bazel test to check
formatting in each Bazel package. The tool also exposes a `prettier` macro which
will run `prettier` in the workspace root and rewrite source files with correct
formatting.

The rule takes the location of `.prettierignore` and `.prettierrc` (of any type)
configs as parameters.

[`prettier`]: https://prettier.io/

### Linters

### `//tools/eslint`

Lint JavaScript code with [`eslint`]. This tool packages `eslint` for Bazel and
exposes an `eslint_check_test` which installs a Bazel test to lint code in each
Bazel package.

The rule takes the location of `.eslintignore` and `.eslintrc` (of any type)
configs as parameters.

[`eslint`]: https://eslint.org/

### `//tools/flake8`

Lint Python code with [`flake8`]. This tool packages `flake8` for Bazel and
exposes a `flake8_check_test` rule which installs a Bazel test to lint code in
each Bazel package.

This rule takes the location of a `.flake8` config as a parameter.

[`flake8`]: https://flake8.pycqa.org/en/latest/

### `//tools/yamllint`

Lint YAML code with [`yamllint`]. This tool packages `yamllint` for Bazel and
exposes a `yamllint_check_test` rule which installs a Bazel test to lint code in
each Bazel package.

This rule takes the location of a `.yamllint.yaml` config as a parameter.

[`flake8`]: https://flake8.pycqa.org/en/latest/
