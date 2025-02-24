#!/bin/bash

# sgifnoc Linux setup script
# This script sets up Linux-specific configurations

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Install packages based on package manager
install_packages() {
    log_info "Would you like to install recommended development packages? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        PKG_MANAGER=$(detect_package_manager)
        log_info "Detected package manager: $PKG_MANAGER"
        
        case $PKG_MANAGER in
            apt)
                log_info "Updating package lists..."
                sudo apt-get update
                
                log_info "Installing packages..."
                sudo apt-get install -y \
                    git \
                    vim \
                    tmux \
                    zsh \
                    build-essential \
                    curl \
                    wget \
                    python3 \
                    python3-pip \
                    python3-venv \
                    nodejs \
                    npm
                ;;
            dnf|yum)
                log_info "Updating package lists..."
                sudo $PKG_MANAGER update -y
                
                log_info "Installing packages..."
                sudo $PKG_MANAGER install -y \
                    git \
                    vim \
                    tmux \
                    zsh \
                    make \
                    gcc \
                    curl \
                    wget \
                    python3 \
                    python3-pip \
                    nodejs \
                    npm
                ;;
            pacman)
                log_info "Updating package lists..."
                sudo pacman -Syu --noconfirm
                
                log_info "Installing packages..."
                sudo pacman -S --noconfirm \
                    git \
                    vim \
                    tmux \
                    zsh \
                    base-devel \
                    curl \
                    wget \
                    python \
                    python-pip \
                    nodejs \
                    npm
                ;;
            *)
                log_warn "Unknown package manager. Please install the following packages manually:"
                echo "git, vim, tmux, zsh, build tools, curl, wget, python3, python3-pip, nodejs, npm"
                return 1
                ;;
        esac
        
        log_info "Packages installed successfully!"
    else
        log_warn "Skipping package installation."
    fi
}

# Setup Python environment with pyenv
setup_python() {
    log_info "Would you like to install pyenv for Python version management? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if ! command -v pyenv >/dev/null 2>&1; then
            log_info "Installing pyenv..."
            curl https://pyenv.run | bash
            
            # Add pyenv to shell configuration
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
            echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
            
            log_info "Pyenv installed successfully!"
        else
            log_info "Pyenv is already installed."
        fi
    else
        log_warn "Skipping pyenv installation."
    fi
}

# Setup Oh My Zsh if needed
setup_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Would you like to install Oh My Zsh? (y/n)"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            log_info "Installing Oh My Zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            
            # Install recommended plugins
            log_info "Installing Zsh plugins..."
            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
            
            log_info "Oh My Zsh installed successfully!"
        else
            log_warn "Skipping Oh My Zsh installation."
        fi
    else
        log_info "Oh My Zsh is already installed."
    fi
}

# Setup node environment with nvm
setup_node() {
    log_info "Would you like to install nvm for Node.js version management? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if [ ! -d "$HOME/.nvm" ]; then
            log_info "Installing nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            
            log_info "NVM installed successfully!"
        else
            log_info "NVM is already installed."
        fi
    else
        log_warn "Skipping nvm installation."
    fi
}

# Main function
main() {
    log_info "Starting Linux-specific setup..."
    
    install_packages
    setup_python
    setup_node
    setup_oh_my_zsh
    
    log_info "Linux setup completed successfully!"
}

# Run main function
main
