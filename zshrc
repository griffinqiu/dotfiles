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


# fzf colors: everforest dark medium (https://github.com/neanias/everforest-nvim)
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=bg+:#543a48 \
  --color=bg:#2d353b \
  --color=border:#3d484d \
  --color=fg:#d3c6aa \
  --color=gutter:#2d353b \
  --color=header:#e69875 \
  --color=hl+:#7fbbb3 \
  --color=hl:#7fbbb3 \
  --color=info:#859289 \
  --color=marker:#e67e80 \
  --color=pointer:#e67e80 \
  --color=prompt:#a7c080 \
  --color=query:#d3c6aa:regular \
  --color=scrollbar:#3d484d \
  --color=separator:#e69875 \
  --color=spinner:#e67e80 \
"

[[ -f ~/.zshrc.oh-my-zsh ]] && source ~/.zshrc.oh-my-zsh
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/Documents/Sync/zshrc.sync ]] && source ~/Documents/Sync/zshrc.sync
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

[[ -f ~/.local/bin/env ]] && source ~/.local/bin/env
export XDG_CONFIG_HOME="$HOME/.config"
