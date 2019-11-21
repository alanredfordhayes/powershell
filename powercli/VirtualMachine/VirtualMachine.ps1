Import-Module VMware.PowerCLI

class VirtualMachine {

    [void]PowerCLIConfiguration(){
        Set-PowerCLIConfiguration -DefaultVIServerMode Single -Confirm:$false
        Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
    }

    [System.Object]Server(
        [String]$Server,
        [System.Management.Automation.PSCredential]$Credential
    ){
        $this.PowerCLIConfiguration()

        try

        $viServer = Connect-VIServer `
        -Server $Server `
        -Credential $Credential
        return $viServer
    }

    [System.Object]NewVMinteractive(
    ){
        function menu002 {
            param ()

            $menu002 = $null
            while ($null -eq $menu002) {
                $menu002 = Read-Host -Prompt "Choose (Cluster) or (Host) | (End) to exit"
                Write-Host ''
                $menu002 = $menu002.ToLower()
                if ($menu002 -eq 'cluster') { return $menu002 ; break }
                elseif ($menu002 -eq 'host') { return $menu002 ; break } 
                elseif ($menu002 -eq 'end') { exit } 
                else { $menu002 = $null }
            }
        }

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

        function menu004 {
            param ()

            $menu004 = $null
            while ($null -eq $menu004) {
                $menu004 = Read-Host -Prompt "Choose (VM) or (Template) | (End) to exit"
                Write-host ''
                $menu004 = $menu004.ToLower()
                if ($menu004 -eq 'vm') { return $menu004 ; break }
                elseif ($menu004 -eq 'template') { return $menu004 ; break } 
                elseif ($menu004 -eq 'end') { exit } 
                else { $menu004 = $null }
            }
        }

        function computeDictionary {
            param ()

            $dictionary = @{}
            $count = 0
            $computeSizes = @(
                @{"CPU"=1;"RAM"=2},
                @{"CPU"=1;"RAM"=4},
                @{"CPU"=2;"RAM"=4},
                @{"CPU"=2;"RAM"=8},
                @{"CPU"=4;"RAM"=8},
                @{"CPU"=4;"RAM"=16},
                @{"CPU"=8;"RAM"=16},
                @{"CPU"=8;"RAM"=32}
            )
            Write-Host 'Select a Compute Size Below:'
            $computeSizes | ForEach-Object {
                $count = $count + 1
                $computeSize = $_
                $dictionary.Add($count, $computeSize)
                Write-Host ($count, "  CPU :"+$computeSize['CPU'], "  RAM :"+$computeSize['RAM'])
            }
            return $dictionary
        }

        function hostDictionary {
            param ()

            $dictionary = @{}
            $count = 0
            $vmHosts = Get-VMHost
            Write-Host 'Select a VMhost Below:'
            $vmHosts | ForEach-Object {
                $count = $count + 1
                $vmhost = $_
                $dictionary.Add($count, $vmhost)
                Write-Host ($count, $vmhost)
            }
            return $dictionary
        }

        function clusterDictionary {
            param ()

            $dictionary = @{}
            $count = 0
            $vmClusters = Get-Cluster
            Write-Host 'Select a Cluster Below:'
            $vmClusters | ForEach-Object {
                $count = $count + 1
                $vmCluster = $_
                $dictionary.Add($count, $vmCluster)
                Write-Host ($count, $vmCluster)
            }
            return $dictionary
        }

        function templateDictionary {
            param ()

            $dictionary = @{}
            $count = 0
            $vmTemplates = Get-Template
            Write-Host 'Select a Template Below:'
            $vmTemplates | ForEach-Object {
                $count = $count + 1
                $vmTemplate = $_
                $dictionary.Add($count, $vmTemplate)
                Write-Host ($count, $vmTemplate)
            }
            return $dictionary
        }

        function vmDictionary {
            param ()

            $dictionary = @{}
            $count = 0
            $vms = Get-VM
            Write-Host 'Select a VM Below:'
            $vms | ForEach-Object {
                $count = $count + 1
                $vm = $_
                $dictionary.Add($count, $vm)
                Write-Host ($count, $vm)
            }
            return $dictionary
        }

        function resourcePoolDictionary {
            param (
                [System.Object]$resource
            )

            $dictionary = @{}
            $count = 0
            $vmResourcePools = $resource | Get-ResourcePool
            Write-Host 'Select a Resource Pool Below:'
            $vmResourcePools | ForEach-Object {
                $count = $count + 1
                $vmResourcePool = $_
                $dictionary.Add($count, $vmResourcePool)
                Write-Host ($count, $vmResourcePool)
            }
            return $dictionary
        }

        function datastoreDictionary {
            param (
                [System.Object]$resource
            )

            $dictionary = @{}
            $count = 0
            $vmDatastores = $resource | Get-Datastore
            Write-Host 'Select a Datastore Below:'
            $vmDatastores | ForEach-Object {
                $count = $count + 1
                $vmDatastore = $_
                $dictionary.Add($count, $vmDatastore)
                Write-Host ($count, $vmDatastore)
            }
            return $dictionary
        }

        function VmName {
            param ()

            $read = Read-Host -Prompt 'Enter VM (Name) | (End) to exit'
            Write-Host ''
            $read = $read.ToLower()
            if ($read.Length -eq 0) { exit }
            elseif ($read -eq 'end') { exit }
            else { return $read }
        }

        function nullVMname {
            param (
                [System.String]$name
            )

            try { $vm = Get-VM -Name $name -ErrorAction Stop }
            catch { return $name }
            if ($vm.Length -gt 0) { Write-Host "$name Exists" ; exit }
        }

        $vm = $null
        while ($null -eq $vm) {
            Write-Host ''
            $menu001 = Read-Host -Prompt '(New) or (Clone) VM | (End) to exit'
            Write-Host ''
            $menu001 = $menu001.ToLower()
            if ($menu001 -eq 'new'){
                $name = VmName
                $name = nullVMname -name $name
                $menu002 = menu002
                $locationDictionary = $null
                $type = $null
                if ($menu002 -eq 'host') { $locationDictionary = hostDictionary; $type = 'host' } 
                elseif ($menu002 -eq 'cluster') { $locationDictionary = clusterDictionary ; $type = 'cluster' }
                $location = menu003 -dictionary $locationDictionary
                $datastoreDictionary = datastoreDictionary -resource $location
                $datastore = menu003 -dictionary $datastoreDictionary
                $computeDictionary = computeDictionary
                $compute = menu003 -dictionary $computeDictionary
                if ($type -eq 'host') { 
                    $vm = New-VM -VMHost $location -Name $name -Datastore $datastore -NumCpu $compute['CPU'] -MemoryGB $compute['RAM'] -Confirm:$true 
                }
                else { 
                    $resourcePoolDictionary = resourcePoolDictionary -resource $location
                    $location = menu003 -dictionary $resourcePoolDictionary
                    $vm = New-VM -ResourcePool $location -Name $name -Datastore $datastore -NumCpu $compute['CPU'] -MemoryGB $compute['RAM'] -Confirm:$true
                }
            } elseif ($menu001 -eq 'clone') {
                $menu004 = menu004
                $typeDictionary = $null
                $source = $null
                if ($menu004 -eq 'vm') { $typeDictionary = vmDictionary ; $source = 'vm'} 
                elseif ($menu004 -eq 'template') { $typeDictionary = templateDictionary ; $source = 'template' }
                $typeVM = menu003 -dictionary $typeDictionary
                $name = VmName
                $name = nullVMname -name $name
                $menu002 = menu002
                $locationDictionary = $null
                $type = $null
                if ($menu002 -eq 'host') { $locationDictionary = hostDictionary; $type = 'host' } 
                elseif ($menu002 -eq 'cluster') { $locationDictionary = clusterDictionary ; $type = 'cluster' }
                $location = menu003 -dictionary $locationDictionary
                $datastoreDictionary = datastoreDictionary -resource $location
                $datastore = menu003 -dictionary $datastoreDictionary
                $computeDictionary = computeDictionary
                $compute = menu003 -dictionary $computeDictionary
                if ($source -eq 'vm') {
                    if ($type -eq 'host') { 
                        $vm = New-VM -VM $typeVM -VMHost $location -Name $name -Datastore $datastore -Confirm:$true
                        Set-VM -VM $vm -NumCpu $compute['CPU'] -MemoryGB $compute['RAM'] -Confirm:$false 
                    }
                    else { 
                        $resourcePoolDictionary = resourcePoolDictionary -resource $location
                        $location = menu003 -dictionary $resourcePoolDictionary
                        $vm = New-VM -VM $typeVM -ResourcePool $location -Name $name -Datastore $datastore -Confirm:$true
                        Set-VM -VM $vm -NumCpu $compute['CPU'] -MemoryGB $compute['RAM'] -Confirm:$false 
                    }
                }
                else {
                    if ($type -eq 'host') { 
                        $vm = New-VM -Template $typeVM -VMHost $location -Name $name -Datastore $datastore -Confirm:$true
                        Set-VM -VM $vm -NumCpu $compute['CPU'] -MemoryGB $compute['RAM'] -Confirm:$false 
                    }
                    else { 
                        $resourcePoolDictionary = resourcePoolDictionary -resource $location
                        $location = menu003 -dictionary $resourcePoolDictionary
                        $vm = New-VM -Template $typeVM -ResourcePool $location -Name $name -Datastore $datastore -Confirm:$true
                        Set-VM -VM $vm -NumCpu $compute['CPU'] -MemoryGB $compute['RAM'] -Confirm:$false 
                    }
                }
            }
            elseif ($menu001 -eq 'end') { $vm = 'Canceled Request' }
        }

        return $vm
    }
}
