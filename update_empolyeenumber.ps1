$name = "update_employeenumber"
$date = Get-Date
$log = "$name.txt"
$home_dir = "~"
$documents_dir = "Documents" 
$downloads_dir = "Downloads"

function Import_CSV {
    param (
        [String]$name,
        [System.DateTime]$date,
        [String]$log,
        [String]$home_dir,
        [String]$documents_dir,
        [String]$downloads_dir
    )
    
    if ( Test-Path -Path ".\$name.csv" ) {
        try { $csv = Import-Csv -Path ".\$name.csv" -ErrorAction Continue
        } catch { $date + $_.Exception >> $log }
    } elseif ( Test-Path -Path "$home_dir\$documents_dir\$name.csv" ) {
        try { $csv = Import-Csv -Path "$home_dir\$documents_dir\$name.csv" -ErrorAction Continue
        } catch { $date + $_.Exception >> $log }   
    } elseif ( Test-Path -Path "$home_dir\$downloads_dir\$name.csv" ) {
        try { $csv = Import-Csv -Path "$home_dir\$downloads_dir\$name.csv" -ErrorAction Continue } 
        catch { $date + $_.Exception >> $log }
    } else {
        Write-Output "Cannot find file to import."
        Write-Output "Please drop a file with name of $name.csv in this directory or the following directories:"
        Write-Output ".\$name.csv"
        Write-Output "$home_dir\$downloads\$name.csv"
        Write-Output "$home_dir\$documents_dir\$name.csv"
        Write-Output "$home_dir\$downloads_dir\$name.csv"
        break
    }
    
    return $csv

}

Import_CSV -name $name -date $date -log $log -home_dir $home_dir -documents_dir $documents_dir -downloads_dir $downloads_dir

