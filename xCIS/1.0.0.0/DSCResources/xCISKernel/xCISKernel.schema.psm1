Configuration xCISKernel 
{

  PARAM([boolean] $accept_all_src_routes, 
        [boolean] $accept_redirects,
        [boolean] $validate_route)


  Import-DscResource -ModuleName nx

# Disable
  nxFileLine SYSCTL_fs.suid_dumpable
  {
   FilePath = "/etc/sysctl.conf"
   ContainsLine = 'fs.suid_dumpable=0'
  }

  nxFileLine SYSCTL_net.ipv4.ip_forward
  {
   FilePath = "/etc/sysctl.conf"
   ContainsLine = 'net.ipv4.ip_forward=0'
  }

  nxFileLine SYSCTL_net.ipv6.conf.all.accept_ra
  {
   FilePath = "/etc/sysctl.conf"
   ContainsLine = 'net.ipv6.conf.all.accept_ra=0'
  }


  # Enable
  nxFileLine SYSCTL_net.ipv4.conf.all.send_redirects
  {
   FilePath = "/etc/sysctl.conf"
   ContainsLine = 'net.ipv4.conf.all.send_redirects=0'
  }

  nxFileLine SYSCTL_net.ipv4.conf.all.log_martians
  {
   FilePath = "/etc/sysctl.conf"
   ContainsLine = 'net.ipv4.conf.all.log_martians=1'
  }

  nxFileLine SYSCTL_net.ipv4.route.flush
  {
   FilePath = "/etc/sysctl.conf"
   ContainsLine = 'net.ipv4.route.flush=1'
  }

  nxFileLine SYSCTL_net.ipv4.icmp_echo_ignore_broadcasts
  {
   FilePath = "/etc/sysctl.conf"
   ContainsLine = 'net.ipv4.icmp_echo_ignore_broadcasts=1'
  }

  nxFileLine SYSCTL_net.ipv4.icmp_ignore_bogus_error_responses
  {
   FilePath = "/etc/sysctl.conf"
   ContainsLine = 'net.ipv4.icmp_ignore_bogus_error_responses=1'
  }



  nxFileLine SYSCTL_net.ipv4.tcp_syncookies
  {
   FilePath = "/etc/sysctl.conf"
   ContainsLine = 'net.ipv4.tcp_syncookies=1'
  }


  # Conditional based on roles

  if ($accept_all_src_routes -EQ $true) {
    nxFileLine SYSCTL_net.ipv4.conf.all.accept_source_route
    {
      FilePath = "/etc/sysctl.conf"
      ContainsLine = 'net.ipv4.conf.all.accept_source_route=1'
    }
  }
  else {
    nxFileLine SYSCTL_net.ipv4.conf.all.accept_source_route
    {
      FilePath = "/etc/sysctl.conf"
      ContainsLine = 'net.ipv4.conf.all.accept_source_route=0'
    }
  }



  if ($accept_redirects -EQ $true) {
    nxFileLine SYSCTL_net.ipv4.conf.all.secure_redirects
    {
      FilePath = "/etc/sysctl.conf"
      ContainsLine = 'net.ipv4.conf.all.secure_redirects=1'
    }
  }
  else {
    nxFileLine SYSCTL_net.ipv4.conf.all.secure_redirects
    {
      FilePath = "/etc/sysctl.conf"
      ContainsLine = 'net.ipv4.conf.all.secure_redirects=0'
    }
  }



  if ($validate_route -EQ $true) {
    nxFileLine SYSCTL_net.ipv4.conf.all.rp_filter
    {
      FilePath = "/etc/sysctl.conf"
      ContainsLine = 'net.ipv4.conf.all.rp_filter=1'
    }
  }
  else {
    nxFileLine SYSCTL_net.ipv4.conf.all.rp_filter
    {
      FilePath = "/etc/sysctl.conf"
      ContainsLine = 'net.ipv4.conf.all.rp_filter=0'
    }
  }


}
