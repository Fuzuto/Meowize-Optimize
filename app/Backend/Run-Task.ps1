[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z][A-Za-z0-9]{0,64}$')]
    [string] $TaskId,
    [ValidateLength(0, 24000)] [string] $Request,
    [switch] $Confirmed
)

$env:PSModulePath = Join-Path $PSHOME 'Modules'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

function Write-Frame([string] $Kind, [string] $Text, [string] $Level, $Value, $Data) {
    $frame = @{ kind = $Kind; text = $Text; level = $Level; value = $Value; data = $Data }
    [Console]::WriteLine("THPO`t" + (ConvertTo-Json -InputObject $frame -Depth 7 -Compress))
}

function Write-GuiLog([string] $Text, [string] $Color) {
    $level = if ($Color -in @('warn', 'yellow') -or $Text -match '^\s*\[(?:-|!)\]') { 'warn' } else { 'info' }
    $message = ($Text -replace '^\s*\[(?:OK|\+)\]\s*', '' -replace '[\x00-\x08\x0b\x0c\x0e-\x1f]', '').Trim()
    if ($message) { Write-Frame 'log' $message $level }
}

function Set-Progress([int] $Percent) {
    Write-Frame 'progress' '' '' ([math]::Max(0, [math]::Min($Percent, 100)))
}

function Confirm-Action { return $Confirmed.IsPresent }
function Show-Popup([string] $Message, [string] $Title) { Write-GuiLog $Message 'info' }

$colorAccent = 'info'
$colorSuccess = 'info'
$colorCyan = 'info'
$colorPurple = 'info'
$colorWarn = 'warn'
$colorYellow = 'yellow'
$colorText = 'info'
$systemFolder = [Environment]::SystemDirectory
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$script:nativeErrors = [Collections.Generic.List[string]]::new()
$script:resultStatus = 'ok'
$script:resultText = $null

function Invoke-Native([string] $Name, [string[]] $Arguments) {
    $executable = Join-Path $systemFolder $Name
    & $executable @Arguments
    if ($LASTEXITCODE -ne 0) {
        $script:nativeErrors.Add("$Name ($LASTEXITCODE)")
    }
}

function reg { Invoke-Native 'reg.exe' $args }
function bcdedit { Invoke-Native 'bcdedit.exe' $args }
function powercfg { Invoke-Native 'powercfg.exe' $args }
function ipconfig { Invoke-Native 'ipconfig.exe' $args }
function netsh { Invoke-Native 'netsh.exe' $args }
function schtasks.exe { Invoke-Native 'schtasks.exe' $args }

try {
    . (Join-Path $PSScriptRoot 'Legacy.ps1')
    . (Join-Path $PSScriptRoot 'Operations.ps1')
    . (Join-Path $PSScriptRoot 'Downloads.ps1')

    $known = $workerTasks.ContainsKey($TaskId) -or $legacyTasks.ContainsKey($TaskId) -or $downloadTasks.ContainsKey($TaskId)
    if (-not $known) { throw 'Mã tác vụ không được hỗ trợ.' }
    $unprivileged = @(
        'HardwareSummary', 'StartupRead', 'StartupRemove', 'BackupList',
        'btnScanHardware', 'btnSmartCheck', 'btnTempCheck', 'btnLicenseCheck', 'btnRunHealthCheck',
        'btnHardwareCompat', 'btnExportHtml', 'btnAppsDesktop', 'btnUnparkApp', 'btnDDU'
    )
    if ($TaskId -notin $unprivileged -and (-not $isAdmin -or -not $Confirmed)) {
        throw 'Tác vụ cần xác nhận và quyền quản trị.'
    }
    $needsConfirmation = @('StartupRemove', 'btnAppsDesktop', 'btnUnparkApp', 'btnDDU')
    if ($TaskId -in $needsConfirmation -and -not $Confirmed) { throw 'Tác vụ cần xác nhận.' }

    $payload = if ($Request) {
        [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Request)) | ConvertFrom-Json
    }
    if ($TaskId -in @('PurgeRAM', 'btnClearRam')) {
        Add-Type -TypeDefinition @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
public static class MemoryManager {
    [DllImport("psapi.dll")]
    private static extern bool EmptyWorkingSet(IntPtr process);
    public static int ClearAllMemory() {
        int count = 0;
        foreach (var process in Process.GetProcesses()) {
            using (process) {
                try { if (EmptyWorkingSet(process.Handle)) count++; }
                catch (System.ComponentModel.Win32Exception) { }
                catch (InvalidOperationException) { }
            }
        }
        return count;
    }
}
'@
    }

    $Error.Clear()
    if ($legacyTasks.ContainsKey($TaskId)) {
        $ErrorActionPreference = 'Continue'
        & $legacyTasks[$TaskId] | ForEach-Object {
            if ($_ -is [string] -and $_.Trim()) { Write-GuiLog $_ 'info' }
        }
        if ($TaskId -notin $unprivileged) {
            $script:resultStatus = 'check'
        }
    } elseif ($workerTasks.ContainsKey($TaskId)) {
        & $workerTasks[$TaskId]
    } else {
        & $downloadTasks[$TaskId]
    }

    if ($Error.Count -or $script:nativeErrors.Count) {
        foreach ($issue in @($Error | Select-Object -First 4)) { Write-GuiLog $issue.Exception.Message 'warn' }
        foreach ($issue in @($script:nativeErrors | Select-Object -Unique -First 8)) { Write-GuiLog "Mã thoát chương trình: $issue" 'warn' }
        if ($script:resultStatus -in @('ok', 'check')) {
            $script:resultStatus = 'partial'
            $script:resultText = $null
        }
    }
    Write-Frame 'result' $script:resultText $script:resultStatus
    exit 0
} catch {
    Write-Frame 'result' $_.Exception.Message 'error'
    exit 1
}
