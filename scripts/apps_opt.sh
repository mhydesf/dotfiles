#! /bin/bash

# Applications Only I Would Want
sudo apt install               \
    neofetch                   \
    kitty                      \
    tree                       \
    nala                       \
    exuberant-ctags            \
    gnome-tweaks               \
    playerctl                  \
    luarocks                   \
    fd-find -y                 \
    python3.10-venv

sudo npm install -g tree-sitter-cli

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

