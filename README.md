# SGIFNOC

Personal dotfiles and development environment configuration for macOS and Linux workstations.

## Quick Start

### New Machine Setup (Recommended Path)

For setting up a new development machine, run these commands in order:

```bash
# 1. Install Python environment (pyenv + Poetry)
make setup

# 2. Install dotfiles and configurations
make install

# 3. Verify everything is working
./scripts/verify-setup.sh
```

**That's it!** Open a new terminal and you're ready to go.

---

## What Gets Installed

### Python Development Environment (`make setup`)

- **pyenv** - Python version manager
- **Python 3.11.6** - Pinned version from `.python-version`
- **Poetry** - Python dependency and package manager
- **GitHub CLI (gh)** - For creating PRs from terminal (optional but recommended)

### Dotfiles and Configurations (`make install`)

- **Shell configs** - Bash and Zsh configurations with aliases and functions
- **Git config** - Enhanced git configuration with GPG signing support
- **Vim setup** - Vim with Vundle plugin manager and pre-configured plugins
- **iTerm2 settings** - Terminal configuration (macOS only)
- **Additional dotfiles** - `.aliases`, `.func`, `.inputrc`, `.screenrc`

---

## Detailed Setup Instructions

### Prerequisites

**macOS:**
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Xcode Command Line Tools
xcode-select --install
```

**Linux:**
- Your distribution's package manager will be used automatically
- Supported: apt, dnf, yum, pacman

### Python Environment Setup

```bash
# Full setup (recommended for new machines)
make setup

# Or individual steps:
make deps                 # Install Homebrew dependencies
make pyenv-install        # Install pyenv
make python-install       # Install Python from .python-version
make poetry-install       # Install Poetry
make configure-poetry     # Configure Poetry settings
```

**What this does:**
- Installs build dependencies (xz, openssl, readline) via Homebrew
- Installs `pyenv` for Python version management
- Builds Python 3.11.6 with proper lzma/compression support
- Installs Poetry using the pyenv-managed Python
- Configures Poetry to use pyenv's active Python version

### Dotfiles Installation

```bash
# Install everything
make install

# Or individual components:
make dotfiles      # Symlink dotfiles to home directory
make zsh           # Install zsh configuration files
make vim           # Install Vim with Vundle and plugins
make iterm-apply   # Apply iTerm2 settings (macOS only)
```

**What this does:**
- Creates symlinks from `~/` to dotfiles in this repository
- Installs Zsh configs: `~/.zshrc` and `~/.zshenv`
- Sets up Vim with Vundle plugin manager
- Installs Vim plugins for Python, Go, Terraform, Docker, etc.
- Applies iTerm2 configuration (macOS only)

### Verification

After installation, verify everything is working:

```bash
./scripts/verify-setup.sh
```

This checks:
- Shell configuration (zsh/bash)
- Git settings
- GitHub CLI authentication
- Python/pyenv/Poetry installation
- Vim setup
- Dotfiles symlinks
- Optional tools (Docker, kubectl, etc.)

---

## Configuration

### Personal Settings

#### Private Environment Variables

Create `~/.boffline` for private variables (API keys, work configs, etc.):

```bash
# Copy the example template
cp .boffline.example ~/.boffline

# Edit with your values
vim ~/.boffline
```

The `.boffline` file is automatically sourced by `.bashrc` and is git-ignored.

#### Git Configuration

Update your personal information in `~/.gitconfig` after installation:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

For work-specific settings, create `~/.gitconfig.local`:

```bash
# ~/.gitconfig.local
[user]
    email = work.email@company.com
