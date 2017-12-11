Configuration  xCISAuthentication 
{

   [CmdletBinding()]
   PARAM ( [Parameter(Mandatory=$true)]
           [ValidateSet("RedHat","CentOS","Fedora","Debian","Ubuntu")] [string] $Distro,
           [Parameter(Mandatory=$true)]  [string] $SSHdaemon,
           [Parameter(Mandatory=$true)]  [string] $StorageURI)

    Import-DscResource -ModuleName nx

    $OSfamilyRedhat = @("RedHat","CentOS","Fedora")
    $OSfamilyDebian = @("Debian","Ubuntu")
 
    $xCISRoot     =New-Object -TypeName 'System.Uri' -ArgumentList $StorageURI
    $xCISFiles    =New-Object -TypeName 'System.Uri' -ArgumentList $xCISRoot,'files/'
    $xCISTemplates=New-Object -TypeName 'System.Uri' -ArgumentList $xCISRoot,'templates/'

    nxfile ETCPASSWD 
    {
        DestinationPath = '/etc/passwd'
        Owner           = 'root'
        Group           = 'root'
        Mode            = '644'
        Type            = 'file'
    }


    nxfile ETCGROUP 
    {
        DestinationPath = '/etc/group'
        Owner           = 'root'
        Group           = 'root'
        Mode            = '644'
        Type            = 'file'
    }


    nxfile ETCSHADOW 
    {
        DestinationPath = '/etc/shadow'
        Owner           = 'root'
        Group           = 'root'
        Mode            =  '000'
    }

    $bannerfile =New-Object -TypeName 'System.Uri' -ArgumentList $xCISFiles,'banner'
    nxfile ETCISSUE {
        DestinationPath = '/etc/issue'
        Owner           = 'root'
        Group           = 'root'
        Mode            = '644'
        SourcePath      = $bannerfile.AbsoluteUri
    }


    nxfile ETCMOTD 
    {
        DestinationPath = '/etc/motd'
        Owner           = 'root'
        Group           = 'root'
        Mode            = '644'
        SourcePath      = $bannerfile.AbsoluteUri
    }


    $sshd_config =New-Object -TypeName 'System.Uri' -ArgumentList $xCISTemplates,'sshd_config.erb'
    $TempFile = New-TemporaryFile
    (New-Object System.Net.WebClient).DownloadFile($sshd_config, $TempFile)

    $sshd_config_contents = Get-Content -Path $TempFile  -Raw
    nxfile ETCSSHDCONFIG 
    { 
        DestinationPath = '/etc/ssh/sshd_config'
        Owner           = 'root'
        Group           = 'root'
        Mode            = '600'
        Contents        = $sshd_config_contents
        #    notify  => Service["${ssh_daemon}"]
    }

    nxScript ReloadSSHD
    {
GetScript = @"
#!/bin/bash
if [ "`systemctl is-active {0}`" = "active" ]
then
exit 1
else
exit 0
fi
"@ -f $SSHdaemon

SetScript = @"
#!/bin/bash
sudo systemctl reload-or-restart {0}
"@  -f $SSHdaemon

TestScript = @'
#!/bin/bash
if [ "`systemctl is-active {0}`" = "active" ]
then
exit 1
else
exit 0
fi
'@  -f $SSHdaemon
   DependsOn = "[nxFile]ETCSSHDCONFIG"
   }


    $logindefs  =New-Object -TypeName 'System.Uri' -ArgumentList $xCISTemplates,'login.defs.erb'
    $TempFile = New-TemporaryFile
    (New-Object System.Net.WebClient).DownloadFile($logindefs, $TempFile)

    $logindefs_contents = Get-Content -Path $TempFile  -Raw
    nxfile ETCLOGINDEFS 
    {
        DestinationPath = '/etc/login.defs'
        Owner           = 'root'
        Group           = 'root'
        Mode            = '644'
        Contents        = $logindefs_contents
        # notify  => Service['auditd'] [TODO] debug auditd module
    }


    if ($Distro -in $OSfamilyRedhat) {
        
        $systemauthfile =New-Object -TypeName 'System.Uri' -ArgumentList $xCISFiles,'system-auth'
        nxfile SYSTEMAUTHAC 
        { 
            DestinationPath = '/etc/pam.d/system-auth-ac'
            Owner           = 'root'
            Group           = 'root'
            Mode            = '644'
            SourcePath      = $systemauthfile.AbsoluteUri
        }
 
        nxfile SYSTEMAUTH 
        {
            DestinationPath = '/etc/pam.d/system-auth'
            ensure          = 'present'
            type            = 'link'
            SourcePath      = '/etc/pam.d/system-auth-ac'
            DependsOn       = "[nxFile]SYSTEMAUTHAC"
        }

        $pwqualityConf_file =New-Object -TypeName 'System.Uri' -ArgumentList $xCISFiles,'pwquality.conf'
        nxfile PWQUALITYCONF 
        {
            DestinationPath = '/etc/security/pwquality.conf'
            Owner           = 'root'
            Group           = 'root'
            Mode            = '644'
            SourcePath      = $pwqualityConf_file.AbsoluteUri
        }

    }



    if ($Distro -in $OSfamilyDebian) {
        
        $commonPasswordFile =New-Object -TypeName 'System.Uri' -ArgumentList $xCISFiles,'common-password'
        nxfile COMMONPASSWORD 
        {
            DestinationPath = '/etc/pam.d/common-password'
            Owner           = 'root'
            Group           = 'root'
            Mode            = '644'
            SourcePath      = $commonPasswordFile.AbsoluteUri
        }

        $suFile=New-Object -TypeName 'System.Uri' -ArgumentList $xCISFiles,'su'
        nxfile SU 
        {
            DestinationPath = '/etc/pam.d/su'
            Owner           = 'root'
            Group           = 'root'
            Mode            = '644'
            SourcePath      = $suFile.AbsoluteUri
        }
    }

}
