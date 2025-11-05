SHELL := /bin/bash
.PHONY: help deps pyenv-install python-install poetry-install configure-poetry setup

HELP_TEXT := "Available targets:\n  make deps                 # Install Homebrew deps (xz openssl readline pyenv)\n  make pyenv-install        # Ensure pyenv is installed (via brew)\n  make python-install       # Install Python from .python-version via pyenv\n  make poetry-install       # Install Poetry using pyenv Python\n  make configure-poetry     # Configure Poetry to prefer the active Python\n  make setup                # Run deps + pyenv + python + poetry + configure\n"

help:
	@printf $(HELP_TEXT)

# Use Homebrew if available; prefer the explicit /opt/homebrew/bin/brew on Apple Silicon
BrewCmd := $(shell command -v brew 2>/dev/null || echo /opt/homebrew/bin/brew)

deps:
	@echo "Using brew: $(BrewCmd)"
	@$(BrewCmd) install xz openssl readline pyenv gh || true

pyenv-install: deps
	@if ! command -v pyenv >/dev/null 2>&1; then \
		echo "Installing pyenv via brew..."; \
		$(BrewCmd) install pyenv; \
	else \
		echo "pyenv already installed"; \
	fi

python-install:
	@PY_VERSION=$$(cat .python-version 2>/dev/null || echo 3.11.6); \
	echo "Requested Python: $$PY_VERSION"; \
	XZ_PREFIX=$$($(BrewCmd) --prefix xz); OPENSSL_PREFIX=$$($(BrewCmd) --prefix openssl 2>/dev/null || true); \
	export LDFLAGS="-L$${XZ_PREFIX}/lib $${OPENSSL_PREFIX:+-L$${OPENSSL_PREFIX}/lib}"; \
	export CPPFLAGS="-I$${XZ_PREFIX}/include $${OPENSSL_PREFIX:+-I$${OPENSSL_PREFIX}/include}"; \
	export PKG_CONFIG_PATH="$${XZ_PREFIX}/lib/pkgconfig:$${OPENSSL_PREFIX:+$${OPENSSL_PREFIX}/lib/pkgconfig}:$$PKG_CONFIG_PATH"; \
	if ! pyenv versions --bare | grep -qx "$$PY_VERSION"; then \
		echo "Installing python $$PY_VERSION via pyenv..."; \
		env LDFLAGS="$$LDFLAGS" CPPFLAGS="$$CPPFLAGS" PKG_CONFIG_PATH="$$PKG_CONFIG_PATH" pyenv install "$$PY_VERSION"; \
	else \
		echo "pyenv python $$PY_VERSION already installed"; \
	fi

poetry-install:
	@PY_VERSION=$$(cat .python-version 2>/dev/null || echo 3.11.6); \
	PY_BIN="$${HOME}/.pyenv/versions/$$PY_VERSION/bin/python3"; \
	if [ ! -x "$$PY_BIN" ]; then \
		echo "Python $$PY_VERSION not found at $$PY_BIN; run 'make python-install' first."; exit 1; \
	fi; \
	if ! command -v poetry >/dev/null 2>&1; then \
		echo "Installing Poetry using $$PY_BIN"; \
		curl -sSL https://install.python-poetry.org | "$$PY_BIN" -; \
	else \
		echo "Poetry already installed"; \
	fi

configure-poetry:
	@export PATH="${HOME}/.local/bin:$$PATH"; \
	if command -v poetry >/dev/null 2>&1; then \
		echo "Configuring Poetry to use project Python"; \
		poetry config virtualenvs.use-poetry-python true || true; \
		poetry config virtualenvs.create true || true; \
	else \
		echo "poetry not found; run 'make poetry-install'"; \
	fi

setup: pyenv-install python-install poetry-install configure-poetry
	@echo "Setup complete. Open a new shell or source your shell profile to pick up pyenv/poetry." 
install: dotfiles zsh vim iterm-apply

dotfiles:
	@echo "Installing non-vim dotfiles..."
	@for full_file_path in $(shell find `pwd` -name ".*" -not -name ".git" -not -name ".vimrc"); do \
		ff=$$(basename $$full_file_path); \
		ln -sf $$full_file_path $(HOME)/$$ff; \
	done

zsh:
	@echo "Installing zsh configuration files..."
	@ln -sf $(shell pwd)/scripts/zsh/zshrc $(HOME)/.zshrc
	@ln -sf $(shell pwd)/scripts/zsh/zshenv $(HOME)/.zshenv
	@echo "Zsh configs installed. Restart your shell or run: source ~/.zshrc"

vim:
	@echo "Installing vim dotfiles..."
	@rm -rf ~/.vim/bundle/Vundle.vim
	@git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	@echo "so ~/.vim/.vimrc" > $(HOME)/.vimrc
	@mkdir -p $(HOME)/.vim/
	@ln -sf $(shell find `pwd` -name ".vimrc") $(HOME)/.vim/.vimrc
	@vim +PluginInstall +qall


ITERM_CONFIG=com.googlecode.iterm2.plist
ITERM_CONFIG_PATH=/Users/$(USER)/Library/Preferences/$(ITERM_CONFIG)

iterm-apply:
	@cp ./iterm2/$(ITERM_CONFIG) ./iterm2/$(ITERM_CONFIG).binary
	@plutil -convert binary1 ./iterm2/$(ITERM_CONFIG).binary
	@cp ./iterm2/$(ITERM_CONFIG).binary $(ITERM_CONFIG_PATH)
	@defaults read $(ITERM_CONFIG_PATH)
	@rm -f ./iterm2/$(ITERM_CONFIG).binary

iterm-capture:
	@cp -f $(ITERM_CONFIG_PATH) ./iterm2/.
	@plutil -convert xml1 ./iterm2/$(ITERM_CONFIG)


.PHONY: install dotfiles zsh vim iterm-apply iterm-capture
