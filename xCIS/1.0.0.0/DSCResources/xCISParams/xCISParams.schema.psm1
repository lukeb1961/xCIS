Configuration xCISParams
{
  [CmdletBinding()]
  PARAM ([ValidateSet("RedHat","CentOS","Fedora","Debian","Ubuntu")]
         [string] $Distro='RedHat')

  Import-DscResource -ModuleName nx

#region ConfigurationData
  $undef = $null

  $global:config = @{
      Nodename                = 'localhost' # Azure
      accept_all_src_routes   = $false
      accept_redirects        = $false
      validate_route          = $false
      ban_exceptions          = $undef
      nat_box                 = $undef
      disable_simple_firewall = $true
      secure_grub             = $false
      aide                    = $true
      lock_stale_users        = $false
      sender_hostname         = 'sender.example.org'
      masquerade_domains      = 'example.org'
      relayhost               = 'receiver.example.org'
   }

  switch ($Distro)
  {

   {$_ -in 'RedHat','CentOS','Fedora'}  {
      $config.distro         = 'RedHat'
      $config.packagemanager = 'Yum'        # "Yum", "Apt", "Zypper"
      $config.controller     = 'systemd'    # "init","upstart","systemd"
      $config.umask_daemon   = '027'
      $config.umask_user     = '077'
      $config.ssh_daemon     = 'sshd' # ssh, sshd
      $config.http_daemon    = 'httpd'
      $config.firewall_ui    = @('firewalld')
      $config.service_base   = @('crond', $config.ssh_daemon) #, 'iptables')
      $config.packages = @('cronie-anacron', 'tcp_wrappers', 'iptables-services')
      $config.disabled = @('rhnsd','chargen-dgram','chargen-stream','daytime-stream','daytime-dgram','echo-dgram','echo-stream',
                          'tcpmux-server','avahi-daemon','cups','autofs','rpcsvgssd','rpcgssd','rpcbind','rpcidmapd','nfslock')
      $config.ban_all  = @('dovecot','squid','setroubleshoot','mctrans','telnet-server','telnet','rsh-server','rsh','net-snmp',
                           'ypserv','ypbind','tftp','tftp-server','talk','talk-server','xinetd','xorg-x11-server-common','dhcp',
                           'openldap-servers','openldap-clients','bind','vsftpd','httpd','samba')
     }


   {$_ -in 'Debian','Ubuntu'}  {

      $config.distro         = 'Debian'
      $config.packagemanager = 'Apt'        # "Yum", "Apt", "Zypper"
      $config.controller     = 'systemd'    # "init","upstart","systemd"
      $config.umask_inactive = '035'
      $config.umask_user     = '077'
      $config.ssh_daemon     = 'ssh'        # ssh, sshd
      $config.firewall_ui    = @('ufw')
      $config.http_daemon    = 'apache2'
      $config.service_base   = @('cron', $config.ssh_daemon, 'apparmor')
      $config.packages = @('tcpd', 'apparmor-utils', 'apparmor-profiles')
      $config.disabled = @('rsync')
      $config.ban_all  = @('apport','vsftpd','discard','bind9','xinetd','smbd',
                           'apache2','tftp','avahi-daemon','daytime','echo','whoopsie',
                           'time','telnet','rpc','nfs-kernel-server','autofs','prelink',
                           'isc-dhcp-server','isc-dhcp-server6','xserver-xorg-core*','slapd',
                           'dovecot','biosdevname','snmpd','nis','chargen','rsh-client','atftp',
                           'rsh-reload-client','talk','ntalk','nfs','squid3','cups','telnet-server')
     }


    default  {  }

  }



  if ($config.ban_exceptions -ne $undef -and $config.disable_simple_firewall -eq $true) {
    $config.banned   = Compare-Object -ReferenceObject $config.ban_all -DifferenceObject $config.ban_exceptions -PassThru
    $config.services = $config.service_base

  } 
  elseif ($config.ban_exceptions -ne $undef -and $config.disable_simple_firewall -eq $false) {

    $tmp = Compare-Object -ReferenceObject $config.ban_all -DifferenceObject $config.ban_exceptions -PassThru

    $config.banned   = $tmp + $config.firewall_ui
    $config.services = $config.service_base + $config.firewall_ui
  }

  elseif ($config.ban_exceptions -ne $true -and $config.disable_simple_firewall -eq $false) {

    $config.banned   = $config.ban_all + $config.firewall_ui

    $config.services = $config.service_base + $config.firewall_ui
  }

  elseif ($config.ban_exceptions -ne $true -and $config.disable_simple_firewall -eq $true) {
    $config.banned   = $config.ban_all

    $config.services = $config.service_base
  }

#endregion


}
