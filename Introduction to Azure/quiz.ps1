function questions {
    param ( $right, $wrong1, $wrong2, $wrong3, $question, $num )
    $question = "Question " + $num + ": "  + $question
    Write-Host $question; Write-Host ""
    $numbers = @(1,2,3,4) | Get-Random -Shuffle
    $index = @{}
    $index.Add($numbers[0],$right)
    $index.Add($numbers[1],$wrong1)
    $index.Add($numbers[2],$wrong2)
    $index.Add($numbers[3],$wrong3)
    $index = $index.GetEnumerator() | Sort-Object -Property Key
    $pa1 =  [string]$index[0].Key + ") " + $index[0].Value
    $pa2 =  [string]$index[1].Key + ") " + $index[1].Value
    $pa3 =  [string]$index[2].Key + ") " + $index[2].Value
    $pa4 =  [string]$index[3].Key + ") " + $index[3].Value
    $paArray = @($pa1, $pa2, $pa3, $pa4)
    $paArray | ForEach-Object { Write-Host $_ }
    Write-Host ""; $answer = Read-Host -Prompt "Pick a number from the following: "
    if (($answer -eq "1") -or ($answer -eq "2") -or ($answer -eq "3") -or ($answer -eq "4")) { $answer = [int32]$answer }
    if ($answer -eq $numbers[0]){ $answer = $right}
    if ($right -ne $answer) { Write-Host "" ; Write-Host "Wrong" -ForegroundColor Red ; Write-Host "" ; return $false} 
    else { Write-Host "" ; Write-Host "Good Job!" -ForegroundColor Green ; Write-Host "" ; return $true }
}

$csv_path = "/Users/ahayes/Documents/study/Azure/AzureStudy.csv"
$csv = Import-Csv -Path $csv_path
$csv = $csv | Get-Random -Shuffle
$bools = @()
$qodURI = "https:/quotes.rest/qod"

Clear-Host
$getQod = Invoke-RestMethod -Uri $qodURI -Method Get -ContentType 'application/json'
$getQod.gettype()

Write-Host "Number of Questions in this Deck: $numberOfQuestion"
Read-Host -prompt "Press Any Key to Continue"

Clear-Host

$csvIter = 0
$csv | ForEach-Object {
    $csvIter = $csvIter + 1
    $right = $_.RightAnswer
    $wrong1 = $_.WrongAnswer1
    $wrong2 = $_.WrongAnswer2
    $wrong3 = $_.WrongAsnwer3
    $question = $_.Question
    $q = questions -right $right -wrong1 $wrong1 -wrong2 $wrong2 -wrong3 $wrong3 -question $question -num $csvIter
    $bools += $q

}

$good = 0
$bools | ForEach-Object {
    if ($true -eq $_) { $good = $good + 1 }
}
$score = $good / $bools.Count
$score = $score * 100
$score = [int32]$score
Write-Host "Youre Score is $score out of 100"
if ($score -lt 90){ Write-Host "Not ready. Try Again!" -ForegroundColor Red} 
else { Write-Host "Congrats. I think you are ready for something harder." -ForegroundColor Green }