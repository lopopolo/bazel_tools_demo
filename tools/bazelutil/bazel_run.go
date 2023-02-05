package bazelutil

import (
	"fmt"
	"os"
	"os/exec"
)

const (
	// Filtering logging outputs from Bazel
	//
	// > To make the logs less noisy, you can suppress the outputs from Bazel
	// > itself with the `--ui_event_filters` and `--noshow_progress` flags.
	//
	// https://bazel.build/docs/user-manual#filtering_logging_outputs_from_bazel
	// https://bazel.build/reference/command-line-reference#flag--ui_event_filters
	uiFilters      string = "--ui_event_filters=-warning,-info,-stdout,-stderr"
	noShowProgress string = "--noshow_progress"
)

func BazelRun(target string) error {
	if target == "" {
		return fmt.Errorf("target must be non-empty")
	}
	cmd := exec.Command("bazel", "run", uiFilters, noShowProgress, target)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = nil // close stdin

	return cmd.Run()
}

func BazelRunArgs(target string, args ...string) error {
	if target == "" {
		return fmt.Errorf("target must be non-empty")
	}
	if len(args) == 0 {
		return fmt.Errorf("args must be non-empty")
	}
	args = append([]string{"run", uiFilters, noShowProgress, target, "--"}, args...)
	cmd := exec.Command("bazel", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = nil // close stdin

	return cmd.Run()
}
