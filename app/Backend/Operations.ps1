$backupPath = 'C:\Meowize_Backup'
$legacyBackupPath = 'C:\THPO_Backup'
$startupPaths = @{
    User = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    Machine = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
}

function Resolve-PlainPath([string] $Path) {
    if (-not [IO.Path]::IsPathRooted($Path)) { throw "Đường dẫn chưa tuyệt đối: $Path" }
    $full = [IO.Path]::GetFullPath($Path)
    if ($full -notmatch '^[A-Za-z]:\\' -or $full.Substring(2).Contains(':')) {
        throw "Không hỗ trợ đường dẫn này: $Path"
    }
    $cursor = $full
    while ($cursor -and $cursor -ne [IO.Path]::GetPathRoot($cursor)) {
        if (Test-Path -LiteralPath $cursor) {
            $item = Get-Item -LiteralPath $cursor -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Đường dẫn chứa liên kết: $cursor" }
        }
        $cursor = [IO.Path]::GetDirectoryName($cursor)
    }
    return $full
}

function New-TaskDirectory([string] $Path) {
    $full = Resolve-PlainPath $Path
    [IO.Directory]::CreateDirectory($full) | Out-Null
    return $full
}

function Invoke-ExactNative([string] $Name, [string[]] $Arguments) {
    Invoke-Native $Name $Arguments | ForEach-Object {
        if ($_ -is [string] -and $_.Trim()) { Write-GuiLog $_ 'info' }
    }
    if ($LASTEXITCODE -ne 0) { throw "$Name trả về mã lỗi $LASTEXITCODE." }
}

function New-RestorePoint {
    $drive = [IO.Path]::GetPathRoot($env:windir)
    $before = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue).SequenceNumber
    Enable-ComputerRestore -Drive $drive -ErrorAction Stop
    Checkpoint-Computer -Description "Meowize_$(Get-Date -Format yyyyMMdd_HHmmss)" -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
    $latest = Get-ComputerRestorePoint | Sort-Object SequenceNumber -Descending | Select-Object -First 1
    if (-not $latest -or $latest.SequenceNumber -in $before) {
        throw 'Windows chưa tạo điểm khôi phục mới. Kiểm tra System Protection hoặc giới hạn 24 giờ.'
    }
    Write-GuiLog "Đã tạo điểm khôi phục $($latest.SequenceNumber)." 'info'
}

function New-RegistrySnapshot([string] $Prefix) {
    $root = New-TaskDirectory $backupPath
    $name = "$($Prefix)_$(Get-Date -Format yyyyMMdd_HHmmss)_$([guid]::NewGuid().ToString('N').Substring(0,6))"
    $stage = New-TaskDirectory (Join-Path $root "$name.incomplete")
    foreach ($hive in @('HKLM', 'HKCU')) {
        $file = Join-Path $stage "$hive.reg"
        Invoke-ExactNative 'reg.exe' @('export', $hive, $file, '/y')
        if (-not (Test-Path -LiteralPath $file -PathType Leaf) -or (Get-Item -LiteralPath $file).Length -le 40) {
            throw "Tệp sao lưu $hive không hợp lệ."
        }
    }
    Rename-Item -LiteralPath $stage -NewName $name
    Write-GuiLog "Đã lưu $name trong $root." 'info'
}

function Invoke-CreateRestoreAndBackup {
    $failure = @()
    try { New-RestorePoint } catch { $failure += $_.Exception.Message }
    try { New-RegistrySnapshot 'PreOptimize' } catch { $failure += $_.Exception.Message }
    if ($failure.Count) {
        $script:resultStatus = if ($failure.Count -eq 2) { 'error' } else { 'partial' }
        $script:resultText = $failure -join ' '
    }
}

