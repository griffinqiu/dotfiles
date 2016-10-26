#!/bin/bash

set +e

echo "      _       _         __ _ _"
echo "   __| | ___ | |_      / _(_) | ___  ___"
echo "  / _\` |/ _ \| __|____| |_| | |/ _ \/ __|"
echo " | (_| | (_) | ||_____|  _| | |  __/\__ \\"
echo "  \__,_|\___/ \__|    |_| |_|_|\___||___/"
echo ""

if which apt-get >/dev/null; then
	sudo apt-get install -y vim vim-gnome ctags xclip astyle git
elif which yum >/dev/null; then
	sudo yum install -y gcc vim git ctags xclip astyle
fi

if which brew >/dev/null;then
    echo "You are using HomeBrew tool"
    brew install vim ctags git astyle reattach-to-user-namespace
fi

echo "Pulling latest dot-files"
git pull

echo "Updating latest dot-files"
git submodule init
git submodule update

BACKUP_DIR="$HOME/dot-files-backups/`date +%Y%m%d%H%M%S`/"
echo "Backup dot-files to $BACKUP_DIR"
mkdir -p $BACKUP_DIR
mv -f $HOME/.gitconfig $BACKUP_DIR
mv -f $HOME/.gitignore $BACKUP_DIR
mv -f $HOME/.tmux.conf $BACKUP_DIR
mv -f $HOME/.tmux-osx.conf $BACKUP_DIR
mv -f $HOME/.bash_profile $BACKUP_DIR
mv -f $HOME/.zshrc $BACKUP_DIR 
mv -f $HOME/.ctags $BACKUP_DIR
mv -f $HOME/.vim $BACKUP_DIR
mv -f $HOME/.vimrc $BACKUP_DIR
mv -f $HOME/.gvimrc $BACKUP_DIR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Setup git dot-files..."
ln -s $DIR/.gitconfig $HOME/.gitconfig
ln -s $DIR/.gitignore_global $HOME/.gitignore

echo "Setup tmux dot-file.."
ln -s $DIR/.tmux.conf $HOME/.tmux.conf
ln -s $DIR/.tmux-osx.conf $HOME/.tmux-osx.conf

echo "Setup bash_profile dot-file..."
ln -s $DIR/.bash_profile $HOME/.bash_profile

echo "Setup zsh dot-file..."
ln -s $DIR/.zshrc $HOME/.zshrc

echo "Setup ctags dot-file..."
ln -s $DIR/.ctags $HOME/.ctags

echo "Setup vim dot-file..."
mkdir -p $HOME/tmp/undofiles
mkdir -p $HOME/tmp/backups

ln -fs $DIR/.vim $HOME/.vim
ln -s $DIR/.vimrc $HOME/.vimrc
ln -s $DIR/.gvimrc $HOME/.gvimrc

echo "Updating latest vim plugins"
vim +PluginInstall +qall

echo "Done"
