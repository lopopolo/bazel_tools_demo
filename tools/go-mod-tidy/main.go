package main

import (
	"flag"
	"fmt"
	"io/fs"
	"log"
	"path/filepath"

	"github.com/lopopolo/bazel-tools-demo/tools/bazelutil"
)

const (
	BinaryName   string = "bazel run //tools/go-mod-tidy"
	ModGoVersion string = "1.19"
)

func skipDir(path string) bool {
	switch filepath.Base(path) {
	case ".git":
	case "node_modules":
	case "pkg":
	case "target":
	case "third_party":
	case "vendor":
	default:
		return false
	}

	return true
}

func FindSourceModules(rootPath string) ([]string, error) {
	paths := make([]string, 0)

	err := filepath.WalkDir(rootPath, func(path string, d fs.DirEntry, err error) error {
		if skipDir(path) {
			return fs.SkipDir
		}

		// Exclude the root go mod
		if filepath.Base(path) == "go.mod" && path != "go.mod" {
			paths = append(paths, path)
		}
		return nil
	})

	if err != nil {
		return []string{}, err
	}

	return paths, nil
}

func main() {
	flag.Usage = func() {
		usage := fmt.Sprintf(
			`%s: Run `+"`go mod tidy`"+`in a Bazel monorepo.

About: This package and binary which works together with //tools/update-go-deps and //:gazelle
       to run`+" `go mod tidy` "+`for all packages with`+" `go.mod` "+`files in this workspace.

Usage: %s -- [OPTIONS]

Options:
	-help		Print help information
`,
			BinaryName,
			BinaryName,
		)

		fmt.Fprintf(flag.CommandLine.Output(), usage)
	}
	flag.Parse()

	if err := bazelutil.ChdirWorkspace(); err != nil {
		log.Fatal(err)
	}

	packages, err := FindSourceModules(".")
	if err != nil {
		log.Fatal(err)
	}
	packages = append([]string{"."}, packages...)
	for _, mod := range packages {
		dir := filepath.Dir(mod)
		version := fmt.Sprintf("-go=%s", ModGoVersion)

		fmt.Printf("🛠️ ✨ Running `go mod edit -go=%s` in `%s` ...\n", ModGoVersion, dir)
		if err := bazelutil.BazelRunArgs("@go_sdk//:bin/go", "mod", "edit", version); err != nil {
			log.Fatal(err)
		}
	}

	targets := []string{
		".",
		"assets",
		"assetutil",
		"contact",
		"content/lifestream",
		"css",
		"js",
		"keys",
		"logo/favicons",
		"logo/optimized",
		"tools/go-mod-tidy",
		"tools/update-go-deps",
	}

	for _, dir := range targets {
		fmt.Printf("🛠️ ✨ Running `go mod tidy` in `%s` ...\n", dir)
		if err := bazelutil.BazelRunArgs("@go_sdk//:bin/go", "mod", "tidy"); err != nil {
			log.Fatal(err)
		}
	}

	fmt.Println("🛠️ ✨ Running `bazel run //tools/update-go-deps` ...")
	if err := bazelutil.BazelRun("//tools/update-go-deps"); err != nil {
		log.Fatal(err)
	}

	fmt.Println("🛠️ ✨ Running `bazel run //:gazelle` ...")
	if err := bazelutil.BazelRun("//:gazelle"); err != nil {
		log.Fatal(err)
	}
}
