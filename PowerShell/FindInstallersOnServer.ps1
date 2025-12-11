##This is my first attempt at making a script in-line with Functional Programing style/best practices

function Get-SoftwareInstallers {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$NetworkPath,
        [Parameter(Mandatory)]
        [string[]]$FileType
    )

    process {
        Get-ChildItem -Path $NetworkPath -Recurse -Include $FileType
    }
}

$NetworkLocations = "\\testpath\folder1", "\\testpath\folder2"
$InstallerTypes = "*.msi", "*.exe"

$NetworkLocations | Get-SoftwareInstallers -FileType $InstallerTypes