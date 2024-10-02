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
