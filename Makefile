install: 
	@echo "Installing non-vim dotfiles..."
	@for full_file_path in $(shell find `pwd` -name ".*" -not -name ".git" -not -name ".vimrc"); do \
		ff=$$(basename $$full_file_path); \
		ln -sf $$full_file_path $(HOME)/$$ff; \
	done

	@echo "Installing vim dotfiles..."
	@rm -rf ~/.vim/bundle/Vundle.vim
	@git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	@echo "so ~/.vim/.vimrc" > $(HOME)/.vimrc
	@mkdir -p $(HOME)/.vim/
	@ln -sf $(shell find `pwd` -name ".vimrc") $(HOME)/.vim/.vimrc
	@vim +PluginInstall +qall

.PHONY: install
