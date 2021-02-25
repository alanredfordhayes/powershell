Import-Module ServerManager

class installDomain {

    #Properties
    static [System.String]$Name = 'AD-Domain-Services'
    static [System.String]$Exception_Log = "Exception_Log.txt"

    # Constructors
    
    # Methods
    [System.Object] GetFeature() 
    {
        [System.Object]$feature = Get-WindowsFeature `
        -Name $this.Name
        return $feature
    }

}

$install = [installDomain]::new()
$install.GetFeature()