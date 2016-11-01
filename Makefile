install: dotfiles vim iterm-apply

dotfiles: 
	@echo "Installing non-vim dotfiles..."
	@for full_file_path in $(shell find `pwd` -name ".*" -not -name ".git" -not -name ".vimrc"); do \
		ff=$$(basename $$full_file_path); \
		ln -sf $$full_file_path $(HOME)/$$ff; \
	done

vim:
	@echo "Installing vim dotfiles..."
	@id=$$(id -u); if [ $$id -eq 0 ]; then pip install flake8; else sudo pip install flake8; fi
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


.PHONY: install dotfiles vim iterm-apply iterm-capture
