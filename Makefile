all: install

install: 
	@echo "Installing non-vim dotfiles..."
	@for full_file_path in $(shell find `pwd` -name ".*" -not -name ".git" -not -name ".vimrc"); do \
		ff=$$(basename $$full_file_path); \
		ln -sf $$full_file_path $(HOME)/$$ff; \
	done

	@echo "Installing vim dotfiles..."
	@echo "so ~/.vim/.vimrc" > $(HOME)/.vimrc
	@mkdir -p $(HOME)/.vim/
	@ln -sf $(shell find `pwd` -name ".vimrc") $(HOME)/.vim/.vimrc

.PHONY: install
