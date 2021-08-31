$filename = "okta employee update"
$name = "update_employeetitle"
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
        catch { $Exception = $_.Exception ; "$date | $Exception " >> $log }
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

function Update_Title {
    param (
        [System.Array]$csv
    )

    $users_list = Get-AdUser -Filter * -Properties mail, employeenumber, proxyAddresses

    $csv | ForEach-Object {
        $employeenumber = $_.Employee_Number
        $employeename = $_.Employee_Name 
        $email_address = $_.Email_Address
        $user = $users_list | Where-Object -Property mail -eq $email_address
        if ($null -eq $user) {
            $email_address_array = $email_address.Split("@")
            $upn = $email_address_array[0] + "@dash.corp"
            $user = $users_list | Where-Object -Property UserPrincipalName -eq $upn
        }

        if ($null -eq $user) {
            $users_list | ForEach-Object {
                $proxyAddresses = $_.proxyAddresses
                $smtp = "smtp:$email_address"
                if ($proxyAddresses.Contains($smtp)) {
                    $user = $_
                }
            }
        } 

        if (($null -ne $user) -and ($user.gettype().basetype.name -eq "Array")) {
            $user = $user | Where-Object -Property Enabled -eq "True"
        }

        if ($user.employeenumber -ne $employeenumber) {
            if ($null -ne $user) {
                Write-Output "Updating User: $employeename"
                try { Set-AdUser $user.DistinguishedName -EmployeeNumber $employeenumber -ErrorAction Continue }
                catch { Write-Output "Error on User: $employeename" ; $Exception = $_.Exception ; "$date | $employeename | $Exception " >> $log }
            } else {
                Write-Output "Error finding: $employeename" ; "$date | $employeename | User NOT Found. " >> $log 
            }
        } else {
            Write-Output "EmployeeNumber for User: $employeename is Good."
        }
    }
    
}

function copy_ToTemp {
    param (
        [String]$filename,
        [String]$home_dir,
        [String]$downloads_dir
    )
    $local_filename_check = Get-ChildItem -Path ".\" | Where-Object -Property Name -Match $filename
    $downloads_dir_check  = Get-ChildItem -Path "$home_dir\$downloads_dir" | Where-Object -Property Name -Match $filename
    $documents_dir_check = Get-ChildItem -Path "$home_dir\$documents_dir" | Where-Object -Property Name -Match $filename

    if ($null -ne $local_filename_check) {
        $untouched_csv = $local_filename_check
    } elseif ($null -ne $downloads_dir_check) {
        $untouched_csv = $downloads_dir_check
    } elseif ($null -ne $documents_dir_check) {
        $untouched_csv = $documents_dir_check
    } else {
        Write-Output "Cannot find file to import."
        Write-Output "Please drop a file with name of $filename.csv in this directory or the following directories:"
        Write-Output ".\$filename.csv"
        Write-Output "$home_dir\$documents_dir\$filename.csv"
        Write-Output "$home_dir\$downloads_dir\$filename.csv"
        break
    }

    if ( Test-Path -Path "$home_dir\AppData\Local\Temp\$filename.csv") {
        try { Remove-Item -Path "$home_dir\AppData\Local\Temp\$name.csv" -ErrorAction Continue }
        catch { $Exception = $_.Exception ; "$date | $Exception " >> $log }
    }

    if ($untouched_csv.GetType().BaseType.FullName -eq "System.Array") {
        $untouched_csv = $untouched_csv | Sort-Object -Property LastWriteTime -Descending
        $untouched_csv[0] | Copy-Item -Destination "$home_dir\AppData\Local\Temp\$filename.csv" -Force
    } else {
        $untouched_csv | Copy-Item -Destination "$home_dir\AppData\Local\Temp\$filename.csv" -Force -
    }
    
}

copy_ToTemp -filename $filename -home_dir $home_dir -downloads_dir $downloads_dir
