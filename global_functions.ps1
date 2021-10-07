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