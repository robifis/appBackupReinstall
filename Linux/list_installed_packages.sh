#!/bin/bash

# Filename: list_packages.sh
# Description: Lists explicitly installed packages based on the detected package manager.

# Output file with timestamp
output_file="installed_packages_$(date +%F_%T).txt"

echo "Detecting package manager..."

# Function to list packages using pacman (Arch Linux, Manjaro)
list_pacman() {
    echo "Listing packages using pacman..."
    pacman -Qqe > "$output_file"
}

# Function to list packages using apt (Debian, Ubuntu)
list_apt() {
    echo "Listing packages using apt..."
    comm -23 <(apt-mark showmanual | sort) <(apt-mark showauto | sort) > "$output_file"
}

# Function to list packages using dnf (Fedora)
list_dnf() {
    echo "Listing packages using dnf..."
    dnf repoquery --qf '%{name}' --userinstalled > "$output_file"
}

# Function to list packages using zypper (openSUSE)
list_zypper() {
    echo "Listing packages using zypper..."
    zypper search --installed-only --type package | awk 'NR>2 {print $2}' > "$output_file"
}

# Detect and list packages based on the package manager
if command -v pacman > /dev/null; then
    list_pacman
elif command -v apt > /dev/null; then
    list_apt
elif command -v dnf > /dev/null; then
    list_dnf
elif command -v zypper > /dev/null; then
    list_zypper
else
    echo "Unsupported package manager. Please add support for your package manager."
    exit 1
fi

echo "Package list saved to $output_file"
