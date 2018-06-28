#!/bin/bash
[[ -f ~/.exports ]] && source ~/.exports
[[ -f ~/.aliases ]] && source ~/.aliases

set -o ignoreeof
stty -ixon -ixoff

[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

eval "$(rbenv init - --no-rehash)"
eval "$(pyenv init -)"
