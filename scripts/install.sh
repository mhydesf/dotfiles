#! /bin/bash

echo "Install applications"
./apps.sh
echo "Configuring filesystem"
./fs.sh
echo "Removing snapd"
./rm_snap.sh

echo "Would you like to install Additional Apps? [y/N]"
read apps

if [ "$apps" == "y" ]; then
    echo "Install additional applications"
    ./apps_opt.sh
else
    echo "Ignoring optional apps installation"
fi

echo "Would you like to install the source repositories? [y/N]"
read source

if [ "$source" == "y" ]; then
    ./sources.sh
else
    echo "Ignoring source repositories"
fi

echo "Would you like to install FiraMono Font? [y/N]"
read font

if [ "$font" == "y" ]; then
    echo "Installing FiraMono Nerd Font"
    ./fonts.sh
else
    echo "Ignoring FiraMono installation"
fi
