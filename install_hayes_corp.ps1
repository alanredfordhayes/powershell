Import-Module ServerManager

class installDomain {

    #Properties
    [String]$DNS = 'DNS'
    [String]$ADDomainServices = 'AD-Domain-Services'

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

    [System.Object] GetDnsFeature(){
        $feature = $this.GetFeature($this.DNS)
        return $feature
    }



}

$install = [installDomain]::new()
$install.GetDnsFeature()