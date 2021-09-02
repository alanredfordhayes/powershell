$filename = "okta employee update"
$name = "update_employeetitle"
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
        [String]$filename
    )

    if ( Test-Path -Path "$home_dir\AppData\Local\Temp\$name.csv") {
        try { Remove-Item -Path "$home_dir\AppData\Local\Temp\$name.csv" -ErrorAction Continue }
        catch { $Exception = $_.Exception ; "$date | $Exception " >> $log }
    }

    $csv_content = Get-Content -Path "$home_dir\AppData\Local\Temp\$filename.csv"
    $csv_content | ForEach-Object {
        $line = $_
        $first_line = Get-Content -Path "$home_dir\AppData\Local\Temp\$filename.csv" -First 1
        if ($line -eq $first_line){ 
            $line = $line.Replace(" ","_")
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

    $ADUsers = Get-ADUser -Filter * -Properties mail, Title

    $csv | ForEach-Object {
        $csv_email_address = $_.Email_Address
        $csv_title = $_.Job_Title
        $csv_employee_name = $_.Employee_Name
        $aduser = $ADUsers | Where-Object -Property mail,Title -EQ $csv_email_address
        if ($null -ne $aduser) {
            $bool_employee_title = $aduser.Title -ne $csv_title
            if ($aduser.Title -ne $csv_title) { 
                Write-Output "UPDATE: Since Employee Title for USER: $csv_employee_name is $bool_employee_title updating TITLE..."
                try { Set-ADUser -Identity $aduser.SamAccountName -Title $csv_title -ErrorAction Continue }
                catch { $Exception = $_.Exception ; "$date | $Exception " >> $log; Write-Output "ERROR: Check Log" }
            } else {
                Write-Output "GOOD: Since Employee Title for USER: $csv_employee_name is $bool_employee_title NOT updating TITLE"
            }
        } else {
            Write-Output "WARNING: Could not find USER: $csv_employee_name based on Email Address from CSV"
            $csv_email_address_array = $csv_email_address.Split("@")
            try { $aduser = Get-ADUser $csv_email_address_array[0] -Property mail,Title -ErrorAction Continue }
            catch { $Exception = $_.Exception ; "$date | $Exception " >> $log; Write-Output "ERROR: Check Log" }
            $bool_aduser_query = $null -ne $aduser
            if ($null -ne $aduser) {
                "UPDATE: Since estimated SamAccountName for USER: $csv_employee_name is $bool_aduser_Query attempting to update..."
                if ($aduser.Title -ne $csv_title) { 
                    Write-Output "UPDATE: Since Employee Title for USER: $csv_employee_name is $bool_employee_title updating TITLE..."
                    try { Set-ADUser -Identity $aduser.SamAccountName -Title $csv_title -ErrorAction Continue }
                    catch { $Exception = $_.Exception ; "$date | $Exception " >> $log; Write-Output "ERROR: Check Log" }
                } else {
                    Write-Output "GOOD: Since Employee Title for USER: $csv_employee_name is $bool_employee_title NOT updating TITLE"
                }
            } else {
                "WARNING: Since estimated SamAccountName for USER: $csv_employee_name is $bool_aduser_Query executing additional search."
            }
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
        try { Remove-Item -Path "$home_dir\AppData\Local\Temp\$filename.csv" -ErrorAction Continue }
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
$csv = Import_CSV -name $name -date $date -log $log -home_dir $home_dir -filename $filename
Update_Title -csv $csv