function Get-CompatibleBackups {
    $roots = @{ current = $backupPath; legacy = $legacyBackupPath }
    $backups = foreach ($location in $roots.Keys) {
        try { $root = Resolve-PlainPath $roots[$location] }
        catch { Write-GuiLog $_.Exception.Message 'warn'; continue }
        if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
        foreach ($folder in Get-ChildItem -LiteralPath $root -Directory) {
            if ($folder.Name -notmatch '^(PreOptimize|Manual)_\d{8}_\d{6}(_[a-fA-F0-9]{6})?$' -or
                ($folder.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }
            $paths = @(foreach ($hive in @('HKLM', 'HKCU')) {
                $filename = Join-Path $folder.FullName "$hive.reg"
                if (Test-Path -LiteralPath $filename -PathType Leaf) {
                    $file = Get-Item -LiteralPath $filename -Force
                    if ($file.Length -gt 40 -and -not ($file.Attributes -band [IO.FileAttributes]::ReparsePoint)) { $file.FullName }
                }
            })
            if ($paths.Count -gt 0) {
                [pscustomobject]@{ Id = "$location/$($folder.Name)"; Name = $folder.Name; Paths = $paths; Created = $folder.CreationTimeUtc }
            }
        }
    }
    $backups | Sort-Object Created -Descending
}

function Restore-RegistrySnapshot([string] $Id) {
    $backup = Get-CompatibleBackups | Where-Object Id -CEQ $Id | Select-Object -First 1
    if (-not $backup) { throw 'Không tìm thấy bản sao lưu đã chọn.' }
    foreach ($path in $backup.Paths) {
        $verified = Resolve-PlainPath $path
        $header = Get-Content -LiteralPath $verified -TotalCount 1
        if ($header -ne 'Windows Registry Editor Version 5.00') { throw "Tệp Registry không hợp lệ: $verified" }
    }
    New-RegistrySnapshot 'PreOptimize'
    foreach ($path in $backup.Paths) {
        Invoke-ExactNative 'reg.exe' @('import', $path)
        Write-GuiLog "Đã nhập $path." 'info'
    }
    $script:resultStatus = 'check'
    $script:resultText = 'Đã nhập bản sao lưu. Khởi động lại và kiểm tra cấu hình.'
}

function Clear-CacheEntry([IO.FileSystemInfo] $Entry, [string] $Root, $Tally) {
    if (-not $Entry.FullName.StartsWith($Root + '\', [StringComparison]::OrdinalIgnoreCase) -or
        ($Entry.Attributes -band [IO.FileAttributes]::ReparsePoint)) { $Tally.Skipped++; return }
    try {
        if ($Entry -is [IO.DirectoryInfo]) {
            foreach ($child in Get-ChildItem -LiteralPath $Entry.FullName -Force) { Clear-CacheEntry $child $Root $Tally }
            [IO.Directory]::Delete($Entry.FullName, $false)
        } else {
            $bytes = $Entry.Length
            Remove-Item -LiteralPath $Entry.FullName -Force -ErrorAction Stop
            $Tally.Bytes += $bytes
        }
    } catch [System.IO.IOException], [System.UnauthorizedAccessException], [System.Management.Automation.ItemNotFoundException] {
        $Tally.Skipped++
    }
}

function Clear-Caches([string[]] $Paths) {
    $tally = @{ Bytes = 0L; Skipped = 0 }
    $index = 0
    foreach ($path in $Paths | Select-Object -Unique) {
        $root = (Resolve-PlainPath $path).TrimEnd('\')
        if (Test-Path -LiteralPath $root -PathType Container) {
            Write-GuiLog "Đang dọn $root." 'info'
            foreach ($entry in Get-ChildItem -LiteralPath $root -Force) { Clear-CacheEntry $entry $root $tally }
        }
        $index++
        Set-Progress ([int](100 * $index / $Paths.Count))
    }
    $script:resultText = "Đã giải phóng $([math]::Round($tally.Bytes / 1MB, 1)) MB."
    if ($tally.Skipped) {
        $script:resultStatus = 'partial'
        $script:resultText += " $($tally.Skipped) mục đang khóa, liên kết hoặc không có quyền."
    }
}

function Get-DesktopPath {
    $path = [Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory)
    if (-not $path -or -not [IO.Directory]::Exists($path)) { throw 'Không tìm thấy Desktop.' }
    return $path
}

function Read-Hardware([object[]] $VideoControllers = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue)) {
    $cpu = @(Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | ForEach-Object Name)
    $gpu = @($VideoControllers | ForEach-Object Name)
    $ram = (Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).TotalPhysicalMemory
    $os = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
    @{
        CPU = ($cpu -join ' · ')
        GPU = ($gpu -join ' · ')
        RAM = $(if ($ram) { "$([math]::Round($ram / 1GB, 1)) GB" })
        OS = $os
    }
}

function Save-HardwareReport {
    $data = Read-Hardware
    $processor = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue
    $architecture = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).OSArchitecture
    if ($processor) {
        $data.CPU = "$($data.CPU) ($((($processor | Measure-Object NumberOfCores -Sum).Sum)) cores, $((($processor | Measure-Object NumberOfLogicalProcessors -Sum).Sum)) threads)"
    }
    if ($architecture) { $data.OS = "$($data.OS) ($architecture)" }
    $rows = foreach ($key in @('CPU', 'GPU', 'RAM', 'OS')) {
        "<tr><th>$key</th><td>$([Net.WebUtility]::HtmlEncode([string] $data[$key]))</td></tr>"
    }
    $file = Resolve-PlainPath (Join-Path (Get-DesktopPath) 'Meowize_System_Report.html')
    $temp = "$file.$([guid]::NewGuid().ToString('N')).tmp"
    $html = @"
<!doctype html>
<html lang="vi"><meta charset="utf-8"><title>Meowize - Báo cáo hệ thống</title>
<style>body{font:16px Segoe UI,sans-serif;color:#f3f6fb;background:#10151d;margin:3rem}table{border-collapse:collapse;width:min(52rem,100%)}th,td{padding:1rem;text-align:left;border-bottom:1px solid #2b3a49}h1{color:#4ddbc6}</style>
<h1>Báo cáo hệ thống</h1><p>$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
<table>$($rows -join '')</table>
<p>Meowize · Lê Hiếu Trung (FuryZ) · <a href="https://github.com/Fuzuto" style="color:#4ddbc6">GitHub</a></p>
<p>Nguồn tác vụ THPO v1.3 của Ngô Thanh Hải (Haisosad).</p></html>
"@
    try {
        [IO.File]::WriteAllText($temp, $html, [Text.UTF8Encoding]::new($false))
        if ([IO.File]::Exists($file)) { [IO.File]::Replace($temp, $file, $null) } else { [IO.File]::Move($temp, $file) }
    } finally {
        if ([IO.File]::Exists($temp)) { [IO.File]::Delete($temp) }
    }
    Start-Process -FilePath $file
    $script:resultText = "Đã tạo $file."
}

$tempPaths = @(
    (Join-Path $env:LOCALAPPDATA 'Temp'),
    (Join-Path $env:windir 'Temp'),
    (Join-Path $env:windir 'Prefetch')
)
$riotPaths = @(
    (Join-Path $env:LOCALAPPDATA 'Riot Games\Riot Client\Logs'),
    (Join-Path $env:LOCALAPPDATA 'VALORANT\Saved\Logs'),
    (Join-Path $env:LOCALAPPDATA 'VALORANT\Saved\Crashes'),
    (Join-Path $env:LOCALAPPDATA 'Riot Games\Riot Client\Data')
)
$shaderPaths = @('NVIDIA\DXCache', 'NVIDIA\GLCache', 'AMD\DxCache', 'AMD\GLCache', 'D3DSCache') | ForEach-Object { Join-Path $env:LOCALAPPDATA $_ }

function Get-ActiveAdapters {
    Get-NetAdapter -ErrorAction Stop | Where-Object Status -EQ 'Up'
}

function Get-TaskAvailability([object[]] $VideoControllers) {
    $blocked = @{}
    # An unsuccessful probe provides no evidence that a task is unavailable.
    if ($null -ne $VideoControllers) {
        $nvidia = @($VideoControllers | Where-Object PNPDeviceID -Match '^PCI\\VEN_10DE')
        if ($nvidia.Count -eq 0) {
            $blocked.btnDriverNvidia581 = 'CompatNoNvidia'
            $blocked.btnDriverNvidia566 = 'CompatNoNvidia'
        } elseif (-not ($nvidia | Where-Object Name -NotMatch '\bRTX\s+50\d{2}\b')) {
            $blocked.btnDriverNvidia566 = 'CompatNvidia566'
        }
    }
    try {
        if (-not (Get-WingetExecutable)) {
            $blocked.WingetApps = 'CompatNoWinget'
            $blocked.btnPostInstall = 'CompatNoWinget'
        }
    } catch {}
    try {
        if (-not (Get-Command Get-NetAdapter -ErrorAction Ignore) -or
            -not (Get-Command Set-DnsClientServerAddress -ErrorAction Ignore)) {
            $blocked.btnApplyDns = 'CompatNoDnsTools'
            $blocked.DnsCloud = 'CompatNoDnsTools'
        } elseif (-not (Get-ActiveAdapters)) {
            $blocked.btnApplyDns = 'CompatNoAdapter'
            $blocked.DnsCloud = 'CompatNoAdapter'
        }
    } catch {}
    try {
        if ($true -notin @(Test-Path -LiteralPath $riotPaths -PathType Container -ErrorAction Stop)) {
            $blocked.CleanRiot = 'CompatNoRiotCache'
            $blocked.btnClearRiotLog = 'CompatNoRiotCache'
        }
    } catch {}
    try {
        if (-not (Get-CompatibleBackups)) { $blocked.btnRestoreReg = 'CompatNoBackup' }
    } catch {}
    if (-not (Get-Command Set-MpPreference -ErrorAction Ignore) -or
        -not (Get-Command Get-MpComputerStatus -ErrorAction Ignore)) {
        $blocked.btnEnableDefender = 'CompatNoDefender'
    }
    return $blocked
}

function Repair-System {
    Write-GuiLog 'Đang chạy DISM RestoreHealth.' 'info'
    Invoke-ExactNative 'DISM.exe' @('/Online','/Cleanup-Image','/RestoreHealth')
    Set-Progress 50
    Write-GuiLog 'Đang chạy SFC.' 'info'
    Invoke-ExactNative 'sfc.exe' @('/scannow')
    Set-Progress 100
    $script:resultStatus = 'check'
    $script:resultText = 'Đã chạy DISM và SFC. Xem kết quả chi tiết trong nhật ký.'
}

$workerTasks = @{
    HardwareSummary = {
        $video = $null
        try { $video = @(Get-CimInstance Win32_VideoController -ErrorAction Stop) } catch {}
        $hardware = Read-Hardware $video
        $hardware.Availability = Get-TaskAvailability $video
        Write-Frame 'data' '' '' $null $hardware
    }
    StartupRead = {
        $items = @(foreach ($scope in @('User','Machine')) {
            if (Test-Path -LiteralPath $startupPaths[$scope]) {
                $key = Get-Item -LiteralPath $startupPaths[$scope]
                foreach ($name in $key.GetValueNames()) {
                    if ($name) { @{ Scope = $scope; Name = $name; Value = [string] $key.GetValue($name, $null, 'DoNotExpandEnvironmentNames') } }
                }
            }
        })
        Write-Frame 'data' '' '' $null $items
    }
    StartupRemove = {
        if (-not $payload -or @($payload).Count -gt 100) { throw 'Danh sách Startup không hợp lệ.' }
        $entries = @(foreach ($item in $payload) {
            if ($item.Scope -notin @('User','Machine') -or -not $item.Name -or $item.Name.Length -gt 512 -or
                ($item.Scope -eq 'Machine' -and -not $isAdmin)) { throw 'Không được phép sửa mục Startup này.' }
            $path = $startupPaths[[string]$item.Scope]
            $key = Get-Item -LiteralPath $path
            $value = $key.GetValue([string]$item.Name, $null, 'DoNotExpandEnvironmentNames')
            if ($null -eq $value -or [string]$value -cne [string]$item.Value) {
                throw "Mục Startup đã thay đổi: $($item.Name). Mở lại danh sách."
            }
            @{ Name = [string]$item.Name; Path = $path; Value = $value; Type = $key.GetValueKind([string]$item.Name).ToString() }
        })
        $root = New-TaskDirectory (Join-Path $env:LOCALAPPDATA 'Meowize\Startup')
        $file = Join-Path $root "Startup_$([guid]::NewGuid().ToString('N')).json"
        $entries | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $file -Encoding UTF8
        foreach ($item in $entries) { Remove-ItemProperty -LiteralPath $item.Path -Name $item.Name }
        $script:resultText = "Đã xử lý $($entries.Count) mục. Bản sao: $file"
    }
    BackupList = {
        Write-Frame 'data' '' '' $null @(Get-CompatibleBackups)
    }
    RestorePoint = { Invoke-CreateRestoreAndBackup }
    BackupReg = {
        $root = if ([IO.Directory]::Exists('D:\')) { 'D:\Meowize_Backup' } else { Join-Path $backupPath 'BranchExports' }
        $root = New-TaskDirectory $root
        $stamp = "$(Get-Date -Format yyyyMMdd_HHmmss)_$([guid]::NewGuid().ToString('N').Substring(0,6))"
        Invoke-ExactNative 'reg.exe' @('export','HKLM\SYSTEM\CurrentControlSet\Control',(Join-Path $root "HKLM_Control_$stamp.reg"),'/y')
        Invoke-ExactNative 'reg.exe' @('export','HKCU\Software\Microsoft\Windows\CurrentVersion',(Join-Path $root "HKCU_Win_$stamp.reg"),'/y')
        $script:resultText = "Đã lưu hai nhánh Registry tại $root."
    }
    CleanSystem = { Clear-Caches $tempPaths }
    CleanRiot = { Clear-Caches $riotPaths }
    ShaderCache = { Clear-Caches $shaderPaths }
    SfcDism = { Repair-System }
    btnClearTemp = { Clear-Caches $tempPaths }
    btnClearRiotLog = { Clear-Caches $riotPaths }
    btnShaderCache = { Clear-Caches $shaderPaths }
    btnDiskCleanAdv = {
        Clear-Caches ($tempPaths + @(
            (Join-Path $env:windir 'SoftwareDistribution\Download'),
            (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Explorer'),
            (Join-Path $env:windir 'Logs'),
            (Join-Path $env:LOCALAPPDATA 'CrashDumps'),
            (Join-Path $env:ProgramData 'Microsoft\Windows\WER')
        ))
    }
    btnApplyDns = {
        $options = @(
            ,@('1.1.1.1','1.0.0.1')
            ,@('8.8.8.8','8.8.4.4')
            ,@('9.9.9.9','149.112.112.112')
            ,@('94.140.14.14','94.140.15.15')
            ,@('208.67.222.222','208.67.220.220')
        )
        if ($null -eq $payload.Index -or $payload.Index -isnot [int] -or $payload.Index -lt 0 -or $payload.Index -ge $options.Count) {
            throw 'Mục DNS không hợp lệ.'
        }
        $adapters = @(Get-ActiveAdapters)
        if (-not $adapters.Count) { throw 'Không có adapter mạng đang hoạt động.' }
        foreach ($adapter in $adapters) {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses $options[$payload.Index]
            $actual = (Get-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4).ServerAddresses
            if (($actual -join ',') -ne ($options[$payload.Index] -join ',')) { throw "DNS chưa khớp trên $($adapter.Name)." }
        }
        Invoke-ExactNative 'ipconfig.exe' @('/flushdns')
        $script:resultText = "Đã áp dụng DNS cho $($adapters.Count) adapter."
    }
    btnCreatePoint = { New-RestorePoint }
    btnEnableDefender = {
        Set-MpPreference -DisableRealtimeMonitoring $false
        if (-not (Get-MpComputerStatus).RealTimeProtectionEnabled) {
            throw 'Windows vẫn chưa bật bảo vệ thời gian thực. Kiểm tra ứng dụng Windows Security hoặc chính sách quản trị.'
        }
        $script:resultText = 'Đã xác minh Windows bật bảo vệ thời gian thực.'
    }
    btnBackupSys = { New-RegistrySnapshot 'Manual' }
    btnRestoreReg = { Restore-RegistrySnapshot ([string]$payload.Id) }
    btnRepair = { Repair-System }
    btnExportHtml = { Save-HardwareReport }
    btnSystemSnapshot = { Invoke-CreateRestoreAndBackup }
    btnBios = {
        Invoke-ExactNative 'shutdown.exe' @('/r','/fw','/t','0')
        $script:resultText = 'Đã gửi yêu cầu khởi động vào UEFI.'
    }
}
