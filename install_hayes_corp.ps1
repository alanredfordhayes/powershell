Import-Module ServerManager

class installDomain {

    #Properties
    static [System.String]$Name = 'AD-Domain-Services'
    static [System.String]$Exception_Log = "Exception_Log.txt"

    # Constructors
    
    # Methods
    [System.String] GetFeature() 
    {
        [System.String]$feature = $this.Name
        return $feature
    }

}

$install = [installDomain]::new()
$install.GetFeature()