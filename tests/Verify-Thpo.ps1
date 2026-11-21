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
$taskDetails = Get-Content -LiteralPath (Join-Path $root 'app\Localization\TaskDetails.json') -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
$detailIds = @($taskDetails | ForEach-Object ids)
Assert ($detailIds.Count -eq $entries.Count -and -not (Compare-Object $entries.id $detailIds -CaseSensitive)) 'Details must cover every task exactly once.'
foreach ($detail in $taskDetails) {
    Assert ($detail.text.Count -eq 5 -and -not ($detail.text | Where-Object { [string]::IsNullOrWhiteSpace($_) })) "Missing task detail for $($detail.ids -join ', ')."
}
$buffer = $taskDetails | Where-Object { $_.ids -contains 'btnInputQueue' }
Assert ($buffer.ids -contains 'InputQueue' -and -not ($buffer.text | Where-Object { $_ -notmatch 'MouseDataQueueSize' -or $_ -notmatch 'KeyboardDataQueueSize' -or $_ -notmatch '(?<!\d)20(?!\d)' })) 'Both input buffer entry points must document the same queue settings.'
& (Join-Path $root 'tools\Update-TaskGuides.ps1') -Check
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

& {
    $originalPlan = '381b4222-f694-41f0-9685-ff5bb260df2e'
    $power = @{ Active = $originalPlan; Copy = $null; Name = $null; RejectActivation = $false; WrongDc = $false }
    $writes = [Collections.Generic.List[string]]::new()

    function powercfg {
        $global:LASTEXITCODE = 0
        switch ($args[0]) {
            '/list' {
                "GUID: $originalPlan (Balanced)"
                if ($power.Copy) { "GUID: $($power.Copy) ($($power.Name))" }
            }
            '/getactivescheme' { "GUID: $($power.Active)" }
            '/qh' {
                if ($args.Count -eq 2) { 'CPMINCORES CPMAXCORES SYSCOOLPOL ASPM'; return }
                'Maximum: 0x00000064'
                'AC: 0x00000064'
                if ($power.WrongDc) { 'DC: 0x00000004' } else { 'DC: 0x00000064' }
            }
            default { throw "Unexpected powercfg query: $args" }
        }
    }

    function Invoke-ExactNative([string] $Name, [string[]] $Arguments) {
        Assert ($Name -eq 'powercfg.exe') "Unexpected executable $Name."
        $writes.Add($Arguments -join ' ')
        switch ($Arguments[0]) {
            '/duplicatescheme' { $power.Copy = $Arguments[2] }
            '/changename' { $power.Name = $Arguments[2] }
            '/setactive' { if (-not $power.RejectActivation) { $power.Active = $Arguments[1] } }
        }
    }
    function Write-GuiLog {}

    try {
        Invoke-UnparkCores
        Assert ($writes.Contains("/setacvalueindex $originalPlan SUB_PROCESSOR CPMINCORES 100") -and
            $writes.Contains("/setdcvalueindex $originalPlan SUB_PROCESSOR CPMINCORES 100") -and
            -not ($writes -match 'CP(?:MIN|MAX)CORES1')) 'Unpark should set supported AC and DC aliases on the active plan.'

        $power.WrongDc = $true
        $verificationError = try { Invoke-UnparkCores } catch { $_.Exception.Message }
        Assert ($verificationError -match 'CPMAXCORES.*AC.*DC') 'Unpark should catch a DC setting that Windows did not save.'

        $writes.Clear()
        Set-FpsPowerPlan
        Set-FpsPowerPlan
        Assert ($power.Active -ne $originalPlan -and $power.Active -eq $power.Copy -and
            @($writes -match '^/duplicatescheme ').Count -eq 1 -and
            -not ($writes -match "^/setacvalueindex $originalPlan ")) 'FPS Boost must reuse its own plan and avoid writing to the previous plan.'

        $power.Active = $originalPlan
        $power.RejectActivation = $true
        $verificationError = try { Set-FpsPowerPlan } catch { $_.Exception.Message }
        Assert ($verificationError -match $power.Copy) 'FPS Boost must report a failure if Windows leaves another plan active.'
    } finally {
        Remove-Variable resultStatus,resultText -Scope Script -ErrorAction SilentlyContinue
    }
}

