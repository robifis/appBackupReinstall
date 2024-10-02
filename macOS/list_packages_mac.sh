#!/bin/bash

# Filename: list_packages_mac.sh
# Description: Lists installed Homebrew formulae and casks.

# Output files with timestamp
brew_formulae="brew_formulae_$(date +%F_%T).txt"
brew_casks="brew_casks_$(date +%F_%T).txt"

echo "Listing installed Homebrew formulae..."
brew list --formula > "$brew_formulae"

echo "Listing installed Homebrew casks..."
brew list --cask > "$brew_casks"

echo "Package lists saved to $brew_formulae and $brew_casks"
