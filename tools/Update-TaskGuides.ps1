param([switch] $Check)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $projectRoot 'app'
$catalog = Get-Content -LiteralPath (Join-Path $appRoot 'Catalog.json') -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
$localeRoot = Join-Path $appRoot 'Localization'
$ui = Get-Content -LiteralPath (Join-Path $localeRoot 'Ui.json') -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
$copy = Get-Content -LiteralPath (Join-Path $localeRoot 'Tasks.json') -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
$details = Get-Content -LiteralPath (Join-Path $localeRoot 'TaskDetails.json') -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
$byId = @{}
foreach ($entry in $details) {
    foreach ($taskId in $entry.ids) { $byId.Add($taskId, $entry.text) }
}

$locales = [ordered]@{
    en = @('English', 'Feature guide', 'Standalone tools', 'Task', 'What Meowize does',
        'Open the indicated page and use the action in the task row. Select ⓘ to see the steps in the app before you run it.',
        'Select **{0}** in the activity log during the countdown.')
    ja = @('日本語', '機能ガイド', '個別ツール', '項目', 'Meowize の動作',
        '対象のページを開き、項目のボタンを選択します。実行前に ⓘ で詳細を確認できます。',
        'カウントダウン中はログの「**{0}**」で中止できます。')
    ko = @('한국어', '기능 가이드', '개별 도구', '작업', 'Meowize의 동작',
        '해당 페이지를 열고 작업 행의 버튼을 사용하세요. 실행 전 ⓘ를 누르면 동작을 확인할 수 있습니다.',
        '카운트다운 중 작업 로그의 **{0}**를 눌러 중단할 수 있습니다.')
    vi = @('Tiếng Việt', 'Hướng dẫn từng tính năng', 'Công cụ chạy riêng', 'Tác vụ', 'Meowize thực hiện',
        'Mở đúng trang rồi bấm nút ở dòng tác vụ. Chọn ⓘ để xem các bước trong ứng dụng trước khi chạy.',
        'Trong lúc đếm ngược, bấm **{0}** trong nhật ký để dừng.')
    'zh-CN' = @('简体中文', '功能指南', '独立工具', '任务', 'Meowize 执行的操作',
        '打开对应页面并点击任务行里的按钮。执行前可点击 ⓘ 查看操作详情。',
        '倒计时期间可在活动日志中点击 **{0}**。')
}
$batchPages = [ordered]@{ core = 'CoreGroup'; gaming = 'GamingGroup'; talon = 'Talon Suite'; network = 'NetworkGroup' }
$toolPages = [ordered]@{
    gaming = 'GamingTitle'; system = 'SystemTitle'; network = 'NetworkTitle'
    apps = 'AppsTitle'; dashboard = 'Diagnostics'; repair = 'RepairTitle'
}
$riskIcons = @{ Safe = '🟢'; Caution = '🟡'; Warning = '🔴' }

function Write-TaskTable($Tasks, $Pages, [bool] $IsBatch) {
    foreach ($page in $Pages.Keys) {
        $items = @($Tasks | Where-Object page -EQ $page)
        $headingKey = $Pages[$page]
        $heading = if ($ui.Contains($headingKey)) { $ui[$headingKey][$localeIndex] } else { $headingKey }
        "<details>"
        "<summary>$heading ($($items.Count))</summary>"
        ''
        "| $($locale[3]) | $($locale[4]) |"
        '| --- | --- |'
        foreach ($item in $items) {
            $reference = $copy[$item.id]
            $title = if ($language -eq 'vi') { $item.title } else { $reference.title[$taskLabelIndex] }
            $note = if ($language -eq 'vi') { $item.riskNote } else { $reference.riskNote | Select-Object -Index $taskLabelIndex }
            $text = @($byId[$item.id][$localeIndex])
            if ($IsBatch -and $item.mode -eq 'settings') { $text += $ui.TaskUseBatchSettings[$localeIndex] }
            if ($item.id -eq 'btnApplyDns') { $text += $ui.TaskUseDns[$localeIndex] }
            if ($item.admin) { $text += $ui.TaskRequiresAdmin[$localeIndex] }
            if ($item.restart) { $text += $ui.TaskMayRestart[$localeIndex] }
            if ($note -and $item.risk -eq 'Warning') { $text += $note }
            $body = ($text -join '<br><br>').Replace('|', '\|')
            "| $($riskIcons[$item.risk]) [$($title.Replace('|', '\|'))]($($reference.source))<br>$($ui[$item.risk][$localeIndex]) | $body |"
        }
        ''
        '</details>'
        ''
    }
}

$localeIndex = 0
foreach ($language in $locales.Keys) {
    $locale = $locales[$language]
    $taskLabelIndex = if ($language -eq 'zh-CN') { 3 } else { $localeIndex }
    $readme = if ($language -eq 'en') { '../README.md' } else { "README.$language.md" }
    $navigation = ($locales.Keys | ForEach-Object {
        if ($_ -eq $language) { "**$($locales[$_][0])**" } else { "[$($locales[$_][0])](features.$_.md)" }
    }) -join ' · '
    $lines = @(
        "# $($locale[1])"
        ''
        "[Meowize]($readme) · $navigation"
        ''
        "## 1-Click ($($catalog.batch.Count))"
        ''
        $ui.TaskUseBatch[$localeIndex]
        ''
        "**$($ui.AutoShutdown[$localeIndex])** · $($ui.CountdownReview[$localeIndex]) $($locale[6] -f $ui.CancelShutdown[$localeIndex])"
        ''
        Write-TaskTable $catalog.batch $batchPages $true
        "## $($locale[2]) ($($catalog.tools.Count))"
        ''
        $locale[5]
        ''
        Write-TaskTable $catalog.tools $toolPages $false
    )
    $path = Join-Path $projectRoot "docs/features.$language.md"
    $expected = [string]::Join([char]10, $lines)
    if ($Check) {
        $actual = [IO.File]::ReadAllText($path).Replace([string][char]13, '')
        if ($actual -cne $expected) { throw "Regenerate docs/features.$language.md with tools/Update-TaskGuides.ps1." }
    } else {
        [IO.File]::WriteAllText($path, $expected, [Text.UTF8Encoding]::new($false))
    }
    $localeIndex++
}
