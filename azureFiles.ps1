Import-Module Az.Accounts
Import-Module -Name Az.Resources

# Global Variables
$scriptName = $MyInvocation.MyCommand.Name
$path = Get-Location
$scriptLog = "$path\$scriptName.log"

$azureFilesResourceGroupName = "AzureFilesDemo"
$azureFilesLocation = "eastus"
$azureFilesServicePrincipalName = $azureFilesResourceGroupName + "Automation"
$azureFilesServicePrincipalRole = "Contributor"

# Functions
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

# Azure Login 
try { $azContext = Get-AzContext -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AzContext" }
if ($null -eq $azContext) { 
    try { Connect-AzAccount -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "Connect-AzAccount" } 
    try { $azContext = Get-AzContext -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AzContext" }
}

# Azure Vars
$azureTenantId = $azContext.Tenant.Id

if ($azContext.Account.Type -eq "User") {
    Write-Output "AzContext Account Type = User"

    # Data Sources
    try { $azADServicePrincipals = Get-AzADServicePrincipal -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AzADServicePrincipal" }
    try { $azResourceGroup = Get-AzResourceGroup } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AzResourceGroup" }

    # Azure Files Resource Group
    $azureFilesTags = @{Department="IT";Purpose="Proof of Concept";Name=$azureFilesResourceGroupName;Location=$azureFilesLocation}
    try { $filterAzResourceGroup = $azResourceGroup | Where-Object -Property ResourceGroupName -eq $azureFilesResourceGroupName -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "filterAzResourceGroup" }
    if ($null -ne $filterAzResourceGroup) { Write-Output "$azureFilesResourceGroupName has been previsously provisioned." ; $azureFilesAzResourceGroup = $filterAzResourceGroup }
    else { try { $azureFilesAzResourceGroup = New-AzResourceGroup -Name $azureFilesResourceGroupName -Location $azureFilesLocation -Tag $azureFilesTags -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "New-AzResourceGroup" } }

    # Azure Files Self Signed Certificate
    $azureFilesServicePrincipalCertificatePath = ".\azureFilesServicePrincipal.cert"
    if ((Test-Path -Path $azureFilesServicePrincipalCertificatePath) -ne $True) { openssl req -newkey rsa:1024 -x509 -sha256 -days 365 -out azureFilesServicePrincipal.cert -keyout azureFilesServicePrincipal.key -nodes -subj "/C=US/ST=NY/L=New York/O=Dotdash/OU=IT/CN=azureFilesServicePrincipal/emailAddress=it@dotdash.com" }

    # Azure Files Service Principal
    $azureFilesServicePrincipalScope = $azureFilesAzResourceGroup.ResourceId
    try { $filterServicePrincipal = $azADServicePrincipals | Where-Object -Property DisplayName -eq $azureFilesServicePrincipalName -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "filterServicePrincipalName" }
    if ( $null -ne $filterServicePrincipal ) { 
        $applicationID = $filterServicePrincipal.ApplicationId
        $securePassword = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        Write-Output "$azureFilesServicePrincipalName has been previsously provisioned." ; $azureFilesAzAdServicePrincipal = $filterServicePrincipal 
        Write-Output "ApplicationID:  $applicationID"
        Write-Output "Secret:  $securePassword"
        Write-Output "TenantID:  $azureTenantId"
    } else { 
        # Azure Files Service Principal Creation
        try { $azureFilesAzAdServicePrincipal = New-AzAdServicePrincipal -DisplayName $azureFilesServicePrincipalName -Role $azureFilesServicePrincipalRole  -Scope $azureFilesServicePrincipalScope -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "New-AzAdServicePrincipal" } 
        $filterServicePrincipal = $azureFilesAzAdServicePrincipal

        # Azure Files Service Principal Secret
        try { $azureFilesNewPassword = New-AzADSpCredential -ObjectId $azureFilesAzAdServicePrincipal.Id -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "New-AzADSpCredential" }
        try { $securePassword = $azureFilesNewPassword.Secret | ConvertFrom-SecureString -AsPlainText } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "ConvertFrom-SecureString" }
        $applicationID = $azureFilesAzAdServicePrincipal.ApplicationId
        Write-Output "ApplicationID:  $applicationID"
        Write-Output "Secret:  $securePassword"
        Write-Output "TenantID:  $azureTenantId"
    }

    if ($securePassword -eq "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx") { try { $securePassword = Read-Host -prompt "Secret for Azure Files Service Principal" -AsSecureString -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "Read-Host" } }
    try { $azureServicePrincipalCredentials = New-Object System.Management.Automation.PSCredential ($applicationID, $securePassword) } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "New-Object" }

    try { Connect-AzAccount -Credential $azureServicePrincipalCredentials -ServicePrincipal -Tenant $azureTenantId -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "Connect-AzAccount" }
} else {
    Write-Output "AzContext Account Type = ServicePrincipal"
}

try { $azResourceGroup = Get-AzResourceGroup } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -name "Get-AzResourceGroup" }
$azureFilesResourceGroupNameCheck = $azResourceGroup.ResourceGroupName
if ($azureFilesResourceGroupNameCheck -ne $azureFilesResourceGroupName ) {
    Write-Output "Resource Group: $azureFilesResourceGroupNameCheck is not correct ($azureFilesResourceGroupName)"
    try { Connect-AzAccount -Credential (Get-Credential) -ServicePrincipal -Tenant $azureTenantId -ErrorAction Stop } catch { errorHandling -handledError $Error[0] -scriptLog $scriptLog -Name "Connect-AzAccount" }
} else {
    Write-Output "Resource Group: $azureFilesResourceGroupNameCheck is good ($azureFilesResourceGroupName)"
}

