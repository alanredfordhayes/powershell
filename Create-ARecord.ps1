

configuration create_Arecord
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Name,
        [Parameter(Mandatory)]
        [String]$Target,
        [Parameter(Mandatory)] [ValidateSet('Arecord','CName','Ptr')]
        [String]$Type,
        [Parameter(Mandatory)]
        [String]$Zone,
        [Parameter()] [ValidateNotNullOrEmpty()]
        [String]$Ensure = "Present"
    )


    Import-DscResource -module xDnsServer
    xDnsRecord TestRecord
    {
        Name = $Name
        Target = $Target
        Zone = $Zone
        Type = $Type
        Ensure = $Ensure
    }
}



$csv = Import-Csv -Path C:\Users\Public\Downloads\dns_objects_dsc.csv

foreach ($line in $csv ) {  create_Arecord -Name $line.Name -Target $line.Target -Type $line.Type -Zone $line.Zone -OutputPath .\Test\$line.name  }