##This is my first attempt at making a script in-line with Functional Programing style/best practices

param(
    [Parameter(Mandatory)]
    [string[]]$NetworkLocations
)
function Get-SoftwareInstallers {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$NetworkPath,
        [Parameter(Mandatory)]
        [string[]]$FileType
    )

    process {
        Get-ChildItem -Path $NetworkPath -Recurse -Include $FileType | Select-Object -Property Directory,Name
    }
}

$InstallerTypes = "*.msi", "*.exe"

$NetworkLocations | Get-SoftwareInstallers -FileType $InstallerTypes | Out-GridView