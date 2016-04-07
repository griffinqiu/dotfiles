#!/bin/bash

set -e

echo "      _       _         __ _ _"
echo "   __| | ___ | |_      / _(_) | ___  ___"
echo "  / _\` |/ _ \| __|____| |_| | |/ _ \/ __|"
echo " | (_| | (_) | ||_____|  _| | |  __/\__ \\"
echo "  \__,_|\___/ \__|    |_| |_|_|\___||___/"
echo ""

echo "Pulling latest dot-files"
git pull  &> /dev/null

echo "Updating latest dot-files"
git submodule init  &> /dev/null
git submodule update  &> /dev/null

echo "Setup git dot-files..."
rm -f ~/.gitconfig && ln -s .gitconfig ~/
rm -f ~/.gitignore && ln -s .gitignore ~/

echo "Setup tmux dot-files..."
rm -f ~/.tmux.conf && ln -s .tmux.conf ~/

echo "Setup vim dot-files..."
rm -f ~/.vimrc && ln -s .vimrc ~/
rm -f ~/.gvimrc && ln -s .gvimrc ~/

echo "Updating latest vim plugins"
vim +PluginInstall +qall

echo "Done"
