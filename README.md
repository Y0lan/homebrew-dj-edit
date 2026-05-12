# homebrew-dj-edit

Homebrew tap for [dj-edit](https://github.com/Y0lan/dj-edit) — auto-edit DJ-set videos into TikTok-ready cuts.

## Install

```bash
brew tap Y0lan/dj-edit
brew install dj-edit
```

This installs `ffmpeg`, `python@3.11`, `jq`, creates a virtual environment with `librosa + scipy + numpy + soundfile`, and puts:

- `dj-edit` CLI on your PATH
- `/Applications/dj-edit-mac.command` for the GUI launcher (macOS only)

## Update

```bash
brew upgrade dj-edit
```

## Uninstall

```bash
brew uninstall dj-edit
brew untap Y0lan/dj-edit
```

## Status

v0.1.0 builds from source. Pre-built bottles (arm64 + x86_64) coming in v0.1.1 once CI infrastructure is set up.
