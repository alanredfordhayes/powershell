Import-Module ServerManager

class installDomain {

    [System.String]$Name = 'AD-Domain-Services'
    [System.DateTime]$Date = (Get-Date)
    [System.String]$Exception_Log = "Exception_Log.txt"
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
            Add-Content -Value $ErrorMessage,$FailedItem -Path $this.Exception_Log
            exit 1
        }

        return $feature
    }

}