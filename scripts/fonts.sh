#! /bin/bash

# Create fonts directory

DIR=$HOME/.local/share/fonts
if [ -d "$DIR"]; then
    echo "Directory exists. Continuing..."
else
    mkdir "$DIR"
fi

# Download Extract
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraMono.zip
unzip FiraMono.zip

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip
untip Meslo.zip

# Copy all font files to created DIR
cp *.otf $DIR
cp *.ttf $DIR

# Load fonts
fc-cache -fv

# Clean Downlaods
sudo rm -rf *
