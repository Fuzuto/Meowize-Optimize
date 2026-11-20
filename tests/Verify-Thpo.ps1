$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $root 'app\Backend'
$reference = Join-Path $root 'upstream\THPO'
$catalog = Get-Content -LiteralPath (Join-Path $root 'app\Catalog.json') -Raw -Encoding UTF8 | ConvertFrom-Json

function Assert($Condition, [string] $Description) {
    if (-not $Condition) { throw $Description }
}

function Parse-Script([string] $File) {
    $tokens = $null
    $issues = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$tokens, [ref]$issues)
    Assert (-not $issues) "$File has PowerShell syntax errors."
    return $ast
}

$sourceAst = Parse-Script $reference
$batchSource = Select-String -LiteralPath $reference -Pattern 'Id = "([^"]+)"; Category = "([^"]+)"; Checkbox = \$(\w+)'
$entries = @($catalog.batch) + @($catalog.tools)
Assert ($catalog.batch.Count -eq 51 -and $catalog.tools.Count -eq 66) 'Unexpected catalog size.'
Assert (@($entries.id | Select-Object -Unique).Count -eq $entries.Count) 'Duplicate action ID.'
Assert (@($entries | Where-Object { $_.risk -notin @('Safe','Caution','Warning') }).Count -eq 0) 'A task has no severity label.'
Assert (@($entries | Where-Object { $_.risk -eq 'Warning' -and [string]::IsNullOrWhiteSpace($_.riskNote) }).Count -eq 0) 'A warning has no explanation.'

$uiText = Get-Content -LiteralPath (Join-Path $root 'app\Localization\Ui.json') -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
$taskText = Get-Content -LiteralPath (Join-Path $root 'app\Localization\Tasks.json') -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
Assert (-not (Compare-Object $entries.id @($taskText.Keys) -CaseSensitive)) 'Task translations differ from the catalog IDs.'
foreach ($entry in $entries) {
    $copy = $taskText[$entry.id]
    Assert ($copy.title.Count -eq 4 -and $copy.description.Count -eq 4 -and
        (-not $entry.riskNote -or $copy.riskNote.Count -eq 4)) "Incomplete localization for $($entry.id)."
    $url = $null
    Assert ([uri]::TryCreate($copy.source, [UriKind]::Absolute, [ref]$url) -and
        $url.Scheme -eq 'https' -and $uiText.Contains($copy.kind)) "Invalid reference metadata for $($entry.id)."
}
foreach ($key in $uiText.Keys) {
    $values = $uiText[$key]
    Assert ($values.Count -eq 5 -and -not ($values | Where-Object { [string]::IsNullOrWhiteSpace($_) })) "Missing UI translation for $key."
    $parameters = @([regex]::Matches($values[0], '\{\d+\}').Value | Sort-Object)
    foreach ($translation in $values | Select-Object -Skip 1) {
        $actual = @([regex]::Matches($translation, '\{\d+\}').Value | Sort-Object)
        Assert (($parameters -join ',') -ceq ($actual -join ',')) "Localized format parameters differ for $key."
    }
}

foreach ($id in @('Defender','DisableVBS','WinUpdate','MSIMode','TscSync','btnDDU','btnBios','btnRestoreReg','btnDriverNvidia581','btnDriverNvidia566')) {
    Assert (($entries | Where-Object id -EQ $id).risk -eq 'Warning') "High-impact task $id requires a warning."
}
Assert ($batchSource.Count -eq $catalog.batch.Count) 'Batch count differs from source.'
for ($index = 0; $index -lt $batchSource.Count; $index++) {
    $source = $batchSource[$index]
    $entry = $catalog.batch[$index]
    $match = $source.Matches[0]
    $checkbox = Select-String -LiteralPath $reference -Pattern ('^\$' + $match.Groups[3].Value + '\s*=\s*New-ThpoCardCheckbox')
    Assert ($entry.id -ceq $match.Groups[1].Value -and $entry.category -ceq $match.Groups[2].Value -and $entry.sourceLine -eq $source.LineNumber) 'Batch order, ID or preset family mismatch.'
    Assert ($entry.selected -eq ($checkbox.Line -match '\$true\s+\$color')) "Default checkbox mismatch for $($entry.id)."
}

