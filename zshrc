# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# extra files in ~/.zsh/configs/pre , ~/.zsh/configs , and ~/.zsh/configs/post
# these are loaded first, second, and third, respectively.
_load_settings() {
  _dir="$1"
  if [ -d "$_dir" ]; then
    if [ -d "$_dir/pre" ]; then
      for config in "$_dir"/pre/**/*~*.zwc(N-.); do
        . $config
      done
    fi

    for config in "$_dir"/**/*(N-.); do
      case "$config" in
        "$_dir"/(pre|post)/*|*.zwc)
          :
          ;;
        *)
          . $config
          ;;
      esac
    done

    if [ -d "$_dir/post" ]; then
      for config in "$_dir"/post/**/*~*.zwc(N-.); do
        . $config
      done
    fi
  fi
}
_load_settings "$HOME/.zsh/configs"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"


# fzf colors: kanagawa dragon (https://github.com/rebelot/kanagawa.nvim)
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=bg+:#2d4f67 \
  --color=bg:#181616 \
  --color=border:#393836 \
  --color=fg:#c5c9c5 \
  --color=gutter:#181616 \
  --color=header:#b6927b \
  --color=hl+:#8ba4b0 \
  --color=hl:#8ba4b0 \
  --color=info:#a6a69c \
  --color=marker:#e46876 \
  --color=pointer:#e46876 \
  --color=prompt:#8a9a7b \
  --color=query:#c5c9c5:regular \
  --color=scrollbar:#393836 \
  --color=separator:#b6927b \
  --color=spinner:#e46876 \
"

[[ -f ~/.zshrc.oh-my-zsh ]] && source ~/.zshrc.oh-my-zsh
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/Documents/Sync/zshrc.sync ]] && source ~/Documents/Sync/zshrc.sync
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

[[ -f ~/.local/bin/env ]] && source ~/.local/bin/env
export XDG_CONFIG_HOME="$HOME/.config"
