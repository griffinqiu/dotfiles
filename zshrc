# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="robbyrussell"
# ZSH_THEME="agnoster"

DISABLE_AUTO_TITLE=true
plugins=(osx tmuxinator)

source $ZSH/oh-my-zsh.sh
[[ -f ~/.exports ]] && source ~/.exports
[[ -f ~/.aliases ]] && source ~/.aliases

stty -ixon -ixoff

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

eval "$(rbenv init - --no-rehash)"
eval "$(pyenv init -)"
