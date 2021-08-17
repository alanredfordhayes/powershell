$name = update_employeenumber
$date = Get-Date
$log = "$name.txt"
$home_dir = "~"
$documents_dir = "Documents" 
$downloads_dir = "Downloads"


if ( -f $name.csv ) {
    try { Import-Csv -Path ".\$name.csv" -ErrorAction Continue
    } catch { $date + $_.Exception >> $log }
} elseif ( -f "$home_dir\$documents_dir\$name.csv" ) {
    try { Import-Csv -Path "$home_dir\$documents_dir\$name.csv" -ErrorAction Continue
    } catch { $date + $_.Exception >> $log }   
} elseif ( -f "$home_dir\$downloads\$name.csv" ) {
    try { Import-Csv -Path "$home_dir\$downloads_dir\$name.csv" -ErrorAction Continue } 
    catch { $date + $_.Exception >> $log }
}