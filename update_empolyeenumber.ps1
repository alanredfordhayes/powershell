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
    
    if ( Test-Path -Path "$home_dir\AppData\Local\Temp\$name.csv") {
        try { Remove-Item -Path "$home_dir\AppData\Local\Temp\$name.csv" -ErrorAction Continue }
        catch { $date >> $log ; $_.Exception >> $log ; "" >> $log }
    }

    $csv_content = Get-Content -Path $csv_path
    $csv_content | ForEach-Object {
        $line = $_
        $first_line = Get-Content -Path $csv_path -First 1
        if ($line -eq $first_line){ 
            $line = $line.Replace(" ","_")
            $lineArray = $line.Split(",")
            $employee_Name = $lineArray[1]
            $employee_NameArray = $Employee_Name.Split("_")
            $employee_Name = $employee_NameArray[0].substring(1) + "_" + $employee_NameArray[1]
            $line = $lineArray[0] + "," + $Employee_Name + "," + $lineArray[3] + "," + $lineArray[4] + "," + $lineArray[5]
        } 

        $line >> "$home_dir\AppData\Local\Temp\$name.csv"
    }

    $csv = Import-Csv "$home_dir\AppData\Local\Temp\$name.csv"
    return $csv

}

function Update_EmployeeNumber {
    param (
        [System.Array]$csv
    )

    $users_list = Get-AdUser -Filter * -Properties mail, employeenumber

    $csv | ForEach-Object {
        $employeenumber = $_.Employee_Number
        $employeename = $_.Employee_Name 
        $email_address = $_.Email_Address
        $user = $users_list | Where-Object -Property mail -eq $email_address
        $user
        if ($user.employeenumber -ne $employeenumber) {
            $user
            Write-Output "Updating User: $employeename"
            try { Set-AdUser $user.DistinguishedName -EmployeeNumber $employeenumber -ErrorAction Continue }
            catch { Write-Output "Error on User: $employeename" ; $date >> $log ; $_.Exception >> $log ; "" >> $log }
        } else {
            Write-Output "EmployeeNumber for User: $employeename is Good."
        }
    }
    
}

$csv = Import_CSV -name $name -date $date -log $log -home_dir $home_dir -documents_dir $documents_dir -downloads_dir $downloads_dir -local_csv_path $local_csv_path -document_csv_path $document_csv_path -download_csv_path $download_csv_path
Update_EmployeeNumber -csv $csv