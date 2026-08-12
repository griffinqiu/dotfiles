# Load order matters and is explicit here: PATH first, then anything resolved
# through it, then Oh My Zsh, then what has to override Oh My Zsh.

PATH="/usr/local/sbin:$PATH"
PATH="$HOME/.bun/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="/opt/homebrew/bin:$PATH"
PATH="$HOME/.bin:$PATH"
PATH=".git/safe/../../bin:$PATH"
export -U PATH

# Runs after PATH so Homebrew's mise wins without hardcoding its location.
# Exact versions and resolved assets live in ~/.config/mise/config.toml.
export MISE_RUBY_COMPILE=false
export MISE_PYTHON_GITHUB_ATTESTATIONS=false
command -v mise >/dev/null && eval "$(mise activate zsh)"

# Must precede Oh My Zsh, which is what actually runs compinit. The Homebrew
# prefix differs between Apple silicon and Intel.
brew_site_functions=/opt/homebrew/share/zsh/site-functions
[[ -d $brew_site_functions ]] || brew_site_functions=/usr/local/share/zsh/site-functions
fpath=($brew_site_functions $fpath)
unset brew_site_functions

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export XDG_CONFIG_HOME="$HOME/.config"
export CLICOLOR=1
export VISUAL=nvim
export EDITOR=$VISUAL
export ERL_AFLAGS="-kernel shell_history enabled"

# Stays on this machine: shell history routinely captures tokens and paths that
# should not reach a synced folder. Oh My Zsh only fills HISTFILE when unset,
# and raises HISTSIZE to its own floor of 50000.
setopt hist_ignore_all_dups inc_append_history
HISTFILE=$HOME/.zsh_history
SAVEHIST=40960

# Oh My Zsh already sets auto_cd, auto_pushd, and pushdminus.
setopt pushdsilent pushdtohome cdablevars
setopt extendedglob
unsetopt nomatch
DIRSTACKSIZE=5

# fzf colors: everforest dark medium (https://github.com/neanias/everforest-nvim)
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=bg+:#686e72 \
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

# After Oh My Zsh, which selects the emacs keymap with its own `bindkey -e`.
# `stty -ixon` frees ^Q at the terminal layer, which zsh options cannot do.
stty -ixon
bindkey "^V" vi-cmd-mode

[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.local/bin/env ]] && source ~/.local/bin/env
[[ -f ~/.openclaw/completions/openclaw.zsh ]] && source ~/.openclaw/completions/openclaw.zsh

ocagent() {
  openclaw tui --session "agent:$1:main"
}

[[ -f ~/Documents/Sync/zshrc.sync ]] && source ~/Documents/Sync/zshrc.sync
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
