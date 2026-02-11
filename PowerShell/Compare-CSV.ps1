param (
    [Parameter(Mandatory)]
    [string]$FirstCSV,
    [Parameter(Mandatory)]
    [string]$SecondCSV
)

#Take CSV file hearders and normalize them to allow data to be easily compared
$FirstAttributes = @(
    @{Name="Client"; Expression={'FIRST FILE REAL HEADER NAME HERE'}},
    @{Name="Computer asset tag"; Expression={'FIRST FILE REAL HEADER NAME HERE'}},
    @{Name="Assigned user"; Expression={'FIRST FILE REAL HEADER NAME HERE'}}
)
$SecondAttributes = @(
    @{Name="Client"; Expression={'SECOND FILE REAL HEADER NAME HERE'}},
    @{Name="Computer asset tag"; Expression={'SECOND FILE REAL HEADER NAME HERE'}},
    @{Name="Assigned user"; Expression={'SECOND FILE REAL HEADER NAME HERE'}}
)

$FirstDataSet = Import-Csv -Path $FirstCSV | Select-Object -Property $FirstAttributes
$SecondDataSet = Import-Csv -Path $SecondCSV | Select-Object -Property $SecondAttributes

$results = @(
    $FirstDataSet
    $SecondDataSet
)

$results | Group-Object -Property "Computer asset tag" | Where-Object Count -EQ 1 | Select-Object -ExpandProperty Group