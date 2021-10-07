$scriptName = $MyInvocation.MyCommand.Name
$path = Get-Location
$scriptLog = "$path\$scriptName.log"

function errorHandling {
    param ([System.Management.Automation.ErrorRecord]$handledError, [System.String]$scriptLog )
    $date = Get-Date
    $message = $handledError.Exception.Message
    $categoryInfo = $handledError.CategoryInfo
    $category = $categoryInfo.Category
    $activity = $categoryInfo.Activity
    $reason = $categoryInfo.Reason
    Write-Warning $message
    Write-Output "$date | azContext | $category on $activity caused by $reason. | $message" >> $scriptLog
}

try { $adSecurityGroup = Read-Host -Prompt "AD Security Grouup" -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Read-Host | AD Security Grouup " }
try { $adGroup = Get-AdGroup -Identity $adSecurityGroup -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AdGroup" } 
try { $adGroupMembers = Get-ADGroupMember -Identity $adGroup -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AdGroupMember" }
try { $Office = Read-Host -Prompt "Office" -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Read-Host | AD Security Grouup " }
try { $PostalCode = Read-Host -Prompt "Postal Code" -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Read-Host | AD Security Grouup " }

$adGroupMembers | ForEach-Object {
    # $distinguishedName   = $_.distinguishedName
    # $name                = $_.name
    # $objectClass         = $_.objectClass
    # $objectGUID          = $_.objectGUID
    $SamAccountName      = $_.SamAccountName
    # $SID                 = $_.SID

    try { $adUser = Get-ADUser -Identity $SamAccountName -Properties Office, physicalDeliveryOfficeName, PostalCode, StreetAddress -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AdGroupUser" }
    if ($adUser.Office -ne $Office) { try { $adUser | Set-ADUser -Office $Office -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-SetADUser | Office" } }
    if ($adUser.PostalCode -ne $PostalCode) { try { $adUser | Set-ADUser -PostalCode $PostalCode -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-SetADUser | Postal Code" } }
    if ($adUser.StreetAddress -ne $Office) { try { $adUser | Set-ADUser -StreetAddress $Office -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-SetADUser | StreetAddress" } }
}
