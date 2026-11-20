# Ported from THPO v1.3 by Ngo Thanh Hai (Haisosad), revision 396552f4cbc20dbaa00cecf0677e68a185f96a66.
# This file defines operations. The entry point in Run-Task.ps1 controls invocation and permissions.

function Invoke-UnparkCores {
    powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 0cc12610-097a-410a-ac78-05f302e078b9 100 2>$null | Out-Null
    powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR 0cc12610-097a-410a-ac78-05f302e078b9 100 2>$null | Out-Null
    powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR ea062031-0e34-4ff1-9844-222a0887e127 100 2>$null | Out-Null
    powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR ea062031-0e34-4ff1-9844-222a0887e127 100 2>$null | Out-Null
    powercfg -setactive SCHEME_CURRENT 2>$null | Out-Null
}

function Enable-UltimatePerformance {
    powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null | Out-Null
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null | Out-Null
}

function Invoke-KillBloatware {
    Write-GuiLog "[*] Don tien trinh ngam, giai phong CPU truoc khi toi uu..." $colorCyan
    $bloatProcesses = @(
        "OneDrive", "Teams", "msedge", "Cortana", "SearchApp",
        "YourPhone", "SkypeApp", "GameBar", "GameBarPresenceWriter",
        "MicrosoftEdgeUpdate", "backgroundTaskHost", "TextInputHost",
        "WindowsTerminal"
    )
    $killed = 0
    $bloatProcesses | ForEach-Object {
        $proc = Get-Process -Name $_ -ErrorAction SilentlyContinue
        if ($proc) {
            $proc | Stop-Process -Force -ErrorAction SilentlyContinue
            $killed++
        }
    }
    Write-GuiLog "  [+] Da giai phong $killed tien trinh ngam ton CPU/RAM." $colorSuccess
}

function Invoke-SetGamePriority {
    Write-GuiLog "[*] Dang dang ky High Priority (CPU = High) cho cac tua game eSports..." $colorSuccess
    $games = @(
        "DeltaForceClient-Win64-Shipping.exe", "DeltaForce.exe",
        "cs2.exe", "valorant-win64-shipping.exe", "VALORANT.exe",
        "TslGame.exe", "ExecPubg.exe",
        "NarakaBladepoint.exe", "Naraka.exe",
        "GTA5.exe", "PlayGTAV.exe",
        "r5apex.exe", "FortniteClient-Win64-Shipping.exe",
        "overwatch.exe", "eldenring.exe"
    )
    $count = 0
    $games | ForEach-Object {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$_\PerfOptions"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force -ErrorAction SilentlyContinue | Out-Null }
        Set-ItemProperty -Path $path -Name "CpuPriorityClass" -Value 3 -Type DWord -ErrorAction SilentlyContinue
        $count++
    }
    Write-GuiLog "  [+] Da gan High Priority thanh cong cho $count file thuc thi game!" $colorSuccess
}

function Disable-HPETDeviceManager {
    Write-GuiLog "[*] Dang tat HPET trong Device Manager & BCD (Giam Input Lag)..." $colorAccent
    try {
        $hpetDevices = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*High precision event timer*" -or $_.InstanceId -like "*PNP0103*" }
        if ($hpetDevices) {
            foreach ($dev in $hpetDevices) {
                Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
                Write-GuiLog "  [+] Da tat HPET trong Device Manager: $($dev.InstanceId)" $colorCyan
            }
        } else {
            Write-GuiLog "  [i] Device Manager khong co HPET hoac da tat san." $colorYellow
        }
        # BCD settings
        bcdedit /set useplatformclock false 2>$null | Out-Null
        bcdedit /deletevalue useplatformclock 2>$null | Out-Null
        bcdedit /set useplatformtick yes 2>$null | Out-Null
        bcdedit /set disabledynamictick yes 2>$null | Out-Null
        Write-GuiLog "  [+] Da tat HPET trong BCD & Device Manager!" $colorSuccess
    } catch {
        Write-GuiLog "  [-] Loi khi tat HPET: $_" $colorWarn
    }
}

