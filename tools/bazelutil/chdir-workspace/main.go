package main

import (
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/lopopolo/bazel-tools-demo/tools/bazelutil"
)

type child struct {
	program string
	args    []string
}

func getChild() (child, error) {
	args := os.Args
	if len(args) < 1 {
		return child{}, fmt.Errorf("args did not include executable name")
	}
	args = args[1:]
	if len(args) == 0 {
		return child{}, fmt.Errorf("args did not include child process")
	}
	if args[0] == "--" {
		args = args[1:]
	}
	if len(args) == 0 {
		return child{}, fmt.Errorf("args did not include child process")
	}

	prog, err := filepath.Abs(args[0])
	if err != nil {
		return child{}, err
	}
	progArgs := args[1:]

	return child{prog, progArgs}, nil
}

func main() {
	child, err := getChild()
	if err != nil {
		log.Fatal(err)
	}

	if err = bazelutil.ChdirWorkspace(); err != nil {
		log.Fatal(err)
	}

	cmd := exec.Command(child.program, child.args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = nil // close stdin

	err = cmd.Run()
	if err == nil {
		return
	}
	var exit *exec.ExitError
	if errors.As(err, &exit) {
		os.Exit(exit.ExitCode())
	}
	log.Fatal(err)
}
