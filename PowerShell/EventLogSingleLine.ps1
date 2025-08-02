<#
A single line PowerShell command that queries the Event Log for key events and outputs the results to console.
Adapted from the code in the ThisIsMyBoomstick script
#>

$EventLogQuery = '<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[(Level=1  or Level=2) and (EventID=7 or EventID=11 or EventID=41 or EventID=55 or EventID=1001 or EventID=7000 or EventID=7001 or EventID=7009 or EventID=7022 or EventID=7023 or EventID=7024 or EventID=7031 or EventID=7034 or EventID=6008) and TimeCreated[timediff(@SystemTime) &lt;= 2592000000]]]</Select></Query></QueryList>' ; $EventLogSort = @{Expression = "Id"; Descending = $False}, @{Expression = "TimeCreated"; Descending = $True} ; $EventLogResults = Get-WinEvent -FilterXml $EventLogQuery | Sort-Object -Property $EventLogSort | Select-Object -Property TimeCreated, Id, LevelDisplayName, Message ; $EventLogResults | Format-Table -AutoSize