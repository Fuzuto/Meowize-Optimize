param(
    [Parameter(Mandatory)] [string] $App,
    [Parameter(Mandatory)] [string] $Screenshots
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing, System.Windows.Forms
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class MeowizeWindow {
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr wnd, IntPtr hdc, uint flags);
    [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr wnd);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr wnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr wnd, int attribute, out int value, int size);
}
'@

$appPath = (Resolve-Path -LiteralPath $App).Path
$output = (New-Item -ItemType Directory -Path $Screenshots -Force).FullName
$catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path (Split-Path -Parent $PSScriptRoot) 'app\Catalog.json') | ConvertFrom-Json
$strings = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path (Split-Path -Parent $PSScriptRoot) 'app\Localization\Ui.json') | ConvertFrom-Json -AsHashtable
$copies = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path (Split-Path -Parent $PSScriptRoot) 'app\Localization\Tasks.json') | ConvertFrom-Json -AsHashtable
$ui = [Windows.Automation.AutomationElement]
$scope = [Windows.Automation.TreeScope]
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('meowize-profile-' + [guid]::NewGuid().ToString('N') + '.json')
$regions = @('en-US','ja-JP','ko-KR','vi-VN','zh-CN')

function Start-Preview {
    $start = [Diagnostics.ProcessStartInfo]::new($appPath, '--preview')
    $start.UseShellExecute = $false
    $start.Environment['MEOWIZE_PREVIEW_PROFILE'] = $fixture
    [Diagnostics.Process]::Start($start)
}

function Wait-Until([scriptblock] $Probe, [string] $Failure, [int] $Seconds = 7) {
    $end = [DateTime]::UtcNow.AddSeconds($Seconds)
    do {
        try { $result = & $Probe; if ($result) { return $result } }
        catch [Windows.Automation.ElementNotAvailableException] { }
        Start-Sleep -Milliseconds 90
    } until ([DateTime]::UtcNow -gt $end)
    throw $Failure
}

function Find-Control([string] $Id, $Root = $window) {
    $condition = [Windows.Automation.PropertyCondition]::new($ui::AutomationIdProperty, $Id)
    Wait-Until { $Root.FindFirst($scope::Descendants, $condition) } "AutomationId $Id is missing."
}

function Invoke-Control([string] $Id, $Root = $window) {
    (Find-Control $Id $Root).GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()
}

function Select-Page([string] $Id) {
    (Find-Control "Nav_$Id").GetCurrentPattern([Windows.Automation.SelectionItemPattern]::Pattern).Select()
}

function Wait-Label([string] $Id, [string] $Text, [int] $Seconds = 7) {
    $null = Wait-Until { (Find-Control $Id).Current.Name -eq $Text } "Expected '$Text' for $Id." $Seconds
}

function Find-Dialog([string] $Title) {
    $filter = [Windows.Automation.AndCondition]::new(
        [Windows.Automation.PropertyCondition]::new($ui::ProcessIdProperty, $process.Id),
        [Windows.Automation.PropertyCondition]::new($ui::NameProperty, $Title),
        [Windows.Automation.PropertyCondition]::new($ui::ControlTypeProperty, [Windows.Automation.ControlType]::Window))
    Wait-Until { $ui::RootElement.FindFirst($scope::Descendants, $filter) } "Window '$Title' did not open."
}

