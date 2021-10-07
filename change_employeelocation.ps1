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
if ($null -eq $adSecurityGroup) { Write-Output "Response was null. Quitting..." ; exit 1 }
else { 
    try {
        $adGroup = Get-AdGroup -Identity $adSecurityGroup -ErrorAction Stop
    }
    catch {
        errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AdGroup"
    }
}