function Invoke-TalonOptimization {
    Write-GuiLog "======================================================" $colorAccent
    Write-GuiLog "[TALON SUITE] BAT DAU TOI UU TOAN DIEN WINDOWS (9 GIAI DOAN)" $colorAccent
    Write-GuiLog "======================================================" $colorAccent
    # Giai doan 1: Telemetry, Tracking & Diagnostic Data
    Write-GuiLog "[1/9] Vo hieu hoa Telemetry, Diagnostic Data, Activity History & WPBT..." $colorCyan
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "DisableWPBT" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    Start-Sleep -Milliseconds 70
    # Giai doan 2: Windows Copilot, Recall AI & Generative AI
    Write-GuiLog "[2/9] Go bo triet de Windows Copilot, Recall AI, Paint AI & Notepad AI..." $colorCyan
    reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "TurnOffRecall" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsAI" /v "TurnOffRecall" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsAppSDK" /v "DisableGenerativeAI" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    Start-Sleep -Milliseconds 70
    # Giai doan 3: Consumer Features, Ads & Delivery Optimization P2P
    Write-GuiLog "[3/9] Tat quang cao, Consumer Features & Delivery Optimization P2P..." $colorCyan
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    Set-Service -Name "DoSvc" -StartupType Disabled -ErrorAction SilentlyContinue
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "SettingsPageVisibility" /t REG_SZ /d "hide:home" /f 2>$null | Out-Null
    Start-Sleep -Milliseconds 70
    # Giai doan 4: Classic Right Click Menu & Windows 10 Explorer
    Write-GuiLog "[4/9] Khoi phuc Menu chuot phai Windows 10 Classic (Phan hoi 0ms)..." $colorSuccess
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace_36354489\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d "NotSpecified" /f 2>$null | Out-Null
    Start-Sleep -Milliseconds 70
    # Giai doan 5: Sticky Keys, Toggle Keys & Filter Keys
    Write-GuiLog "[5/9] Tat Sticky Keys (Shift 5 lan) & Filter Keys (Chong vang/khung game)..." $colorSuccess
    reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f 2>$null | Out-Null
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f 2>$null | Out-Null
    reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f 2>$null | Out-Null
    Start-Sleep -Milliseconds 70
    # Giai doan 6: Start Menu, Bing Search & Widgets
    Write-GuiLog "[6/9] Tat Bing Search tren Start Menu, Widgets & Recommended section..." $colorCyan
    reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_IrisRecommendations" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    Start-Sleep -Milliseconds 70
    # Giai doan 7: Scheduled Tasks Debloat
    Write-GuiLog "[7/9] Vo hieu hoa 15+ Scheduled Tasks thu thap du lieu & Telemetry..." $colorYellow
    $tasksToDisable = @(
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Application Experience\StartupAppTask",
        "\Microsoft\Windows\Application Experience\MareBackup",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
        "\Microsoft\Windows\Maps\MapsUpdateTask",
        "\Microsoft\Windows\Maps\MapsToastTask",
        "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem",
        "\Microsoft\Windows\Autochk\Proxy",
        "\Microsoft\Windows\Feedback\Siuf\DmClient",
        "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
        "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
    )
    $disabledTasksCount = 0
    foreach ($task in $tasksToDisable) {
        $taskPath = $task.Substring(0, $task.LastIndexOf('\')+1)
        $taskName = $task.Substring($task.LastIndexOf('\')+1)
        try {
            Disable-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue | Out-Null
            $disabledTasksCount++
        } catch {}
    }
    Write-GuiLog "  [+] Da vo hieu hoa $disabledTasksCount Scheduled Tasks rac ngam." $colorSuccess
    Start-Sleep -Milliseconds 70
    # Giai doan 8: Background Apps & Explorer Snappiness
    Write-GuiLog "[8/9] Toi uu do phan hoi Desktop, Explorer & Background Apps..." $colorCyan
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Control Panel\Desktop" /v "WaitToKillServiceTimeout" /t REG_SZ /d 2000 /f 2>$null | Out-Null
    reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarEndTask" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    Start-Sleep -Milliseconds 70
    # Giai doan 9: Kernel Memory Paging & Power Throttling
    Write-GuiLog "[9/9] Khoa Kernel vao RAM (DisablePagingExecutive) & Tat Power Throttling..." $colorSuccess
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 8 /f 2>$null | Out-Null
    Start-Sleep -Milliseconds 70
    Write-GuiLog "[HOAN TAT] Talon Windows Optimization Suite da ap dung 100%!" $colorSuccess
}

function Invoke-EnableHAGS {
    try {
        $gfxPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
        if (-not (Test-Path $gfxPath)) { New-Item -Path $gfxPath -Force | Out-Null }
        Set-ItemProperty -Path $gfxPath -Name "HwSchMode" -Value 2 -Type DWord -Force
        Write-GuiLog "  [+] Da kich hoat HAGS (HwSchMode = 2)." $colorSuccess
    } catch {
        Write-GuiLog "  [-] Loi HAGS: $_" $colorWarn
    }
}

function Invoke-DisableULPS {
    Write-GuiLog "[*] Dang tat ULPS (CPU / GPU Ultra Low Power State)..." $colorAccent
    $disabledCount = 0
    try {
        $videoClassKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
        if (Test-Path $videoClassKey) {
            Get-ChildItem -Path $videoClassKey -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                $subKey = $_.PSPath
                $props = Get-ItemProperty -Path $subKey -ErrorAction SilentlyContinue
                if ($null -ne $props.EnableUlps) {
                    Set-ItemProperty -Path $subKey -Name "EnableUlps" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                    $disabledCount++
                }
                if ($null -ne $props.EnableUlps_NA) {
                    Set-ItemProperty -Path $subKey -Name "EnableUlps_NA" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                    $disabledCount++
                }
            }
        }
    } catch {}
    try {
        $hfsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\ProcessorPerformance\HFS"
        if (-not (Test-Path $hfsPath)) { New-Item -Path $hfsPath -Force | Out-Null }
        Set-ItemProperty -Path $hfsPath -Name "Enable" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        $disabledCount++
    } catch {}
    try {
        powercfg -attributes SUB_PROCESSOR 0E4F0A28-2E6F-467E-9F96-8F5CEDC56F3E -ATTRIBUTES 2>$null
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 0E4F0A28-2E6F-467E-9F96-8F5CEDC56F3E 0 2>$null
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR 0E4F0A28-2E6F-467E-9F96-8F5CEDC56F3E 0 2>$null
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS 50db5c2c-238f-4741-a18a-19c30f205162 0 2>$null
        powercfg -setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS 50db5c2c-238f-4741-a18a-19c30f205162 0 2>$null
        powercfg -setactive SCHEME_CURRENT 2>$null
        $disabledCount++
    } catch {}
    Write-GuiLog "  [+] Da tat ULPS ($disabledCount thiet lap chong tut xung GPU/CPU)!" $colorSuccess
}

function Invoke-FpsBoostProfile {
    Write-GuiLog "[*] Kich hoat Power Plan ThanhHaiPerformance & Toi uu 1% Low..." $colorAccent
    try {
        $allPlans = powercfg /list
        $targetGuid = $null
        foreach ($line in ($allPlans -split "`r?`n")) {
            if ($line -match "ThanhHaiPerformance") {
                if ($line -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
                    $targetGuid = $matches[1]
                    break
                }
            }
        }
        if (-not $targetGuid) {
            $dupResult = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
            if ($dupResult -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
                $targetGuid = $matches[1]
            } else {
                $dupResult = powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
                if ($dupResult -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
                    $targetGuid = $matches[1]
                }
            }
            if ($targetGuid) {
                powercfg -changename $targetGuid "ThanhHaiPerformance" "Goi dien nang toi uu Gaming Low Latency & 1% Low boi Ngo Thanh Hai"
            } else {
                $targetGuid = "SCHEME_CURRENT"
            }
        }
        powercfg -setactive $targetGuid 2>$null
        powercfg -change -disk-timeout-ac 0 2>$null
        powercfg -change -standby-timeout-ac 0 2>$null
        powercfg -change -hibernate-timeout-ac 0 2>$null
        powercfg -setacvalueindex $targetGuid SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null
        powercfg -setacvalueindex $targetGuid SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null
        powercfg -setacvalueindex $targetGuid SUB_PROCESSOR CPMINCORES 100 2>$null
        powercfg -setacvalueindex $targetGuid SUB_PROCESSOR CPMAXCORES 100 2>$null
        powercfg -setacvalueindex $targetGuid SUB_PROCESSOR 0E4F0A28-2E6F-467E-9F96-8F5CEDC56F3E 0 2>$null
        powercfg -setacvalueindex $targetGuid SUB_PROCESSOR SYSCOOLPOL 0 2>$null
        powercfg -setacvalueindex $targetGuid SUB_PCIEXPRESS 50db5c2c-238f-4741-a18a-19c30f205162 0 2>$null
        powercfg -setactive $targetGuid 2>$null
        Write-GuiLog "  [+] Da kich hoat Power Plan: ThanhHaiPerformance" $colorSuccess
    } catch {}
    # Win32PrioritySeparation = 26 (0x1A - 3:1 Foreground Boost)
    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 26 -Type DWord -Force
        Write-GuiLog "  [+] Da khoa Win32PrioritySeparation = 26 (On dinh 1% Low FPS)" $colorSuccess
    } catch {}
    # Disable MPO
    try {
        $dwmPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
        if (-not (Test-Path $dwmPath)) { New-Item -Path $dwmPath -Force | Out-Null }
        Set-ItemProperty -Path $dwmPath -Name "OverlayTestMode" -Value 5 -Type DWord -Force
        $mpoPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MultiplaneOverlay"
        if (-not (Test-Path $mpoPath)) { New-Item -Path $mpoPath -Force | Out-Null }
        Set-ItemProperty -Path $mpoPath -Name "EnableMPO" -Value 0 -Type DWord -Force
        Write-GuiLog "  [+] Da tat MPO (Multiplane Overlay) chong drop FPS" $colorSuccess
    } catch {}
    # Multimedia System Profile & GPU Priority 8
    try {
        $sysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        Set-ItemProperty -Path $sysProfile -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $sysProfile -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
        Set-ItemProperty -Path $sysProfile -Name "NoLazyMode" -Value 1 -Type DWord -Force
        $gameTask = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
        if (-not (Test-Path $gameTask)) { New-Item -Path $gameTask -Force | Out-Null }
        Set-ItemProperty -Path $gameTask -Name "GPU Priority" -Value 8 -Type DWord -Force
        Set-ItemProperty -Path $gameTask -Name "Priority" -Value 6 -Type DWord -Force
        Set-ItemProperty -Path $gameTask -Name "Scheduling Category" -Value "High" -Type String -Force
        Set-ItemProperty -Path $gameTask -Name "SFIO Priority" -Value "High" -Type String -Force
        Write-GuiLog "  [+] Da toi uu Multimedia SystemProfile (GPU Priority 8, Responsiveness 0)" $colorSuccess
    } catch {}
    # Dynamic Tick & TSC Sync Enhanced
    try {
        bcdedit /set disabledynamictick yes 2>$null | Out-Null
        bcdedit /set useplatformtick yes 2>$null | Out-Null
        bcdedit /deletevalue useplatformclock 2>$null | Out-Null
        bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
        Write-GuiLog "  [+] Da bat TSC Sync Enhanced & tat Dynamic Tick (Frametime pacing phang li)" $colorSuccess
    } catch {}
    # Disable GameDVR
    try {
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_EFSEFeatureFlags" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-GuiLog "  [+] Da tat GameDVR & Ep Exclusive Fullscreen" $colorSuccess
    } catch {}
    # Mouse Acceleration Fix
    try {
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force
        Write-GuiLog "  [+] Da tat gia toc chuot (Chuan Aim 1:1 eSports)" $colorSuccess
    } catch {}
    # Disable Paging Executive & Power Throttling
    try {
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f 2>$null | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f 2>$null | Out-Null
        Write-GuiLog "  [+] Da khoa Kernel vao RAM & tat Power Throttling" $colorSuccess
    } catch {}
}

function Invoke-DisableNetworkPowerSaving {
    Write-GuiLog "[*] Dang tat che do tiet kiem dien tren tat ca Card mang..." $colorCyan
    try {
        Get-NetAdapter | Set-NetAdapterPowerManagement -AllowComputerToPowerOff Disabled -ErrorAction SilentlyContinue
        Get-NetAdapterAdvancedProperty -ErrorAction SilentlyContinue | Where-Object {
            $_.DisplayName -match "Energy Efficient|Power Saving|Green Ethernet|Gigabit Lite"
        } | Set-NetAdapterAdvancedProperty -RegistryValue "0" -ErrorAction SilentlyContinue
        Write-GuiLog "  [+] Da tat Energy Efficient & Green Ethernet (Ping khong bao gio bi delay)!" $colorSuccess
    } catch {
        Write-GuiLog "  [-] Loi tiet kiem dien mang: $_" $colorWarn
    }
}

$legacyTasks = @{
    KillBloat = { Invoke-KillBloatware }
    Hibernate = {
            powercfg -h off 2>$null | Out-Null
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -ErrorAction SilentlyContinue
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da tat Hibernate (powercfg -h off) & Fast Startup (HiberbootEnabled = 0)." $colorSuccess
        }
    DefenderCpu = {
            Set-MpPreference -ScanAvgCPULoadFactor 20 -EnableLowCpuPriority $true -ErrorAction SilentlyContinue
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "AvgCPULoadFactor" /t REG_DWORD /d 20 /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "EnableLowCpuPriority" /t REG_DWORD /d 1 /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da gioi han Windows Defender: ScanAvgCPULoadFactor = 20%, LowCpuPriority = True." $colorSuccess
        }
    SysMain = {
            Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
            reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" /t REG_DWORD /d 4 /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da tat triet de dich vu SysMain (Superfetch), ngan chan full disk & giam nen RAM." $colorSuccess
        }
    Telemetry = {
            $services = @("DiagTrack", "dmwappushservice", "SysMain", "MapsBroker")
            foreach ($svc in $services) {
                Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f 2>$null | Out-Null
            Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\*" -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
            Get-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\*" -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
            Write-GuiLog "  [+] Da vo hieu hoa toan bo Telemetry, DiagTrack, MapsBroker va Diagnostic Data Collection." $colorSuccess
        }
    DebloatUWP = {
            $bloatApps = @(
                "*Microsoft.XboxApp*", "*Microsoft.XboxGamingOverlay*", "*Microsoft.XboxIdentityProvider*",
                "*Microsoft.XboxSpeechToTextOverlay*", "*Microsoft.Xbox.TCG*", "*Microsoft.GamingApp*",
                "*Microsoft.BingNews*", "*Microsoft.BingWeather*", "*Microsoft.BingSports*", "*Microsoft.BingFinance*",
                "*Microsoft.GetHelp*", "*Microsoft.Getstarted*", "*Microsoft.MicrosoftOfficeHub*",
                "*Microsoft.MicrosoftSolitaireCollection*", "*Microsoft.People*", "*Microsoft.WindowsFeedbackHub*",
                "*Microsoft.YourPhone*", "*Microsoft.WindowsMaps*", "*Microsoft.ZuneMusic*", "*Microsoft.ZuneVideo*",
                "*Microsoft.PowerAutomateDesktop*", "*Microsoft.Todos*", "*Clipchamp.Clipchamp*"
            )
            foreach ($app in $bloatApps) {
                Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Out-Null
                Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
            }
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f 2>$null | Out-Null
            reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
            $protocols = @("ms-gamingoverlay", "ms-gamebar", "ms-gamebarservices", "ms-gamingoverlaywidget")
            foreach ($p in $protocols) {
                reg delete "HKCR\$p" /f 2>$null | Out-Null
                reg delete "HKLM\SOFTWARE\Classes\$p" /f 2>$null | Out-Null
                reg add "HKCR\$p" /v "URL Protocol" /t REG_SZ /d "" /f 2>$null | Out-Null
                reg add "HKCR\$p\shell\open\command" /ve /t REG_SZ /d "systray.exe" /f 2>$null | Out-Null
            }
            Write-GuiLog "  [+] Da go sach Bloatware UWP mac dinh & chan vinh vien popup ms-gamingoverlay." $colorSuccess
        }
    InputQueue = {
            New-Item -Path "HKCU:\Software\Microsoft\GameBar" -Force -ErrorAction SilentlyContinue | Out-Null
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 -ErrorAction SilentlyContinue
            reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f 2>$null | Out-Null
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -ErrorAction SilentlyContinue
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f 2>$null | Out-Null
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 20 -ErrorAction SilentlyContinue
            reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 20 /f 2>$null | Out-Null
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 20 -ErrorAction SilentlyContinue
            reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 20 /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da bat Windows Game Mode, HAGS va set Mouse/Keyboard DataQueueSize = 20." $colorSuccess
        }
    FlipModel = {
            reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "SwapEffectUpgradeEnable=1;" /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "SwapEffectUpgradeEnable=1;" /f 2>$null | Out-Null
            reg add "HKCU\System\GameConfigStore" /v "Win32_AutoFlip" /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\DWM" /v "SwapEffectUpgradeEnable" /t REG_DWORD /d 1 /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da ep Presentation Flip Model (SwapEffectUpgradeEnable=1) cho DWM (Input lag Windowed bang Fullscreen)." $colorSuccess
        }
    PriorityGame = { Invoke-SetGamePriority }
    HPET = { Disable-HPETDeviceManager }
    Win32Pri = {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -ErrorAction SilentlyContinue
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f 2>$null | Out-Null
            bcdedit /set useplatformtick yes 2>$null | Out-Null
            bcdedit /deletevalue useplatformclock 2>$null | Out-Null
            bcdedit /set disabledynamictick yes 2>$null | Out-Null
            Write-GuiLog "  [+] Da khoa Win32PrioritySeparation = 38 (0x26 hex) & BCD Timers Enhanced." $colorSuccess
        }
    MPO = {
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\MultiplaneOverlay" /v EnableMPO /t REG_DWORD /d 0 /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\MultiplaneOverlay" /v OverlayTestMode /t REG_DWORD /d 5 /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da tat MPO (OverlayTestMode = 5 & EnableMPO = 0)." $colorSuccess
        }
    Fullscreen = {
            $fsePath = "HKCU:\System\GameConfigStore"
            if (-not (Test-Path $fsePath)) { New-Item -Path $fsePath -Force | Out-Null }
            Set-ItemProperty -Path $fsePath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force
            Set-ItemProperty -Path $fsePath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force
            Set-ItemProperty -Path $fsePath -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force
            Set-ItemProperty -Path $fsePath -Name "GameDVR_EFSEFeatureFlags" -Value 0 -Type DWord -Force
            # Fix triet de popup ms-gamingoverlay khi tat GameDVR
            $protocols = @("ms-gamingoverlay", "ms-gamebar", "ms-gamebarservices", "ms-gamingoverlaywidget")
            foreach ($p in $protocols) {
                $baseKey = "HKCU:\Software\Classes\$p"
                if (-not (Test-Path $baseKey)) { New-Item -Path $baseKey -Force | Out-Null }
                Set-ItemProperty -Path $baseKey -Name "(Default)" -Value "URL:$p" -Force
                Set-ItemProperty -Path $baseKey -Name "URL Protocol" -Value "" -Force
                Set-ItemProperty -Path $baseKey -Name "NoOpenWith" -Value "" -Force
                $cmdKey = "$baseKey\shell\open\command"
                if (-not (Test-Path $cmdKey)) { New-Item -Path $cmdKey -Force | Out-Null }
                Set-ItemProperty -Path $cmdKey -Name "(Default)" -Value "C:\Windows\System32\systray.exe" -Force
                $hklmKey = "HKLM:\SOFTWARE\Classes\$p"
                if (-not (Test-Path $hklmKey)) { New-Item -Path $hklmKey -Force | Out-Null }
                Set-ItemProperty -Path $hklmKey -Name "(Default)" -Value "URL:$p" -Force
                Set-ItemProperty -Path $hklmKey -Name "URL Protocol" -Value "" -Force
                Set-ItemProperty -Path $hklmKey -Name "NoOpenWith" -Value "" -Force
                $hklmCmd = "$hklmKey\shell\open\command"
                if (-not (Test-Path $hklmCmd)) { New-Item -Path $hklmCmd -Force | Out-Null }
                Set-ItemProperty -Path $hklmCmd -Name "(Default)" -Value "C:\Windows\System32\systray.exe" -Force
            }
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            $polDvr = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
            if (-not (Test-Path $polDvr)) { New-Item -Path $polDvr -Force | Out-Null }
            Set-ItemProperty -Path $polDvr -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Get-Service -Name "BcastDVRUserService*" -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
            Write-GuiLog "  [+] Da tat Fullscreen Optimizations & Ep Exclusive Fullscreen (0ms)." $colorSuccess
            Write-GuiLog "  [+] Da chan triet de loi popup ms-gamingoverlay (HKCU + HKLM)." $colorSuccess
        }
    MSIMode = {
            $enumPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI"
            if (Test-Path $enumPath) {
                Get-ChildItem -Path $enumPath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq "Device Parameters" } | ForEach-Object {
                    $msiPath = Join-Path $_.PSPath "Interrupt Management\MessageSignaledInterruptProperties"
                    if (-not (Test-Path $msiPath)) { New-Item -Path $msiPath -Force -ErrorAction SilentlyContinue | Out-Null }
                    Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1 -Type DWord -ErrorAction SilentlyContinue
                }
            }
            Write-GuiLog "  [+] Da bat MSI Mode cho GPU va Card Mang (Giam DPC Latency)." $colorSuccess
        }
    HAGS = { Invoke-EnableHAGS }
    PowerPlan = { Invoke-FpsBoostProfile }
    UnparkCore = { Invoke-UnparkCores }
    DisableULPS = { Invoke-DisableULPS }
    MouseAim = {
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" 2>$null
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" 2>$null
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" 2>$null
            Write-GuiLog "  [+] Da tat gia toc chuot (Chuan Aim 1:1 eSports)." $colorSuccess
        }
    TscSync = {
            bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
            Write-GuiLog "  [+] Da bat BCD TSC Sync Policy Enhanced." $colorSuccess
        }
    KernelRam = {
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da khoa Windows Kernel vao RAM & tat Power Throttling." $colorSuccess
        }
    Multimedia = {
            $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
            if (Test-Path $mmPath) {
                Set-ItemProperty -Path $mmPath -Name "SystemResponsiveness" -Value 0 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $mmPath -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -ErrorAction SilentlyContinue
            }
            $taskPath = "$mmPath\Tasks\Games"
            if (Test-Path $taskPath) {
                Set-ItemProperty -Path $taskPath -Name "GPU Priority" -Value 8 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $taskPath -Name "Priority" -Value 6 -Type DWord -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $taskPath -Name "Scheduling Category" -Value "High" -Type String -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $taskPath -Name "SFIO Priority" -Value "High" -Type String -ErrorAction SilentlyContinue
            }
            Write-GuiLog "  [+] Da toi uu Multimedia SystemProfile (NetworkThrottling=0xFFFFFFFF, GPU=8)." $colorSuccess
        }
    TdrDelay = {
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d 8 /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da dat TdrDelay = 8 (Chong crash driver GPU)." $colorSuccess
        }
    StickyFix = {
            reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d "506" /f 2>$null | Out-Null
            reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v Flags /t REG_SZ /d "122" /f 2>$null | Out-Null
            reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v Flags /t REG_SZ /d "58" /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da tat Sticky Keys, Toggle Keys, Filter Keys." $colorSuccess
        }
    Talon1 = {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f 2>$null | Out-Null
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v DisableWpbtExecution /t REG_DWORD /d 1 /f 2>$null | Out-Null
            Write-GuiLog "  [+] [Talon 1] Da tat Telemetry, Activity History & WPBT OEM." $colorSuccess
        }
    Talon2 = {
            reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsAI" /v DisableAIDataAnalysis /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v DisableAIDataAnalysis /t REG_DWORD /d 1 /f 2>$null | Out-Null
            Write-GuiLog "  [+] [Talon 2] Da go sach Copilot & Recall AI." $colorSuccess
        }
    Talon3 = {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f 2>$null | Out-Null
            Write-GuiLog "  [+] [Talon 3] Da tat Consumer Features & DoSvc P2P." $colorSuccess
        }
    Talon4 = {
            reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve 2>$null | Out-Null
            Write-GuiLog "  [+] [Talon 4] Da khoi phuc Menu chuot phai Windows 10 Classic." $colorSuccess
        }
    Talon5 = {
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-ed353b709a60}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f 2>$null | Out-Null
            Write-GuiLog "  [+] [Talon 5] Da dat This PC mac dinh & an Gallery." $colorSuccess
        }
    Talon6 = {
            reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f 2>$null | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f 2>$null | Out-Null
            Write-GuiLog "  [+] [Talon 6] Da tat Bing Search & Widgets." $colorSuccess
        }
    Talon7 = {
            $talonTasks = @(
                "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
                "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
                "\Microsoft\Windows\Autochk\Proxy",
                "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
                "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
                "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
                "\Microsoft\Windows\Feedback\Siuf\DmClient",
                "\Microsoft\Windows\Maintenance\WinSAT"
            )
            foreach ($task in $talonTasks) {
                schtasks.exe /change /tn $task /disable 2>$null | Out-Null
            }
            Write-GuiLog "  [+] [Talon 7] Da vo hieu hoa cac Scheduled Tasks thu thap du lieu." $colorSuccess
        }
    Talon8 = {
            @("DiagTrack","dmwappushservice","SysMain","WSearch") | ForEach-Object {
                Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
                Set-Service -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
            }
            Write-GuiLog "  [+] [Talon 8] Da tat cac dich vu rac ngam (DiagTrack, SysMain, WSearch)." $colorSuccess
        }
    Talon9 = {
            $bloatApps = @(
                "Microsoft.3DBuilder", "Microsoft.BingNews", "Microsoft.BingWeather",
                "Microsoft.GetHelp", "Microsoft.SkypeApp", "Microsoft.YourPhone",
                "Microsoft.ZuneVideo", "Microsoft.MixedReality.Portal",
                "Microsoft.WindowsFeedbackHub", "Microsoft.Getstarted",
                "Microsoft.People", "Microsoft.WindowsMaps",
                "Clipchamp.Clipchamp", "Microsoft.549981C3F5F10"
            )
            $bloatApps | ForEach-Object {
                Get-AppxPackage -Name "*$_*" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            }
            Write-GuiLog "  [+] [Talon 9] Da go bo sach Bloatware UWP mac dinh." $colorSuccess
        }
    SpeedUI = {
            reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d 0 /f 2>$null | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarEndTask" /t REG_DWORD /d 1 /f 2>$null | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f 2>$null | Out-Null
            Write-GuiLog "  [+] Da toi uu toc do Explorer, MenuShowDelay = 0, Taskbar End Task." $colorSuccess
        }
    NetLatency = {
            Disable-NetAdapterLso -Name * -IPv4 -IPv6 -ErrorAction SilentlyContinue | Out-Null
            Disable-NetAdapterChecksumOffload -Name * -ErrorAction SilentlyContinue | Out-Null
            Get-NetAdapterAdvancedProperty -DisplayName "*Energy Efficient Ethernet*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue 0 -ErrorAction SilentlyContinue | Out-Null
            Get-NetAdapterAdvancedProperty -DisplayName "*Green Ethernet*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue 0 -ErrorAction SilentlyContinue | Out-Null
            Get-NetAdapterAdvancedProperty -DisplayName "*Gigabit Lite*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue 0 -ErrorAction SilentlyContinue | Out-Null
            Get-NetAdapterAdvancedProperty -DisplayName "*Power Saving Mode*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue 0 -ErrorAction SilentlyContinue | Out-Null
            Get-NetAdapterAdvancedProperty -DisplayName "*Interrupt Moderation*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
            Write-GuiLog "  [+] Da tat Large Send Offload (LSO), Green Ethernet & toi uu DPC Latency Card Mang." $colorSuccess
        }
    TCPGaming = {
            $adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
            foreach ($adapter in $adapters) {
                Set-ItemProperty -Path $adapter.PSPath -Name "TcpAckFrequency" -Value 1 -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $adapter.PSPath -Name "TCPNoDelay" -Value 1 -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $adapter.PSPath -Name "TcpDelAckTicks" -Value 0 -ErrorAction SilentlyContinue
            }
            Write-GuiLog "  [+] Da khoa TCPNoDelay = 1 & TcpAckFrequency = 1 tren toan bo Network Interfaces." $colorSuccess
        }
    NetPower = { Invoke-DisableNetworkPowerSaving }
    DnsCloud = {
            Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
                Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses @("1.1.1.1", "1.0.0.1") -ErrorAction SilentlyContinue
            }
            Write-GuiLog "  [+] Da dat DNS Cloudflare Gaming 1.1.1.1 / 1.0.0.1." $colorSuccess
        }
    ResetNet = {
            ipconfig /flushdns 2>$null | Out-Null
            netsh winsock reset 2>$null | Out-Null
            netsh int ip reset 2>$null | Out-Null
            Write-GuiLog "  [+] Da Flush DNS va Reset toan bo Network Stack." $colorSuccess
        }
    PurgeRAM = {
            [MemoryManager]::ClearAllMemory() | Out-Null
            [System.GC]::Collect()
            Write-GuiLog "  [+] Da xa sach RAM vat ly bang Win32 API." $colorSuccess
        }
    btnFpsBoost = {
    Invoke-FpsBoostProfile
    Show-Popup "Da kich hoat Power Plan ThanhHaiPerformance va toi uu 1% Low FPS!" -title "THPO v1.2"
}
    btnKernelRam = {
    Write-GuiLog "=== KHOA KERNEL VAO RAM (DISABLE PAGING EXECUTIVE) ===" $colorAccent
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    Write-GuiLog "[OK] Da khoa Windows Kernel & Drivers vao physical RAM. Triet tieu micro-stutter!" $colorSuccess
    Show-Popup "Da khoa Kernel vao RAM! Vui long khoi dong lai may de ap dung." -title "THPO v1.2"
}
    btnTscSync = {
    Write-GuiLog "=== DONG BO NHIP TIMERS (TSC SYNC ENHANCED) ===" $colorAccent
    bcdedit /set tscsyncpolicy Enhanced 2>$null | Out-Null
    bcdedit /set useplatformtick yes 2>$null | Out-Null
    bcdedit /deletevalue useplatformclock 2>$null | Out-Null
    bcdedit /set disabledynamictick yes 2>$null | Out-Null
    Write-GuiLog "[OK] Da kich hoat TSC Sync Policy Enhanced tren tat ca cac core CPU!" $colorSuccess
    Show-Popup "Da dong bo TSC Timers Enhanced! Vui long khoi dong lai may." -title "THPO v1.2"
}
    btnStickyFix = {
    Write-GuiLog "=== TAT STICKY KEYS & FILTER KEYS ===" $colorAccent
    reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f 2>$null | Out-Null
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f 2>$null | Out-Null
    reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f 2>$null | Out-Null
    Write-GuiLog "[OK] Da tat tinh nang bam Shift 5 lan hien Sticky Keys. Chong vang game 100%!" $colorSuccess
    Show-Popup "Da tat Sticky Keys & Filter Keys thanh cong!" -title "THPO v1.2"
}
    btnHPETDevMgr = {
    Disable-HPETDeviceManager
    Show-Popup "Da tat HPET trong Device Manager va BCD! Vui long khoi dong lai may." -title "THPO v1.2"
}
    btnUnparkCore = {
    Write-GuiLog "=== UNPARK CORE ALL 100% ===" $colorAccent
    Invoke-UnparkCores
    Write-GuiLog "[OK] Da unpark toan bo nhan/luong CPU 100%!" $colorSuccess
}
    btnGamePriority = {
    Invoke-SetGamePriority
    Show-Popup "Da dang ky High Priority cho tat ca tua game eSports!" -title "THPO v1.2"
}
    btnMPO = {
    $mpoPath = "HKLM:\SOFTWARE\Microsoft\Windows\DWM"
    if (-not (Test-Path $mpoPath)) { New-Item -Path $mpoPath -Force | Out-Null }
    $currentVal = (Get-ItemProperty -Path $mpoPath -Name "OverlayTestMode" -ErrorAction SilentlyContinue).OverlayTestMode
    if ($currentVal -eq 5) {
        Set-ItemProperty -Path $mpoPath -Name "OverlayTestMode" -Value 0 -Type DWord
        Write-GuiLog "[OK] Da BAT lai MPO (MultiPlane Overlay)." $colorSuccess
    } else {
        Set-ItemProperty -Path $mpoPath -Name "OverlayTestMode" -Value 5 -Type DWord
        Write-GuiLog "[OK] Da TAT MPO (MultiPlane Overlay)." $colorSuccess
    }
}
    btnMSIMode = {
    Write-GuiLog "=== KICH HOAT MSI MODE ===" $colorAccent
    Set-Progress 30
    $enumPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI"
    $count = 0
    if (Test-Path $enumPath) {
        Get-ChildItem -Path $enumPath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq "Device Parameters" } | ForEach-Object {
            $msiPath = Join-Path $_.PSPath "Interrupt Management\MessageSignaledInterruptProperties"
            if (-not (Test-Path $msiPath)) { New-Item -Path $msiPath -Force -ErrorAction SilentlyContinue | Out-Null }
            Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1 -Type DWord -ErrorAction SilentlyContinue
            $count++
        }
    }
    Set-Progress 100
    Write-GuiLog "[OK] Da kich hoat MSI Mode cho $count PCI devices." $colorSuccess
    Set-Progress 0
}
    btnHAGS = {
    Invoke-EnableHAGS
    Show-Popup "Da bat Hardware-Accelerated GPU Scheduling (HAGS)! Vui long khoi dong lai may." -title "THPO v1.2"
}
    btnFullscreenOpt = {
    $fsePath = "HKCU:\System\GameConfigStore"
    if (-not (Test-Path $fsePath)) { New-Item -Path $fsePath -Force | Out-Null }
    Set-ItemProperty -Path $fsePath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord
    Set-ItemProperty -Path $fsePath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord
    Set-ItemProperty -Path $fsePath -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord
    Set-ItemProperty -Path $fsePath -Name "GameDVR_EFSEFeatureFlags" -Value 0 -Type DWord
    $protocols = @("ms-gamingoverlay", "ms-gamebar", "ms-gamebarservices", "ms-gamingoverlaywidget")
    foreach ($p in $protocols) {
        $baseKey = "HKCU:\Software\Classes\$p"
        if (-not (Test-Path $baseKey)) { New-Item -Path $baseKey -Force | Out-Null }
        Set-ItemProperty -Path $baseKey -Name "(Default)" -Value "URL:$p" -Force
        Set-ItemProperty -Path $baseKey -Name "URL Protocol" -Value "" -Force
        Set-ItemProperty -Path $baseKey -Name "NoOpenWith" -Value "" -Force
        $cmdKey = "$baseKey\shell\open\command"
        if (-not (Test-Path $cmdKey)) { New-Item -Path $cmdKey -Force | Out-Null }
        Set-ItemProperty -Path $cmdKey -Name "(Default)" -Value "C:\Windows\System32\systray.exe" -Force
        $hklmKey = "HKLM:\SOFTWARE\Classes\$p"
        if (-not (Test-Path $hklmKey)) { New-Item -Path $hklmKey -Force | Out-Null }
        Set-ItemProperty -Path $hklmKey -Name "(Default)" -Value "URL:$p" -Force
        Set-ItemProperty -Path $hklmKey -Name "URL Protocol" -Value "" -Force
        Set-ItemProperty -Path $hklmKey -Name "NoOpenWith" -Value "" -Force
        $hklmCmd = "$hklmKey\shell\open\command"
        if (-not (Test-Path $hklmCmd)) { New-Item -Path $hklmCmd -Force | Out-Null }
        Set-ItemProperty -Path $hklmCmd -Name "(Default)" -Value "C:\Windows\System32\systray.exe" -Force
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    $polDvr = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $polDvr)) { New-Item -Path $polDvr -Force | Out-Null }
    Set-ItemProperty -Path $polDvr -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Get-Service -Name "BcastDVRUserService*" -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
    Write-GuiLog "[OK] Da tat Fullscreen Optimizations & Chan popup ms-gamingoverlay." $colorSuccess
}
    btnTimerRes = {
    $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (Test-Path $mmPath) {
        Set-ItemProperty -Path $mmPath -Name "SystemResponsiveness" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $mmPath -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -ErrorAction SilentlyContinue
    }
    $tasksPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (Test-Path $tasksPath) {
        Set-ItemProperty -Path $tasksPath -Name "GPU Priority" -Value 8 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tasksPath -Name "Priority" -Value 6 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tasksPath -Name "Scheduling Category" -Value "High" -Type String -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $tasksPath -Name "SFIO Priority" -Value "High" -Type String -ErrorAction SilentlyContinue
    }
    Write-GuiLog "[OK] Da toi uu Timer Resolution & Multimedia Profile." $colorSuccess
}
    btnMouseFix = {
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"
    Write-GuiLog "[OK] Da tat gia toc chuot (chuan AIM FPS 1:1)." $colorSuccess
}
    btnKillBloat = {
    Invoke-KillBloatware
    Show-Popup "Da kill cac process rac, giai phong tai nguyen cho game!" -title "THPO v1.2"
}
    btnInputQueue = {
    Write-GuiLog "=== TOI UU BUFFER CHUOT / PHIM & WINDOWS GAME MODE ===" $colorAccent
    New-Item -Path "HKCU:\Software\Microsoft\GameBar" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 -ErrorAction SilentlyContinue
    reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -ErrorAction SilentlyContinue
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f 2>$null | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 20 -ErrorAction SilentlyContinue
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 20 /f 2>$null | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 20 -ErrorAction SilentlyContinue
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 20 /f 2>$null | Out-Null
    Write-GuiLog "[OK] Da bat Windows Game Mode, HAGS va giam Mouse/Keyboard DataQueueSize ve 20 packets." $colorSuccess
    Show-Popup "Da toi uu Buffer Chuot & Ban phim ve 20 packets (0 delay) va bat Game Mode!" -title "THPO v1.3"
}
    btnFlipModel = {
    Write-GuiLog "=== EP DIRECTX PRESENTATION FLIP MODEL (SWAPEFFECTUPGRADEENABLE) ===" $colorAccent
    reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "SwapEffectUpgradeEnable=1;" /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "SwapEffectUpgradeEnable=1;" /f 2>$null | Out-Null
    reg add "HKCU\System\GameConfigStore" /v "Win32_AutoFlip" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\DWM" /v "SwapEffectUpgradeEnable" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    Write-GuiLog "[OK] Da ep DirectX Presentation Flip Model cho DWM (Input lag Windowed bang Fullscreen)." $colorSuccess
    Show-Popup "Da ep Presentation Flip Model! Cac tua game che do Windowed/Borderless se dat do tre input lag toi thieu." -title "THPO v1.3"
}
    btnTalonFull = {
    if (-not (Confirm-Action "Chay goi toi uu Talon Windows Suite toan dien (9 giai doan)?")) { return }
    Set-Progress 15
    Invoke-TalonOptimization
    Set-Progress 100
    Show-Popup "Da ap dung Talon Windows Suite thanh cong! Vui long khoi dong lai may." -title "THPO v1.2"
    Set-Progress 0
}
    btnClassicMenu = {
    Write-GuiLog "=== KHOI PHUC MENU CHUOT PHAI WINDOWS 10 CLASSIC ===" $colorAccent
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve 2>$null | Out-Null
    Write-GuiLog "[OK] Da khoi phuc Menu chuot phai Windows 10 classic! Khoi dong lai Explorer hoac may de hien thi." $colorSuccess
    Show-Popup "Da kich hoat Menu chuot phai Windows 10 co dien (0ms delay)!" -title "THPO v1.2"
}
    btnDisableULPS = {
    Invoke-DisableULPS
    Show-Popup "Da tat ULPS thanh cong! Vui long khoi dong lai may de GPU/CPU ap dung." -title "THPO v1.2"
}
    btnDefenderCpu = {
    Write-GuiLog "=== GIAM TAI CPU CHO WINDOWS DEFENDER ===" $colorAccent
    Set-MpPreference -ScanAvgCPULoadFactor 20 -EnableLowCpuPriority $true -ErrorAction SilentlyContinue
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "AvgCPULoadFactor" /t REG_DWORD /d 20 /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "EnableLowCpuPriority" /t REG_DWORD /d 1 /f 2>$null | Out-Null
    Write-GuiLog "[OK] Da gioi han Windows Defender: ScanAvgCPULoadFactor = 20%, LowCpuPriority = True." $colorSuccess
    Show-Popup "Da thiet lap Windows Defender chay o muc CPU toi da 20% va Low CPU Priority!" -title "THPO v1.3"
}
    btnSysMain = {
    Write-GuiLog "=== TAT DICH VU SYSMAIN (SUPERFETCH) ===" $colorAccent
    Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" /t REG_DWORD /d 4 /f 2>$null | Out-Null
    Write-GuiLog "[OK] Da tat triet de dich vu SysMain (Superfetch), ngan chan 100% full disk & giam nen RAM." $colorSuccess
    Show-Popup "Da tat dich vu SysMain (Superfetch) thanh cong!" -title "THPO v1.3"
}
    btnFastStartup = {
    Write-GuiLog "=== TAT FAST STARTUP & HIBERNATION ===" $colorAccent
    powercfg -h off 2>$null | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -ErrorAction SilentlyContinue
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f 2>$null | Out-Null
    Write-GuiLog "[OK] Da tat Fast Startup (HiberbootEnabled = 0) & Hibernation (powercfg -h off)." $colorSuccess
    Show-Popup "Da tat Fast Startup & Hibernation! Chong ket driver va khong luu cache rac khi reboot." -title "THPO v1.3"
}
    btnTelemetry = {
    Write-GuiLog "=== TAT DICH VU RAC & TELEMETRY ===" $colorAccent
    Set-Progress 20
    $services = @("DiagTrack", "dmwappushservice", "SysMain", "WSearch", "MapsBroker", "lfsvc", "RetailDemo", "DoSvc")
    $stopped = 0
    foreach ($s in $services) {
        $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
        if ($svc) {
            Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
            Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
            $stopped++
            Write-GuiLog "  [+] Da tat dich vu: $s" $colorCyan
        }
    }
    Set-Progress 100
    Write-GuiLog "[OK] Da tat $stopped dich vu telemetry & rac." $colorSuccess
    Set-Progress 0
}
    btnRemoveBloat = {
    if (-not (Confirm-Action "Go bo cac ung dung bloatware mac dinh cua Windows?")) { return }
    Write-GuiLog "=== GO APPS RAC WINDOWS ===" $colorAccent
    Set-Progress 10
    $bloatList = @(
        "Microsoft.3DBuilder", "Microsoft.BingNews", "Microsoft.BingWeather",
        "Microsoft.GetHelp", "Microsoft.Getstarted", "Microsoft.Messaging",
        "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection", "Microsoft.NetworkSpeedTest",
        "Microsoft.News", "Microsoft.Office.OneNote", "Microsoft.People",
        "Microsoft.Print3D", "Microsoft.SkypeApp", "Microsoft.Wallet",
        "Microsoft.Whiteboard", "Microsoft.WindowsAlarms",
        "Microsoft.WindowsFeedbackHub", "Microsoft.WindowsMaps",
        "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo",
        "Clipchamp.Clipchamp", "Microsoft.549981C3F5F10"
    )
    $removed = 0
    $total = $bloatList.Count
    $i = 0
    foreach ($app in $bloatList) {
        $i++
        $pkg = Get-AppxPackage -Name "*$app*" -AllUsers -ErrorAction SilentlyContinue
        if ($pkg) {
            $pkg | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            $removed++
            Write-GuiLog "  [+] Da go: $app" $colorCyan
        }
        Set-Progress ([math]::Round($i / $total * 100))
    }
    Write-GuiLog "[OK] Da go $removed ung dung bloatware." $colorSuccess
    Set-Progress 0
}
    btnClearRam = {
    Write-GuiLog "=== XA RAM (EmptyWorkingSet Win32 API) ===" $colorAccent
    $osBefore = Get-CimInstance Win32_OperatingSystem
    $freeBeforeMB = [math]::Round($osBefore.FreePhysicalMemory / 1024, 0)
    $cleared = [MemoryManager]::ClearAllMemory()
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    $osAfter = Get-CimInstance Win32_OperatingSystem
    $freeAfterMB = [math]::Round($osAfter.FreePhysicalMemory / 1024, 0)
    $freedMB = $freeAfterMB - $freeBeforeMB
    Write-GuiLog "  [+] Da quet $cleared process." $colorCyan
    Write-GuiLog "  [+] RAM trong truoc: $freeBeforeMB MB -> Sau: $freeAfterMB MB" $colorCyan
    if ($freedMB -gt 0) {
        Write-GuiLog "[OK] Da giai phong thanh cong: $freedMB MB RAM!" $colorSuccess
    } else {
        Write-GuiLog "[OK] RAM da o trang thai toi uu nhat!" $colorSuccess
    }
}
    btnHibernate = {
    $hibFile = "C:\hiberfil.sys"
    if (Test-Path $hibFile) {
        powercfg -h off
        Write-GuiLog "[OK] Da TAT Hibernate. Giai phong bo nho tren o C!" $colorSuccess
    } else {
        powercfg -h on
        Write-GuiLog "[OK] Da BAT lai Hibernate." $colorSuccess
    }
}
    btnNetPowerOpt = {
    Invoke-DisableNetworkPowerSaving
    Show-Popup "Da tat che do tiet kiem dien tren toan bo Card mang!" -title "THPO v1.2"
}
    btnDeepPing = {
    Write-GuiLog "=== TOI UU MANG TCP/IP GIAM LATENCY ===" $colorAccent
    $tcpKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem -Path $tcpKey -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-GuiLog "[OK] Da kich hoat TCPNoDelay & TcpAckFrequency = 1!" $colorSuccess
}
    btnNetLatency = {
    Write-GuiLog "=== TOI UU NETWORK DPC LATENCY (TAT LSO & GREEN ETHERNET) ===" $colorAccent
    Disable-NetAdapterLso -Name * -IPv4 -IPv6 -ErrorAction SilentlyContinue | Out-Null
    Disable-NetAdapterChecksumOffload -Name * -ErrorAction SilentlyContinue | Out-Null
    Get-NetAdapterAdvancedProperty -DisplayName "*Energy Efficient Ethernet*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue 0 -ErrorAction SilentlyContinue | Out-Null
    Get-NetAdapterAdvancedProperty -DisplayName "*Green Ethernet*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue 0 -ErrorAction SilentlyContinue | Out-Null
    Get-NetAdapterAdvancedProperty -DisplayName "*Gigabit Lite*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue 0 -ErrorAction SilentlyContinue | Out-Null
    Get-NetAdapterAdvancedProperty -DisplayName "*Power Saving Mode*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue 0 -ErrorAction SilentlyContinue | Out-Null
    Get-NetAdapterAdvancedProperty -DisplayName "*Interrupt Moderation*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
    Write-GuiLog "[OK] Da tat Large Send Offload (LSO), Green Ethernet & toi uu DPC Latency Card Mang." $colorSuccess
    Show-Popup "Da toi uu Network DPC Latency, tat LSO & Green Ethernet thanh cong!" -title "THPO v1.3"
}
    btnFlushDns = {
    Write-GuiLog "=== FLUSH DNS CACHE ===" $colorAccent
    ipconfig /flushdns 2>$null | Out-Null
    Write-GuiLog "[OK] Da xoa sach DNS Resolver Cache!" $colorSuccess
}
    btnResetNetwork = {
    if (-not (Confirm-Action "Reset toan bo Network Stack? May can khoi dong lai sau do.")) { return }
    Write-GuiLog "=== RESET NETWORK STACK ===" $colorWarn
    netsh winsock reset 2>$null | Out-Null
    netsh int ip reset 2>$null | Out-Null
    ipconfig /release 2>$null | Out-Null
    ipconfig /renew 2>$null | Out-Null
    ipconfig /flushdns 2>$null | Out-Null
    Write-GuiLog "[OK] Da reset Winsock, TCP/IP, IPConfig. Vui long khoi dong lai may!" $colorSuccess
}
    btnScanHardware = {
    Write-GuiLog "=== QUET & PHAN TICH PHAN CUNG ===" $colorAccent
    Set-Progress 20
    $cpuObj  = Get-CimInstance Win32_Processor
    $gpuObj  = Get-CimInstance Win32_VideoController
    $ramObj  = Get-CimInstance Win32_ComputerSystem
    $diskObj = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
    Set-Progress 60
    Write-GuiLog "[+] CPU: $($cpuObj.Name)" $colorCyan
    Write-GuiLog "[+] Cores: $($cpuObj.NumberOfCores) | Threads: $($cpuObj.NumberOfLogicalProcessors)" $colorCyan
    Write-GuiLog "[+] GPU: $($gpuObj.Name)" $colorCyan
    Write-GuiLog "[+] RAM: $([math]::Round($ramObj.TotalPhysicalMemory/1GB,1)) GB" $colorCyan
    Write-GuiLog "[+] O C Trong: $([math]::Round($diskObj.FreeSpace/1GB,1)) GB / $([math]::Round($diskObj.Size/1GB,1)) GB" $colorCyan
    Set-Progress 100
    Write-GuiLog "[OK] Hoan tat quet phan cung!" $colorSuccess
    Set-Progress 0
}
    btnSmartCheck = {
    Write-GuiLog "=== KIEM TRA SUC KHOE O CUNG (S.M.A.R.T) ===" $colorAccent
    Set-Progress 30
    try {
        $disks = Get-PhysicalDisk -ErrorAction Stop
        foreach ($d in $disks) {
            $status = $d.HealthStatus
            $media  = $d.MediaType
            $size   = [math]::Round($d.Size / 1GB, 0)
            $color  = if ($status -eq "Healthy") { $colorSuccess } else { $colorWarn }
            Write-GuiLog "[+] $($d.FriendlyName) | $media | $size GB | Trang thai: $status" $color
        }
    } catch {
        Write-GuiLog "[-] Khong doc duoc thong tin SMART: $_" $colorWarn
    }
    Set-Progress 100
    Set-Progress 0
}
    btnTempCheck = {
    Write-GuiLog "=== KIEM TRA NHIET DO CPU ===" $colorAccent
    try {
        $temps = Get-CimInstance -Namespace "root\wmi" -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop
        foreach ($t in $temps) {
            $celsius = [math]::Round(($t.CurrentTemperature - 2732) / 10.0, 1)
            $color = if ($celsius -gt 85) { $colorWarn } elseif ($celsius -gt 70) { $colorYellow } else { $colorSuccess }
            Write-GuiLog "[+] Vung nhiet: $($t.InstanceName) | Nhiet do: ${celsius}*C" $color
        }
    } catch {
        Write-GuiLog "[i] Khong doc duoc WMI thermal. Vui long dung HWMonitor de xem chi tiet." $colorYellow
    }
}
    btnLicenseCheck = {
    Write-GuiLog "=== KIEM TRA LICENSE WINDOWS ===" $colorAccent
    try {
        $license = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.Name -match "Windows" } | Select-Object -First 1
        if ($license) {
            $licStatus = if ($license.LicenseStatus -eq 1) { "Licensed (Da kich hoat)" } else { "Chua kich hoat / Dung thu" }
            $color = if ($license.LicenseStatus -eq 1) { $colorSuccess } else { $colorWarn }
            Write-GuiLog "[+] San pham: $($license.Name)" $colorCyan
            Write-GuiLog "[+] Trang thai: $licStatus" $color
            Write-GuiLog "[+] Product Key (5 ky tu cuoi): $($license.PartialProductKey)" $colorCyan
        }
    } catch {
        Write-GuiLog "[-] Loi kiem tra license: $_" $colorWarn
    }
}
    btnRunHealthCheck = {
    Write-GuiLog "=== CHAY HEALTH CHECK HE THONG ===" $colorAccent
    $score = 100
    $issues = @()
    $disk = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
    $freeGB = [math]::Round($disk.FreeSpace / 1GB, 1)
    if ($freeGB -lt 15) { $score -= 15; $issues += "O C con it hon 15GB trong" }
    $os = Get-CimInstance Win32_OperatingSystem
    $ramUsed = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 1)
    if ($ramUsed -gt 85) { $score -= 15; $issues += "RAM dang su dung $ramUsed% (cao)" }
    $gradeColor = if ($score -ge 80) { $colorSuccess } elseif ($score -ge 60) { $colorYellow } else { $colorWarn }
    Write-GuiLog "[SCORE] Diem suc khoe he thong: $score/100" $gradeColor
    if ($issues.Count -eq 0) {
        Write-GuiLog "[OK] He thong rat tot va on dinh!" $colorSuccess
    } else {
        $issues | ForEach-Object { Write-GuiLog "  [!] $_" $colorWarn }
    }
}
    btnHardwareCompat = {
    $cpuName = (Get-CimInstance Win32_Processor).Name
    $isXeon  = $cpuName -match "Xeon"
    $isRyzen = $cpuName -match "Ryzen"
    $isIntel = $cpuName -match "Intel"
    Write-GuiLog "=== KIEM TRA TUONG THICH ===" $colorAccent
    Write-GuiLog "[i] CPU: $cpuName" $colorCyan
    if ($isXeon)  { Write-GuiLog "[!] CPU Xeon: Chu y power plan va MPO." $colorWarn }
    if ($isRyzen) { Write-GuiLog "[i] CPU AMD Ryzen: Ho tro hoan hao cac tweak gaming." $colorSuccess }
    if ($isIntel -and -not $isXeon) { Write-GuiLog "[i] CPU Intel Consumer: Ho tro day du cac tweak." $colorSuccess }
}
}
