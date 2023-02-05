package bazelutil

import (
	"errors"
	"os"
	"strings"
)

const (
	BuildWorkspaceDirectoryEnv string = "BUILD_WORKSPACE_DIRECTORY"
)

var ErrNotBazelRun = errors.New("not running under `bazel run`")

func EnvironmentIsBazelRun() error {
	for _, e := range os.Environ() {
		pair := strings.SplitN(e, "=", 2)
		if pair[0] == BuildWorkspaceDirectoryEnv {
			return nil
		}
	}
	return ErrNotBazelRun
}

func GetWorkspaceDir() (string, error) {
	if workspace := os.Getenv("BUILD_WORKSPACE_DIRECTORY"); workspace != "" {
		return workspace, nil
	}
	return "", ErrNotBazelRun
}

func ChdirWorkspace() error {
	workspace, err := GetWorkspaceDir()
	if err != nil {
		return err
	}
	if err := os.Chdir(workspace); err != nil {
		return err
	}
	return nil
}
