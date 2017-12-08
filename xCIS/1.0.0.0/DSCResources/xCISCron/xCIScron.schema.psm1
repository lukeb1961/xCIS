Configuration xCIScron {

    Import-DscResource -ModuleName nx

    $CronDirs = @(
        @{Name = 'CronHourly' ; Destination = '/etc/cron.hourly'},
        @{Name = 'CronDaily'  ; Destination = '/etc/cron.daily'},
        @{Name = 'CronWeekly' ; Destination = '/etc/cron.weekly'},   
        @{Name = 'CronMonthly'; Destination = '/etc/cron.monthly'},
        @{Name = 'CronD'      ; Destination = '/etc/cron.d'}
    )


    foreach ($CronDir in $CronDirs) {
        nxfile ($CronDir.Name) {
            DestinationPath = $CronDir.Destination
            Type            = 'directory'
            Ensure          = 'present'
            Owner           = 'root'
            Group           = 'root'
            Mode            = '0770'
            Recurse         = $true
        }

    }

    $CronFiles = @(
        @{Name = 'CronTab'   ; Destination = '/etc/crontab'},  
        @{Name = 'CronAllow' ; Destination = '/etc/cron.allow'},
        @{Name = 'AtAllow'   ; Destination = '/etc/at.allow'}
    )

    foreach ($CronFile in $CronFiles) {
        nxfile ($CronFile.Name) {
            DestinationPath = $CronFile.Destination
            Ensure          = 'present'
            Owner           = 'root'
            Group           = 'root'
            Mode            = '0600'
            Contents        = ''
        }

    }


    $DenyFiles = @(
         @{Name = 'CronDeny' ; Destination = '/etc/cron.deny'},
         @{Name = 'AtDeny'   ; Destination = '/etc/at.deny'}
    )

    foreach ($DenyFile in $DenyFiles) {
        nxfile ($DenyFile.Name) {
            DestinationPath = $DenyFile.Destination
            Ensure          = 'absent'
        }
    }


}

