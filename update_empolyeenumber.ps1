$name = "update_employeenumber"
$date = Get-Date
$log = "$name.txt"
$home_dir = "~"
$documents_dir = "Documents" 
$downloads_dir = "Downloads"
$local_csv_path = ".\$name.csv"
$document_csv_path = "$home_dir\$documents_dir\$name.csv"
$download_csv_path = "$home_dir\$downloads_dir\$name.csv"

function Import_CSV {
    param (
        [String]$name,
        [System.DateTime]$date,
        [String]$log,
        [String]$home_dir,
        [String]$documents_dir,
        [String]$downloads_dir,
        [String]$local_csv_path,
        [String]$document_csv_path,
        [String]$download_csv_path
    )
    
    if ( Test-Path -Path $local_csv_path ) { $csv_path = $local_csv_path } 
    elseif ( Test-Path -Path $document_csv_path  ) { $csv_path = $document_csv_path } 
    elseif ( Test-Path -Path $download_csv_path ) { $csv_path = $download_csv_path } 
    else {
        Write-Output "Cannot find file to import."
        Write-Output "Please drop a file with name of $name.csv in this directory or the following directories:"
        Write-Output ".\$name.csv"
        Write-Output "$home_dir\$downloads\$name.csv"
        Write-Output "$home_dir\$documents_dir\$name.csv"
        Write-Output "$home_dir\$downloads_dir\$name.csv"
        break
    }
    
    $csv_content = Get-Content -Path $csv_path -First 1
    $csv_content | ForEach-Object {
        $line = $_
        $first_line = Get-Content -Path $csv_path -First 1
        if ($line -eq $first_line){ 
            $line = $line.Replace(" ","_")
            $line > "$home_dir\$documents_dir\$name.csv"
        } else {
            $line >> "$home_dir\$documents_dir\$name.csv"
        }
    }

    $csv = Import-Csv $name.csv
    return $csv

}

$csv = Import_CSV -name $name -date $date -log $log -home_dir $home_dir -documents_dir $documents_dir -downloads_dir $downloads_dir -local_csv_path $local_csv_path -document_csv_path $document_csv_path -download_csv_path $download_csv_path

$csv