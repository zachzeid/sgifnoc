#!/usr/bin/env bash
#
# verify-setup.sh - Verify that SGIFNOC environment setup is complete
#
# This script checks that all required tools and configurations are properly
# installed and configured. Run this after completing setup to verify
# everything is working correctly.
#

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

check_pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((PASSED++))
}

check_fail() {
  echo -e "${RED}✗${NC} $1"
  ((FAILED++))
}

check_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
  ((WARNINGS++))
}

print_header "SGIFNOC Environment Verification"

# Check Shell
print_header "Shell Configuration"
if [[ -n "$ZSH_VERSION" ]]; then
  check_pass "Running zsh"

  if [[ -f "$HOME/.zshrc" ]]; then
    check_pass "~/.zshrc exists"
    if [[ -L "$HOME/.zshrc" ]]; then
      check_pass "~/.zshrc is a symlink (managed by repo)"
    else
      check_warn "~/.zshrc is not a symlink (may not be managed by repo)"
    fi
  else
    check_fail "~/.zshrc not found"
  fi

  if [[ -f "$HOME/.zshenv" ]]; then
    check_pass "~/.zshenv exists"
  else
    check_warn "~/.zshenv not found (optional but recommended)"
  fi

  if command -v omz &> /dev/null; then
    check_pass "Oh-My-Zsh is installed"
  else
    check_warn "Oh-My-Zsh not found (optional but recommended)"
  fi
elif [[ -n "$BASH_VERSION" ]]; then
  check_pass "Running bash"

  if [[ -f "$HOME/.bashrc" ]]; then
    check_pass "~/.bashrc exists"
  else
    check_fail "~/.bashrc not found"
  fi
else
  check_warn "Unknown shell: $SHELL"
fi

# Check Git Configuration
print_header "Git Configuration"
if command -v git &> /dev/null; then
  check_pass "Git is installed ($(git --version))"

  if [[ -f "$HOME/.gitconfig" ]]; then
    check_pass "~/.gitconfig exists"

    git_name=$(git config --global user.name 2>/dev/null || echo "")
    git_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -n "$git_name" ]]; then
      check_pass "Git user.name configured: $git_name"
    else
      check_fail "Git user.name not configured"
    fi

    if [[ -n "$git_email" ]]; then
      check_pass "Git user.email configured: $git_email"
    else
      check_fail "Git user.email not configured"
    fi

    default_branch=$(git config --global init.defaultBranch 2>/dev/null || echo "")
    if [[ "$default_branch" == "main" ]]; then
      check_pass "Git default branch set to 'main'"
    else
      check_warn "Git default branch not set to 'main' (current: ${default_branch:-not set})"
    fi
  else
    check_fail "~/.gitconfig not found"
  fi

  if [[ -f "$HOME/.gitignore_global" ]]; then
    check_pass "Global .gitignore exists"
  else
    check_warn "Global .gitignore not found (optional)"
  fi
else
  check_fail "Git is not installed"
fi

# Check GitHub CLI
print_header "GitHub CLI"
if command -v gh &> /dev/null; then
  check_pass "GitHub CLI is installed ($(gh --version | head -n1))"

  if gh auth status &> /dev/null; then
    check_pass "GitHub CLI is authenticated"
  else
    check_warn "GitHub CLI is not authenticated (run: gh auth login)"
  fi
else
  check_warn "GitHub CLI (gh) not installed (optional but recommended)"
fi

# Check Homebrew (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  print_header "Homebrew (macOS)"
  if command -v brew &> /dev/null; then
    check_pass "Homebrew is installed"
  else
    check_fail "Homebrew is not installed"
  fi
fi

# Check Python/pyenv
print_header "Python Environment"
if command -v pyenv &> /dev/null; then
  check_pass "pyenv is installed ($(pyenv --version))"

  # Check if pyenv is properly initialized
  if pyenv versions &> /dev/null; then
    check_pass "pyenv is properly initialized"

    # Get Python version from .python-version if it exists
    if [[ -f "$HOME/.python-version" ]] || [[ -f ".python-version" ]]; then
      python_version=$(cat .python-version 2>/dev/null || cat "$HOME/.python-version" 2>/dev/null || echo "")
      if [[ -n "$python_version" ]]; then
        if pyenv versions --bare | grep -qx "$python_version"; then
          check_pass "Python $python_version is installed via pyenv"

          # Check if this version has lzma module (common issue)
          if pyenv exec python -c "import lzma" 2>/dev/null; then
            check_pass "Python lzma module is available"
          else
            check_fail "Python lzma module not available (rebuild Python with: brew install xz && pyenv install $python_version)"
          fi
        else
          check_fail "Python $python_version not installed (run: pyenv install $python_version)"
        fi
      fi
    fi
  else
    check_warn "pyenv not properly initialized in shell"
  fi
else
  check_fail "pyenv is not installed"
fi

# Check Poetry
print_header "Poetry (Python Package Manager)"
if command -v poetry &> /dev/null; then
  check_pass "Poetry is installed ($(poetry --version))"

  # Check Poetry configuration
  use_poetry_python=$(poetry config virtualenvs.use-poetry-python 2>/dev/null || echo "")
  if [[ "$use_poetry_python" == "true" ]]; then
    check_pass "Poetry configured to use project Python"
  else
    check_warn "Poetry not configured to use project Python (run: poetry config virtualenvs.use-poetry-python true)"
  fi
else
  check_warn "Poetry is not installed (optional but recommended for Python projects)"
fi

# Check Vim
print_header "Vim Configuration"
if command -v vim &> /dev/null; then
  check_pass "Vim is installed"

  if [[ -f "$HOME/.vimrc" ]]; then
    check_pass "~/.vimrc exists"
  else
    check_warn "~/.vimrc not found"
  fi

  if [[ -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
    check_pass "Vundle plugin manager installed"
  else
    check_warn "Vundle not installed (run: make vim)"
  fi
else
  check_warn "Vim is not installed (optional)"
fi

# Check Dotfiles
print_header "Dotfiles Symlinks"
dotfiles=(".aliases" ".func" ".inputrc" ".screenrc")
for dotfile in "${dotfiles[@]}"; do
  if [[ -f "$HOME/$dotfile" ]]; then
    if [[ -L "$HOME/$dotfile" ]]; then
      check_pass "$dotfile exists and is a symlink"
    else
      check_warn "$dotfile exists but is not a symlink"
    fi
  else
    check_warn "$dotfile not found in home directory"
  fi
done

# Check Additional Tools
print_header "Additional Tools"
tools=("docker" "kubectl" "terraform" "node" "go")
for tool in "${tools[@]}"; do
  if command -v "$tool" &> /dev/null; then
    version=$($tool version 2>&1 | head -n1 || $tool --version 2>&1 | head -n1)
    check_pass "$tool is installed: $version"
  else
    check_warn "$tool not installed (optional)"
  fi
done

# Summary
print_header "Verification Summary"
echo ""
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC}   $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
  if [[ $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✓ All checks passed! Your environment is fully set up.${NC}"
    exit 0
  else
    echo -e "${YELLOW}⚠ Setup is functional but has some warnings (see above).${NC}"
    exit 0
  fi
else
  echo -e "${RED}✗ Some checks failed. Please address the issues above.${NC}"
  echo ""
  echo "Common fixes:"
  echo "  - Run 'make setup' to install Python environment"
  echo "  - Run 'make install' to symlink dotfiles"
  echo "  - Run 'make vim' to install Vim plugins"
  echo "  - Run 'gh auth login' to authenticate GitHub CLI"
  exit 1
fi
