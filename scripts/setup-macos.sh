#!/usr/bin/env bash
set -euo pipefail

# Bootstrap developer environment on macOS for this repository.
# - Ensures Homebrew packages needed to build Python are present (xz/openssl/readline/zlib)
# - Installs pyenv (via Homebrew) if missing
# - Installs the pinned Python version (from .python-version) via pyenv
# - Installs Poetry using the pyenv-installed Python
# - Configures Poetry to prefer using the active Python provided by pyenv
#
# Usage: ./scripts/setup-macos.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

log(){ printf "%s\n" "$*" >&2; }

if ! command -v /opt/homebrew/bin/brew >/dev/null 2>&1 && ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found in PATH. Please install Homebrew first: https://brew.sh"
  exit 1
fi

# Prefer explicit Homebrew binary if available (Apple Silicon default)
BREW="$(command -v brew || echo /opt/homebrew/bin/brew)"

log "Using brew: $BREW"

log "Installing required brew packages (xz openssl readline)"
"$BREW" install xz openssl readline || true

# Ensure pyenv is installed via Homebrew (idempotent)
if ! command -v pyenv >/dev/null 2>&1; then
  log "Installing pyenv via Homebrew"
  "$BREW" install pyenv
else
  log "pyenv already installed"
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Initialize pyenv for this script
eval "$(pyenv init --path)" || true

# Read pinned version from .python-version
if [ -f "$REPO_ROOT/.python-version" ]; then
  PY_VERSION=$(tr -d ' \n\r' < "$REPO_ROOT/.python-version")
else
  log "No .python-version in repo; defaulting to 3.11.6"
  PY_VERSION=3.11.6
fi

log "Requested Python version: $PY_VERSION"

# Install required build flags (point to brewed libs) when building
XZ_PREFIX="$($BREW --prefix xz)"
OPENSSL_PREFIX="$($BREW --prefix openssl || true)"

export LDFLAGS="-L${XZ_PREFIX}/lib ${OPENSSL_PREFIX:+-L${OPENSSL_PREFIX}/lib}"
export CPPFLAGS="-I${XZ_PREFIX}/include ${OPENSSL_PREFIX:+-I${OPENSSL_PREFIX}/include}"
export PKG_CONFIG_PATH="${XZ_PREFIX}/lib/pkgconfig:${OPENSSL_PREFIX:+${OPENSSL_PREFIX}/lib/pkgconfig}:$PKG_CONFIG_PATH"

# Install Python using pyenv if missing
if ! pyenv versions --bare | grep -qx "$PY_VERSION"; then
  log "Installing Python $PY_VERSION via pyenv (this may take a few minutes)"
  env LDFLAGS="$LDFLAGS" CPPFLAGS="$CPPFLAGS" PKG_CONFIG_PATH="$PKG_CONFIG_PATH" pyenv install "$PY_VERSION"
else
  log "pyenv Python $PY_VERSION already installed"
fi

# Set project-local version
log "Writing .python-version with $PY_VERSION"
echo "$PY_VERSION" > "$REPO_ROOT/.python-version"

# Use the pyenv-installed python to install Poetry
PY_BIN="$HOME/.pyenv/versions/$PY_VERSION/bin/python3"
if [ ! -x "$PY_BIN" ]; then
  log "Python binary not found at $PY_BIN; aborting"
  exit 1
fi

if ! command -v poetry >/dev/null 2>&1; then
  log "Installing Poetry using $PY_BIN"
  curl -sSL https://install.python-poetry.org | "$PY_BIN" -
  log "Note: you may need to add \"export PATH=\"$HOME/.local/bin:$PATH\"\" to your shell profile"
else
  log "Poetry already installed"
fi

# Configure Poetry to use the active Python (provided by pyenv) where possible
export PATH="$HOME/.local/bin:$PATH"
if command -v poetry >/dev/null 2>&1; then
  log "Configuring Poetry to use the project's active Python"
  poetry config virtualenvs.use-poetry-python true || true
  poetry config virtualenvs.create true || true
fi

log "Setup complete. Open a new terminal or source your shell profile to ensure pyenv/poetry are available."

exit 0
