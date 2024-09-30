<#
.SYNOPSIS
Installs all .msu (Windows Update) files from the current directory using wusa.exe and logs the installation process.

.DESCRIPTION
This script automates the process of finding and installing all .msu files in the current directory. It utilizes the `wusa.exe` utility for silent installation of Windows updates and logs each step of the installation process, including success or failure, to a log file. The log file is created in the current directory with a timestamped filename.

.PARAMETER MSUFiles
An array of file paths for .msu files to be installed. The function will verify if each file exists before attempting installation.

.NOTES
The script creates a log file in the current directory with a timestamp suffix. Each installation step is recorded in this log file, including errors.

.EXAMPLE
# Automatically install all .msu files in the current directory
$msuFiles = Get-ChildItem -Path (Get-Location) -Filter *.msu | Select-Object -ExpandProperty FullName
Install-MSUFiles -MSUFiles $msuFiles

This example finds all .msu files in the current directory and installs them silently. Logs are saved to a file in the current directory.

.EXAMPLE
# Specify MSU files manually
Install-MSUFiles -MSUFiles "C:\Updates\update1.msu", "C:\Updates\update2.msu"

This example installs specific .msu files located in the 'C:\Updates' directory and logs the process.
#>

function Install-MSUFiles {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$MSUFiles
    )

    process {
        foreach ($file in $MSUFiles) {
            if (Test-Path $file) {
                Write-Host "Installing $file..."
                Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Installing $file..."

                try {
                    Start-Process -FilePath "wusa.exe" -ArgumentList "`"$file`" /quiet /norestart" -NoNewWindow -Wait
                    Write-Host "Successfully installed $file."
                    Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Successfully installed $file."
                }
                catch {
                    Write-Host "Failed to install $file. Error: $_"
                    Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Failed to install $file. Error: $_"
                }
            }
            else {
                Write-Host "File not found: $file"
                Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): File not found: $file"
            }
        }
    }
}

# Generate log file name with timestamp suffix
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logDirectory = Get-Location
$logFileName = "InstallLog_$timestamp.log"
$LogFile = Join-Path -Path $logDirectory -ChildPath $logFileName

# Automatically find all .msu files in the current directory
$msuFiles = Get-ChildItem -Path (Get-Location) -Filter *.msu | Select-Object -ExpandProperty FullName

# Log start of the installation process
Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Starting installation of MSU files."

# Call the function to install the found .msu files
Install-MSUFiles -MSUFiles $msuFiles

# Log completion of the installation process
Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Completed installation of MSU files."
