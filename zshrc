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
export NVIM_APPNAME=nvim_lazy
eval "$(gh copilot alias -- zsh)"

[[ -f ~/.zshrc.oh-my-zsh ]] && source ~/.zshrc.oh-my-zsh
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/Documents/Sync/zshrc.sync ]] && source ~/Documents/Sync/zshrc.sync
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

[[ -f ~/.local/bin/env ]] && source ~/.local/bin/env

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# Created by `pipx` on 2025-03-14 06:26:33
export PATH="$PATH:/Users/griffin/.local/bin"
