#!/bin/bash

# refer  spf13-vim bootstrap.sh`
BASEDIR=$(dirname $0)
cd $BASEDIR
VIM_DIR=$HOME/.vim

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
}

echo "Step1: backing up current vim config"
today=`date +%Y%m%d`
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimrc.bundles; do [ -e $i ] && [ ! -L $i ] && mv $i $i.$today; done
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimrc.bundles; do [ -L $i ] && unlink $i ; done


echo "Step2: setting up symlinks"
git clone https://github.com/lkpjj/vim-configs $VIM_DIR
lnif $VIM_DIR/vimrc $HOME/.vimrc
lnif $VIM_DIR/vimrc.bundles $HOME/.vimrc.bundles

echo "Step3: install vundle"
if [ ! -e $VIM_DIR/bundle/vundle ]; then
    echo "Installing Vundle"
    git clone https://github.com/gmarik/vundle.git $VIM_DIR/bundle/vundle
else
    echo "Upgrade Vundle"
    cd "$HOME/.vim/bundle/vundle" && git pull origin master
fi

echo "Step4: update/install plugins using Vundle"
system_shell=$SHELL
export SHELL="/bin/sh"
vim -u $HOME/.vimrc.bundles +BundleInstall! +BundleClean +qall
export SHELL=$system_shell

echo "Step5: compile YouCompleteMe"
echo "It will take a long time, just be patient!"
echo "If error,you need to compile it yourself"
echo "cd $VIM_DIR/bundle/YouCompleteMe/ && bash -x install.sh --clang-completer"
cd $VIM_DIR/bundle/YouCompleteMe/

if [ `which clang` ]   # check system clang
then
    bash -x install.sh --clang-completer --system-libclang   # use system clang
else
    bash -x install.sh --clang-completer
fi


#vim bk and undo dir
if [ ! -d /tmp/vimbk ]
then
    mkdir -p /tmp/vimbk
fi

if [ ! -d /tmp/vimundo ]
then
    mkdir -p /tmp/vimundo
fi

echo "Install Done!"