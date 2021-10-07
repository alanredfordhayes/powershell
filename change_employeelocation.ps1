Import-Module .\global_vars.ps1
Import-Module .\global_functions.ps1

try { $adSecurityGroup = Read-Host -Prompt "AD Security Grouup" } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Read-Host | AD Security Grouup " }
if ($null -eq $adSecurityGroup) { Write-Error -Message "Response was null. Quitting..." ; exit 1 }

