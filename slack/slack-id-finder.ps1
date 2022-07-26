$slackExportCSV = $env:slack_export_csv
$csv = Import-Csv -Path $slackExportCSV 
$csv