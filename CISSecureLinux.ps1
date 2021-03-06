﻿Configuration CISSecureLinux {

  [CmdletBinding()]
  PARAM ([ValidateSet("RedHat","CentOS","Fedora","Debian","Ubuntu")]
         [string] $Distro='RedHat',
         [string] $storageURI='https://raw.githubusercontent.com/lukeb1961/xCIS/master/xCIS/1.0.0.0/')

  Import-DscResource -ModuleName xCIS

  Node localhost  {

    xCISParams params   # all settings are done in xCISparams and passed to the others
    {
      Distro = $Distro
    }

    xCISServices svcs
    {
      services   = $config.services
      controller = $config.controller
    }

    xCISPackages pkgs
    {
      packages       = $config.packages
      PackageManager = $config.packagemanager
    }

    xCISBanned banned
    {
      disabledServices = $config.disabled
      controller       = $config.controller
      bannedPackages   = $config.banned
      packageManager   = $config.packagemanager
    }

    xCISKernel sysctl
    {
      accept_all_src_routes = $config.accept_all_src_routes
      accept_redirects      = $config.accept_redirects
      validate_route        = $config.validate_route
    }

    xCIScron cron
    {
    }
 
    xCISAuditRules audit
    {
      StorageURI = $storageURI
    }

    xCISAuthentication authentication
    {
      Distro     = $Distro
      SSHdaemon  = $config.ssh_daemon
      Storageuri = $storageuri
    }

    xCISMail postfix_relay
    {
      sender_hostname    = $config.sender_hostname
      masquerade_domains = $config.masquerade_domains
      relayhost          = $config.relayhost
    }
 
    xCISGrub kernelAudit
    {
    }

  }
}
