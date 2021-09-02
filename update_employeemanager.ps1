$filename = "okta employee update"
$name = "update_manager"
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

function Update_Manager {
    param (
        [System.Array]$csv
    )

    function set_manager {
        param (
            [Microsoft.ActiveDirectory.Management.ADAccount]$aduser,
            [String]$csv_manager,
            [String]$csv_employee_name,
            $bool
        )

        $dn = "CN=$csv_manager,OU=Users_OU,DC=dash,DC=corp"
        try { $manager = Get-ADUser $dn -ErrorAction Continue }
        catch { $Exception = $_.Exception ; "$date | $Exception " >> $log; Write-Output "ERROR: Check Log" }
        
        if ($null -ne $manager) {
            $manager
        }
        
        # if ($aduser.Manager -ne $csv_manager) { 
        #     Write-Output "UPDATE: Since Employee Manager for USER: $csv_employee_name is $bool updating Manager..."
        #     try { Set-ADUser -Identity $aduser.SamAccountName -Manager $csv_manager -ErrorAction Continue }
        #     catch { $Exception = $_.Exception ; "$date | $Exception " >> $log; Write-Output "ERROR: Check Log" }
        #     Write-Output "Done"
        # } else {
        #     Write-Output "GOOD: Since Employee Manager for USER: $csv_employee_name is $bool NOT updating Manager"
        # }

    }

    $ADUsers = Get-ADUser -Filter * -Properties mail, Manager, targetAddress

    $csv | ForEach-Object {
        $csv_email_address = $_.Email_Address
        $csv_manager = $_.Manager
        $csv_employee_name = $_.Employee_Name
        $aduser = $ADUsers | Where-Object -Property mail -EQ $csv_email_address
        if ($null -ne $aduser) {
            Write-Output "Info: Found USER: $csv_employee_name based on CSV comparison."
            if ($aduser.GetType().BaseType.Name -ne "Array") {
                $bool_employee_manager = $aduser.Manager -ne $csv_manager
                set_manager -aduser $aduser -csv_manager $csv_manager -csv_employee_name $csv_employee_name -bool $bool_employee_manager
            } else {
                Write-Output "Warning: Found multiple entries for USER: $csv_employee_name"
                $aduser = $aduser | Where-Object -Property Enabled -eq "True"
                $bool_employee_manager = $aduser.Manager -ne $csv_manager
                set_manager -aduser $aduser -csv_manager $csv_manager -csv_employee_name $csv_employee_name -bool $bool_employee_manager
            }
        } else {
            Write-Output "WARNING: Could not find USER: $csv_employee_name based on Email Address from CSV"
            $aduser = $ADUsers | Where-Object -Property targetAddress -EQ "SMTP:$csv_email_address"
            if ($null -ne $aduser) {
                Write-Output "Info: Found USER: $csv_employee_name based on Target Address"
                $bool_employee_manager = $aduser.Manager -ne $csv_manager
                set_manager -aduser $aduser -csv_manager $csv_manager -csv_employee_name $csv_employee_name -bool $bool_employee_manager
            } else {
                Write-Output "WARNING: Could not find USER: $csv_employee_name based on Target Addreess from CSV"
                $csv_email_address_array = $csv_email_address.Split("@")
                try { $aduser = Get-ADUser $csv_email_address_array[0] -Properties mail, Manager -ErrorAction Continue }
                catch { $Exception = $_.Exception ; "$date | $Exception " >> $log; Write-Output "ERROR: Check Log" }
                $bool_aduser_query = $null -ne $aduser
                if ($null -ne $aduser) {
                    Write-Output "Info: Since estimated SamAccountName for USER: $csv_employee_name is $bool_aduser_Query"
                    set_manager -aduser $aduser -csv_manager $csv_manager -csv_employee_name $csv_employee_name -bool $bool_aduser_Query
                } else {
                    Write-Output "WARNING: Since estimated SamAccountName for USER: $csv_employee_name is $bool_aduser_Query executing additional search."
                    $dn = "CN=$csv_employee_name,OU=Users_OU,DC=dash,DC=corp"
                    try { $aduser = Get-ADUser $dn -Properties mail, Manager -ErrorAction Continue }
                    catch { $Exception = $_.Exception ; "$date | $Exception " >> $log; Write-Output "ERROR: Check Log" }
                    $bool_dn_query = $null -ne $aduser
                    if ($null -ne $aduser) {
                        Write-Output "Info: Since estimated Distinguished Name for USER: $csv_employee_name is $bool_dn_query"
                        set_manager -aduser $aduser -csv_manager $csv_manager -csv_employee_name $csv_employee_name -bool $bool_dn_query
                    } else {
                        Write-Output "WARNING: Since estimated Distinguished Name for USER: $csv_employee_name is $bool_dn_query executing addtional search."
                    }
                }
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
Update_Manager -csv $csv