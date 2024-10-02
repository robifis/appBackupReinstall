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
