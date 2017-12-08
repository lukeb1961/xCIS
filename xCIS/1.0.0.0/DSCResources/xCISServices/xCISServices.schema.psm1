Configuration xCISServices 
{
  [CmdletBinding()]
  PARAM ([Parameter(Mandatory=$true)]              [string[]] $services,
         [Parameter(Mandatory=$true)]
         [ValidateSet("init","upstart","systemd")] [string]   $controller)

 Import-DscResource -ModuleName nx

  foreach ($service in $services) {
    $svctag = $service.Replace('-','').Replace('_','')
    nxService $svctag
    {
      Name=$service
      State = 'Running'
      Enabled = $true
      Controller=$controller
    }
  }


}
