#!/usr/bin/env bash
set -euo pipefail

dry_run=0

usage() {
  cat <<'EOF'
Usage: ./install-system-packages.sh [--dry-run]

Installs system packages needed by these dotfiles.

Supported platforms:
  - macOS with Homebrew
  - Ubuntu or Ubuntu-like Linux with apt

Also installs the npm language servers configured in .config/nvim:
  - pyright
  - typescript
  - typescript-language-server
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      dry_run=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n\n' "$arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'

  if (( dry_run == 0 )); then
    "$@"
  fi
}

have() {
  command -v "$1" >/dev/null 2>&1
}

sudo_cmd=()
if (( EUID != 0 )); then
  if have sudo || (( dry_run == 1 )); then
    sudo_cmd=(sudo)
  else
    die "sudo is required on Linux when not running as root"
  fi
fi

install_macos() {
  have brew || die "Homebrew is required on macOS. Install it from https://brew.sh/ and rerun this script."

  local formulae=(
    git
    vim
    neovim
    tmux
    fzf
    gnupg
    nmap
    tcpdump
    node
    python
    perl
  )

  local casks=(
    ghostty
    font-jetbrains-mono
  )

  log "Installing Homebrew formulae..."
  run brew install "${formulae[@]}"

  log "Installing Homebrew casks..."
  run brew install --cask "${casks[@]}"
}

apt_package_exists() {
  apt-cache show "$1" >/dev/null 2>&1
}

install_ubuntu() {
  have apt-get || die "apt-get was not found; this script only supports Ubuntu-like Linux systems"

  local packages=(
    ca-certificates
    curl
    git
    zsh
    vim
    neovim
    tmux
    fzf
    gnupg
    nmap
    tcpdump
    nodejs
    npm
    python3
    python3-pip
    python3-venv
    perl
    gawk
    procps
    xclip
    xdg-utils
    fonts-jetbrains-mono
  )

  local optional_packages=(
    ghostty
    wl-clipboard
  )

  log "Refreshing apt metadata..."
  run "${sudo_cmd[@]}" apt-get update

  log "Installing apt packages..."
  run "${sudo_cmd[@]}" apt-get install -y "${packages[@]}"

  local available_optional=()
  local pkg
  for pkg in "${optional_packages[@]}"; do
    if (( dry_run == 1 )) || apt_package_exists "$pkg"; then
      available_optional+=("$pkg")
    else
      warn "optional package '$pkg' is not available from the configured apt repositories"
    fi
  done

  if (( ${#available_optional[@]} > 0 )); then
    log "Installing available optional apt packages..."
    run "${sudo_cmd[@]}" apt-get install -y "${available_optional[@]}"
  fi
}

install_npm_language_servers() {
  local npm_packages=(
    pyright
    typescript
    typescript-language-server
  )

  if ! have npm; then
    if (( dry_run == 1 )); then
      log "Installing npm language servers..."
      run npm install -g "${npm_packages[@]}"
      return
    fi

    die "npm was not installed or is not on PATH; cannot install Neovim language servers"
  fi

  local npm_prefix
  npm_prefix="$(npm config get prefix 2>/dev/null || true)"

  if [[ -n "$npm_prefix" && ( -w "$npm_prefix" || ! -e "$npm_prefix" ) ]] || (( EUID == 0 )); then
    log "Installing npm language servers..."
    run npm install -g "${npm_packages[@]}"
  else
    log "Installing npm language servers with sudo..."
    run "${sudo_cmd[@]}" npm install -g "${npm_packages[@]}"
  fi
}

check_neovim_version() {
  have nvim || return 0

  local version
  version="$(NVIM_LOG_FILE=/dev/null nvim --version | sed -n '1s/^NVIM v//p')"

  case "$version" in
    0.11.*|0.12.*|0.13.*|1.*)
      ;;
    "")
      warn "could not determine Neovim version"
      ;;
    *)
      warn "this Neovim config uses vim.lsp.config/vim.lsp.enable; use Neovim 0.11+ if '$version' is too old"
      ;;
  esac
}

main() {
  case "$(uname -s)" in
    Darwin)
      install_macos
      ;;
    Linux)
      install_ubuntu
      ;;
    *)
      die "unsupported OS: $(uname -s)"
      ;;
  esac

  install_npm_language_servers
  check_neovim_version

  log "Done."
}

main