function Save-Window([string] $Filename, $Root = $window) {
    $bounds = $Root.Current.BoundingRectangle
    $hwnd = [IntPtr]$Root.Current.NativeWindowHandle
    $bitmap = [Drawing.Bitmap]::new([int]$bounds.Width, [int]$bounds.Height)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $dc = $graphics.GetHdc()
    try {
        if (-not [MeowizeWindow]::PrintWindow($hwnd, $dc, 2)) { throw 'Could not capture preview window.' }
    } finally {
        $graphics.ReleaseHdc($dc)
    }
    try {
        $bitmap.Save((Join-Path $output $Filename), [Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
    "Rendered $Filename at $($bounds.Width)x$($bounds.Height), $([MeowizeWindow]::GetDpiForWindow($hwnd)) DPI."
}

function Close-WithAltF4 {
    $hwnd = [IntPtr]$window.Current.NativeWindowHandle
    [void][MeowizeWindow]::SetForegroundWindow($hwnd)
    $null = Wait-Until { [MeowizeWindow]::GetForegroundWindow() -eq $hwnd } 'Preview did not receive foreground focus for Alt+F4.' 2
    [Windows.Forms.SendKeys]::SendWait('%{F4}')
}

function Set-PreviewRegion([int] $From, [int] $To, [int] $Selected) {
    Invoke-Control 'PreferencesButton'
    $settings = Find-Dialog $strings.Settings[$From]
    $picker = Find-Control 'LanguagePicker' $settings
    $picker.GetCurrentPattern([Windows.Automation.ExpandCollapsePattern]::Pattern).Expand()
    (Find-Control "Region_$($regions[$To])" $picker).GetCurrentPattern([Windows.Automation.SelectionItemPattern]::Pattern).Select()
    Invoke-Control 'ConfirmPrimary' $settings
    Wait-Label 'Nav_gaming' $strings.GamingTitle[$To]
    Wait-Label 'SelectionCount' ($strings.SelectionCount[$To] -f $Selected)
    $taskTitle = if ($To -eq 3) { ($catalog.batch | Where-Object id -EQ 'RestorePoint').title }
        else { $copies.RestorePoint.title[([Math]::Min($To, 3))] }
    Wait-Label 'Source_RestorePoint' ($strings.OpenReference[$To] -f $taskTitle)
}

$process = Start-Preview
try {
    $start = Find-Dialog 'Choose your region to start'
    foreach ($region in $regions) { $null = Find-Control "Region_$region" $start }
    if (-not (Find-Control 'Region_en-US' $start).GetCurrentPattern([Windows.Automation.SelectionItemPattern]::Pattern).Current.IsSelected) {
        throw 'English should be selected at first launch.'
    }
    Save-Window 'Meowize-Region.png' $start
    Invoke-Control 'LanguageContinue' $start
    $window = Find-Dialog 'Meowize'
    Select-Page 'batch'
    Wait-Label 'SelectionCount' ($strings.SelectionCount[0] -f 48)
    Start-Sleep -Milliseconds 250
    Save-Window 'Meowize-Dark.png'
    Invoke-Control 'ThemeToggle'
    Wait-Label 'ThemeToggle' $strings.DarkTheme[0]
    Start-Sleep -Milliseconds 250
    Save-Window 'Meowize-Light.png'
    Set-PreviewRegion 0 3 48
    foreach ($risk in @('Safe','Caution','Warning')) {
        $selectedRisk = @($catalog.batch | Where-Object { $_.selected -and $_.risk -eq $risk }).Count
        Wait-Label "Selected_$risk" "$selectedRisk"
    }
    $backdrop = 0
    $hr = [MeowizeWindow]::DwmGetWindowAttribute([IntPtr]$window.Current.NativeWindowHandle, 38, [ref]$backdrop, 4)
    if ($hr -eq 0) { "Windows reported DWM backdrop type $backdrop." }
    $search = Find-Control 'SearchTasks'
    $search.SetFocus()
    $null = Wait-Until { $search.Current.HasKeyboardFocus } 'The task search could not receive keyboard focus.'
    $searchValue = $search.GetCurrentPattern([Windows.Automation.ValuePattern]::Pattern)
    $searchValue.SetValue('no-match-aio-test')
    $null = Find-Control 'NoMatchingTasks'
    Wait-Label 'SelectionCount' '48 mục đã chọn · 48 mục ngoài bộ lọc'
    $searchValue.SetValue('sao luu')
    $backup = Find-Control 'Batch_BackupReg'
    if ($backup.Current.Name -notmatch 'An toàn') { throw 'Accent-insensitive search or Safe label did not work.' }
    if ((Find-Control 'Source_BackupReg').Current.ControlType -ne [Windows.Automation.ControlType]::Hyperlink) {
        throw 'The source link must be a separate control from the task checkbox.'
    }
    $searchValue.SetValue('')
    Wait-Label 'SelectionCount' '48 mục đã chọn'
    $levelPicker = Find-Control 'SeverityFilter'
    $levelPicker.GetCurrentPattern([Windows.Automation.ExpandCollapsePattern]::Pattern).Expand()
    (Find-Control 'Filter_Warning' $levelPicker).GetCurrentPattern([Windows.Automation.SelectionItemPattern]::Pattern).Select()
    $warning = Find-Control 'Batch_HPET'
    if ($warning.Current.Name -notmatch 'Cảnh báo' -or -not $warning.Current.HelpText) { throw 'Missing high-impact accessible label or explanation.' }
    $levelPicker.GetCurrentPattern([Windows.Automation.ExpandCollapsePattern]::Pattern).Expand()
    (Find-Control 'Filter_All' $levelPicker).GetCurrentPattern([Windows.Automation.SelectionItemPattern]::Pattern).Select()
    Wait-Label 'SelectionCount' '48 mục đã chọn'
    foreach ($group in $catalog.batch | Group-Object page) {
        $expander = (Find-Control "Group_$($group.Name)").GetCurrentPattern([Windows.Automation.ExpandCollapsePattern]::Pattern)
        $expander.Expand()
        foreach ($item in $group.Group) { $null = Find-Control "Batch_$($item.id)" }
        if ($group.Name -ne 'core') { $expander.Collapse() }
    }

    foreach ($preset in @(@('Gaming',36),@('Talon',23),@('Technician',48),@('All',51),@('None',0))) {
        Invoke-Control "Preset_$($preset[0])"
        Wait-Label 'SelectionCount' "$($preset[1]) mục đã chọn"
    }
    $auto = (Find-Control 'AutoShutdown').GetCurrentPattern([Windows.Automation.TogglePattern]::Pattern)
    if ($auto.Current.ToggleState -ne [Windows.Automation.ToggleState]::Off) { throw 'Auto shutdown should start off.' }
    $auto.Toggle()
    Invoke-Control 'Preset_Gaming'
    Wait-Label 'SelectionCount' '36 mục đã chọn'
    if ($auto.Current.ToggleState -ne [Windows.Automation.ToggleState]::On) { throw 'Preset changed the auto shutdown checkbox.' }
    $auto.Toggle()
    Invoke-Control 'ReviewBatch'
    $review = Find-Dialog ($strings.RunTasks[3] -f 36)
    $null = Find-Control 'ReviewWarningCount' $review
    Start-Sleep -Milliseconds 225
    Save-Window 'Meowize-Review.png' $review
    Invoke-Control 'ConfirmPrimary' $review
    $progress = Find-Control 'JobProgress'
    if ($progress.Current.IsOffscreen) { throw 'In-flight batch progress was not visible.' }
    Wait-Label 'RunStatus' 'Mô phỏng hoàn tất' 15
    (Find-Dialog 'Cài đặt Windows').GetCurrentPattern([Windows.Automation.WindowPattern]::Pattern).Close()

    foreach ($page in $catalog.tools | Group-Object page) {
        Select-Page $page.Name
        foreach ($item in $page.Group) { $null = Find-Control $item.id }
        if ($page.Name -eq 'network') {
            $null = Find-Control 'DnsProvider'
            $null = Find-Control 'Source_DnsProvider'
        }
    }

    Invoke-Control 'SupportButton'
    $support = Find-Dialog 'Hỗ trợ'
    if ((Find-Control 'SupportMaintainer' $support).Current.Name -ne 'Lê Hiếu Trung (FuryZ)' -or
        (Find-Control 'SupportGitHubUrl' $support).Current.Name -ne 'https://github.com/Fuzuto') {
        throw 'Support identity did not match the maintainer profile.'
    }
    $null = Find-Control 'OpenSupportGitHub' $support
    $supportText = ($support.FindAll($scope::Descendants, [Windows.Automation.Condition]::TrueCondition) |
        ForEach-Object { $_.Current.Name }) -join ' '
    if ($supportText -notmatch 'Miễn phí.+MIT' -or $supportText -match '\b(QR|VPBank|Zalo|Facebook)\b') {
        throw 'Support dialog is missing licensing info or still displays old contact data.'
    }
    Start-Sleep -Milliseconds 225
    Save-Window 'Meowize-Support.png' $support
    $support.GetCurrentPattern([Windows.Automation.WindowPattern]::Pattern).Close()

    $window.GetCurrentPattern([Windows.Automation.TransformPattern]::Pattern).Resize(920, 690)
    Select-Page 'batch'
    Invoke-Control 'Preset_Technician'
    Wait-Label 'SelectionCount' '48 mục đã chọn'
    Start-Sleep -Milliseconds 225
    Save-Window 'Meowize-Compact.png'
    Invoke-Control 'ToggleLogButton'
    $null = Find-Control 'CloseLogButton'
    Invoke-Control 'CloseLogButton'
    Invoke-Control 'Preset_Gaming'
    Close-WithAltF4
    $close = Find-Dialog $strings.SaveExitTitle[3]
    Invoke-Control 'DialogCancel' $close
    Wait-Label 'SelectionCount' '36 mục đã chọn'
    Close-WithAltF4
    $close = Find-Dialog $strings.SaveExitTitle[3]
    (Find-Control 'ExitRemember' $close).GetCurrentPattern([Windows.Automation.TogglePattern]::Pattern).Toggle()
    Invoke-Control 'ConfirmPrimary' $close
    if (-not $process.WaitForExit(6000)) { throw 'Save and close did not exit.' }
    $process.Dispose()
    $profile = Get-Content -LiteralPath $fixture -Raw | ConvertFrom-Json
    if ($profile.Language -ne 'vi-VN' -or $profile.Exit -ne 1 -or -not $profile.Window.Light -or
        $profile.Window.Selection.Count -ne 36) { throw 'The saved profile lacks the selected language, theme, preset or exit choice.' }

    $process = Start-Preview
    $window = Find-Dialog 'Meowize'
    Wait-Label 'SelectionCount' '36 mục đã chọn'
    Wait-Label 'ThemeToggle' $strings.DarkTheme[3]
    [void]$process.CloseMainWindow()
    if (-not $process.WaitForExit(6000)) { throw 'Remembered save should close without asking again.' }
    $process.Dispose()

    $process = Start-Preview
    $window = Find-Dialog 'Meowize'
    Set-PreviewRegion 3 1 36
    Set-PreviewRegion 1 2 36
    Set-PreviewRegion 2 4 36
    Set-PreviewRegion 4 0 36
    Invoke-Control 'PreferencesButton'
    $settings = Find-Dialog $strings.Settings[0]
    (Find-Control 'AskAtExit' $settings).GetCurrentPattern([Windows.Automation.TogglePattern]::Pattern).Toggle()
    Invoke-Control 'ConfirmPrimary' $settings
    Invoke-Control 'Preset_Talon'
    Wait-Label 'SelectionCount' ($strings.SelectionCount[0] -f 23)
    [void]$process.CloseMainWindow()
    $close = Find-Dialog $strings.SaveExitTitle[0]
    (Find-Control 'ExitRemember' $close).GetCurrentPattern([Windows.Automation.TogglePattern]::Pattern).Toggle()
    Invoke-Control 'ExitDiscard' $close
    if (-not $process.WaitForExit(6000)) { throw 'Discard and close did not exit.' }
    $profile = Get-Content -LiteralPath $fixture -Raw | ConvertFrom-Json
    if ($profile.Language -ne 'en-US' -or $profile.Exit -ne 2 -or $profile.Window.Selection.Count -ne 36) {
        throw 'Discard should remember the exit policy without saving the changed selection.'
    }
    'Verified 51 batch checkboxes, 66 tool buttons, source links, presets, both themes, five languages, Alt+F4, and saving and discarding choices.'
} finally {
    $process.Refresh()
    if (-not $process.HasExited) {
        $null = $process.CloseMainWindow()
        if (-not $process.WaitForExit(2500)) { $process.Kill() }
    }
    $process.Dispose()
    [IO.File]::Delete($fixture)
}
