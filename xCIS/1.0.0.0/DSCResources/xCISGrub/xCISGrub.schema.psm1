Configuration xCISGrub
{
    Import-DscResource -ModuleName nx

# grub2 /etc/default/grub
# GRUB_CMDLINE_LINUX="audit=1"
 nxScript AUDIT
 {
     GetScript=@"
#!/bin/bash
file='/etc/default/grub'
grep -q 'GRUB_CMDLINE_LINUX_DEFAULT.*audit=1.*' "$file"
"@

  SetScript=@"
#!/bin/bash
file='/etc/default/grub'
if [ -e /boot/grub2/grub.cfg ]
then
 CFG='/boot/grub2/grub.cfg'
else
 CFG='/boot/grub/grub.cfg'
fi
if ! grep -q 'GRUB_CMDLINE_LINUX.*audit=1.*' "$file"
then
  if grep -q 'GRUB_CMDLINE_LINUX.*audit=0.*' "$file"
  then
    sed --in-place '/^GRUB_CMDLINE_LINUX/s/audit=0/audit=1/' "$file"
  else
    sed --in-place '/^GRUB_CMDLINE_LINUX/s/="\(.*\)"/="\1 audit=1"/' "$file"
  fi
  if which grub-mkconfig >/dev/null 2>&1
  then
    grub-mkconfig --output="$CFG"
  else
    grub2-mkconfig --output="$CFG"
  fi
fi
exit 0
"@

  TestScript=@"
#!/bin/bash
file='/etc/default/grub'
if grep -q 'GRUB_CMDLINE_LINUX.*audit=1.*' "$file"
then
  exit 0
else
  exit 1
fi
"@
 }


##
## grub menu security is irrelevant for AZURE as you never get to see the grub boot loader.
##

 <#
 # enable password protection on grub 

    augeas { "Add SHA-512 password to Grub":
        context => "/files/boot/grub/menu.lst"
        changes => ["ins password after timeout", "${grub_secret}", "${grub_password}", ],
        onlyif  => "match password size == 0"
    }
#>


}
