# Cross-Platform Application Backup and Restoration Scripts

## Table of Contents

1. [Introduction](#1-introduction)
2. [Prerequisites](#2-prerequisites)
3. [Directory Structure](#3-directory-structure)
4. [Scripts Overview](#4-scripts-overview)
    - [1. Listing Installed Applications](#1-listing-installed-applications)
    - [2. Installing Applications from the List](#2-installing-applications-from-the-list)
5. [Platform-Specific Scripts](#5-platform-specific-scripts)
    - [A. Linux](#a-linux)
        - [A.1. List Installed Packages (`list_packages.sh`)](#a1-list-installed-packages-list_packagessh)
        - [A.2. Install Packages (`install_packages.sh`)](#a2-install-packages-install_packagessh)
    - [B. macOS](#b-macos)
        - [B.1. List Installed Applications (`list_packages_mac.sh`)](#b1-list-installed-applications-list_packages_macsh)
        - [B.2. Install Applications (`install_packages_mac.sh`)](#b2-install-applications-install_packages_macsh)
    - [C. Windows](#c-windows)
        - [C.1. List Installed Applications (`List-InstalledApps.ps1`)](#c1-list-installed-applications-list-installedappssp1)
        - [C.2. Install Applications (`Install-Apps.ps1`)](#c2-install-applications-install-appsps1)
6. [Usage Instructions](#6-usage-instructions)
    - [1. Linux](#1-linux)
    - [2. macOS](#2-macos)
    - [3. Windows](#3-windows)
7. [Customization and Best Practices](#7-customization-and-best-practices)
8. [Limitations and Considerations](#8-limitations-and-considerations)
9. [Conclusion](#9-conclusion)

---

## 1. Introduction

Managing and migrating installed applications across different operating systems can be cumbersome. This guide provides a set of scripts to **list** and **reinstall** your applications on **Linux**, **macOS**, and **Windows**. By following these instructions, you can ensure a smoother transition between systems or recover your setup after a fresh installation.

**_Important:_** *These scripts are templates. It's crucial to **review and customize** them to match your specific environment and requirements. Directly copying and executing them without adjustments may lead to unintended consequences.*

## 2. Prerequisites

Before proceeding, ensure you have the following:

### **For All Platforms:**

- **Basic Knowledge:** Familiarity with command-line interfaces (Terminal for macOS/Linux, PowerShell for Windows).
- **Backup Important Data:** Always back up critical data to prevent loss during system modifications.
- **Administrator/Superuser Access:** Necessary permissions to install or remove applications.

### **Platform-Specific Requirements:**

- **Linux:**
  - Supported distributions (e.g., Arch, Ubuntu, Fedora, openSUSE).
  - Familiarity with your distribution's package manager.

- **macOS:**
  - [Homebrew](https://brew.sh/) installed.
  
- **Windows:**
  - [PowerShell 5.0+](https://docs.microsoft.com/en-us/powershell/scripting/overview) or [PowerShell Core](https://github.com/PowerShell/PowerShell) installed.
  - [Chocolatey](https://chocolatey.org/install) or [Winget](https://github.com/microsoft/winget-cli) as a package manager (optional but recommended).

## 3. Directory Structure

Organize your scripts and package lists in a structured manner to enhance manageability.

```plaintext
app-backup-restore/
├── linux/
│   ├── list_packages.sh
│   └── install_packages.sh
├── macos/
│   ├── list_packages_mac.sh
│   └── install_packages_mac.sh
└── windows/
    ├── List-InstalledApps.ps1
    └── Install-Apps.ps1
```

*Create the directories as needed and place the respective scripts within them.*

## 4. Scripts Overview

### 1. Listing Installed Applications

Scripts under each platform's directory will generate a list of currently installed applications and save them to a text file.

### 2. Installing Applications from the List

These scripts will read the generated list, detect the platform and distribution/package manager, verify the availability of each application, and proceed to install them accordingly.

## 5. Platform-Specific Scripts

### A. Linux

#### A.1. List Installed Packages (`list_packages.sh`)

**Description:** Detects the package manager of your Linux distribution and exports a list of explicitly installed packages.

```bash
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
```

**Usage:**

1. **Navigate to Linux Scripts Directory:**

   ```bash
   cd ~/app-backup-restore/linux/
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x list_packages.sh
   ```

3. **Run the Script:**

   ```bash
   ./list_packages.sh
   ```

   - **Output:** A file named `installed_packages_YYYY-MM-DD_HH:MM:SS.txt` containing the list of installed packages.

#### A.2. Install Packages (`install_packages.sh`)

**Description:** Reads the generated package list, detects the current Linux distribution's package manager, checks package availability, and installs them.

```bash
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
```

**Usage:**

1. **Navigate to Linux Scripts Directory:**

   ```bash
   cd ~/app-backup-restore/linux/
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x install_packages.sh
   ```

3. **Run the Script with the Package List:**

   ```bash
   sudo ./install_packages.sh installed_packages_YYYY-MM-DD_HH:MM:SS.txt
   ```

   - **Ensure** you replace `installed_packages_YYYY-MM-DD_HH:MM:SS.txt` with the actual filename generated by the listing script.

---

### B. macOS

#### B.1. List Installed Applications (`list_packages_mac.sh`)

**Description:** Uses Homebrew to list installed formulae (CLI applications) and casks (GUI applications), exporting them to separate lists.

```bash
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
```

**Usage:**

1. **Navigate to macOS Scripts Directory:**

   ```bash
   cd ~/app-backup-restore/macos/
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x list_packages_mac.sh
   ```

3. **Run the Script:**

   ```bash
   ./list_packages_mac.sh
   ```

   - **Output:** Two files named `brew_formulae_YYYY-MM-DD_HH:MM:SS.txt` and `brew_casks_YYYY-MM-DD_HH:MM:SS.txt` containing the lists of installed CLI and GUI applications, respectively.

#### B.2. Install Applications (`install_packages_mac.sh`)

**Description:** Reads the generated Homebrew formulae and casks lists, checks for availability, and installs them.

```bash
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
```

**Usage:**

1. **Navigate to macOS Scripts Directory:**

   ```bash
   cd ~/app-backup-restore/macos/
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x install_packages_mac.sh
   ```

3. **Run the Script with Package Lists:**

   ```bash
   ./install_packages_mac.sh brew_formulae_YYYY-MM-DD_HH:MM:SS.txt brew_casks_YYYY-MM-DD_HH:MM:SS.txt
   ```

   - **Ensure** you replace the filenames with the actual package list files generated by the listing script.

---

### C. Windows

#### C.1. List Installed Applications (`List-InstalledApps.ps1`)

**Description:** Uses PowerShell to list installed applications via both the Windows registry and the `Get-Package` cmdlet, exporting them to a text file.

```powershell
<#
.SYNOPSIS
    Lists installed applications on Windows and exports them to a text file.

.DESCRIPTION
    This script retrieves a list of installed applications from both the registry and the package manager (if available).
    It combines these lists and removes duplicates.

.NOTES
    Author: Your Name
    Date: YYYY-MM-DD
#>

# Define output file
$output_file = "Installed_Apps_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"

# Get installed applications from registry (for traditional installers)
$registry_paths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$registry_apps = foreach ($path in $registry_paths) {
    Get-ItemProperty $path | Where-Object { $_.DisplayName } | Select-Object -ExpandProperty DisplayName
}

# Get installed packages via PackageManagement (if using Package Managers like Chocolatey or Winget)
$package_apps = @()
if (Get-Command Get-Package -ErrorAction SilentlyContinue) {
    $package_apps = Get-Package | Select-Object -ExpandProperty Name
}

# Combine and remove duplicates
$all_apps = $registry_apps + $package_apps | Sort-Object -Unique

# Export to file
$all_apps | Out-File -FilePath $output_file -Encoding UTF8

Write-Output "Installed applications have been listed in $output_file"
```

**Usage:**

1. **Save the Script:**

   - Open **Notepad** or any text editor.
   - Paste the above script into the editor.
   - Save the file as `List-InstalledApps.ps1` in `C:\app-backup-restore\windows\`.

2. **Run PowerShell as Administrator:**

   - Right-click the **Start** button.
   - Select **Windows PowerShell (Admin)** or **Windows Terminal (Admin)**.

3. **Set Execution Policy (If Not Already Set):**

   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

   - **_Note:_** *This allows running scripts created on your machine.*

4. **Navigate to Scripts Directory:**

   ```powershell
   cd C:\app-backup-restore\windows\
   ```

5. **Run the Script:**

   ```powershell
   .\List-InstalledApps.ps1
   ```

   - **Output:** A file named `Installed_Apps_YYYY-MM-DD_HH-MM-SS.txt` containing the list of installed applications.

#### C.2. Install Applications (`Install-Apps.ps1`)

**Description:** Reads the generated list of installed applications and installs them using package managers like **Chocolatey** or **Winget**, checking for availability before installation.

```powershell
<#
.SYNOPSIS
    Installs applications from a provided list using Chocolatey and Winget.

.DESCRIPTION
    This script reads a text file containing a list of applications and attempts to install them using 
    available package managers (Chocolatey and Winget). It checks for the availability of each application 
    before attempting installation.

    Ensure you have Chocolatey or Winget installed before running this script.

.NOTES
    Author: Your Name
    Date: YYYY-MM-DD
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$PackageListPath
)

# Check if the package list file exists
if (!(Test-Path -Path $PackageListPath)) {
    Write-Error "Package list file '$PackageListPath' does not exist."
    exit 1
}

# Function to install using Chocolatey
function Install-ChocolateyPackage($pkg) {
    if (choco search $pkg --exact --return-all | Select-String $pkg) {
        Write-Output "Installing $pkg via Chocolatey..."
        choco install $pkg -y
    } else {
        Write-Warning "$pkg not found in Chocolatey repositories."
    }
}

# Function to install using Winget
function Install-WingetPackage($pkg) {
    $search = winget search --id $pkg --exact
    if ($search) {
        Write-Output "Installing $pkg via Winget..."
        winget install --id $pkg -e --silent
    } else {
        Write-Warning "$pkg not found in Winget repositories."
    }
}

# Read the package list
$packages = Get-Content -Path $PackageListPath

foreach ($pkg in $packages) {
    # Attempt installation with Chocolatey
    Install-ChocolateyPackage $pkg

    # Attempt installation with Winget
    Install-WingetPackage $pkg
}

Write-Output "Application installation process completed."
```

**Usage:**

1. **Save the Script:**

   - Open **Notepad** or any text editor.
   - Paste the above script into the editor.
   - Save the file as `Install-Apps.ps1` in `C:\app-backup-restore\windows\`.

2. **Ensure Package Managers are Installed:**

   - **Chocolatey:**
     - Follow installation instructions from [Chocolatey Official Website](https://chocolatey.org/install).

   - **Winget:**
     - Winget comes pre-installed on recent Windows 10 and 11 versions. If not, update to the latest Windows features.

3. **Run PowerShell as Administrator:**

   - Right-click the **Start** button.
   - Select **Windows PowerShell (Admin)** or **Windows Terminal (Admin)**.

4. **Set Execution Policy (If Not Already Set):**

   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

5. **Navigate to Scripts Directory:**

   ```powershell
   cd C:\app-backup-restore\windows\
   ```

6. **Run the Script with Package List:**

   ```powershell
   .\Install-Apps.ps1 -PackageListPath "Installed_Apps_YYYY-MM-DD_HH-MM-SS.txt"
   ```

   - **Replace** `Installed_Apps_YYYY-MM-DD_HH-MM-SS.txt` with the actual filename generated by the listing script.

---

## 6. Usage Instructions

### 1. Linux

**Listing Installed Packages:**

```bash
cd ~/app-backup-restore/linux/
chmod +x list_packages.sh
./list_packages.sh
```

- **Output:** `installed_packages_YYYY-MM-DD_HH:MM:SS.txt`

**Installing Packages:**

```bash
sudo ./install_packages.sh installed_packages_YYYY-MM-DD_HH:MM:SS.txt
```

### 2. macOS

**Listing Installed Applications:**

```bash
cd ~/app-backup-restore/macos/
chmod +x list_packages_mac.sh
./list_packages_mac.sh
```

- **Output:** `brew_formulae_YYYY-MM-DD_HH:MM:SS.txt` and `brew_casks_YYYY-MM-DD_HH:MM:SS.txt`

**Installing Applications:**

```bash
chmod +x install_packages_mac.sh
./install_packages_mac.sh brew_formulae_YYYY-MM-DD_HH:MM:SS.txt brew_casks_YYYY-MM-DD_HH:MM:SS.txt
```

### 3. Windows

**Listing Installed Applications:**

1. **Run the Listing Script:**

   ```powershell
   cd C:\app-backup-restore\windows\
   .\List-InstalledApps.ps1
   ```

   - **Output:** `Installed_Apps_YYYY-MM-DD_HH-MM-SS.txt`

**Installing Applications:**

1. **Run the Installation Script:**

   ```powershell
   cd C:\app-backup-restore\windows\
   .\Install-Apps.ps1 -PackageListPath "Installed_Apps_YYYY-MM-DD_HH-MM-SS.txt"
   ```

---

## 7. Customization and Best Practices

- **Review Package Lists:** Before reinstalling, manually review the generated package lists to remove any unnecessary or unsupported applications.

- **Mapping Package Names:**
  - Application names might differ across package managers or platforms.
  - Create a mapping file to translate package names if needed.

- **Handling Special Cases:**
  - Some applications may require additional configuration or dependencies.
  - Consider adding conditional checks or manual installation steps for such cases.

- **Script Enhancements:**
  - Incorporate logging mechanisms to track installations.
  - Add error handling to manage failed installations gracefully.

- **Security Considerations:**
  - Ensure scripts are sourced from trusted locations to avoid potential security risks.
  - Use secure methods to transfer scripts and package lists between devices.

---

## 8. Limitations and Considerations

1. **Package Availability:**
   - Not all applications are available across all package managers or repositories.
   - Some applications may require manual installation or alternative methods like AppImages (Linux), DMGs (macOS), or executable installers (Windows).

2. **Cross-Platform Differences:**
   - Scripts are designed per platform; ensure you're running the correct script for your operating system.
   - Avoid running scripts meant for one platform on another to prevent system issues.

3. **Application Versions:**
   - Installed versions may differ based on repository updates or package manager capabilities.
   - Consider pinning versions if consistency is critical.

4. **Administrator/Superuser Rights:**
   - Installation scripts generally require elevated permissions. Ensure you understand the implications of granting such permissions.

5. **System Configurations:**
   - Some applications may rely on specific system configurations or dependencies not handled by the scripts.
   - Additional manual setup might be necessary post-installation.

6. **User Data and Configurations:**
   - These scripts handle applications only. User-specific data, configurations, and dotfiles need separate backup and restoration methods.

---

## 9. Conclusion

Automating the backup and restoration of installed applications across multiple operating systems can significantly streamline your system setup and recovery processes. By utilizing the provided scripts, you can efficiently:

- **Export** a list of installed applications from one system.
- **Import** and **install** those applications on another system, regardless of the underlying operating system.

However, due to inherent differences in package managers, application naming conventions, and system architectures, **customization** and **manual reviews** are essential to ensure a smooth and error-free installation process. Always approach automation with caution and verify each step to maintain system integrity and security.

**_Happy Computing!_**

---

## 10. License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---

# License

```plaintext
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
...
```

*Replace the above text with the actual MIT License text or any other license you prefer.*

---

# Acknowledgements

- **Homebrew:** For providing a robust package manager for macOS.
- **Chocolatey & Winget:** For simplifying application installations on Windows.
- **Arch Linux, Ubuntu, Fedora, openSUSE:** For their comprehensive package management systems.
- **PowerShell:** For enabling cross-platform scripting on Windows.

---

# Contribution

Contributions are welcome! Please fork the repository and submit a pull request with your enhancements or fixes.

---

# Questions

For any questions or support, please open an issue in the repository or contact [your-email@example.com](mailto:your-email@example.com).

---

# Final Notes

- **Backup Regularly:** Always keep your application lists and important data backed up.
- **Stay Updated:** Package managers and repositories frequently update. Regularly update your package lists and scripts as needed.
- **Community Resources:** Leverage forums, documentation, and community support for troubleshooting and advanced configurations.

---

**_Remember:_** *Automation scripts are powerful tools. Use them responsibly and ensure you understand each step to avoid unintended system modifications.*

---
