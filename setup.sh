#!/bin/bash

set +e

echo "      _       _         __ _ _"
echo "   __| | ___ | |_      / _(_) | ___  ___"
echo "  / _\` |/ _ \| __|____| |_| | |/ _ \/ __|"
echo " | (_| | (_) | ||_____|  _| | |  __/\__ \\"
echo "  \__,_|\___/ \__|    |_| |_|_|\___||___/"
echo ""

echo "Pulling latest dot-files"
git pull

echo "Updating latest dot-files"
git submodule init
git submodule update

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Setup git dot-files..."
rm -f ~/.gitconfig && ln -s $DIR/.gitconfig ~/.gitconfig
rm -f ~/.gitignore_global && ln -s $DIR/.gitignore_global ~/.gitignore

echo "Setup tmux dot-file.."
rm -f ~/.tmux.conf && ln -s $DIR/.tmux.conf ~/.tmux.conf
rm -f ~/.tmux-osx.conf && ln -s $DIR/.tmux-osx.conf ~/.tmux-osx.conf

echo "Setup bash_profile dot-file..."
rm -f ~/.bash_profile && ln -s $DIR/.bash_profile ~/.bash_profile

echo "Setup zsh dot-file..."
rm -f ~/.zshrc && ln -s $DIR/.zshrc ~/.zshrc

echo "Setup ctags dot-file..."
rm -f ~/.ctags && ln -s $DIR/.ctags ~/.ctags

echo "Setup vim dot-file..."
mkdir -p ~/tmp/undofiles
mkdir -p ~/tmp/backups

rm -rf ~/.vim && ln -fs $DIR/.vim ~/.vim
rm -f ~/.vimrc && ln -s $DIR/.vimrc ~/.vimrc
rm -f ~/.gvimrc && ln -s $DIR/.gvimrc ~/.gvimrc

echo "Updating latest vim plugins"
vim +PluginInstall +qall

echo "Done"
