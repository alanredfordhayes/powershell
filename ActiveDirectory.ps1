Import-Module ActiveDirectory

class myActiveDirectory {
    

    [System.Object]Credentials()
    {
        $username = Read-Host -Prompt 'Username'
        try { $password = (Get-Credential -UserName $username -Message "Password for $username").Password | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop }
        catch { $_.Exception.Message ; exit}
        $credentials = @{"Username"=$username;"Password"=$password}
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
$ADUser = $a.ADUser($Credentials)
$ADUser