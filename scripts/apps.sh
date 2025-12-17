#! /bin/bash

yes | sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update

# Software Essentials
sudo apt install                \
    cmake                       \
    make                        \
    build-essential             \
    software-properties-common  \
    python3-dev                 \
    libstdc++-13-dev            \
    pkg-config                  \
    gcc-13                      \
    g++-13 -y

# Applications Only I Would Want
sudo apt install                \
    curl                        \
    htop                        \
    xsel                        \
    keychain                    \
    git                         \
    vim                         \
    ripgrep                     \
    fzf                         \
    polybar                     \
    feh                         \
    rofi                        \
    blueman                     \
    gettext -y

# Normal Person Applications
sudo apt install                \
    npm -y

# Update to latest NPM
sudo npm install -g n
sudo n stable

