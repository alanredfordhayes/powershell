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
$adGroupMembers | ForEach-Object {
    $distinguishedName   = $_.distinguishedName
    $name                = $_.name
    $objectClass         = $_.objectClass
    $objectGUID          = $_.objectGUID
    $SamAccountName      = $_.SamAccountName
    $SID                 = $_.SID

    $Office                      = "28 Liberty St, Floor 7, New York, NY 10005"
    $physicalDeliveryOfficeName  = "28 Liberty St, Floor 7, New York, NY 10005"
    $PostalCode                  = "10005"
    $StreetAddress               = "28 Liberty St, Floor 7, New York, NY 10005"

    try { $adUser = Get-ADUser -Identity $SamAccountName -Properties Office, physicalDeliveryOfficeName, PostalCode, StreetAddress -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AdGroupUser" }
    $adUser
}
