#!/bin/bash

# Filename: install_packages_mac.sh
# Description: Installs Homebrew formulae and casks from provided lists.

# Check if package list files are provided
if [ $# -ne 2 ]; then
    echo "Usage: ./install_packages_mac.sh <brew_formulae_file> <brew_casks_file>"
    exit 1
fi

formulae_file="$1"
casks_file="$2"

# Verify the package list files exist
if [ ! -f "$formulae_file" ] || [ ! -f "$casks_file" ]; then
    echo "One or both package list files do not exist."
    exit 1
fi

echo "Starting installation of Homebrew formulae..."
while read -r pkg; do
    if brew list --formula | grep -qw "$pkg"; then
        echo "$pkg is already installed. Skipping."
    else
        if brew info --formula "$pkg" > /dev/null 2>&1; then
            echo "Installing $pkg..."
            brew install "$pkg"
        else
            echo "$pkg is not available in Homebrew repositories. Skipping."
        fi
    fi
done < "$formulae_file"

echo "Starting installation of Homebrew casks..."
while read -r cask; do
    if brew list --cask | grep -qw "$cask"; then
        echo "$cask is already installed. Skipping."
    else
        if brew info --cask "$cask" > /dev/null 2>&1; then
            echo "Installing $cask..."
            brew install --cask "$cask"
        else
            echo "$cask is not available in Homebrew repositories. Skipping."
        fi
    fi
done < "$casks_file"

echo "Application installation process completed."
