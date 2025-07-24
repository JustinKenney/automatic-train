# Check for Administrator privileges
# Full disclosure, I had Gemini AI write this specific check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # If not running as Administrator, restart the script with elevated privileges
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$EventLogQuery = @'
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[(Level=1  or Level=2) and (EventID=7 or EventID=11 or EventID=41 or EventID=55 or EventID=1001 or EventID=7000 or EventID=7001 or EventID=7009 or EventID=7022 or EventID=7023 or EventID=7024 or EventID=7031 or EventID=7034 or EventID=6008) and TimeCreated[timediff(@SystemTime) &lt;= 2592000000]]]</Select>
  </Query>
</QueryList>
'@

$EventLogSort = @{Expression = "Id"; Descending = $False},
                @{Expression = "TimeCreated"; Descending = $True}

$EventLogResults = Get-WinEvent -FilterXml $EventLogQuery | Sort-Object -Property $EventLogSort | Select-Object -Property TimeCreated, Id, LevelDisplayName, Message
$EventLogResults | Format-Table -AutoSize

try {
  Write-Host "Beginning SFC scan. Please wait"
  $SFCResults = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -NoNewWindow
} catch {
  Write-Host "Error running SFC"
  Write-Host "Error: $($_.Exception.Message)"
}

try {
  Write-Host "Beginning DISM scan"
  $DISMResults = Repair-WindowsImage -Online -RestoreHealth
  Write-Host "DISM scan complete"
} catch {
  Write-Host "Error running DISM"
  Write-Host "Error: $($_.Exception.Message)"
}