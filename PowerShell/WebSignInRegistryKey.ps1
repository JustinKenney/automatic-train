#A basic script that adds a registry key to enable web sign-in on Windows (allows for signing in with modern authentication methods)
#Note: script must be run as admin

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\"
$KeyName = "Authentication"
$ValueName = "EnableWebSignIn"
$ValueType = "DWord"
$ValueContents = "1"

Try {
    Set-Location -Path $RegistryPath
} Catch {
    Write-Host "Registry path not found!"
}

Try {
    New-Item -Name $KeyName -Force
} Catch {
    Write-Host "Could not create registry key!"
}

Try {
    New-ItemProperty -Path $ValueName -Name $ValueName -Value $ValueContents -PropertyType $ValueType -Force
    Write-Host "Web sign in enabled!"
} Catch {
    Write-Host "Could not create registry value!"
}