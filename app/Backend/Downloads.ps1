function Save-VendorFile([uri] $Uri, [string[]] $Hosts, [string] $Filename, [long] $MaxBytes) {
    $folder = New-TaskDirectory (Join-Path $env:LOCALAPPDATA "Meowize\Downloads\$([guid]::NewGuid().ToString('N'))")
    $path = Join-Path $folder $Filename
    $response = $null
    $stream = $null
    $target = $null
    $finished = $false
    try {
        for ($hop = 0; $hop -le 4; $hop++) {
            if ($Uri.Scheme -ne 'https' -or $Uri.DnsSafeHost -notin $Hosts -or $Uri.UserInfo -or -not $Uri.IsDefaultPort) {
                throw 'Địa chỉ tải về không thuộc danh sách nguồn được phép.'
            }
            $request = [Net.HttpWebRequest][Net.WebRequest]::Create($Uri)
            $request.AllowAutoRedirect = $false
            $request.Timeout = 20000
            $request.ReadWriteTimeout = 25000
            $request.UserAgent = 'Meowize/1.3'
            $response = [Net.HttpWebResponse]$request.GetResponse()
            if ([int]$response.StatusCode -eq 200) { break }
            $location = $response.Headers['Location']
            $response.Close()
            $response = $null
            if (-not $location) { throw 'Máy chủ không trả về tệp tải xuống.' }
            $Uri = [uri]::new($Uri, $location)
        }
        if (-not $response) { throw 'Đã vượt giới hạn chuyển hướng khi tải.' }
        if ($response.ContentLength -gt $MaxBytes) { throw 'Gói tải về vượt giới hạn dung lượng.' }
        $stream = $response.GetResponseStream()
        $target = [IO.File]::Open($path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
        $buffer = New-Object byte[] (128 * 1024)
        $read = 0L
        $lastProgress = -1
        while (($count = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $read += $count
            if ($read -gt $MaxBytes) { throw 'Gói tải về vượt giới hạn dung lượng.' }
            $target.Write($buffer, 0, $count)
            if ($response.ContentLength -gt 0) {
                $percent = [int][math]::Min(100, [math]::Floor(100.0 * $read / $response.ContentLength))
                if ($percent -ne $lastProgress) { Set-Progress $percent; $lastProgress = $percent }
            }
        }
        if ($read -lt 4 -or ($response.ContentLength -gt 0 -and $read -ne $response.ContentLength)) {
            throw 'Tệp tải về chưa đầy đủ.'
        }
        $finished = $true
        return $path
    } finally {
        if ($target) { $target.Dispose() }
        if ($stream) { $stream.Dispose() }
        if ($response) { $response.Dispose() }
        if (-not $finished -and [IO.File]::Exists($path)) { [IO.File]::Delete($path) }
    }
}

function Test-Publisher([string] $Path, [string] $Publisher) {
    $signature = Get-AuthenticodeSignature -LiteralPath (Resolve-PlainPath $Path)
    return ($signature.Status -eq 'Valid' -and $signature.SignerCertificate.Subject -match $Publisher)
}

function Start-VendorTool([string] $File, [string] $Publisher, [string] $Arguments, [switch] $Wait) {
    if (-not (Test-Publisher $File $Publisher)) {
        $script:resultStatus = 'manual'
        $script:resultText = "Đã tải tệp. Chưa xác minh được chữ ký nhà phát hành: $File"
        return
    }
    if ($Wait) {
        $process = Start-Process -FilePath $File -WorkingDirectory ([IO.Path]::GetDirectoryName($File)) -ArgumentList $Arguments -PassThru -Wait
        if ($process.ExitCode -notin @(0, 1641, 3010)) { throw "Bộ cài trả về mã lỗi $($process.ExitCode)." }
        if ($process.ExitCode -in @(1641, 3010)) { Write-GuiLog 'Bộ cài yêu cầu khởi động lại.' 'warn' }
    } else {
        Start-Process -FilePath $File -WorkingDirectory ([IO.Path]::GetDirectoryName($File))
    }
    Write-GuiLog "Đã xác minh chữ ký của $([IO.Path]::GetFileName($File))." 'info'
}

function Expand-ToolArchive([string] $Archive, [string] $Name) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $tools = New-TaskDirectory (Join-Path (Get-DesktopPath) 'Meowize_Tools')
    $path = Join-Path $tools $Name
    if (Test-Path -LiteralPath $path) { $path += "_$(Get-Date -Format yyyyMMdd_HHmmss)_$([guid]::NewGuid().ToString('N').Substring(0,6))" }
    $path = New-TaskDirectory $path
    $zip = [IO.Compression.ZipFile]::OpenRead($Archive)
    try {
        $bytes = 0L
        if ($zip.Entries.Count -gt 5000) { throw 'Gói ZIP chứa quá nhiều tệp.' }
        foreach ($entry in $zip.Entries) {
            $full = [IO.Path]::GetFullPath((Join-Path $path $entry.FullName))
            if (-not $full.StartsWith($path + '\', [StringComparison]::OrdinalIgnoreCase) -or
                $entry.FullName.Contains(':') -or $entry.FullName -match '(?:^|[\\/])\.\.(?:[\\/]|$)' -or
                (($entry.ExternalAttributes -shr 16) -band 0xF000) -eq 0xA000) {
                throw 'Đường dẫn trong gói ZIP không hợp lệ.'
            }
            $bytes += $entry.Length
            if ($bytes -gt 750MB) { throw 'Dung lượng giải nén vượt giới hạn.' }
        }
        foreach ($entry in $zip.Entries) {
            $full = Resolve-PlainPath (Join-Path $path $entry.FullName)
            if (-not $entry.Name) {
                New-TaskDirectory $full | Out-Null
            } else {
                New-TaskDirectory ([IO.Path]::GetDirectoryName($full)) | Out-Null
                [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $full, $false)
            }
        }
    } finally {
        $zip.Dispose()
    }
    return $path
}

function Open-PortableTool([uri] $Uri, [string] $Name, [string] $Pattern, [string] $Publisher) {
    Write-GuiLog "Đang tải $Name." 'info'
    $file = Save-VendorFile $Uri @($Uri.DnsSafeHost) "$Name.zip" 100MB
    $folder = Expand-ToolArchive $file $Name
    $executables = @(Get-ChildItem -LiteralPath $folder -Filter $Pattern -File -Recurse | Sort-Object FullName)
    foreach ($executable in $executables) {
        if (Test-Publisher $executable.FullName $Publisher) {
            Start-VendorTool $executable.FullName $Publisher
            return
        }
    }
    $script:resultStatus = 'manual'
    $script:resultText = "Đã giải nén $Name tại $folder. Chưa xác minh được chữ ký tệp chạy."
    Write-GuiLog $script:resultText 'warn'
}

function Install-Nvidia([string] $Version) {
    $device = Get-CimInstance Win32_VideoController | Where-Object PNPDeviceID -Match '^PCI\\VEN_10DE' | Select-Object -First 1
    if (-not $device) { throw 'Không tìm thấy GPU NVIDIA trên máy.' }
    $url = "https://us.download.nvidia.com/Windows/$Version/$Version-desktop-win10-win11-64bit-international-dch-whql.exe"
    Write-GuiLog "Đang tải driver NVIDIA $Version." 'info'
    $file = Save-VendorFile $url @('us.download.nvidia.com', 'download.nvidia.com') "NVIDIA_$Version.exe" 2GB
    Write-GuiLog 'Đang kiểm tra chữ ký và chạy bộ cài.' 'info'
    Start-VendorTool $file 'CN=NVIDIA Corporation(?:,|$)' '-s' -Wait
}

function Install-Winget([string[]] $Packages) {
    $app = Get-AppxPackage Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $app.InstallLocation) { throw 'Chưa có Windows Package Manager (App Installer).' }
    $winget = Join-Path $app.InstallLocation 'winget.exe'
    if (-not [IO.File]::Exists($winget)) { throw 'Không tìm thấy winget trong App Installer.' }
    $count = 0
    foreach ($package in $Packages) {
        Write-GuiLog "Đang xử lý $package." 'info'
        & $winget install --id $package --exact --source winget --silent --accept-source-agreements --accept-package-agreements --disable-interactivity |
            ForEach-Object { if ($_.Trim()) { Write-GuiLog $_ 'info' } }
        if ($LASTEXITCODE -ne 0) { $script:nativeErrors.Add("winget $package ($LASTEXITCODE)") }
        $count++
        Set-Progress ([int](100.0 * $count / $Packages.Count))
    }
}

$downloadTasks = @{
    btnDDU = {
        $uri = 'https://www.wagnardsoft.com/DDU/download/DDU%20v18.0.8.6.exe'
        $file = Save-VendorFile $uri @('www.wagnardsoft.com', 'wagnardsoft.com') 'DDU-18.0.8.6.exe' 100MB
        Start-VendorTool $file 'CN=Wagnardsoft[^,]*(?:,|$)'
    }
    btnDriverNvidia581 = { Install-Nvidia '581.80' }
    btnDriverNvidia566 = { Install-Nvidia '566.36' }
    btnAppsDesktop = {
        Open-PortableTool 'https://download.cpuid.com/cpu-z/cpu-z_2.11-en.zip' 'CPU-Z' '*x64.exe' 'CN=CPUID[^,]*(?:,|$)'
        Open-PortableTool 'https://download.cpuid.com/hwmonitor/hwmonitor_1.55.zip' 'HWMonitor' '*x64.exe' 'CN=CPUID[^,]*(?:,|$)'
    }
    btnUnparkApp = {
        Open-PortableTool 'https://coderbag.com/assets/downloads/disable-cpu-core-parking/Unpark-CPU-App.zip' 'UnparkCpu' '*.exe' 'CN=CoderBag[^,]*(?:,|$)'
    }
    btnInstallCpp = {
        $file = Save-VendorFile 'https://aka.ms/vs/17/release/vc_redist.x64.exe' @('aka.ms','download.visualstudio.microsoft.com') 'vc_redist.x64.exe' 100MB
        Start-VendorTool $file 'CN=Microsoft Corporation(?:,|$)' '/install /passive /norestart' -Wait
    }
    btnPostInstall = { Install-Winget @('Google.Chrome', 'Discord.Discord', '7zip.7zip') }
    WingetApps = { Install-Winget @('Google.Chrome', 'Discord.Discord', '7zip.7zip', 'UniKey.UniKey', 'DucFabulous.UltraViewer', 'VNGCorp.Zalo') }
}