```

Or use conditional includes for work directories:

```bash
# Add to ~/.gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig.work
```

#### GPG Signing with 1Password

The git config includes GPG signing via 1Password SSH. To set it up:

1. Install 1Password and enable SSH agent
2. Generate an SSH key in 1Password
3. Update the signing key in `.gitconfig`:
   ```bash
   git config --global user.signingkey "ssh-ed25519 YOUR_KEY_HERE"
   ```

Or disable GPG signing:
```bash
git config --global commit.gpgsign false
```

### Shell Choice

This repository supports both **Bash** and **Zsh**. Zsh is recommended for modern setups.

**Switch to Zsh (macOS default since Catalina):**
```bash
chsh -s /bin/zsh
```

**Zsh Features:**
- Oh-My-Zsh integration with plugins
- Git status in prompt
- Syntax highlighting and autosuggestions
- Enhanced completion

---

## Usage

### Shell Aliases

Common git aliases (see `.aliases` for full list):

```bash
gs          # git status
gd          # git diff
gl          # git log
gpr         # git pull --rebase
gp          # git push
```

Kubernetes shortcuts:
```bash
kc          # kubectl
kn          # kubens (switch namespace)
k           # kubectl get
```

### Shell Functions

Available functions (see `.func` for full list):

```bash
trash FILE              # Move file to trash instead of rm
randomstring [LENGTH]   # Generate random string
geoip IP                # Get geolocation for IP address
```

### Creating Pull Requests

Use the `prq` function (requires GitHub CLI):

```bash
# Create PR with auto-generated title and body
prq

# Create PR with custom title
prq "My PR Title"

# Create PR with title and body
prq "Title" "Description"

# Create PR against different base branch
prq "Title" "Description" develop
```

---

## Platform Support

- **macOS** - Primary platform, fully supported
- **Linux** - Supported via `scripts/setup.sh`
  - Tested on: Ubuntu, Fedora, CentOS, Arch Linux

---

## Maintenance

### Update iTerm2 Settings

After changing iTerm2 settings:

```bash
make iterm-capture    # Save current iTerm2 settings to repo
```

### Update Python Version

To change Python version:

```bash
# Update .python-version file
echo "3.12.0" > .python-version

# Reinstall Python
make python-install
```

### Keep Git Config in Sync

The repository has two git config files:
- `.gitconfig` - Active configuration (gets symlinked to `~/.gitconfig`)
- `configs/git/gitconfig` - Template/reference (for backup)

After running `make dotfiles`, `~/.gitconfig` will link to the root `.gitconfig`.

---

## Alternative Setup Scripts

For historical/reference purposes, alternative setup scripts exist:

- `scripts/setup-macos.sh` - Standalone macOS setup script
- `scripts/macos.sh` - Interactive macOS setup with system preferences
- `scripts/setup.sh` - Linux setup script

**Note:** The `Makefile` approach is now recommended and provides the same functionality with better integration.

---

## Troubleshooting

### Python Build Fails

If Python installation fails with lzma/compression errors:

```bash
# Install dependencies
brew install xz openssl readline

# Rebuild Python
pyenv uninstall 3.11.6
make python-install
```

### Zsh Config Not Loading

If zsh configuration isn't loading:

```bash
# Ensure files are symlinked
make zsh

# Verify symlinks exist
ls -la ~/.zshrc ~/.zshenv

# Reload shell
source ~/.zshrc
```

### Vim Plugins Not Working

```bash
# Reinstall Vundle and plugins
make vim

# Or manually update plugins
vim +PluginInstall +qall
```

### GitHub CLI Authentication

```bash
# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status
```

---

## Tools and Technologies

This repository configures:

- **Shell:** Bash, Zsh, Oh-My-Zsh
- **Version Control:** Git with GPG signing
- **Python:** pyenv, Poetry, flake8
- **Editor:** Vim with Vundle and extensive plugins
- **Terminal:** iTerm2 (macOS)
- **Cloud/Containers:** Docker, Kubernetes, Terraform
- **CI/CD:** GitHub Actions for macOS testing

---

## Contributing

This is a personal dotfiles repository, but feel free to:
- Fork for your own use
- Submit issues for bugs
- Suggest improvements via PRs

---

## License

Personal configuration files - use at your own risk and customize to your needs.
