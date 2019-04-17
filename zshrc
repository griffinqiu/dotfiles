# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
# export POSTGRES_DB_USERNAME=goku_development

ZSH_THEME="robbyrussell"
# ZSH_THEME="agnoster"

DISABLE_AUTO_TITLE=true
plugins=(osx tmuxinator docker docker-compose docker-machine)

source $ZSH/oh-my-zsh.sh
[[ -f ~/.exports ]] && source ~/.exports
[[ -f ~/.aliases ]] && source ~/.aliases

stty -ixon -ixoff

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/Documents/Sync/zshrc.sync ]] && source ~/Documents/Sync/zshrc.sync
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

eval "$(rbenv init - --no-rehash)"
# eval "$(pyenv init -)"

# export PATH="$HOME/.bin:$PATH"
export GOPATH=$HOME/Documents/Sync/go
export PATH="/usr/local/sbin:$HOME/Documents/Sync/go/bin:$PATH"
