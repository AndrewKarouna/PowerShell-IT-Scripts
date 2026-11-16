#Purpose: Collect network information and test common connectivity paths. Great for "no internet", "limited connectivity", or Wi-Fi issues
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Comprehensive network and connectivity diagnostics for IT support.
.DESCRIPTION
    Gathers adapter status, IP config, DNS, gateway tests, common ports, and writes a timestamped report.
#>

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportPath = "C:\IT-Lab\Scripts\Network-Report-$timestamp.txt"
$log = { param($msg) $msg | Tee-Object -FilePath $reportPath -Append }

& $log "=== Network Diagnostics Report - $(Get-Date) ==="
& $log "Computer: $env:COMPUTERNAME"
& $log ""

# 1. Adapter status
& $log "--- Network Adapters ---"
Get-NetAdapter | Select-Object Name, Status, LinkSpeed, MacAddress | Format-Table -AutoSize | Out-String | ForEach-Object { & $log $_ }

# 2. IP Configuration
& $log "--- IP Configuration ---"
Get-NetIPConfiguration | Format-List | Out-String | ForEach-Object { & $log $_ }

# 3. DNS Servers
& $log "--- DNS Servers ---"
Get-DnsClientServerAddress -AddressFamily IPv4 | Format-Table -AutoSize | Out-String | ForEach-Object { & $log $_ }

# 4. Basic connectivity tests
$targets = @("8.8.8.8", "1.1.1.1", "google.com", "microsoft.com")
& $log "--- Connectivity Tests ---"
foreach ($t in $targets) {
    $ping = Test-Connection -ComputerName $t -Count 2 -Quiet -ErrorAction SilentlyContinue
    $result = if ($ping) { "Success" } else { "FAILED" }
    & $log "Ping $t : $result"
}

# 5. Detailed Test-NetConnection examples
& $log "--- Detailed Tests (Google DNS + HTTPS) ---"
Test-NetConnection -ComputerName 8.8.8.8 -InformationLevel Detailed | Out-String | ForEach-Object { & $log $_ }
Test-NetConnection -ComputerName google.com -Port 443 -InformationLevel Detailed | Out-String | ForEach-Object { & $log $_ }

# 6. Common troubleshooting actions 
# ipconfig /flushdns
# Clear-DnsClientCache
# Restart-NetAdapter -Name "Wi-Fi" -Confirm:$false   # change name as needed

& $log ""
& $log "Report saved to: $reportPath"
Write-Host "Diagnostics complete. Report: $reportPath" -ForegroundColor Green

#How to test itL 
#-Run it normally then verify report
#Disable network adapter or unplug virtual NIC -> run again and draw comparison
#Change DNS to a bad server and re-test
