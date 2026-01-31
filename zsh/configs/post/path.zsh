# ensure homebrew and dotfiles bin directory is loaded first
PATH="$HOME/.bin:/opt/homebrew/bin:/usr/local/sbin:$PATH"

# mkdir .git/safe in the root of repositories you trust
PATH=".git/safe/../../bin:$PATH"

export -U PATH
