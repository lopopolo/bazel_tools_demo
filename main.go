package main

import (
	"flag"
	"fmt"
)

const (
	BinaryName string = "bazel run //:static"
)

func main() {
	usage := fmt.Sprintf(
		`%s: a dummy package for go dependency management.

About: This is a dummy package and binary which works together with //tools/update-go-deps
       to allow for Gazelle to manage dependencies for the hyperbola-static Bazel workspace
       while each go package manages its own dependencies through package-local`+" `go.mod` "+`
       files.

       See the README in //tools/update-go-deps for more information.

Usage: %s -- [OPTIONS]

Options:
	-help		Print help information
`,
		BinaryName,
		BinaryName,
	)

	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), usage)
	}
	flag.Parse()

	fmt.Printf(usage)
}
