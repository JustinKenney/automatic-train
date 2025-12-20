#A basic script that adds a registry key to enable web sign-in on Windows (allows for signing in with modern authentication methods)
#Note: script must be run as admin

function Set-RegistryKey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$RegistryPath,
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$KeyName,
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ValueName,
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ValueType,
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ValueContents
    )

    process {
        $FullKeyPath = Join-Path -Path $RegistryPath -ChildPath $KeyName

        try {
            if($false -eq (Test-Path -Path $FullKeyPath)) {
                New-Item -Path $RegistryPath -Name $KeyName -Force -ErrorAction Stop
            }
        }
        catch {
            Write-Host "Registry key does not exist and could not be created"
        }

        try{
            if($ValueContents -ne (Get-ItemPropertyValue -Path $FullKeyPath -Name $ValueName)) {
                Set-ItemProperty -Path $FullKeyPath -Name $ValueName -Value $ValueContents -Type $ValueType -Force -ErrorAction Stop
            }
        }
        Catch {
            Write-Host "Could not set registry value"
        }
    }
    
}

$params = @{
    RegistryPath = "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\"
    KeyName = "Authentication"
    ValueName = "EnableWebSignIn"
    ValueType = "DWord"
    ValueContents = "1"
}

Set-RegistryKey @params