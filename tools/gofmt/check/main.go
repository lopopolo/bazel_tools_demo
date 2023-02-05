package main

import (
	"bufio"
	"bytes"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type ErrIncorrectFormat struct {
	Output string
}

func (e *ErrIncorrectFormat) Error() string {
	return "gofmt detected changes"
}

type Flags struct {
	Gofmt       string
	Sourcesfile string
}

type Config struct {
	Gofmt string
	Files []string
}

func (cfg Config) PrintSuccess() {
	fmt.Println("All done! ✨ 🔮 ✨")
	if len(cfg.Files) == 1 {
		fmt.Println("1 file would be left unchanged.")
	} else {
		fmt.Printf("%d files would be left unchanged.\n", len(cfg.Files))
	}
}

func parseArgs() (Flags, error) {
	var flags Flags
	flag.StringVar(&flags.Gofmt, "gofmt", "", "path to gofmt binary")
	flag.StringVar(&flags.Sourcesfile, "sourcesfile", "", "path to list of go sources to check")
	flag.Parse()

	if len(flags.Gofmt) == 0 {
		return Flags{}, fmt.Errorf("-gofmt argument is required")
	}

	if len(flags.Sourcesfile) == 0 {
		return Flags{}, fmt.Errorf("-sourcesfile argument is required")
	}

	return flags, nil
}

func loadConfig(flags Flags) (Config, error) {
	content, err := os.ReadFile(flags.Sourcesfile)
	if err != nil {
		return Config{}, err
	}

	gofmt, err := filepath.Abs(flags.Gofmt)
	if err != nil {
		return Config{}, err
	}
	cfg := Config{Gofmt: gofmt}

	scanner := bufio.NewScanner(strings.NewReader(string(content)))
	for scanner.Scan() {
		file := scanner.Text()
		if len(file) == 0 {
			continue
		}
		cfg.Files = append(cfg.Files, file)
	}
	if len(cfg.Files) == 0 {
		return Config{}, fmt.Errorf("go source files not present in sourcesfile")
	}

	return cfg, nil
}

func gofmtCheck(cfg Config, logger io.Writer) error {
	gofmtArgs := []string{"-l", "-s", "-d"}
	gofmtArgs = append(gofmtArgs, cfg.Files...)

	fmt.Fprintf(logger, "🛠️ ✨ Running `gofmt %s`\n", strings.Join(gofmtArgs, " "))

	var buf bytes.Buffer
	out := bufio.NewWriter(&buf)

	cmd := exec.Command(cfg.Gofmt, gofmtArgs...)
	cmd.Stdout = out
	cmd.Stderr = os.Stderr
	cmd.Stdin = nil // close stdin

	if err := cmd.Run(); err != nil {
		return err
	}

	output := strings.TrimSpace(buf.String())
	if len(output) != 0 {
		return &ErrIncorrectFormat{
			Output: output,
		}
	}
	return nil
}

func main() {
	flags, err := parseArgs()
	if err != nil {
		log.Fatal(err)
	}

	cfg, err := loadConfig(flags)
	if err != nil {
		log.Fatal(err)
	}

	err = gofmtCheck(cfg, os.Stdout)
	if err == nil {
		cfg.PrintSuccess()
		return
	}

	var incorrect *ErrIncorrectFormat
	if errors.As(err, &incorrect) {
		fmt.Println("❌❌ gofmt detected incorrect formatting and would make changes")
		fmt.Println("")
		fmt.Printf("%s\n", incorrect.Output)
		os.Exit(1)
	}
	log.Fatal(err)
}