$buttons = @($sourceAst.FindAll({
    param($item)
    $item -is [System.Management.Automation.Language.AssignmentStatementAst] -and $item.Right.Extent.Text -match '^New-ThpoButton\b'
}, $true).Left.Extent.Text)
$unbound = '$btnInputQueue', '$btnDisableVBS', '$btnFlipModel', '$btnBlockPresence'
$expectedButtons = ($buttons + $unbound) | ForEach-Object { $_.Substring(1) }
Assert (-not (Compare-Object $expectedButtons $catalog.tools.id)) 'Standalone button IDs differ from source.'

foreach ($file in Get-ChildItem -LiteralPath $backend -File -Filter '*.ps1') {
    $null = Parse-Script $file.FullName
}
. (Join-Path $backend 'Legacy.ps1')
. (Join-Path $backend 'Operations.ps1')
. (Join-Path $backend 'Downloads.ps1')
$backupFixture = Join-Path ([IO.Path]::GetTempPath()) ('meowize-backups-' + [guid]::NewGuid().ToString('N'))
$namedBackup = 'Manual_20261120_000000'
try {
    $backupPath = Join-Path $backupFixture 'current'
    $legacyBackupPath = Join-Path $backupFixture 'legacy'
    foreach ($location in @($backupPath, $legacyBackupPath)) {
        $folder = [IO.Directory]::CreateDirectory((Join-Path $location $namedBackup))
        [IO.File]::WriteAllText((Join-Path $folder.FullName 'HKCU.reg'), "Windows Registry Editor Version 5.00`r`n; Fixture for list-only verification")
    }
    $backups = @(Get-CompatibleBackups)
    Assert ($backups.Count -eq 2 -and $backups.Id -contains "current/$namedBackup" -and
        $backups.Id -contains "legacy/$namedBackup") 'Current and legacy backups with the same name should have distinct restore IDs.'
} finally {
    foreach ($location in @($backupPath, $legacyBackupPath)) {
        $folder = Join-Path $location $namedBackup
        [IO.File]::Delete((Join-Path $folder 'HKCU.reg'))
        if ([IO.Directory]::Exists($folder)) { [IO.Directory]::Delete($folder) }
        if ([IO.Directory]::Exists($location)) { [IO.Directory]::Delete($location) }
    }
    if ([IO.Directory]::Exists($backupFixture)) { [IO.Directory]::Delete($backupFixture) }
}
$workerIds = @($workerTasks.Keys) + @($downloadTasks.Keys) | Where-Object { $_ -notin ('HardwareSummary', 'StartupRead', 'StartupRemove', 'BackupList') }
Assert (-not (Compare-Object @($legacyTasks.Keys) @($entries | Where-Object mode -EQ 'legacy' | ForEach-Object id))) 'A legacy action is missing or duplicated.'
Assert (-not (Compare-Object @($workerIds) @($entries | Where-Object mode -EQ 'worker' | ForEach-Object id))) 'A worker action is missing or duplicated.'

$source = Get-Content -Raw -LiteralPath (Join-Path $root 'app\MainWindow.Actions.cs') -Encoding UTF8
foreach ($entry in $entries | Where-Object mode -In ('desktop','settings')) {
    Assert ($source.Contains('"' + $entry.id + '"')) "Missing desktop mapping $($entry.id)."
}

$powerShell = Join-Path ([Environment]::SystemDirectory) 'WindowsPowerShell\v1.0\powershell.exe'
$entryPoint = Join-Path $backend 'Run-Task.ps1'
foreach ($id in @('HardwareSummary', 'BackupList')) {
    $response = & $powerShell -NoProfile -NonInteractive -File $entryPoint -TaskId $id
    Assert ($LASTEXITCODE -eq 0 -and $response.Count -ge 2 -and $response[-1] -match '"level":"ok"') "Read-only worker check failed for $id."
}
$response = & $powerShell -NoProfile -NonInteractive -File $entryPoint -TaskId btnFpsBoost
Assert ($LASTEXITCODE -eq 1 -and $response -match '"level":"error"') 'A restricted action ran without confirmation.'
'51 batch actions, 66 standalone actions, localization, compatibility and PowerShell permission checks passed.'
