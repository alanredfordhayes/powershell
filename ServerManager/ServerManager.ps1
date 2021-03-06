Import-Module ServerManager

class installTestDomain {

    [System.String]$Name = 'AD-Domain-Services'
    [System.DateTime]$Date = (Get-Date)
    [System.String]$Log = "log.txt"

    [System.Object]GetFeature(
        [String]$Name
    ) 
    {

        try {
            $feature = Get-WindowsFeature `
            -Name $this.Name `
            -ErrorAction Stop `
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.GetType().FullName
            Add-Content -Value $ErrorMessage,$FailedItem -Path $this.Log
            exit 1
        }

        return $feature
    }

}