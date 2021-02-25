Import-Module ServerManager

class installDomain {

    #Properties

    # Constructors
    installDomain(){}
    
    # Methods
    [System.Object] GetFeature(
        [String]$Name
    ) 
    {
        try {
            $feature = Get-WindowsFeature `
            -Name $Name `
            -ErrorAction Stop
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.GetType().FullName
            $feature = ($ErrorMessage, $FailedItem)
        }

        return $feature
    }

}

$install = [installDomain]::new()
$install.GetFeature('AD-Domain-Services')