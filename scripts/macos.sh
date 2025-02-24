#!/bin/bash

# sgifnoc macOS setup script
# This script sets up macOS-specific configurations

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

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_warn "Homebrew is not installed. Would you like to install it? (y/n)"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            log_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            log_warn "Skipping Homebrew installation."
        fi
    else
        log_info "Homebrew is already installed."
    fi
}

# Install essential packages
install_packages() {
    log_info "Would you like to install recommended development packages? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        log_info "Installing packages..."
        brew update
        
        # Core utilities
        brew install coreutils
        brew install gnu-sed
        brew install grep
        brew install wget
        brew install curl
        
        # Development tools
        brew install git
        brew install vim
        brew install tmux
        brew install zsh
        
        # Programming languages and environments
        log_info "Would you like to install programming language environments? (y/n)"
        read -r lang_answer
        if [[ "$lang_answer" =~ ^[Yy]$ ]]; then
            # Python environment
            brew install pyenv
            
            # Node.js environment
            brew install node
            
            # Go environment
            brew install go
        fi
        
        log_info "Packages installed successfully!"
    else
        log_warn "Skipping package installation."
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

# Set macOS defaults
set_macos_defaults() {
    log_info "Would you like to set recommended macOS development settings? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        log_info "Setting macOS defaults..."
        
        # Show hidden files in Finder
        defaults write com.apple.finder AppleShowAllFiles -bool true
        
        # Show all filename extensions
        defaults write NSGlobalDomain AppleShowAllExtensions -bool true
        
        # Disable press-and-hold for keys in favor of key repeat
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
        
        # Set a faster keyboard repeat rate
        defaults write NSGlobalDomain KeyRepeat -int 2
        defaults write NSGlobalDomain InitialKeyRepeat -int 15
        
        # Show path bar in Finder
        defaults write com.apple.finder ShowPathbar -bool true
        
        # Restart affected applications
        for app in "Finder" "SystemUIServer"; do
            killall "${app}" &> /dev/null || true
        done
        
        log_info "macOS defaults set successfully!"
    else
        log_warn "Skipping macOS defaults."
    fi
}

# Main function
main() {
    log_info "Starting macOS-specific setup..."
    
    check_homebrew
    install_packages
    setup_oh_my_zsh
    set_macos_defaults
    
    log_info "macOS setup completed successfully!"
}

# Run main function
main
