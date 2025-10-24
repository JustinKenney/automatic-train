$InstallDir = 'Temp'
$InstallLocation = 'C:\'
$FullPath = (Join-Path -Path $InstallLocation -ChildPath $InstallDir)
$URl ='https://for.bar.local'
$InstallerFile = (Join-Path -Path $FullPath -ChildPath 'files.zip')

#Check for Temp folder, create if needed
if ($null -eq (Test-Path -Path $FullPath))
{
    try {
        New-Item -Path $InstallLocation -Name $InstallDir -ItemType Directory
    }
    catch {
        Exit
    }
}

#Download installer and config file
try {
    Invoke-WebRequest -Uri $URl -OutFile $InstallerFile
}
catch {
    Exit
}