& {
    function Resolve-PlainPath([string] $Path) { $Path }
    $certificate = [pscustomobject]@{ Subject = 'CN="CoderBag, LLC", O="CoderBag, LLC"' }
    $certificate | Add-Member -MemberType ScriptMethod -Name GetNameInfo -Value { 'CoderBag, LLC' }
    $signature = [pscustomobject]@{ Status = 'Valid'; SignerCertificate = $certificate }
    function Get-AuthenticodeSignature { $signature }
    Assert (Test-Publisher 'UnparkCpu.exe' '^CoderBag, LLC$') 'An otherwise valid publisher with a quoted common name must be recognized.'
    $signature.Status = 'HashMismatch'
    Assert (-not (Test-Publisher 'UnparkCpu.exe' '^CoderBag, LLC$')) 'A modified executable must still be rejected.'
}

& {
    function Get-WingetExecutable {}
    function Get-ActiveAdapters {}
    function Get-CompatibleBackups {}
    function Test-Path { $false }

    $amd = [pscustomobject]@{ Name = 'AMD Radeon Graphics'; PNPDeviceID = 'PCI\VEN_1002&DEV_0000' }
    $rtx = [pscustomobject]@{ Name = 'NVIDIA GeForce RTX 5080'; PNPDeviceID = 'PCI\VEN_10DE&DEV_0000' }
    $olderRtx = [pscustomobject]@{ Name = 'NVIDIA GeForce RTX 4070'; PNPDeviceID = 'PCI\VEN_10DE&DEV_0001' }
    $unavailable = Get-TaskAvailability @($amd)
    Assert ($unavailable.btnDriverNvidia581 -eq 'CompatNoNvidia' -and
        $unavailable.btnDriverNvidia566 -eq 'CompatNoNvidia') 'A PC without NVIDIA must not offer NVIDIA installers.'
    Assert ($unavailable.WingetApps -eq 'CompatNoWinget' -and
        $unavailable.btnPostInstall -eq 'CompatNoWinget') 'Both WinGet entries must require WinGet.'
    Assert ($unavailable.btnApplyDns -in @('CompatNoAdapter','CompatNoDnsTools') -and $unavailable.DnsCloud -eq $unavailable.btnApplyDns -and
        $unavailable.btnRestoreReg -eq 'CompatNoBackup') 'DNS and restore must require their prerequisites.'

    $newGpu = Get-TaskAvailability @($rtx)
    Assert ($newGpu.btnDriverNvidia566 -eq 'CompatNvidia566' -and
        -not $newGpu.ContainsKey('btnDriverNvidia581')) 'RTX 50-only PCs must filter the older driver.'
    Assert (-not (Get-TaskAvailability @($rtx, $olderRtx)).ContainsKey('btnDriverNvidia566')) 'An older NVIDIA GPU may still use 566.36.'
    Assert (-not (Get-TaskAvailability $null).ContainsKey('btnDriverNvidia566')) 'An unsuccessful GPU probe should leave normal validation available.'
}

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
    $response = & $powerShell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $entryPoint -TaskId $id
    Assert ($LASTEXITCODE -eq 0 -and $response.Count -ge 2 -and $response[-1] -match '"level":"ok"') "Read-only worker check failed for $id."
    if ($id -eq 'HardwareSummary') {
        $frames = $response | Where-Object { $_ -match '^THPO\t' } |
            ForEach-Object { $_.Substring(5) | ConvertFrom-Json -AsHashtable }
        $report = ($frames | Where-Object kind -EQ 'data').data
        Assert ($report.Availability -is [Collections.IDictionary]) 'The hardware summary must include a compatibility report.'
        foreach ($blockedId in $report.Availability.Keys) {
            Assert ($entries.id -ccontains $blockedId -and $uiText.Contains($report.Availability[$blockedId])) "Invalid availability entry for $blockedId."
        }
    }
}
$response = & $powerShell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $entryPoint -TaskId btnFpsBoost
Assert ($LASTEXITCODE -eq 1 -and $response -match '"level":"error"') 'A restricted action ran without confirmation.'
'51 batch actions, 66 standalone actions, localization, compatibility and PowerShell permission checks passed.'
