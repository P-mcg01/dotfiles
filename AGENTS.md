# Project: personal linux dotfiles

## Overview

Personal dotfiles source managed with [chezmoi](https://www.chezmoi.io/).

## Commands

Required loop before considering any bash change done — in this order:

`task fmt` — format with shfmt (writes changes)
`task lint` — lint with shellcheck
`task test` — run the shellspec suite

Required loop before considering any GitHub Actions change done — in this order:

`task actions-fmt` — format workflows with yamlfmt (writes changes)
`task actions-lint` — lint workflows with actionlint

## File map

- `scripts/` — bash scripts
- `spec/` — ShellSpec tests mirroring `scripts/`
- `home/` — chezmoi source state
- `doppler.yaml` / `.env.example` — secrets management (Doppler); `.env.example` only holds a token placeholder, never a real secret
- `mise.toml` — pinned tool versions
- `Taskfile.yml` — source of truth for dev tasks (format/lint/test)
- `validation/` — ephemeral container/VM environments used to test dotfiles; out of scope unless explicitly requested

## Constraints

- Do NOT modify anything under `home/`
- Do NOT install new dependencies without flagging it first
