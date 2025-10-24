$InstallDir = 'Temp'
$InstallLocation = 'C:\'
$FullPath = (Join-Path -Path $InstallDir -ChildPath $InstallLocation)
$URl ='https:\\for.bar.local'

#Check for Temp folder, create if needed
if ($null -eq (Test-Path -Path $FullPath))
{
    try {
        New-Item -Path $InstallDir -Name $InstallLocation -ItemType Directory
    }
    catch {
        Exit
    }
}

#Download installer and config file
try {
    Invoke-WebRequest -Uri $URl -OutFile $FullPath
}
catch {
    Exit
}

