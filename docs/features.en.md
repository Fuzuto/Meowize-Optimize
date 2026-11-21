# Feature guide

[Meowize](../README.md) · **English** · [日本語](features.ja.md) · [한국어](features.ko.md) · [Tiếng Việt](features.vi.md) · [简体中文](features.zh-CN.md)

## 1-Click (51)

Select this task in 1-Click, then choose Review and run.

**Shut down when finished** · A 45-second shutdown countdown starts if the batch is eligible. Select **Cancel shutdown** in the activity log during the countdown.

<details>
<summary>Safety and system (10)</summary>

| Task | What Meowize does |
| --- | --- |
| 🟢 [System snapshot](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>Safe | Requests and verifies a new Windows restore point and exports HKLM and HKCU to C:\Meowize_Backup. Both steps are attempted independently.<br><br>Administrator access required. |
| 🟢 [Registry branch backup](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>Safe | Exports HKLM\SYSTEM\CurrentControlSet\Control and HKCU\Software\Microsoft\Windows\CurrentVersion to D:\Meowize_Backup when D: exists, or C:\Meowize_Backup\BranchExports.<br><br>Administrator access required. |
| 🟡 [Close background processes](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>Caution | Forcibly closes running processes from a fixed list, including OneDrive, Teams, Edge and Game Bar. Save work in those apps first.<br><br>Administrator access required. |
| 🟡 [Fast Startup and hibernation](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Caution | Turns off hibernation with powercfg and sets HiberbootEnabled to 0. This also turns off Fast Startup.<br><br>Administrator access required. |
| 🔴 [Real-time protection](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>Warning | Opens the Virus & threat protection settings in Windows Security for you to review real-time protection there.<br><br>Select this task in 1-Click. Use Open Windows settings in the review to visit the Windows page.<br><br>Turning off real-time protection reduces malware detection. |
| 🔴 [Windows Update](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>Warning | Opens Windows Update in Settings so you can review update and restart options.<br><br>Select this task in 1-Click. Use Open Windows settings in the review to visit the Windows page.<br><br>Pausing updates can delay security fixes. |
| 🟡 [Defender scan priority](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>Caution | Requests a 20% average CPU usage target for Defender scans and enables low CPU priority for scanning.<br><br>Administrator access required. |
| 🟡 [SysMain service](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>Caution | Stops SysMain and sets its startup type to Disabled.<br><br>Administrator access required. |
| 🟡 [Diagnostics and telemetry](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>Caution | Stops DiagTrack, dmwappushservice, SysMain and MapsBroker and disables their startup. Sets AllowTelemetry = 0 and disables matching Customer Experience and Application Experience scheduled tasks.<br><br>Administrator access required. |
| 🔴 [Remove built-in apps](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>Warning | Removes selected AppX apps for all users and removes their provisioned packages for new profiles. The list includes Xbox apps, Weather and Clipchamp. Also changes Game DVR policy and Game Bar protocol handlers.<br><br>Administrator access required.<br><br>Removing Windows apps may require reinstalling them to restore features. |

</details>

<details>
<summary>Gaming and latency (20)</summary>

| Task | What Meowize does |
| --- | --- |
| 🟡 [Mouse and keyboard buffers](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>Caution | Sets MouseDataQueueSize and KeyboardDataQueueSize to 20 in the Windows class-driver Registry settings. Also enables Game Mode for this account and requests HAGS with HwSchMode = 2.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect. |
| 🔴 [VBS and Memory integrity](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>Warning | Opens Core isolation in Windows Security, where you can review Memory integrity and its requirements.<br><br>Select this task in 1-Click. Use Open Windows settings in the review to visit the Windows page.<br><br>Windows may need to restart for this change to take effect.<br><br>Changing Memory integrity can reduce Windows isolation protections. |
| 🟡 [DirectX Flip Model](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>Caution | Requests Flip Model presentation for eligible windowed games by writing SwapEffectUpgradeEnable and Win32_AutoFlip settings in DirectX, GameConfigStore and DWM.<br><br>Administrator access required. |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>Caution | Opens the Xbox Game Bar options in Windows gaming settings so you can review the overlay configuration there.<br><br>Select this task in 1-Click. Use Open Windows settings in the review to visit the Windows page. |
| 🟡 [Game CPU priority](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>Caution | Sets High CPU priority for listed game executables, including VALORANT, CS2 and Overwatch. Windows reads the per-executable setting when a matching game starts.<br><br>Administrator access required. |
| 🔴 [HPET timer](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Warning | Attempts to disable detected HPET devices and changes boot timer settings in BCD. It clears the platform clock override, enables platform tick and disables dynamic tick.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Changes hardware timer and boot settings. |
| 🔴 [CPU priority and BCD](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Warning | Sets Win32PrioritySeparation to 38 (0x26). In BCD, enables platform tick, clears the platform clock override and disables dynamic tick.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Changes BCD boot settings. Verify after restarting. |
| 🟡 [Multiplane Overlay](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>Caution | Writes EnableMPO = 0 and OverlayTestMode = 5 in the machine’s MultiplaneOverlay Registry branch.<br><br>Administrator access required. |
| 🟡 [Fullscreen Optimizations](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>Caution | Writes fullscreen and Game DVR settings, disables app capture, redirects selected Game Bar links and attempts to stop the per-user Game DVR capture services.<br><br>Administrator access required. |
| 🔴 [MSI interrupt mode](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>Warning | Sets MSISupported = 1 for matching PCI device entries in the Registry. This can reach PCI devices beyond the graphics card and network adapter. Driver and device support matter.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Changing interrupts for matching PCI devices may cause instability. |
| 🟡 [Hardware GPU scheduling](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>Caution | Requests hardware-accelerated GPU scheduling by setting HwSchMode = 2. Windows also requires supported graphics hardware and a compatible driver.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect. |
| 🔴 [FPS Boost profile](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Warning | Creates or activates a performance power plan and adjusts plugged-in CPU, parking, cooling and sleep settings. Also writes BCD timers, foreground scheduling, MPO, multimedia priority, Game DVR, mouse acceleration and kernel power settings.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Applies multiple changes together, including BCD boot settings. |
| 🟡 [Unpark CPU cores](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>Caution | Requests a 100% minimum for unparked cores in the active Windows power plan, both plugged in and on battery.<br><br>Administrator access required. |
| 🟡 [ULPS and PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Caution | Sets existing graphics-driver ULPS flags to 0, disables the HFS setting and changes PCIe link-state power management and selected CPU power settings in the active plan.<br><br>Administrator access required. |
| 🟡 [Mouse acceleration](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>Caution | Sets MouseSpeed, MouseThreshold1 and MouseThreshold2 to 0 for the current Windows account to turn off pointer acceleration.<br><br>Administrator access required. |
| 🔴 [TSC synchronization](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Warning | Sets the BCD time stamp counter synchronization policy to Enhanced.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Changes BCD boot settings. Verify after restarting. |
| 🟡 [Kernel paging](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>Caution | Sets DisablePagingExecutive = 1 and PowerThrottlingOff = 1 in the Windows Registry.<br><br>Administrator access required. |
| 🟡 [Multimedia Scheduler](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>Caution | Writes SystemResponsiveness = 0 and NetworkThrottlingIndex = 0xFFFFFFFF where the multimedia profile exists. For its Games task, requests GPU priority 8, priority 6 and High scheduling.<br><br>Administrator access required. |
| 🟡 [GPU recovery delay](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/timeout-detection-and-recovery)<br>Caution | Sets TdrDelay = 8 seconds for Windows GPU timeout detection. Microsoft documents this value for driver testing and debugging.<br><br>Administrator access required. |
| 🟡 [Sticky, Toggle, and Filter Keys](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>Caution | Writes per-user accessibility flags for Sticky Keys, Filter Keys and Toggle Keys to alter their shortcut behavior.<br><br>Administrator access required. |

</details>

<details>
<summary>Talon Suite (10)</summary>

| Task | What Meowize does |
| --- | --- |
| 🟡 [Diagnostic data](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>Caution | Writes the Windows policies for diagnostic data and activity history and sets DisableWpbtExecution = 1 for the Windows Platform Binary Table.<br><br>Administrator access required. |
| 🔴 [Copilot and Recall policies](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-windowsai)<br>Warning | Writes TurnOffWindowsCopilot = 1 and DisableAIDataAnalysis = 1 in the user and machine policy branches.<br><br>Administrator access required.<br><br>These policies can change Copilot and Recall features across Windows accounts. |
| 🟡 [Promotions and update delivery](https://learn.microsoft.com/en-us/windows/deployment/do/waas-delivery-optimization)<br>Caution | Sets DisableWindowsConsumerFeatures = 1 and Delivery Optimization download mode to 0 for HTTP-only delivery.<br><br>Administrator access required. |
| 🟡 [Classic context menu](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>Caution | Adds the per-user Explorer shell override for the classic context menu. Restart Explorer or sign in again before checking the menu.<br><br>Administrator access required. |
| 🟡 [File Explorer settings](https://support.microsoft.com/en-us/windows/file-explorer-in-windows-ef370130-1cca-9dc5-e0df-2f7416fe1cb1)<br>Caution | Sets Explorer to open This PC via LaunchTo = 1 and requests that Gallery be unpinned from the navigation tree.<br><br>Administrator access required. |
| 🟡 [Search and Widgets](https://learn.microsoft.com/en-us/windows/configuration/start/)<br>Caution | Writes policies for Bing and search-box suggestions and sets the Windows Widgets policy to disabled.<br><br>Administrator access required. |
| 🔴 [Scheduled tasks](https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/disable-scheduledtask)<br>Warning | Attempts to disable eight named scheduled tasks, including Compatibility Appraiser, the Disk Diagnostic Data Collector and WinSAT.<br><br>Administrator access required.<br><br>Disabling scheduled tasks can affect related Windows maintenance. |
| 🟡 [Windows services](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>Caution | Stops DiagTrack, dmwappushservice, SysMain and Windows Search (WSearch) and disables their startup.<br><br>Administrator access required. |
| 🔴 [Talon app list](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>Warning | Removes installed AppX packages for all users from Talon’s fixed list, including Weather, Mixed Reality Portal and Clipchamp.<br><br>Administrator access required.<br><br>Removing Windows apps may require reinstalling them to restore features. |
| 🟡 [Menu delay and End task](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>Caution | Sets the menu display delay to 0, enables the taskbar’s End task option and shows file extensions in Explorer.<br><br>Administrator access required. |

</details>

<details>
<summary>Network and cleanup (11)</summary>

| Task | What Meowize does |
| --- | --- |
| 🟡 [Large Send Offload](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>Caution | Attempts to disable LSO for IPv4 and IPv6 and checksum offload. It also changes driver properties when exposed, including Energy Efficient or Green Ethernet, Gigabit Lite, power saving and interrupt moderation.<br><br>Administrator access required. |
| 🟡 [TCP/IP tuning](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>Caution | Writes TCPNoDelay = 1, TcpAckFrequency = 1 and TcpDelAckTicks = 0 for recorded TCP/IP interfaces in the Registry. The effect depends on the connection and what the application uses.<br><br>Administrator access required. |
| 🟡 [Network power saving](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>Caution | Changes adapter power management to prevent Windows from turning off the device. It also disables matching sleep and energy-saving properties when the adapter driver exposes them.<br><br>Administrator access required. |
| 🟡 [Cloudflare DNS](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>Caution | Sets Cloudflare IPv4 DNS addresses 1.1.1.1 and 1.0.0.1 on adapters reported as Up by Windows.<br><br>Administrator access required. |
| 🔴 [Reset network](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>Warning | Clears the local DNS cache and resets Winsock and TCP/IP. Windows can require a restart.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>May disconnect the network or change its configuration. |
| 🟡 [Clear temporary files](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Caution | Deletes eligible contents from the current user’s Temp folder, Windows Temp and Windows Prefetch. Skips locked or protected entries and reports the space freed.<br><br>Administrator access required. |
| 🔴 [Clear Riot client cache](https://support-valorant.riotgames.com/)<br>Warning | Deletes eligible contents of Riot Client Logs and Data, and VALORANT Saved Logs and Crashes, under the current account’s Local AppData. Close Riot Client and VALORANT first.<br><br>Administrator access required.<br><br>Deletes cache, logs, and some local Riot Client data. |
| 🟡 [Clear shader cache](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Caution | Clears selected NVIDIA DX and GL caches, AMD DX and GL caches, and Windows D3DSCache in Local AppData. Games may rebuild shader caches when opened.<br><br>Administrator access required. |
| 🟡 [Trim working sets](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>Caution | Requests Windows to trim the working sets of accessible processes with EmptyWorkingSet and runs garbage collection in the worker process.<br><br>Administrator access required. |
| 🟡 [Install six apps with WinGet](https://github.com/microsoft/winget-cli)<br>Caution | Uses WinGet from Windows App Installer to install Chrome, Discord, 7-Zip, UniKey, UltraViewer and Zalo sequentially. The log records each package’s result.<br><br>Administrator access required. |
| 🟡 [Repair Windows with DISM and SFC](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>Caution | Runs DISM /Online /Cleanup-Image /RestoreHealth. If DISM finishes successfully, runs sfc /scannow and displays command output in the log.<br><br>Administrator access required. |

</details>

## Standalone tools (66)

Open the indicated page and use the action in the task row. Select ⓘ to see the steps in the app before you run it.

<details>
<summary>Gaming & FPS (20)</summary>

| Task | What Meowize does |
| --- | --- |
| 🟡 [Mouse and keyboard buffers](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>Caution | Sets MouseDataQueueSize and KeyboardDataQueueSize to 20 in the Windows class-driver Registry settings. Also enables Game Mode for this account and requests HAGS with HwSchMode = 2.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect. |
| 🔴 [FPS Boost profile](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Warning | Creates or activates a performance power plan and adjusts plugged-in CPU, parking, cooling and sleep settings. Also writes BCD timers, foreground scheduling, MPO, multimedia priority, Game DVR, mouse acceleration and kernel power settings.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Applies multiple changes together, including BCD boot settings. |
| 🟡 [Kernel paging](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>Caution | Sets DisablePagingExecutive = 1, LargeSystemCache = 0 and PowerThrottlingOff = 1. Restart before comparing results.<br><br>Administrator access required. |
| 🔴 [TSC synchronization](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Warning | Sets TSC synchronization to Enhanced, enables platform tick, clears the platform clock override and disables dynamic tick in BCD.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Changes BCD boot settings. Verify after restarting. |
| 🟡 [Sticky, Toggle, and Filter Keys](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>Caution | Writes per-user accessibility flags for Sticky Keys, Filter Keys and Toggle Keys to alter their shortcut behavior.<br><br>Administrator access required. |
| 🔴 [HPET timer](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Warning | Attempts to disable detected HPET devices and changes boot timer settings in BCD. It clears the platform clock override, enables platform tick and disables dynamic tick.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Changes hardware timer and boot settings. |
| 🟡 [Unpark CPU cores](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>Caution | Requests a 100% minimum for unparked cores in the active Windows power plan, both plugged in and on battery.<br><br>Administrator access required. |
| 🟡 [Game CPU priority](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>Caution | Sets High CPU priority for listed game executables, including VALORANT, CS2 and Overwatch. Windows reads the per-executable setting when a matching game starts.<br><br>Administrator access required. |
| 🟡 [Multiplane Overlay](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>Caution | Toggles the DWM OverlayTestMode value. A current value of 5 becomes 0. Any other value becomes 5.<br><br>Administrator access required. |
| 🔴 [MSI interrupt mode](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>Warning | Sets MSISupported = 1 for matching PCI device entries in the Registry. This can reach PCI devices beyond the graphics card and network adapter. Driver and device support matter.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Changing interrupts for matching PCI devices may cause instability. |
| 🟡 [Hardware GPU scheduling](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>Caution | Requests hardware-accelerated GPU scheduling by setting HwSchMode = 2. Windows also requires supported graphics hardware and a compatible driver.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect. |
| 🟡 [Clear shader cache](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Caution | Clears selected NVIDIA DX and GL caches, AMD DX and GL caches, and Windows D3DSCache in Local AppData. Games may rebuild shader caches when opened.<br><br>Administrator access required. |
| 🟡 [Fullscreen Optimizations](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>Caution | Writes fullscreen and Game DVR settings, disables app capture, redirects selected Game Bar links and attempts to stop the per-user Game DVR capture services.<br><br>Administrator access required. |
| 🟡 [Multimedia Scheduler](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>Caution | Writes SystemResponsiveness = 0 and NetworkThrottlingIndex = 0xFFFFFFFF where the multimedia profile exists. For its Games task, requests GPU priority 8, priority 6 and High scheduling.<br><br>Administrator access required. |
| 🟡 [Mouse acceleration](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>Caution | Sets MouseSpeed, MouseThreshold1 and MouseThreshold2 to 0 for the current Windows account to turn off pointer acceleration.<br><br>Administrator access required. |
| 🔴 [Clear Riot client cache](https://support-valorant.riotgames.com/)<br>Warning | Deletes eligible contents of Riot Client Logs and Data, and VALORANT Saved Logs and Crashes, under the current account’s Local AppData. Close Riot Client and VALORANT first.<br><br>Administrator access required.<br><br>Deletes cache, logs, and some local Riot Client data. |
| 🟡 [Close background processes](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>Caution | Forcibly closes running processes from a fixed list, including OneDrive, Teams, Edge and Game Bar. Save work in those apps first.<br><br>Administrator access required. |
| 🔴 [VBS and Memory integrity](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>Warning | Opens Core isolation in Windows Security, where you can review Memory integrity and its requirements.<br><br>Windows may need to restart for this change to take effect.<br><br>Changing Memory integrity can reduce Windows isolation protections. |
| 🟡 [DirectX Flip Model](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>Caution | Requests Flip Model presentation for eligible windowed games by writing SwapEffectUpgradeEnable and Win32_AutoFlip settings in DirectX, GameConfigStore and DWM.<br><br>Administrator access required. |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>Caution | Opens the Xbox Game Bar options in Windows gaming settings so you can review the overlay configuration there. |

</details>

<details>
<summary>System & Talon (16)</summary>

| Task | What Meowize does |
| --- | --- |
| 🔴 [Talon Suite](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>Warning | Runs nine stages that write diagnostic and activity policies, Copilot and Recall settings, delivery and suggestions policies, Explorer, accessibility, Start and Widgets, scheduled tasks, background app settings and kernel/GPU timeout values.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Changes several apps, services, and system tasks at once. |
| 🟡 [Classic context menu](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>Caution | Adds the per-user Explorer shell override for the classic context menu. Restart Explorer or sign in again before checking the menu.<br><br>Administrator access required. |
| 🟡 [ULPS and PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Caution | Sets existing graphics-driver ULPS flags to 0, disables the HFS setting and changes PCIe link-state power management and selected CPU power settings in the active plan.<br><br>Administrator access required. |
| 🟡 [Re-enable Defender](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>Caution | Requests real-time protection through Microsoft Defender PowerShell and checks that RealTimeProtectionEnabled reports true.<br><br>Administrator access required. |
| 🔴 [Real-time protection](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>Warning | Opens the Virus & threat protection settings in Windows Security for you to review real-time protection there.<br><br>Turning off real-time protection reduces malware detection. |
| 🟡 [Defender scan priority](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>Caution | Requests a 20% average CPU usage target for Defender scans and enables low CPU priority for scanning.<br><br>Administrator access required. |
| 🟡 [SysMain service](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>Caution | Stops SysMain and sets its startup type to Disabled.<br><br>Administrator access required. |
| 🟡 [Fast Startup and hibernation](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Caution | Turns off hibernation with powercfg and sets HiberbootEnabled to 0. This also turns off Fast Startup.<br><br>Administrator access required. |
| 🟡 [Diagnostics and telemetry](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>Caution | Stops and disables up to eight installed services, including DiagTrack, SysMain, Windows Search, MapsBroker and Delivery Optimization (DoSvc).<br><br>Administrator access required. |
| 🔴 [Remove built-in apps](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>Warning | Uninstalls matching installed AppX packages for all users from a fixed list, including Phone Link, Weather, Clipchamp and Windows Maps.<br><br>Administrator access required.<br><br>Removing Windows apps may require reinstalling them to restore features. |
| 🟡 [Trim working sets](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>Caution | Trims accessible processes’ working sets with EmptyWorkingSet and logs reported free RAM before and after the operation.<br><br>Administrator access required. |
| 🟡 [Clear temporary files](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Caution | Deletes eligible contents from the current user’s Temp folder, Windows Temp and Windows Prefetch. Skips locked or protected entries and reports the space freed.<br><br>Administrator access required. |
| 🔴 [Advanced disk cleanup](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Warning | Cleans the standard Temp and Prefetch locations plus downloaded Windows Update files, Explorer caches, Windows logs, crash dumps and Windows Error Reporting files. Locked and protected entries are skipped.<br><br>Administrator access required.<br><br>Deletes update caches, system logs, and diagnostic files. |
| 🟡 [Toggle hibernation](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Caution | Checks whether C:\hiberfil.sys exists. If the file is present, requests hibernation off. Otherwise, requests it on.<br><br>Administrator access required. |
| 🟡 [Startup apps](https://learn.microsoft.com/en-us/windows/win32/setupapi/run-and-runonce-registry-keys)<br>Caution | Lists the current user’s and machine’s Registry Run entries. Uncheck entries to remove, review and confirm. Meowize writes their values to a backup JSON before removal. Machine entries require administrator access. |
| 🔴 [Windows Update](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>Warning | Opens Windows Update in Settings so you can review update and restart options.<br><br>Pausing updates can delay security fixes. |

</details>

<details>
<summary>Network & drivers (8)</summary>

| Task | What Meowize does |
| --- | --- |
| 🟡 [Network power saving](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>Caution | Changes adapter power management to prevent Windows from turning off the device. It also disables matching sleep and energy-saving properties when the adapter driver exposes them.<br><br>Administrator access required. |
| 🟡 [TCP/IP tuning](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>Caution | Writes TCPNoDelay = 1, TcpAckFrequency = 1 and TcpDelAckTicks = 0 for recorded TCP/IP interfaces in the Registry. The effect depends on the connection and what the application uses.<br><br>Administrator access required. |
| 🟡 [Large Send Offload](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>Caution | Attempts to disable LSO for IPv4 and IPv6 and checksum offload. It also changes driver properties when exposed, including Energy Efficient or Green Ethernet, Gigabit Lite, power saving and interrupt moderation.<br><br>Administrator access required. |
| 🟡 [DNS address](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>Caution | Applies the chosen provider’s two IPv4 DNS addresses to all active adapters, reads the values back for verification and then clears the local DNS cache.<br><br>Choose a DNS provider, select Apply and review the addresses before confirming.<br><br>Administrator access required. |
| 🟢 [Flush the DNS cache](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig)<br>Safe | Runs ipconfig /flushdns to clear the local Windows DNS resolver cache.<br><br>Administrator access required. |
| 🔴 [Reset network](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>Warning | Resets Winsock and TCP/IP, releases and renews IP leases, then clears the DNS cache. This can interrupt the connection.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>May disconnect the network or change its configuration. |
| 🔴 [Display Driver Uninstaller](https://www.wagnardsoft.com/)<br>Warning | Downloads Display Driver Uninstaller 18.0.8.6 from Wagnardsoft. Meowize opens the downloaded file after checking the publisher signature. Driver removal is performed separately in DDU.<br><br>DDU removes display drivers. A restart may be needed. |
| 🔴 [Restart into UEFI](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/shutdown)<br>Warning | After confirmation, immediately requests a restart into UEFI firmware. Save open work before running it.<br><br>Administrator access required.<br><br>Restarts the computer into UEFI immediately. Save your work first. |

</details>

<details>
<summary>Apps & tools (7)</summary>

| Task | What Meowize does |
| --- | --- |
| 🔴 [NVIDIA 581.80 WHQL](https://www.nvidia.com/en-us/drivers/details/257497/)<br>Warning | Downloads the NVIDIA desktop driver version shown in this row. If its NVIDIA signature is valid, launches the silent installer and waits for its exit code. Check the supported GPU list first.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>The display may flicker. Windows may need to restart. |
| 🔴 [NVIDIA 566.36 WHQL](https://www.nvidia.com/en-us/drivers/details/237719/)<br>Warning | Downloads the NVIDIA desktop driver version shown in this row. If its NVIDIA signature is valid, launches the silent installer and waits for its exit code. Check the supported GPU list first.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>The display may flicker. Windows may need to restart. |
| 🟡 [CPU-Z and HWMonitor](https://www.cpuid.com/)<br>Caution | Downloads CPU-Z 2.11 and HWMonitor 1.55 from CPUID, extracts them under Meowize_Tools on the Desktop and opens x64 executables with a verified CPUID signature. |
| 🟡 [Unpark CPU App](https://coderbag.com/product/quickcpu)<br>Caution | Downloads and extracts CoderBag’s Unpark CPU App under Meowize_Tools on the Desktop. It opens a verified executable. Any CPU parking changes are chosen inside the utility. |
| 🟡 [Visual C++ x64](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)<br>Caution | Downloads the Visual C++ x64 Redistributable from Microsoft, checks the publisher signature and runs the installer in passive mode with automatic restart disabled.<br><br>Administrator access required. |
| 🟡 [Install three apps with WinGet](https://github.com/microsoft/winget-cli)<br>Caution | Uses WinGet from Windows App Installer to install Google Chrome, Discord and 7-Zip sequentially. Check the activity log for progress and any package errors.<br><br>Administrator access required. |
| 🟢 [Office deployment settings](https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/overview-office-deployment-tool)<br>Safe | Opens Microsoft’s Office Customization Tool in your default browser, where you choose deployment settings. |

</details>

<details>
<summary>Diagnostics (7)</summary>

| Task | What Meowize does |
| --- | --- |
| 🟢 [Hardware information](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/operating-system-classes)<br>Safe | Uses Windows CIM to read CPU name, cores and threads, GPU names, total memory and capacity/free space on C:. Results appear in the activity log. |
| 🟢 [Physical disk health](https://learn.microsoft.com/en-us/powershell/module/storage/get-physicaldisk)<br>Safe | Lists the name, media type, capacity and HealthStatus reported by Get-PhysicalDisk for each physical disk. |
| 🟢 [ACPI temperatures](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/thermal-management-in-windows)<br>Safe | Reads the ACPI thermal zones exposed by the PC via WMI and converts each reading to °C. Available sensors vary by firmware. |
| 🟢 [Windows activation](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/sppwmi/softwarelicensingproduct)<br>Safe | Reads Windows activation data from SoftwareLicensingProduct. Logs the Windows edition, activation status and the last five characters of the installed key when available. |
| 🟢 [Disk and memory check](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/systeminfo)<br>Safe | Starts with a score of 100 and subtracts 15 for each condition met. The checks are less than 15 GB free on C: and more than 85% RAM used. |
| 🟢 [Hardware compatibility](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor)<br>Safe | Reads the CPU model name through CIM and logs notes for Intel, Xeon or Ryzen based on name matching. |
| 🟢 [System snapshot](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>Safe | Requests and verifies a new Windows restore point and exports HKLM and HKCU to C:\Meowize_Backup. Both steps are attempted independently.<br><br>Administrator access required. |

</details>

<details>
<summary>Recovery & reports (8)</summary>

| Task | What Meowize does |
| --- | --- |
| 🟢 [Create a restore point](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>Safe | Enables System Protection for the Windows drive, requests a restore point named Meowize with a timestamp, and checks that its sequence number is new.<br><br>Administrator access required. |
| 🟢 [Back up the Registry](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>Safe | Exports HKLM and HKCU as HKLM.reg and HKCU.reg in a new Manual snapshot under C:\Meowize_Backup.<br><br>Administrator access required. |
| 🔴 [Restore the Registry](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-import)<br>Warning | Shows the newest compatible snapshot and its paths before confirmation. Verifies the Registry file headers, takes a new backup of the current Registry and imports the selected snapshot.<br><br>Administrator access required.<br><br>Windows may need to restart for this change to take effect.<br><br>Imports machine or account Registry settings from a backup. |
| 🟡 [Repair Windows with DISM and SFC](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>Caution | Runs DISM /Online /Cleanup-Image /RestoreHealth. If DISM finishes successfully, runs sfc /scannow and displays command output in the log.<br><br>Administrator access required. |
| 🟢 [HTML system report](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-html)<br>Safe | Writes the CPU, GPU, RAM and Windows details to Meowize_System_Report.html on the Desktop and opens it in your default browser. |
| 🟢 [Export the activity log](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file)<br>Safe | Opens a save dialog and writes the current activity log with timestamps to a UTF-8 .txt file. |
| 🟢 [Copy the log](https://learn.microsoft.com/en-us/dotnet/api/system.windows.clipboard.settext)<br>Safe | Copies the current activity log, including timestamps, to the Windows clipboard. |
| 🟡 [Diagnostic ZIP](https://learn.microsoft.com/en-us/dotnet/api/system.io.compression.ziparchive)<br>Caution | Prompts for a path, runs systeminfo and ipconfig /all, and writes their output and the current Meowize log to a local ZIP. Review the device and network information in the archive before sharing. |

</details>
