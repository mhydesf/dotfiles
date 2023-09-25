#! /bin/bash

yes | sudo add-apt-repository ppa:ubuntu-toolchain-r/test

# Software Essentials
sudo apt install               \
    cmake                      \
    make                       \
    build-essential            \
    software-properties-common \
    libstdc++-13-dev           \
    gcc-13                     \
    g++-13

# Applications Only I Would Want
sudo apt install               \
    kitty                      \
    neofetch                   \
    tree                       \
    htop                       \
    git                        \
    vim                        \
    ripgrep                    \
    gettext                    \
    exuberant-ctags            \
    luarocks                   \
    fd-find

# Normal Person Applications
sudo apt install               \
    spotify-client             \
    code                       \
    npm

sudo npm install -g tree-sitter-cli

