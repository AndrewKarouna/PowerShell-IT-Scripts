#Purpose: Upgrade all (or selected) applications silently using the built-in winget tool.
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Silently upgrades applications using winget.
#>

$logPath = "C:\IT-Lab\Scripts\Winget-Upgrade-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
function Write-Log { param($Message) "$(Get-Date -Format 'HH:mm:ss') $Message" | Tee-Object -FilePath $logPath -Append }

Write-Log "Starting winget upgrade..."

# Update winget sources first
winget source update 2>&1 | Tee-Object -FilePath $logPath -Append

# Upgrade everything silently
Write-Log "Running winget upgrade --all..."
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Tee-Object -FilePath $logPath -Append

Write-Log "Upgrade process finished."
Write-Host "Log: $logPath" -ForegroundColor Green#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Silently upgrades applications using winget.
#>

$logPath = "C:\IT-Lab\Scripts\Winget-Upgrade-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
function Write-Log { param($Message) "$(Get-Date -Format 'HH:mm:ss') $Message" | Tee-Object -FilePath $logPath -Append }

Write-Log "Starting winget upgrade..."

# Update winget sources first
winget source update 2>&1 | Tee-Object -FilePath $logPath -Append

# Upgrade everything silently
Write-Log "Running winget upgrade --all..."
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Tee-Object -FilePath $logPath -Append

Write-Log "Upgrade process finished."
Write-Host "Log: $logPath" -ForegroundColor Green

#Optional enhancement - install a specific list of apps:
$apps = @(
    "7zip.7zip",
    "Notepad++.Notepad++",
    "Google.Chrome",
    "Mozilla.Firefox"
)

foreach ($app in $apps) {
    Write-Log "Installing/Upgrading $app"
    winget install --id $app --exact --silent --accept-package-agreements --accept-source-agreements 2>&1 | Tee-Object -FilePath $logPath -Append
}

