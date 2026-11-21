# 功能指南

[Meowize](README.zh-CN.md) · [English](features.en.md) · [日本語](features.ja.md) · [한국어](features.ko.md) · [Tiếng Việt](features.vi.md) · **简体中文**

## 1-Click (51)

在 1-Click 中选择此任务，然后点击检查并运行。

**完成后关机** · 批处理满足条件后将开始 45 秒关机倒计时。 倒计时期间可在活动日志中点击 **取消关机**。

<details>
<summary>安全与系统 (10)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🟢 [系统快照](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>安全 | 请求创建并验证 Windows 还原点，同时将 HKLM 和 HKCU 导出到 C:\Meowize_Backup。两个步骤会独立尝试。<br><br>需要管理员权限。 |
| 🟢 [注册表分支备份](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>安全 | 导出 HKLM\SYSTEM\CurrentControlSet\Control 和 HKCU\Software\Microsoft\Windows\CurrentVersion。存在 D: 时保存到 D:\Meowize_Backup，否则使用 C:\Meowize_Backup\BranchExports。<br><br>需要管理员权限。 |
| 🟡 [关闭后台进程](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>注意 | 强制结束固定列表中的运行进程，包括 OneDrive、Teams、Edge 和 Game Bar。请先保存工作。<br><br>需要管理员权限。 |
| 🟡 [快速启动和休眠](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | 通过 powercfg 关闭休眠，并将 HiberbootEnabled 设为 0，同时关闭快速启动。<br><br>需要管理员权限。 |
| 🔴 [实时防护](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>警告 | 打开 Windows 安全中心的病毒和威胁防护设置，以便在该页面检查实时保护。<br><br>在 1-Click 中选择此任务，再在检查页面点击打开 Windows 设置。<br><br>关闭实时防护会降低恶意软件检测能力。 |
| 🔴 [Windows 更新](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>警告 | 打开设置中的 Windows 更新页面，以便检查更新和重启选项。<br><br>在 1-Click 中选择此任务，再在检查页面点击打开 Windows 设置。<br><br>暂停更新可能延迟安装安全修复。 |
| 🟡 [Defender 扫描优先级](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>注意 | 将 Defender 扫描的平均 CPU 使用率目标设为 20%，并启用低优先级扫描。<br><br>需要管理员权限。 |
| 🟡 [SysMain 服务](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>注意 | 停止 SysMain，并将启动类型设为禁用。<br><br>需要管理员权限。 |
| 🟡 [诊断与遥测](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>注意 | 停止并禁用 DiagTrack、dmwappushservice、SysMain 和 MapsBroker 的启动。将 AllowTelemetry 设为 0，并禁用匹配的客户体验和应用体验计划任务。<br><br>需要管理员权限。 |
| 🔴 [移除内置应用](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>警告 | 为所有用户移除选定的 AppX 和新用户的预配包，包括 Xbox 应用、天气和 Clipchamp，同时修改 Game DVR 策略及 Game Bar 协议处理程序。<br><br>需要管理员权限。<br><br>移除 Windows 应用后，可能需要重新安装才能恢复相关功能。 |

</details>

<details>
<summary>游戏与延迟 (20)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🟡 [鼠标和键盘缓冲区](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>注意 | 在 Windows 类驱动注册表设置中将 MouseDataQueueSize 和 KeyboardDataQueueSize 设为 20。为当前账户启用游戏模式，并通过 HwSchMode = 2 请求启用 HAGS。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。 |
| 🔴 [VBS 与内存完整性](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>警告 | 打开 Windows 安全中心的内核隔离页面，以便检查内存完整性及其要求。<br><br>在 1-Click 中选择此任务，再在检查页面点击打开 Windows 设置。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>更改内存完整性可能削弱 Windows 隔离防护。 |
| 🟡 [DirectX 翻转模型](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>注意 | 写入 DirectX、GameConfigStore 和 DWM 的 SwapEffectUpgradeEnable 与 Win32_AutoFlip 设置，为符合条件的窗口化游戏请求 Flip Model。<br><br>需要管理员权限。 |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>注意 | 打开 Windows 游戏设置中的 Xbox Game Bar 页面，以便检查叠加层设置。<br><br>在 1-Click 中选择此任务，再在检查页面点击打开 Windows 设置。 |
| 🟡 [游戏 CPU 优先级](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>注意 | 为列表中的游戏可执行文件设置高 CPU 优先级，包括 VALORANT、CS2 和 Overwatch。Windows 在启动匹配的游戏时读取该设置。<br><br>需要管理员权限。 |
| 🔴 [HPET 定时器](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | 尝试禁用检测到的 HPET 设备并修改 BCD 启动计时器。清除平台时钟覆盖，启用平台时钟节拍并关闭动态节拍。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>影响硬件计时器和启动设置。 |
| 🔴 [CPU 优先级与 BCD](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | 将 Win32PrioritySeparation 设为 38（0x26）。在 BCD 中启用平台节拍、清除平台时钟覆盖并关闭动态节拍。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>更改 BCD 启动设置。请在重启后验证。 |
| 🟡 [多平面叠加](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>注意 | 在系统的 MultiplaneOverlay 注册表分支中写入 EnableMPO = 0 和 OverlayTestMode = 5。<br><br>需要管理员权限。 |
| 🟡 [全屏优化](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>注意 | 写入全屏与 Game DVR 设置，关闭应用录制，重定向选定的 Game Bar 链接，并尝试停止按用户运行的 Game DVR 捕获服务。<br><br>需要管理员权限。 |
| 🔴 [MSI 中断模式](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>警告 | 为注册表中匹配的 PCI 设备写入 MSISupported = 1。范围可能超出显卡和网卡，效果取决于设备和驱动支持。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>更改匹配 PCI 设备的中断设置可能导致不稳定。 |
| 🟡 [硬件加速 GPU 调度](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>注意 | 通过 HwSchMode = 2 请求启用硬件加速 GPU 调度。Windows 需要受支持的图形硬件和兼容驱动。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。 |
| 🔴 [FPS Boost 配置](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>警告 | 创建或激活性能电源计划并调整接通电源时的 CPU、核心停放、冷却和睡眠设置。还会修改 BCD 计时器、前台调度、MPO、多媒体优先级、Game DVR、鼠标加速及内核电源设置。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>一次应用多项更改，包括 BCD 启动设置。 |
| 🟡 [取消 CPU 核心停放](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>注意 | 将当前电源计划中未停放核心的最低比例设为 100%，同时用于接通电源和电池模式。<br><br>需要管理员权限。 |
| 🟡 [ULPS 与 PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | 将显卡驱动现有的 ULPS 标志置为 0，关闭 HFS，并调整当前电源计划的 PCIe 链路状态和部分 CPU 电源设置。<br><br>需要管理员权限。 |
| 🟡 [鼠标加速](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>注意 | 将当前 Windows 账户的 MouseSpeed、MouseThreshold1 和 MouseThreshold2 设为 0，以关闭指针加速。<br><br>需要管理员权限。 |
| 🔴 [TSC 同步](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | 将 BCD 的时间戳计数器同步策略设为 Enhanced。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>更改 BCD 启动设置。请在重启后验证。 |
| 🟡 [内核分页](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>注意 | 在 Windows 注册表中设置 DisablePagingExecutive = 1 和 PowerThrottlingOff = 1。<br><br>需要管理员权限。 |
| 🟡 [多媒体调度器](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>注意 | 若多媒体配置存在，写入 SystemResponsiveness = 0 和 NetworkThrottlingIndex = 0xFFFFFFFF。其 Games 任务请求 GPU 优先级 8、优先级 6 和 High 调度。<br><br>需要管理员权限。 |
| 🟡 [GPU 恢复延迟](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/timeout-detection-and-recovery)<br>注意 | 将 Windows GPU 超时检测的 TdrDelay 设为 8 秒。Microsoft 将此值用于驱动测试和调试场景。<br><br>需要管理员权限。 |
| 🟡 [粘滞键、切换键与筛选键](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>注意 | 写入当前用户的粘滞键、筛选键和切换键辅助功能标志，调整这些快捷键的行为。<br><br>需要管理员权限。 |

</details>

<details>
<summary>Talon Suite (10)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🟡 [诊断数据](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>注意 | 写入 Windows 诊断数据和活动历史记录策略，并为 Windows Platform Binary Table 设置 DisableWpbtExecution = 1。<br><br>需要管理员权限。 |
| 🔴 [Copilot 与 Recall 策略](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-windowsai)<br>警告 | 在用户和计算机策略分支中写入 TurnOffWindowsCopilot = 1 与 DisableAIDataAnalysis = 1。<br><br>需要管理员权限。<br><br>这些策略可能影响多个 Windows 账户的 Copilot 和 Recall 功能。 |
| 🟡 [推荐内容与更新传递](https://learn.microsoft.com/en-us/windows/deployment/do/waas-delivery-optimization)<br>注意 | 将 DisableWindowsConsumerFeatures 设为 1，并把传递优化下载模式设为仅 HTTP 的 0。<br><br>需要管理员权限。 |
| 🟡 [经典右键菜单](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>注意 | 为当前用户添加经典右键菜单的资源管理器覆盖设置。重新启动资源管理器或重新登录后检查菜单。<br><br>需要管理员权限。 |
| 🟡 [文件资源管理器设置](https://support.microsoft.com/en-us/windows/file-explorer-in-windows-ef370130-1cca-9dc5-e0df-2f7416fe1cb1)<br>注意 | 通过 LaunchTo = 1 让文件资源管理器打开此电脑，并设置图库从导航树取消固定。<br><br>需要管理员权限。 |
| 🟡 [搜索与小组件](https://learn.microsoft.com/en-us/windows/configuration/start/)<br>注意 | 写入 Bing 和搜索框建议的设置，并禁用 Windows 小组件策略。<br><br>需要管理员权限。 |
| 🔴 [计划任务](https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/disable-scheduledtask)<br>警告 | 尝试禁用八项指定的计划任务，包括 Compatibility Appraiser、磁盘诊断数据收集器和 WinSAT。<br><br>需要管理员权限。<br><br>禁用计划任务可能影响相关的 Windows 维护。 |
| 🟡 [Windows 服务](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>注意 | 停止 DiagTrack、dmwappushservice、SysMain 和 Windows 搜索（WSearch），并禁用其启动。<br><br>需要管理员权限。 |
| 🔴 [Talon 应用列表](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>警告 | 为所有用户移除 Talon 固定列表中已安装的 AppX 包，包括天气、混合现实门户和 Clipchamp。<br><br>需要管理员权限。<br><br>移除 Windows 应用后，可能需要重新安装才能恢复相关功能。 |
| 🟡 [菜单延迟与结束任务](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>注意 | 将菜单显示延迟设为 0，启用任务栏的结束任务选项，并在资源管理器中显示文件扩展名。<br><br>需要管理员权限。 |

</details>

<details>
<summary>网络与清理 (11)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🟡 [大型发送卸载](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>注意 | 尝试关闭 IPv4 和 IPv6 的 LSO 与校验和卸载，并在驱动提供时调整节能以太网、Gigabit Lite、节电及中断调节。<br><br>需要管理员权限。 |
| 🟡 [TCP/IP 调整](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>注意 | 在注册表的 TCP/IP 接口中写入 TCPNoDelay = 1、TcpAckFrequency = 1 和 TcpDelAckTicks = 0。影响取决于连接和应用所用协议。<br><br>需要管理员权限。 |
| 🟡 [网络节能](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>注意 | 调整网卡电源管理以阻止 Windows 关闭设备，并在驱动提供时关闭相关节能属性。<br><br>需要管理员权限。 |
| 🟡 [Cloudflare DNS](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>注意 | 为 Windows 报告为活动（Up）的适配器设置 Cloudflare IPv4 DNS 1.1.1.1 和 1.0.0.1。<br><br>需要管理员权限。 |
| 🔴 [重置网络](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>警告 | 清除本地 DNS 缓存并重置 Winsock 和 TCP/IP。Windows 可能需要重启。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>可能中断网络连接或更改网络配置。 |
| 🟡 [清理临时文件](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>注意 | 删除当前账户 Temp、Windows Temp 和 Windows Prefetch 中可清理的内容。跳过锁定或受保护的条目并报告释放空间。<br><br>需要管理员权限。 |
| 🔴 [清理 Riot 客户端缓存](https://support-valorant.riotgames.com/)<br>警告 | 清理当前账户 Local AppData 中 Riot Client 的 Logs 与 Data，以及 VALORANT Saved 下的 Logs 与 Crashes。请先退出客户端和游戏。<br><br>需要管理员权限。<br><br>删除缓存、日志以及部分 Riot 客户端本地数据。 |
| 🟡 [清理着色器缓存](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>注意 | 清理 Local AppData 中 NVIDIA、AMD 的 DX 和 GL 缓存及 Windows 的 D3DSCache。游戏启动时可能重新生成着色器缓存。<br><br>需要管理员权限。 |
| 🟡 [精简工作集](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>注意 | 使用 EmptyWorkingSet 请求 Windows 缩减可访问进程的工作集，并在执行器进程内运行垃圾回收。<br><br>需要管理员权限。 |
| 🟡 [用 WinGet 安装 6 个应用](https://github.com/microsoft/winget-cli)<br>注意 | 使用 Windows 应用安装程序中的 WinGet 依次安装 Chrome、Discord、7-Zip、UniKey、UltraViewer 和 Zalo。日志记录每个包的结果。<br><br>需要管理员权限。 |
| 🟡 [使用 DISM 和 SFC 修复 Windows](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>注意 | 运行 DISM /Online /Cleanup-Image /RestoreHealth。DISM 成功后运行 sfc /scannow，并将命令输出写入日志。<br><br>需要管理员权限。 |

</details>

## 独立工具 (66)

打开对应页面并点击任务行里的按钮。执行前可点击 ⓘ 查看操作详情。

<details>
<summary>游戏与 FPS (20)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🟡 [鼠标和键盘缓冲区](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>注意 | 在 Windows 类驱动注册表设置中将 MouseDataQueueSize 和 KeyboardDataQueueSize 设为 20。为当前账户启用游戏模式，并通过 HwSchMode = 2 请求启用 HAGS。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。 |
| 🔴 [FPS Boost 配置](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>警告 | 创建或激活性能电源计划并调整接通电源时的 CPU、核心停放、冷却和睡眠设置。还会修改 BCD 计时器、前台调度、MPO、多媒体优先级、Game DVR、鼠标加速及内核电源设置。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>一次应用多项更改，包括 BCD 启动设置。 |
| 🟡 [内核分页](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>注意 | 设置 DisablePagingExecutive = 1、LargeSystemCache = 0 和 PowerThrottlingOff = 1。重启后再比较结果。<br><br>需要管理员权限。 |
| 🔴 [TSC 同步](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | 在 BCD 中将 TSC 同步设为 Enhanced，启用平台节拍，清除平台时钟覆盖并关闭动态节拍。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>更改 BCD 启动设置。请在重启后验证。 |
| 🟡 [粘滞键、切换键与筛选键](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>注意 | 写入当前用户的粘滞键、筛选键和切换键辅助功能标志，调整这些快捷键的行为。<br><br>需要管理员权限。 |
| 🔴 [HPET 定时器](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | 尝试禁用检测到的 HPET 设备并修改 BCD 启动计时器。清除平台时钟覆盖，启用平台时钟节拍并关闭动态节拍。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>影响硬件计时器和启动设置。 |
| 🟡 [取消 CPU 核心停放](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>注意 | 将当前电源计划中未停放核心的最低比例设为 100%，同时用于接通电源和电池模式。<br><br>需要管理员权限。 |
| 🟡 [游戏 CPU 优先级](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>注意 | 为列表中的游戏可执行文件设置高 CPU 优先级，包括 VALORANT、CS2 和 Overwatch。Windows 在启动匹配的游戏时读取该设置。<br><br>需要管理员权限。 |
| 🟡 [多平面叠加](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>注意 | 切换 DWM 的 OverlayTestMode。当前值为 5 时改为 0，其他值改为 5。<br><br>需要管理员权限。 |
| 🔴 [MSI 中断模式](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>警告 | 为注册表中匹配的 PCI 设备写入 MSISupported = 1。范围可能超出显卡和网卡，效果取决于设备和驱动支持。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>更改匹配 PCI 设备的中断设置可能导致不稳定。 |
| 🟡 [硬件加速 GPU 调度](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>注意 | 通过 HwSchMode = 2 请求启用硬件加速 GPU 调度。Windows 需要受支持的图形硬件和兼容驱动。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。 |
| 🟡 [清理着色器缓存](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>注意 | 清理 Local AppData 中 NVIDIA、AMD 的 DX 和 GL 缓存及 Windows 的 D3DSCache。游戏启动时可能重新生成着色器缓存。<br><br>需要管理员权限。 |
| 🟡 [全屏优化](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>注意 | 写入全屏与 Game DVR 设置，关闭应用录制，重定向选定的 Game Bar 链接，并尝试停止按用户运行的 Game DVR 捕获服务。<br><br>需要管理员权限。 |
| 🟡 [多媒体调度器](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>注意 | 若多媒体配置存在，写入 SystemResponsiveness = 0 和 NetworkThrottlingIndex = 0xFFFFFFFF。其 Games 任务请求 GPU 优先级 8、优先级 6 和 High 调度。<br><br>需要管理员权限。 |
| 🟡 [鼠标加速](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>注意 | 将当前 Windows 账户的 MouseSpeed、MouseThreshold1 和 MouseThreshold2 设为 0，以关闭指针加速。<br><br>需要管理员权限。 |
| 🔴 [清理 Riot 客户端缓存](https://support-valorant.riotgames.com/)<br>警告 | 清理当前账户 Local AppData 中 Riot Client 的 Logs 与 Data，以及 VALORANT Saved 下的 Logs 与 Crashes。请先退出客户端和游戏。<br><br>需要管理员权限。<br><br>删除缓存、日志以及部分 Riot 客户端本地数据。 |
| 🟡 [关闭后台进程](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>注意 | 强制结束固定列表中的运行进程，包括 OneDrive、Teams、Edge 和 Game Bar。请先保存工作。<br><br>需要管理员权限。 |
| 🔴 [VBS 与内存完整性](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>警告 | 打开 Windows 安全中心的内核隔离页面，以便检查内存完整性及其要求。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>更改内存完整性可能削弱 Windows 隔离防护。 |
| 🟡 [DirectX 翻转模型](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>注意 | 写入 DirectX、GameConfigStore 和 DWM 的 SwapEffectUpgradeEnable 与 Win32_AutoFlip 设置，为符合条件的窗口化游戏请求 Flip Model。<br><br>需要管理员权限。 |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>注意 | 打开 Windows 游戏设置中的 Xbox Game Bar 页面，以便检查叠加层设置。 |

</details>

<details>
<summary>系统与 Talon (16)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🔴 [Talon Suite](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>警告 | 分九个阶段调整诊断与活动策略、Copilot 与 Recall、传递与建议、资源管理器、辅助功能、开始菜单与小组件、计划任务、后台应用以及内核和 GPU 超时。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>同时更改多个应用、服务和系统任务。 |
| 🟡 [经典右键菜单](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>注意 | 为当前用户添加经典右键菜单的资源管理器覆盖设置。重新启动资源管理器或重新登录后检查菜单。<br><br>需要管理员权限。 |
| 🟡 [ULPS 与 PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | 将显卡驱动现有的 ULPS 标志置为 0，关闭 HFS，并调整当前电源计划的 PCIe 链路状态和部分 CPU 电源设置。<br><br>需要管理员权限。 |
| 🟡 [重新启用 Defender](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>注意 | 通过 Microsoft Defender PowerShell 请求启用实时保护，并检查 RealTimeProtectionEnabled 是否为 true。<br><br>需要管理员权限。 |
| 🔴 [实时防护](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>警告 | 打开 Windows 安全中心的病毒和威胁防护设置，以便在该页面检查实时保护。<br><br>关闭实时防护会降低恶意软件检测能力。 |
| 🟡 [Defender 扫描优先级](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>注意 | 将 Defender 扫描的平均 CPU 使用率目标设为 20%，并启用低优先级扫描。<br><br>需要管理员权限。 |
| 🟡 [SysMain 服务](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>注意 | 停止 SysMain，并将启动类型设为禁用。<br><br>需要管理员权限。 |
| 🟡 [快速启动和休眠](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | 通过 powercfg 关闭休眠，并将 HiberbootEnabled 设为 0，同时关闭快速启动。<br><br>需要管理员权限。 |
| 🟡 [诊断与遥测](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>注意 | 停止并禁用最多 8 项现有服务，包括 DiagTrack、SysMain、Windows 搜索、MapsBroker 和传递优化（DoSvc）。<br><br>需要管理员权限。 |
| 🔴 [移除内置应用](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>警告 | 为所有用户卸载固定列表中已安装的 AppX 包，包括手机连接、天气、Clipchamp 和 Windows 地图。<br><br>需要管理员权限。<br><br>移除 Windows 应用后，可能需要重新安装才能恢复相关功能。 |
| 🟡 [精简工作集](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>注意 | 使用 EmptyWorkingSet 缩减可访问进程的工作集，并记录操作前后的可用 RAM。<br><br>需要管理员权限。 |
| 🟡 [清理临时文件](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>注意 | 删除当前账户 Temp、Windows Temp 和 Windows Prefetch 中可清理的内容。跳过锁定或受保护的条目并报告释放空间。<br><br>需要管理员权限。 |
| 🔴 [高级磁盘清理](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>警告 | 清理常规 Temp 和 Prefetch，以及 Windows 更新下载文件、资源管理器缓存、系统日志、崩溃转储和错误报告。跳过锁定与受保护项。<br><br>需要管理员权限。<br><br>删除更新缓存、系统日志和诊断文件。 |
| 🟡 [切换休眠](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | 检查 C:\hiberfil.sys 是否存在。存在时请求关闭休眠，否则请求启用。<br><br>需要管理员权限。 |
| 🟡 [启动应用](https://learn.microsoft.com/en-us/windows/win32/setupapi/run-and-runonce-registry-keys)<br>注意 | 列出当前用户和整台电脑的注册表 Run 项。取消勾选要移除的项，检查后确认。Meowize 会先将值备份到 JSON。整机条目需要管理员权限。 |
| 🔴 [Windows 更新](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>警告 | 打开设置中的 Windows 更新页面，以便检查更新和重启选项。<br><br>暂停更新可能延迟安装安全修复。 |

</details>

<details>
<summary>网络与驱动 (8)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🟡 [网络节能](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>注意 | 调整网卡电源管理以阻止 Windows 关闭设备，并在驱动提供时关闭相关节能属性。<br><br>需要管理员权限。 |
| 🟡 [TCP/IP 调整](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>注意 | 在注册表的 TCP/IP 接口中写入 TCPNoDelay = 1、TcpAckFrequency = 1 和 TcpDelAckTicks = 0。影响取决于连接和应用所用协议。<br><br>需要管理员权限。 |
| 🟡 [大型发送卸载](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>注意 | 尝试关闭 IPv4 和 IPv6 的 LSO 与校验和卸载，并在驱动提供时调整节能以太网、Gigabit Lite、节电及中断调节。<br><br>需要管理员权限。 |
| 🟡 [DNS 地址](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>注意 | 把所选提供商的两个 IPv4 DNS 地址应用到所有活动网卡，回读验证后清除本地 DNS 缓存。<br><br>选择 DNS 提供商，点击应用，并在确认前检查地址。<br><br>需要管理员权限。 |
| 🟢 [清除 DNS 缓存](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig)<br>安全 | 运行 ipconfig /flushdns 清空 Windows 本地 DNS 解析器缓存。<br><br>需要管理员权限。 |
| 🔴 [重置网络](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>警告 | 重置 Winsock 和 TCP/IP，释放并续订 IP 租约，然后清除 DNS 缓存。连接可能中断。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>可能中断网络连接或更改网络配置。 |
| 🔴 [Display Driver Uninstaller](https://www.wagnardsoft.com/)<br>警告 | 从 Wagnardsoft 下载 Display Driver Uninstaller 18.0.8.6，验证发布者签名后打开。实际卸载驱动在 DDU 中单独操作。<br><br>DDU 用于移除显示驱动，可能需要重启。 |
| 🔴 [重启进入 UEFI](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/shutdown)<br>警告 | 确认后立即请求重启进入 UEFI 固件设置。请先保存工作。<br><br>需要管理员权限。<br><br>立即重启到 UEFI。请先保存工作。 |

</details>

<details>
<summary>应用与工具 (7)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🔴 [NVIDIA 581.80 WHQL](https://www.nvidia.com/en-us/drivers/details/257497/)<br>警告 | 下载此行所示版本的 NVIDIA 桌面显卡驱动。签名有效时启动静默安装程序并等待退出代码。请先查阅支持的 GPU 列表。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>屏幕可能闪烁，Windows 可能需要重启。 |
| 🔴 [NVIDIA 566.36 WHQL](https://www.nvidia.com/en-us/drivers/details/237719/)<br>警告 | 下载此行所示版本的 NVIDIA 桌面显卡驱动。签名有效时启动静默安装程序并等待退出代码。请先查阅支持的 GPU 列表。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>屏幕可能闪烁，Windows 可能需要重启。 |
| 🟡 [CPU-Z 与 HWMonitor](https://www.cpuid.com/)<br>注意 | 从 CPUID 下载 CPU-Z 2.11 和 HWMonitor 1.55，解压至桌面的 Meowize_Tools，并打开通过 CPUID 签名验证的 x64 程序。 |
| 🟡 [Unpark CPU App](https://coderbag.com/product/quickcpu)<br>注意 | 下载 CoderBag 的 Unpark CPU App，解压到桌面的 Meowize_Tools，并打开通过签名验证的程序。核心停放设置在该工具中选择。 |
| 🟡 [Visual C++ x64](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)<br>注意 | 从 Microsoft 下载 Visual C++ x64 可再发行组件，验证发布者签名后以被动模式运行安装程序，并禁用自动重启。<br><br>需要管理员权限。 |
| 🟡 [用 WinGet 安装 3 个应用](https://github.com/microsoft/winget-cli)<br>注意 | 借助 Windows 应用安装程序中的 WinGet 依次安装 Google Chrome、Discord 和 7-Zip。进度与包错误可在活动日志中查看。<br><br>需要管理员权限。 |
| 🟢 [Office 部署设置](https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/overview-office-deployment-tool)<br>安全 | 在默认浏览器中打开 Microsoft Office 自定义工具，以便选择部署设置。 |

</details>

<details>
<summary>诊断 (7)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🟢 [硬件信息](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/operating-system-classes)<br>安全 | 使用 Windows CIM 读取 CPU 型号及核心和线程数、GPU 型号、内存总量以及 C: 盘容量和可用空间，并写入活动日志。 |
| 🟢 [物理磁盘健康](https://learn.microsoft.com/en-us/powershell/module/storage/get-physicaldisk)<br>安全 | 显示 Get-PhysicalDisk 报告的各物理磁盘名称、介质类型、容量和 HealthStatus。 |
| 🟢 [ACPI 温度](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/thermal-management-in-windows)<br>安全 | 通过 WMI 读取设备提供的 ACPI 热区，并将温度转换为摄氏度。可用传感器取决于固件。 |
| 🟢 [Windows 激活](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/sppwmi/softwarelicensingproduct)<br>安全 | 从 SoftwareLicensingProduct 读取 Windows 激活数据，记录版本、激活状态及可用时的已安装密钥末尾五个字符。 |
| 🟢 [磁盘与内存检查](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/systeminfo)<br>安全 | 从 100 分起算，每符合一项扣 15 分。检查条件为 C: 盘剩余不足 15 GB 和内存使用率超过 85%。 |
| 🟢 [硬件兼容性](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor)<br>安全 | 通过 CIM 读取 CPU 型号，根据名称是否匹配 Intel、Xeon 或 Ryzen 输出相应提示。 |
| 🟢 [系统快照](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>安全 | 请求创建并验证 Windows 还原点，同时将 HKLM 和 HKCU 导出到 C:\Meowize_Backup。两个步骤会独立尝试。<br><br>需要管理员权限。 |

</details>

<details>
<summary>恢复与报告 (8)</summary>

| 任务 | Meowize 执行的操作 |
| --- | --- |
| 🟢 [创建还原点](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>安全 | 为 Windows 所在驱动器启用系统保护，请求创建带时间戳的 Meowize 还原点，并验证其序列号为新值。<br><br>需要管理员权限。 |
| 🟢 [备份注册表](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>安全 | 将 HKLM 与 HKCU 以 HKLM.reg 和 HKCU.reg 导出到 C:\Meowize_Backup 下的新 Manual 快照。<br><br>需要管理员权限。 |
| 🔴 [还原注册表](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-import)<br>警告 | 确认前显示最新的兼容快照和路径。验证注册表文件头，备份当前注册表，再导入该快照。<br><br>需要管理员权限。<br><br>此更改可能需要重启 Windows 才会生效。<br><br>从备份导入计算机或账户的注册表设置。 |
| 🟡 [使用 DISM 和 SFC 修复 Windows](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>注意 | 运行 DISM /Online /Cleanup-Image /RestoreHealth。DISM 成功后运行 sfc /scannow，并将命令输出写入日志。<br><br>需要管理员权限。 |
| 🟢 [HTML 系统报告](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-html)<br>安全 | 将 CPU、GPU、RAM 和 Windows 信息写入桌面的 Meowize_System_Report.html，并用默认浏览器打开。 |
| 🟢 [导出活动日志](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file)<br>安全 | 打开保存对话框，将带时间戳的当前活动日志写入 UTF-8 .txt 文件。 |
| 🟢 [复制日志](https://learn.microsoft.com/en-us/dotnet/api/system.windows.clipboard.settext)<br>安全 | 将当前活动日志及时间戳复制到 Windows 剪贴板。 |
| 🟡 [诊断 ZIP](https://learn.microsoft.com/en-us/dotnet/api/system.io.compression.ziparchive)<br>注意 | 选择保存路径后运行 systeminfo 和 ipconfig /all，将输出及当前 Meowize 日志写入本地 ZIP。分享前请查看包中的设备和网络信息。 |

</details>
