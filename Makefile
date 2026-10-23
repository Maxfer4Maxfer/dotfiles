SHELL_SCRIPTS := install.sh scripts/*.sh test/*.sh common/tmux/.config/tmux/nvim-autokill common/tmux/.config/tmux/ru-keys common/tmux/.config/tmux/window-menu common/tmux/.config/tmux/battery common/tmux/.config/tmux/keyboard-layout common/tmux/.config/claude-tmux/*.sh

.PHONY: install link test smoke lint

install: ## full install / update of this machine
	./install.sh

link: ## only (re)create symlinks
	./install.sh link

smoke: ## check this machine
	./test/smoke.sh

test: ## install from scratch into a clean Ubuntu container
	docker build -q -t dotfiles-test test
	docker run --rm -v $(CURDIR):/src:ro dotfiles-test

lint:
	shellcheck -x $(SHELL_SCRIPTS)
