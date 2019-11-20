$path = 'C:\Users\ahayes\Documents\CSVs\nsx_lb.csv'
$csv = Import-Csv -Path $path


Function myInterface
  ($name, $ConnectedTo, $PrimaryAddress, $SubnetPrefixLength, $Index)
  {
    <#
    .SYNOPSIS
      Short description

    .DESCRIPTION
      Long description

    .OUTPUTS
      The value returned by this cmdlet

    .EXAMPLE
      Example of how to use this cmdlet

    .LINK
      To other relevant cmdlets or help
    #>

    $ConnectedTo = Get-VDPortgroup | Where-Object {$_.Name -match $ConnectedTo}
    if ($ConnectedTo.Length -lt 1) { exit 1 }

    if ($name -eq 'uplink') { $type = 'uplink' }
    else { $type = 'internal' }

    $interface = New-NsxEdgeInterfaceSpec -Index $Index -Name $name -Type $type -ConnectedTo $ConnectedTo -PrimaryAddress $PrimaryAddress -SubnetPrefixLength $SubnetPrefixLength -Connected:$true
    return $interface
  }


Function myNSXedge
  ($name, $formFactor, $uplink, $ha)
  {
    <#
    .SYNOPSIS
      Short description

    .DESCRIPTION
      Long description

    .OUTPUTS
      The value returned by this cmdlet

    .EXAMPLE
      Example of how to use this cmdlet

    .LINK
      To other relevant cmdlets or help
    #>
    $resourcePool = Get-ResourcePool | Where-Object {$_.Name -match 'Resources'}
    $datastore = Get-Datastore | Where-Object {$_.Name -match 'vsan'}
    $filter = Get-NsxEdge | Where-Object {$_.Name -eq $name }
    if ($filter -eq $null) {
      New-NsxEdge -Interface $uplink,$ha -Name $name -ResourcePool $resourcePool -Datastore $datastore -FormFactor $formFactor -HaVnic 9 -FwEnabled:$true -FwDefaultPolicyAllow:$true -FwLoggingEnabled:$true -EnableHa:$true -AutoGenerateRules:$true -EnableSSH:$true
    }
  }


Function enableLB
($name)
{
  <#
  .SYNOPSIS
    Short description

  .DESCRIPTION
    Long description

  .OUTPUTS
    The value returned by this cmdlet

  .EXAMPLE
    Example of how to use this cmdlet

  .LINK
    To other relevant cmdlets or help
  #>

  $lb = Get-NsxEdge $name | Get-NsxLoadBalancer
  if ($lb.enabled -eq 'false') { $enlb = $lb | Set-NsxLoadBalancer -Enabled:$true -LogLevel info -EnableLogging:$true }
  else { $enlb = $lb }
  return $enlb
}


Function monitorlb
($name)
{
  <#
  .SYNOPSIS
    Short description

  .DESCRIPTION
    Long description

  .OUTPUTS
    The value returned by this cmdlet

  .EXAMPLE
    Example of how to use this cmdlet

  .LINK
    To other relevant cmdlets or help
  #>
  $mon = Get-NsxEdge $name | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor
  $mon
}


$uplink = myInterface -ConnectedTo $csv.UplinkConnectedTo -PrimaryAddress $csv.UplinkPrimaryAddress -SubnetPrefixLength $csv.UplinkSubnetPrefixLength -Index 1 -name uplink
$ha = New-NsxEdgeInterfaceSpec -Name 'ha' -Index 9 -ConnectedTo (Get-VDPortgroup | Where-Object {$_.Name -match 'mgmt'})
$lb = myNSXedge -name $csv.name -formFactor $csv.formfactor -uplink $uplink -ha $ha
$enlb = enableLB -name $csv.name
$monitor = monitorlb -name $csv.name
$monitor
