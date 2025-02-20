alias update-nvim=install-nvim
function install-nvim {
    TARGET="$HOME/Documents/sources/neovim"
    if [ "$(pwd)" == "$TARGET" ]; then
        rm -r build/
        make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.neovim -DCMAKE_BUILD_TYPE=Release"
        make install
        export PATH="$HOME/.neovim/bin:$PATH"
    else
        echo "Please run this function in $TARGET"
    fi
}

