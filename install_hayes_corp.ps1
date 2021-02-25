Import-Module ServerManager

class installDomain {

    #Properties
    [System.String]$Name 
    [System.String]$Exception_Log
    
    # Constructors
    installDomain (
        [System.String]$Name,
        [System.String]$Exception_Log
    ) {
        $this.Name = 'AD-Domain-Services'
        $this.Exception_log = "Exception_Log.txt"
    }
    
    # Methods
    [System.Object] GetFeature() 
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