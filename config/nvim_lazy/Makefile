build:
	rm -rf ~/.config/nvim_lazy
	rm -rf ~/.local/share/nvim_lazy
	rm -rf ~/.local/state/nvim_lazy
	rm -rf ~/.cache/nvim_lazy
	ln -s $(CURDIR) ~/.config/nvim_lazy

clean:
	rm -rf ~/.config/nvim_lazy
	rm -rf ~/.local/share/nvim_lazy
	rm -rf ~/.local/state/nvim_lazy
	rm -rf ~/.cache/nvim_lazy

try:
	docker build -t my-alpine-nvim .
	docker run -w /root/.config -it --rm \
    -v ~/github/LazyVim:/root/.config/nvim \
    my-alpine-nvim ash
