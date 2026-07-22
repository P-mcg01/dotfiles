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

This repository contains my personal Linux configuration files managed with **chezmoi**.

For a detailed history of changes, see the [CHANGELOG.md](./CHANGELOG.md).

## Showcase

![desktop](./.github/assets/desktop.png)
![terminal](./.github/assets/terminal.png)
![workflow](./.github/assets/workflow.png)

### Core Components

- **OS:** Fedora 44
- **Compositor:** Hyprland
- **Terminal:** Kitty
- **Shell:** Zsh
- **Dotfile Manager:** Chezmoi

## Installation

Clone and initialize the dotfiles with chezmoi:

```bash
chezmoi init git@github.com:P-mcg01/dotfiles.git
chezmoi apply
```
