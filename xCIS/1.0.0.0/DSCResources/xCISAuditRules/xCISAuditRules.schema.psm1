Configuration xCISAuditRules
{

    Import-DscResource -ModuleName nx
    Import-DscResource -ModuleName xCIS
 
    $uri='https://raw.githubusercontent.com/lukeb1961/xCIS/master/xCIS/1.0.0.0/'
    $xCISRoot     =New-Object -TypeName 'System.Uri' -ArgumentList $uri
    $xCISTemplates=New-Object -TypeName 'System.Uri' -ArgumentList $xCISRoot,'templates/'

    $AuditRules =New-Object -TypeName 'System.Uri' -ArgumentList $xCISTemplates,'audit.rules.erb'
    $TempFile = New-TemporaryFile
    (New-Object System.Net.WebClient).DownloadFile($AuditRules, $TempFile)

    $AuditRules_contents = Get-Content -Path $TempFile  -Raw
    $CISrules='/etc/audit/rules.d/cis.rules'

    nxFile CISRULES 
    {
        DestinationPath = $CISrules
        Ensure          = 'present'
        Type            = 'file'
        Mode            = '0640'
        Owner           = 'root'
        Contents        = $AuditRules_contents
    }

    nxScript AUGENRULES 
    {
     GetScript=@"
#!/bin/bash
augenrules --check
"@
     SetScript=@"
#!/bin/bash
augenrules --load
exit 0
"@
     TestScript=@"
#!/bin/bash
if [-e {0}]
then
exit 1
else
exit 0
"@ -f $CISrules

     DependsOn="[nxFile]CISRULES"
    }
}
