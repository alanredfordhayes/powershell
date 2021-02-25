Import-Module ActiveDirectory

class myActiveDirectory {
    
    [System.Object]Credentials()
    {
        Write-Output "Info: Reading Username from prompt."
        try {
            $username = Read-Host `
            -Prompt 'Username' `
            -ErrorAction Stop `
            -Verbose
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.GetType().FullName
            Write-Output "Error: Reading Username from prompt." 
            Write-Debug "Failed Item: $FailedItem" 
            Write-Debug "ErrorMessage: $ErrorMessage"
            Write-Output "Warning: Please investigate."
            Write-Output "Error: Contact System Administrators"
            exit 1
        }

        Write-Output "Info: Retrieving Password"
        
        try {
            $rawPassword = (
                Get-Credential `
                -UserName $username `
                -Message "Password for $username" `
                -ErrorAction Stop `
                -Verbose
            ).Password    
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.GetType().FullName
            Write-Output "Error: Retrieving Password" 
            Write-Debug "Failed Item: $FailedItem" 
            Write-Debug "ErrorMessage: $ErrorMessage"
            Write-Output "Warning: Please investigate."
            Write-Output "Error: Contact System Administrators"
            exit 1    
        }
        

        Write-Output "Info: Converting String To Secured String"
        try {
            $password = ConvertTo-SecureString `
            -String $rawPassword `
            -AsPlainText `
            -Force `
            -ErrorAction Stop `
            -Verbose
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.GetType().FullName
            Write-Output "Error: Converting String To Secured String" 
            Write-Debug "Failed Item: $FailedItem" 
            Write-Debug "ErrorMessage: $ErrorMessage"
            Write-Output "Warning: Please investigate."
            Write-Output "Error: Contact System Administrators"
            exit 1
        }

        Write-Output "Info: Creating PsCredential"
        try {
            [PSCredential]$credentials =  New-Object System.Management.Automation.PSCredential (
                $userName,
                $password
            ) `
            -ErrorAction Stop `
            -Verbose
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.GetType().FullName
            Write-Output "Error: Creating PsCredential" 
            Write-Debug "Failed Item: $FailedItem" 
            Write-Debug "ErrorMessage: $ErrorMessage"
            Write-Output "Warning: Please investigate."
            Write-Output "Error: Contact System Administrators"
            exit 1
        }
        
        return $credentials 
    }

    [System.Object]ADUser($Credentials)
    {
        $username = $Credentials['Username']
        $password = $Credentials['Password']
        $ADCredentials = New-Object System.Management.Automation.PSCredential($username, $password)
        $AdUserName = Read-Host -Prompt 'User First Name'
        $ADLastName = Read-Host -Prompt 'User Last Name'
        $AdUserName = $AdUserName.ToLower()
        $ADLastName = $ADLastName.ToLower()
        $num = [int]$AdUserName.Length -1
        $AdUserName = $AdUserName.TrimEnd($num)
        
        return $AdUserName
    }

    [System.Object]AdUserADAccountAuthorizationGroup()
    {

        function get {
            $Identity = Get-ADUser 
            $ADAccountAuthorizationGroup = Get-ADAccountAuthorizationGroup -Identity $Identity
            return $ADAccountAuthorizationGroup
        }

        $ADAccountAuthorizationGroup = get
        return $ADAccountAuthorizationGroup
    }
}

$a = [myActiveDirectory]::new()
$Credentials = $a.Credentials()
$Credentials