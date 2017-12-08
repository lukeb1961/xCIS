Configuration xCISPackages 
{
    [CmdletBinding()]
    PARAM ([Parameter(Mandatory=$true)]           [string[]] $packages,
           [Parameter(Mandatory=$true)]
           [ValidateSet("Yum", "Apt", "Zypper")]  [string]$PackageManager)

    Import-DscResource -ModuleName nx

    foreach ($package in $packages) {
        $pkgtag = $package.Replace('-', '').Replace('_', '')
        nxPackage $pkgtag {
           Name           = $package
           Ensure         = 'Present'
        PackageManager = $packagemanager
        }
    }

}
