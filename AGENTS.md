# Project: personal linux dotfiles

## Overview

Personal dotfiles source managed with [chezmoi](https://www.chezmoi.io/).

## Commands

Required loop before considering any bash change done in this order:

`task sh:fmt`: format with shfmt (writes changes)
`task sh:lint`: lint with shellcheck
`task sh:test`: run the shellspec suite

Required loop before considering any GitHub Actions change done in this order:

`task gh:fmt`: format workflows with yamlfmt (writes changes)
`task gh:lint`: lint workflows with actionlint

## File map

- `scripts/lib/`: reusable shell libraries and functions
- `scripts/setup/`: installation and provisioning scripts
- `spec/`: ShellSpec tests mirroring the project's Bash sources:
  - `spec/lib/` mirrors `scripts/lib/`
  - `spec/setup/` mirrors `scripts/setup/`
  - `spec/chezmoiscripts/` mirrors `home/.chezmoiscripts/`
- `home/`: chezmoi source state
- `home/.chezmoiexternals/`: definitions for fetching and installing external files or archives into chezmoi
- `home/.chezmoiscripts/`: lifecycle scripts executed by chezmoi during apply
- `.env.example`: secrets management (Doppler); `.env.example` only holds a token placeholder, never a real secret
- `mise.toml`: pinned tool versions
- `Taskfile.yml`: source of truth for dev tasks (format/lint/test)
- `validation/`: ephemeral container/VM environments used to test dotfiles; out of scope unless explicitly requested

## Constraints

- Do NOT modify anything under `home/` (EXCEPT `home/.chezmoiexternals/` and `home/.chezmoiscripts/`)
- Do NOT install new dependencies without flagging it first
