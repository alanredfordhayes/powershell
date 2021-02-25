Import-Module ServerManager

class installDomain {

    #Properties
    static [System.String]$Name = 'AD-Domain-Services'

    # Constructors
    installDomain(){}
    
    # Methods
    [System.Object] GetFeature(
        $Name
    ) 
    {
        try {
            $feature = Get-WindowsFeature `
            -Name $this.Name `
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
$install.GetFeature()