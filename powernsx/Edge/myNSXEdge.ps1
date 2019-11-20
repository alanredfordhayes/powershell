Param
(
  # Param1 help description
  [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position=1)]
  [string]$csv_name

)
Begin
{
  #
  function PG_ConnectedTo
  ($ConnectedTo, $clusterName) {
    if ($ConnectedTo.Length -eq 0) { "Set ConnectedTo for VDPortgroup" ; "Exiting..." ; Exit 1 }
    else { $ConnectedToPG = Get-Cluster $clusterName | Get-VMHost | Get-VDSwitch | Get-VDPortgroup | Where-Object {$_.name -match "$ConnectedTo"} }
    if ($ConnectedToPG.Length -eq 0) { "ConnectedTo[$ConnectedTo] not found" ;  "Exiting..." ;  Exit 1 }
    else { return $ConnectedToPG }
  }


  function LS_ConnectedTo
  ($ConnectedTo) {
    if ($ConnectedTo.Length -eq 0) { "Set ConnectedTo for Logical Switch" ; "Exiting..." ; Exit 1 }
    else { $ConnectedToPG = Get-NsxLogicalSwitch | Where-Object {$_.name -match "$ConnectedTo"} }
    if ($ConnectedToPG.Length -eq 0) { "ConnectedTo[$ConnectedTo] not found" ;  "Exiting..." ;  Exit 1 }
    else { return $ConnectedToPG }
  }

  function CheckPrimaryAddress
  ($CheckPrimaryAddress)
  {
    if ($CheckPrimaryAddress.Length -eq 0) { "Set PrimaryAddress" ; "Exiting..." ; Exit 1 }
    else {
      $CheckPrimaryAddressArray = $CheckPrimaryAddress.split('.')
      if ($CheckPrimaryAddressArray.Length -ne 4) { "PrimaryAddress not correctly set '111.222.333.444'" ;  "Exiting..." ; Exit 1 }
      else { Return $CheckPrimaryAddress }
    }
  }


  function CheckSubnetPrefixLength
  ($CheckSubnetPrefixLength)
  {
    if ($CheckSubnetPrefixLength.Length -eq 0) { "Set SubnetPrefixLength" ; "Exiting..." ; Exit 1 }
    else {
      if ($CheckSubnetPrefixLength.Length -gt 2) { "SubnetPrefixLength should be 2 digits or less" ; "Exiting..." ; Exit 1}
      elseif (([int]::TryParse($CheckSubnetPrefixLength, [ref]2)) -eq $false) { "SubnetPrefixLength should be a number" ; "Exiting..." ; Exit 1 }
      else { return $CheckSubnetPrefixLength }
    }
  }


  function checkdatastore
  ($datastore, $clusterName)
  {
    if ($datastore.Length -eq 0) { "Set datastore" ; "Exiting..." ; Exit 1 }
    else { $datastore = Get-Cluster $clusterName  | Get-Datastore | where-object { $_.Name -match $datastore}
      if ($datastore.Length -eq 0) { "Datastore not found" ; "Exiting..." ; Exit 1 }
    }
    return $datastore
  }


  function checkformFactor
  ($formFactor)
  {
    if ($formFactor.Length -eq 0) { "Set formFactor" ; "Exiting..." ; Exit 1 }
    else {
      if (($formFactor -ne "compact") -and ($formFactor -ne "large") -and ($formFactor -ne "quadlarge") -and ($formFactor -ne "xlarge")) { "FormFactor not found" ; "Exiting..." ; Exit 1 }
      else { return $formfactor }
    }
  }


  function checkvmFolder
  ($vmFolder)
  {
    if ($vmFolder.Length -eq 0) { $vmFolder = Get-Folder | Where-Object { $_.Name -eq "Discovered virtual machine" } }
    else { $vmFolder = Get-Folder | Where-Object { $_.Name -match $vmFolder }
      if ($vmFolder.Length -eq 0) { $vmFolder = Get-Folder | Where-Object { $_.Name -eq "Discovered virtual machine" } }
    }
    return $vmFolder
  }


  try {$csv = Get-Item "C:\Users\ahayes\Documents\CSVs\$csv_name.csv" -ErrorAction Stop }
  catch { "Cannot find file $csv_name.csv" ; Exit 1 }


  $csv = Import-Csv $csv
  foreach ($line in $csv) {


    $name = $line.name
    $resourcePool = $line.resourcePool
    $cluster = $line.cluster
    $datastore = $line.datastore
    $username = $line.username
    $password = $line.password
    $formFactor = $line.formFactor
    $vmFolder = $line.vmFolder
    $tenant = $line.tenant
    $uplinkConnectedTo = $line.uplinkConnectedTo
    $uplinkPrimaryAddress	= $line.uplinkPrimaryAddress
    $uplinkSubnetPrefixLength	= $line.uplinkSubnetPrefixLength
    $downlinkConnectedTo = $line.downlinkConnectedTo
    $downlinkPrimaryAddress	= $line.downlinkPrimaryAddress
    $downlinkSubnetPrefixLength = $line.downlinkSubnetPrefixLength


    $filterEdge = Get-NsxEdge | Where-Object { $_.name -eq $name }
    if ($filterEdge.Length -eq 0) {
      if (($resourcePool.Length -eq 0 ) -and ($cluster.Length -eq 0)) {
        "Set resourcePool or cluster"
        "Exiting..."
        Exit 1
      }
      else {
        if ($resourcePool.Length -gt 0 ) {
          $resourcePool = Get-ResourcePool | where-object { $_.Name -match $resourcePool }
          if ($resourcePool.Length -eq 0) { "resourcePool not found" ; "Exiting..." ; Exit 1 }
          $clusterName = Get-Cluster | Get-ResourcePool | Where-Object {$_.Name -match "$resourcePool"} | Select-Object @{Name="Name"; Expression={$_.Parent.Name}}
        }
        elseif ($cluster.Length -gt 0 ) {
          $cluster = Get-Cluster | where-object { $_.Name -match $cluster }
          if ($cluster.Length -eq 0) { "Cluster not found" ; "Exiting..." ; Exit 1 }
          $clusterName = $cluster.Name
        }


        $cluster = Get-Cluster $clusterName
        $uplinkConnectedToPG = PG_ConnectedTo $uplinkConnectedTo $clusterName
        $uplinkPrimaryAddress = CheckPrimaryAddress $uplinkPrimaryAddress
        $uplinkSubnetPrefixLength = CheckSubnetPrefixLength $uplinkSubnetPrefixLength
        $downlinkConnectedToPG = LS_ConnectedTo $downlinkConnectedTo
        $downlinkPrimaryAddress = CheckPrimaryAddress $downlinkPrimaryAddress
        $downlinkSubnetPrefixLength = CheckSubnetPrefixLength $downlinkSubnetPrefixLength
        $datastore = checkdatastore $datastore $clusterName
        if ($username.Length -eq 0) { $username = "admin" }
        if ($password.Length -eq 0) { $password = -join (33..126 | ForEach-Object {[char]$_} | Get-Random -Count 20) }
        $formFactor = checkformFactor $formFactor
        $vmFolder = checkvmFolder $vmFolder


        $uplink = New-NsxEdgeInterfaceSpec -Index 0 -Name 'uplink' -Type 'uplink' -ConnectedTo ($uplinkConnectedToPG) -PrimaryAddress $uplinkPrimaryAddress -SubnetPrefixLength $uplinkSubnetPrefixLength
        $downlink = New-NsxEdgeInterfaceSpec -Index 1 -Name 'downlink' -Type 'internal' -ConnectedTo ($downlinkConnectedToPG) -PrimaryAddress $downlinkPrimaryAddress -SubnetPrefixLength $downlinkSubnetPrefixLength


        $nsxEdge = Get-NsxEdge | Where-Object {$_.Name -eq $name}
        if ($nsxEdge.Length -eq 0) {
          New-NsxEdge -Name $name -Interface $uplink,$downlink -Cluster $cluster -Datastore $datastore -Username $username -Password $password -FormFactor $formFactor -VMFolder $vmFolder -EnableSSH:$true -Hostname $name -AutoGenerateRules:$true -FwDefaultPolicyAllow:$true -FwEnabled:$true -FwLoggingEnabled:$true -EnableHa:$true -HaVnic 1
          Get-Date >> .\log.txt
          $username >> .\log.txt
          $password >> .\log.txt
        }
      }
    }
  }
}

Process
{
}
End
{
}
