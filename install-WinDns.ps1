if ((Get-WindowsFeature -Name 'DNS').Installed -eq $false) { Install-WindowsFeature -Name 'DNS' -Confirm:$false -Restart }

