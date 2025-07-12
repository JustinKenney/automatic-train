#A basic script that adds a registry key to enable web sign-in on Windows (allows for signing in with modern authentication methods)
#Note: script must be run as admin

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\"
$KeyName = "Authentication"
$ValueName = "EnableWebSignIn"
$ValueType = "DWord"
$ValueContents = "1"

$FullKeyPath = Join-Path -Path $RegistryPath -ChildPath $KeyName

Try {
    New-Item -Path $RegistryPath -Name $KeyName -Force -ErrorAction Stop  | Out-Null
} Catch {
    Write-Host "Could not create registry key!"
    Write-Host "Error: $($_.Exception.Message)"
    Exit 1
}

Try {
    Set-ItemProperty -Path $FullKeyPath -Name $ValueName -Value $ValueContents -PropertyType $ValueType -Force -ErrorAction Stop | Out-Null
    Write-Host "Web sign in enabled!"
} Catch {
    Write-Host "Could not create registry value!"
    Exit 1
}