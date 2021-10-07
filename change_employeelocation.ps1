Import-Module .\global_vars.ps1
Import-Module .\global_functions.ps1

try { $adSecurityGroup = Read-Host -Prompt "AD Security Grouup" } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Read-Host | AD Security Grouup " }
$adSecurityGroup

