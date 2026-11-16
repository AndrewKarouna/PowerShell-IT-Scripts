#Purpose: Safely reset the most common causes of Windows Update Failures (services, SoftwareDistribution, catroot2) and run DISM + SFC.
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Repairs common Windows Update issues.
.DESCRIPTION
    Stops services, renames SoftwareDistribution and catroot2, restarts services,
    then runs DISM RestoreHealth and SFC. Creates a log.
#>

$logPath = "C:\IT-Lab\Scripts\WU-Repair-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
function Write-Log { param($Message) "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" | Tee-Object -FilePath $logPath -Append }

Write-Log "Starting Windows Update repair..."

# 1. Stop related services
$services = @("wuauserv", "bits", "cryptsvc", "msiserver")
foreach ($svc in $services) {
    try {
        Stop-Service -Name $svc -Force -ErrorAction Stop
        Write-Log "Stopped service: $svc"
    } catch {
        Write-Log "Could not stop $svc - $($_.Exception.Message)"
    }
}

# 2. Rename folders (safer than deleting)
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$sdPath = "$env:SystemRoot\SoftwareDistribution"
$catPath = "$env:SystemRoot\System32\catroot2"

if (Test-Path $sdPath) {
    Rename-Item -Path $sdPath -NewName "SoftwareDistribution.bak-$timestamp" -ErrorAction SilentlyContinue
    Write-Log "Renamed SoftwareDistribution"
}
if (Test-Path $catPath) {
    Rename-Item -Path $catPath -NewName "catroot2.bak-$timestamp" -ErrorAction SilentlyContinue
    Write-Log "Renamed catroot2"
}

# 3. Restart services
foreach ($svc in $services) {
    try {
        Start-Service -Name $svc -ErrorAction Stop
        Write-Log "Started service: $svc"
    } catch {
        Write-Log "Could not start $svc - $($_.Exception.Message)"
    }
}

# 4. DISM + SFC (these take time)
Write-Log "Running DISM /RestoreHealth (this can take 10-30 minutes)..."
DISM.exe /Online /Cleanup-Image /RestoreHealth | Tee-Object -FilePath $logPath -Append

Write-Log "Running SFC /scannow..."
sfc /scannow | Tee-Object -FilePath $logPath -Append

#How to test:
#Manually stop the "wuauserv" and rename SoftwareDistribution yourself, then run the script to confirm it recovers.
#After running, open Settings -> Windows Update and check for updates

Write-Log "Repair complete. Reboot recommended before checking for updates again."
Write-Host "Log saved to: $logPath" -ForegroundColor Green
Write-Host "Please restart the computer, then run Windows Update." -ForegroundColor Yellow
