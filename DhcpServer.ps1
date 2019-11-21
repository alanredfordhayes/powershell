Import-Module -Name 'DhcpServer'

class RemoteDhcpServer {

    [System.Object]NewSession(
        [string]$ComputerName
    )
    {
        try { $CimSession = New-CimSession -ComputerName $ComputerName -Name 'dhcpServer' -Credential (Get-Credential) }
        catch { $_.Exception.Message ; exit }
        return $CimSession
    }

    [void]RemoveSession(){
        Get-CimSession | Remove-CimSession
    }

    [System.Object]AuditLog(
        [string]$ComputerName,
        [System.Object]$CimSession
        )
    {
        $DhcpServerAuditLog = Get-DhcpServerAuditLog -ComputerName $ComputerName -CimSession $CimSession
        return $DhcpServerAuditLog
    }

    [System.Object]ScopesList(
        [string]$ComputerName,
        [System.Object]$CimSession
    )
    {
        try { $dhcpServerv4Scopes = Get-DhcpServerv4Scope -ComputerName $ComputerName -CimSession $CimSession -ErrorAction Stop }
        catch { Write-Output $_.Exception.Message ; exit }
        if ($null -eq $dhcpServerv4Scopes) {exit}
        $scopes = $dhcpServerv4Scopes | Select-Object -Property ScopeId, Name, State, StartRange, EndRange
        return $scopes
    }

    [System.Object]LeasesList(
        [string]$ComputerName,
        [string]$ScopeId,
        [System.Object]$CimSession
    )
    {
        try { $leases = Get-DhcpServerv4Lease -ComputerName $ComputerName -ScopeId $ScopeId -AllLeases -CimSession $CimSession -ErrorAction Stop }
        catch { Write-Output $_.Exception.Message ; exit }
        if ( $null -eq $leases ) { exit }
        return $leases
    }

    [System.Object]FindLeaseInteractively(
        [string]$ComputerName,
        [System.Object]$CimSession
    )
    {
        function menu003 {
            param (
                [System.Object]$dictionary
            )

            $prompt = 'Select Key (1 to num) for Value | (End) to exit'
            $prompt = $prompt -replace 'num',$dictionary.Count 
            $read = Read-Host -Prompt $prompt
            $read = [int]$read
            if ($read -eq 0) { Write-Host $read ; exit } 
            elseif ( $read -gt $dictionary.Count ) { Write-Host $read ; exit } 
            elseif ( $read -eq 'end') { exit }
            else { $value = $dictionary[$read] }
            Write-Host 'Selected' $read 'for' $value
            Write-Host ""
            return $value
        }


        function scopesDictionary {
            param (
                [string]$ComputerName,
                [System.Object]$CimSession    
            )
            
            $scopes = $this.ScopesList($ComputerName, $CimSession)
            $count = 0
            $hash = @{}
            $scopes | ForEach-Object {
                $count = $count + 1
                $scope = $_
                $hash.Add($count, $scope)
                Write-Host ($count, $scope.Name)
            }

            return $hash
        }

        function leaseDictionary {
            param (
                [string]$ComputerName,
                [string]$ScopeId,
                [system.object]$CimSession
            )
            
            $DhcpServerv4Leases = $this.LeasesList($ComputerName, $ScopeId, $CimSession)
            $count = 0
            $hash = @{}
            $DhcpServerv4Leases | ForEach-Object {
                $count = $count + 1
                $lease = $_
                $lease = $lease | Select-Object -Property IPAddress, ClientId, HostName, AddressState
                $hash.Add($count, $lease)
                Write-Host ($count, $lease.HostName)
            }

            return $hash
        }

        $scopesDictionary = scopesDictionary -ComputerName $ComputerName -CimSession $CimSession
        $scope = menu003 -dictionary $scopesDictionary
        $leaseDictionary = leaseDictionary -ComputerName $ComputerName -ScopeId $scope.ScopeId -CimSession $CimSession
        $lease = menu003 -dictionary $leaseDictionary

        return $lease
    }

}

Clear-Host
$s = [RemoteDhcpServer]::new()
$ComputerName = Read-Host -Prompt 'DHCP Server Name'
$CimSession = $s.NewSession($ComputerName)
$FindLease = $s.FindLeaseInteractively($ComputerName,$CimSession)
$FindLease
$s.RemoveSession()