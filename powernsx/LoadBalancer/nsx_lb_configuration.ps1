$path = 'C:\Users\ahayes\Documents\CSVs\nsx_lb_configuration.csv'
$csvs = Import-Csv -Path $path


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
($name, $Url, $type, $Interval, $Timeout, $MaxRetries, $Method)
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
  $array = $Url.split('.')
  $mon_name = $array -join '_'
  $lbmon = Get-NsxEdge $name | Get-NsxLoadBalancer
  $mon = $lbmon | Get-NsxLoadBalancerMonitor | Where-Object {$_.Name -eq $mon_name}
  if ($mon -eq $null) {
    if ($type -eq 'Https') { $mon = $lbmon | New-NsxLoadBalancerMonitor -Name $mon_name -TypeHttps:$true -Interval $Interval -Timeout $Timeout -MaxRetries $MaxRetries -Method $Method -Url $Url }
    elseif ($type -eq 'Http') { $mon = $lbmon | New-NsxLoadBalancerMonitor -Name $mon_name -TypeHttp:$true -Interval $Interval -Timeout $Timeout -MaxRetries $MaxRetries -Method $Method -Url $Url }
  }
  return $mon

}


Function poolslb
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

}


foreach ($csv in $csvs) {
  $enlb = enableLB -name $csv.name
  $monitor = monitorlb -name $csv.name -Url $csv.mon_url -type $csv.mon_type -Interval $csv.mon_interval -Timeout $csv.mon_timeout -MaxRetries $csv.mon_maxretries -Method $csv.mon_method
}


$pools = @()
foreach ($pool in $csvs.pool) {
  if ($pools.Contains($pool) -eq $false) {
    $pools += $pool
  }
}


foreach ($pool in $pools) {
  $pool
}
