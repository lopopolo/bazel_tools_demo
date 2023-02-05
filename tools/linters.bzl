load("//tools/black:defs.bzl", "black_check_test")
load("//tools/buildifier:defs.bzl", "buildifier_check_test")
load("//tools/eslint:defs.bzl", "eslint_check_test")
load("//tools/flake8:defs.bzl", "flake8_check_test")
load("//tools/gofmt:defs.bzl", "gofmt_check_test")
load("//tools/isort:defs.bzl", "isort_check_test")
load("//tools/prettier:defs.bzl", "prettier_check_test")
load("//tools/yamllint:defs.bzl", "yamllint_check_test")

def lint_tests(
        name = "lint_test",  # @unused
        exclude_patterns = []):
    black_check_test(exclude_patterns = exclude_patterns)
    buildifier_check_test(exclude_patterns = exclude_patterns)
    eslint_check_test(exclude_patterns = exclude_patterns)
    flake8_check_test(exclude_patterns = exclude_patterns)
    gofmt_check_test(exclude_patterns = exclude_patterns)
    isort_check_test(exclude_patterns = exclude_patterns)
    prettier_check_test(exclude_patterns = exclude_patterns)
    yamllint_check_test(exclude_patterns = exclude_patterns)
