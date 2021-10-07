$scriptName = $MyInvocation.MyCommand.Name
$path = Get-Location
$scriptLog = "$path\$scriptName.log"

$canvasURL = "https://dotdash.instructure.com" 

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

# try { $canvasCredential = Get-Credential -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "canvasCredential"  }
# https://<canvas-install-url>/login/oauth2/auth?client_id=XXX&response_type=code&redirect_uri=https://example.com/oauth_complete&state=YYY&scope=%20<value_2>%20<value_n>

$client_id     = '208170000000000102'
$response_type = 'code'
$redirect_uri  = 'https://oauth.workflows.okta.com/oauth/httpfunctions/cb'
$scope         = "users"

try {
    $canvasBasicAuth = Invoke-WebRequest `
    -Uri "$canvasURL/login/oauth2/auth?client_id=$client_id&response_type=$response_type&redirect_uri=$redirect_uri&scope=$scope" `
    -Form $canvasBasicAuthForm `
    -Method Get `
    -ErrorAction Stop `
} catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "canvasBasicAuth" }

$canvasBasicAuth