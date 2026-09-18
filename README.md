# Personal Dotfiles

A modern Linux desktop focused on productivity, simplicity, and a keyboard-first workflow.

Built on Fedora Linux with Hyprland, Kitty, and Zsh.

![Fedora](https://img.shields.io/badge/Fedora-294172?style=for-the-badge&logo=fedora&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=wayland&logoColor=black)
![Kitty](https://img.shields.io/badge/Kitty-000000?style=for-the-badge&logo=gnubash&logoColor=white)
![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=zsh&logoColor=white)
![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=for-the-badge&logo=wayland&logoColor=black)
![CalVer](https://img.shields.io/badge/CalVer-YYYY.0M.MICRO-blue?style=for-the-badge)
![Protected by Gitleaks](https://img.shields.io/badge/Protected%20by-Gitleaks-blue?style=for-the-badge)

## Overview

This repository contains my personal Linux configuration files managed with [chezmoi](https://www.chezmoi.io/).

For a detailed history of changes, see the [CHANGELOG.md](./CHANGELOG.md).

## Showcase

![desktop](./.github/assets/desktop.png)
![terminal](./.github/assets/terminal.png)
![workflow](./.github/assets/workflow.png)

## Development

### Testing on containers

For safe testing of configurations without affecting the local system, this repository provides a containerized development environment powered by [Podman](https://podman.io/) and [Taskfile](https://taskfile.dev/).

#### Execution of test containers

1. Copy the environment template file:

```bash
cp .env.example .env
```

2. Define the `DOPPLER_TOKEN` variable inside `.env`.

> [!IMPORTANT]
> This token is injected into the container during execution. Manual installation of the Doppler CLI inside the container is not required, as a hook manages the installation process automatically.

3. To launch an interactive container session, the following task command is executed:

```bash
task run:<OS> [TAG="<version>"]
```

- `<OS>`: Target distribution ( [fedora](https://github.com/P-mcg01/dotfiles/pkgs/container/dotfiles-fedora) or [debian](https://github.com/P-mcg01/dotfiles/pkgs/container/dotfiles-debian) ).
- `TAG`: Container image tag from GHCR. Defaults to `dev` when omitted.

Example:

```bash
task run:fedora TAG=v26.09.05-r2.2
```

4. An interactive TTY session opens directly at `~/.local/share/chezmoi`.

```bash
chezmoi status
```

#### Local container builds

To test modifications made to `validation/containers/` prior to opening a Pull Request, container images must be built locally using:

```bash
task build:<OS>
```

This command parses the corresponding `Containerfile` under `validation/containers/<OS>` and generates a local image tagged as `dev`.
