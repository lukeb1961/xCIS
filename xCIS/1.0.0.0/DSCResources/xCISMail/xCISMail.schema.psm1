Configuration xCISMail 
{
  [CmdletBinding()]
  PARAM ([Parameter(Mandatory=$true)] [string]   $sender_hostname,
         [Parameter(Mandatory=$true)] [string[]] $masquerade_domains,
         [Parameter(Mandatory=$true)] [string]   $relayhost)

  Import-DscResource -ModuleName nx
  Import-DscResource -ModuleName xCIS

<#
  $sender_hostname     # The domain name that locally-posted mail appears to come from, and that locally posted mail is delivered to.
  $masquerade_domains  # Optional list of domains whose subdomain structure will be stripped off in email addresses. 
  $relayhost           # The next-hop destination of non-local mail; overrides non-local domains in recipient addresses.
#>

  nxFileLine myhostname
  {
    FilePath = "/etc/postfix/main.cf"
    ContainsLine = "myhostname=$sender_hostname"
  }

  nxFileLine myorigin
  {
    FilePath = "/etc/postfix/main.cf"
    ContainsLine = "myorigin=$sender_hostname"
  }

  nxFileLine mydestination
  {
    FilePath = "/etc/postfix/main.cf"
    ContainsLine = "mydestination=$sender_hostname"
  }

  nxFileLine relayhost
  {
    FilePath = "/etc/postfix/main.cf"
    ContainsLine = "relayhost=$relayhost"
  }

  $masqueradeDomains = ('masquerade_domains={0}' -f ($masquerade_domains -Join ' '))

  nxFileLine masqueradedomains
  {
   FilePath = "/etc/postfix/main.cf"
   ContainsLine = $masqueradeDomains
  }

# TODO need to trigger a restart of service if required...

}
