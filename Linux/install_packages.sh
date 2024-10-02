#!/bin/bash

# Filename: install_packages.sh
# Description: Installs packages from a provided list based on the detected package manager.

# Check if a package list file is provided
if [ -z "$1" ]; then
    echo "Usage: sudo ./install_packages.sh <package_list_file>"
    exit 1
fi

package_list="$1"

# Verify the package list file exists
if [ ! -f "$package_list" ]; then
    echo "Package list file '$package_list' does not exist."
    exit 1
fi

echo "Detecting package manager..."

# Function to install packages using pacman (Arch Linux, Manjaro)
install_pacman() {
    echo "Using pacman to install packages..."
    while read -r pkg; do
        # Check if the package is already installed
        if pacman -Qi "$pkg" &> /dev/null; then
            echo "$pkg is already installed. Skipping."
            continue
        fi

        # Check if the package exists in the repositories
        if pacman -Si "$pkg" &> /dev/null; then
            echo "Installing $pkg..."
            sudo pacman -S --noconfirm "$pkg"
        else
            echo "$pkg is not available in the official repositories. Skipping."
        fi
    done < "$package_list"
}

# Function to install packages using apt (Debian, Ubuntu)
install_apt() {
    echo "Using apt to install packages..."
    sudo apt update
    while read -r pkg; do
        # Check if the package is already installed
        dpkg -s "$pkg" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "$pkg is already installed. Skipping."
            continue
        fi

        # Check if the package exists
        apt-cache show "$pkg" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "Installing $pkg..."
            sudo apt install -y "$pkg"
        else
            echo "$pkg is not available in the repositories. Skipping."
        fi
    done < "$package_list"
}

# Function to install packages using dnf (Fedora)
install_dnf() {
    echo "Using dnf to install packages..."
    sudo dnf check-update
    while read -r pkg; do
        # Check if the package is already installed
        dnf list installed "$pkg" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "$pkg is already installed. Skipping."
            continue
        fi

        # Check if the package exists
        dnf list available "$pkg" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "Installing $pkg..."
            sudo dnf install -y "$pkg"
        else
            echo "$pkg is not available in the repositories. Skipping."
        fi
    done < "$package_list"
}

# Function to install packages using zypper (openSUSE)
install_zypper() {
    echo "Using zypper to install packages..."
    sudo zypper refresh
    while read -r pkg; do
        # Check if the package is already installed
        zypper se -i "$pkg" | grep "$pkg" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "$pkg is already installed. Skipping."
            continue
        fi

        # Check if the package exists
        zypper se -s "$pkg" | grep "$pkg" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "Installing $pkg..."
            sudo zypper install -y "$pkg"
        else
            echo "$pkg is not available in the repositories. Skipping."
        fi
    done < "$package_list"
}

# Detect and install packages based on the package manager
if command -v pacman > /dev/null; then
    install_pacman
elif command -v apt > /dev/null; then
    install_apt
elif command -v dnf > /dev/null; then
    install_dnf
elif command -v zypper > /dev/null; then
    install_zypper
else
    echo "Unsupported package manager. Please add support for your package manager."
    exit 1
fi

echo "Package installation process completed."
