Configuration xCISBanned
{

  [CmdletBinding()]
  PARAM ([Parameter(Mandatory=$true)]              [string[]] $disabledServices,
         [Parameter(Mandatory=$true)]
         [ValidateSet("init","upstart","systemd")] [string]   $controller,
         [Parameter(Mandatory=$true)]              [string[]] $bannedPackages,
         [Parameter(Mandatory=$true)]
         [ValidateSet("Yum", "Apt", "Zypper")]     [string]   $packageManager)

    Import-DscResource -ModuleName nx

    foreach ($service in $disabledServices) {
        $svctag = $service.Replace('-', '').Replace('_', '')

        nxService $svctag {
            Name       = $service
            Enabled    = $false
            State      = 'Stopped'
            Controller = $controller  # "init","upstart","systemd"
        }

    }



    foreach ($package in $bannedPackages) {

        $pkgtag = $package.Replace('-', '').Replace('_', '')
        nxPackage $pkgtag { 
            Name           = $package
            Ensure         = 'Absent'
            PackageManager = $packageManager # "Yum", "Apt", "Zypper"
        }

    }


}
