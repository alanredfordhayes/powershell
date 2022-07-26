$emptyHash = @{}
$numberHash = @{}

$csv01 = @()
$csv02 = @()
$csv03 = @()
$csv04 = @()
$csv05 = @()
$csv06 = @()
$csv07 = @()
$csv08 = @()
$csv09 = @()
$csv10 = @()
$csv11 = @()
$csv12 = @()
$csv13 = @()

$iter = 0
$csv = Import-Csv -Path '~/Downloads/Video JIRA Legacy Parent_Child Issue List - video_parent_child_id_edit.csv'

$parentKeys = $csv.parent_key
$parentKeys = $parentKeys | Sort-Object -Descending -Unique
$countdown = $parentKeys.Length
"Starting at $countdown"
$parentKeys | ForEach-Object {
    $countdown = $countdown - 1
    $countdown
    $key = $_
    $parentIssue = $csv | Where-Object -Property jira_key -eq $key
    $childIssues = $csv | Where-Object -Property parent_key -eq $key
    $array = @()
    $array += $parentIssue

    if ($childIssues.gettype().BaseType.Name -eq 'Array') {
        $childIssues | ForEach-Object {
            $issue = $_
            $array += $issue
        }
    } else {
        $array += $childIssues
    }

    $iter = $iter + $array.length
    if ($iter -lt 1000) {
        $array | ForEach-Object {
            $iss = $_
            $csv01 += $iss
        }
    } elseif ($iter -lt 2000) {
        $array | ForEach-Object {
            $iss = $_
            $csv02 += $iss
        }
    } elseif ($iter -lt 3000) {
        $array | ForEach-Object {
            $iss = $_
            $csv03 += $iss
        }
    } elseif ($iter -lt 4000) {
        $array | ForEach-Object {
            $iss = $_
            $csv04 += $iss
        }
    } elseif ($iter -lt 5000) {
        $array | ForEach-Object {
            $iss = $_
            $csv05 += $iss
        }
    } elseif ($iter -lt 6000) {
        $array | ForEach-Object {
            $iss = $_
            $csv06 += $iss
        }
    } elseif ($iter -lt 7000) {
        $array | ForEach-Object {
            $iss = $_
            $csv07 += $iss
        }
    } elseif ($iter -lt 8000) {
        $array | ForEach-Object {
            $iss = $_
            $csv08 += $iss
        }
    } elseif ($iter -lt 9000) {
        $array | ForEach-Object {
            $iss = $_
            $csv09 += $iss
        }
    } elseif ($iter -lt 10000) {
        $array | ForEach-Object {
            $iss = $_
            $csv10 += $iss
        }
    } elseif ($iter -lt 11000) {
        $array | ForEach-Object {
            $iss = $_
            $csv11 += $iss
        }
    } elseif ($iter -lt 12000) {
        $array | ForEach-Object {
            $iss = $_
            $csv12 += $iss
        }
    }
} 

$allCSVs = @($csv01,
$csv02, 
$csv03, 
$csv04, 
$csv05, 
$csv06, 
$csv07, 
$csv08, 
$csv09, 
$csv10, 
$csv11, 
$csv12)

$i = 0
$allCSVs | ForEach-Object {
    $i = $i + 1
    $name = 'import' + $i + '.csv'
    $csv = $_
    $csv | Export-Csv $name
}