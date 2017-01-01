#!/bin/bash

# User specific environment and startup programs
export PATH=$PATH:$HOME/bin:$HOME/.rvm/bin

set -o ignoreeof
stty -ixon -ixoff

# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
