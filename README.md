# README

## Overview

This dotfiles repository provides a comprehensive, idempotent installation system for setting up a development environment on Linux/Unix systems. It includes automated installation of development tools, programming languages, and applications.

## Prerequisites

- Ubuntu/Debian-based Linux distribution
- `curl` or `wget` installed
- `sudo` access for system-wide installations

## Installation

Run the main installation script with sudo:

```sh
sudo ./install.sh
```

This will:
1. Install Homebrew package manager automatically
2. Set up essential system packages
3. Configure Bash environment with Bash-it
4. Install programming languages (Python via uv, Node.js via nvm, Rust, PHP)
5. Set up development tools (Docker, Git, etc.)
6. Install desktop applications

## Features

### 🔄 Idempotent Installation
- Scripts can be run multiple times safely
- Checks for existing installations before proceeding
- No duplicate configurations or PATH entries

### 🐍 Modern Python Management
- Uses `uv` for Python version management (similar to nvm for Node.js)
- Pre-configured helper functions for virtual environments
- Essential Python tools pre-installed

### 📦 Package Managers
- Homebrew for command-line tools
- Flatpak for desktop applications
- Snap for additional packages
- All package managers installed automatically

### 🛠️ Development Tools
- Docker and Docker Compose
- Git with global configuration
- VS Code, Sublime Text, and other editors
- Guake drop-down terminal

## Verification

Check installation status:

```sh
./verify-installation.sh
```

Test idempotency:

```sh
./test-idempotency.sh
```
## Todo
- [ ] Add options to install specific packages.
- [ ] Add options to install specific applications.
- [ ] Add options to install specific fonts.
- [ ] Add options to install specific themes.
- [ ] Add options to install extra tooling.
- [ ] Add options to install specific configurations.


## License

This project is licensed under the MIT License.