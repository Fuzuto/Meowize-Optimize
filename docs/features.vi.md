# Hướng dẫn từng tính năng

[Meowize](README.vi.md) · [English](features.en.md) · [日本語](features.ja.md) · [한국어](features.ko.md) · **Tiếng Việt** · [简体中文](features.zh-CN.md)

## 1-Click (51)

Chọn mục này trong 1-Click, rồi bấm Xem và chạy.

**Tự tắt máy sau khi hoàn tất** · Nếu batch đủ điều kiện, máy sẽ đếm ngược 45 giây trước khi tắt. Trong lúc đếm ngược, bấm **Hủy tắt máy** trong nhật ký để dừng.

<details>
<summary>An toàn và hệ thống (10)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🟢 [Tạo điểm khôi phục](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>An toàn | Yêu cầu tạo và xác minh điểm khôi phục Windows, đồng thời xuất HKLM và HKCU vào C:\Meowize_Backup. Hai bước được thử độc lập.<br><br>Cần quyền quản trị. |
| 🟢 [Sao lưu Registry phụ](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>An toàn | Xuất hai nhánh HKLM\SYSTEM\CurrentControlSet\Control và HKCU\Software\Microsoft\Windows\CurrentVersion. Lưu ở D:\Meowize_Backup nếu có ổ D, nếu không dùng C:\Meowize_Backup\BranchExports.<br><br>Cần quyền quản trị. |
| 🟡 [Dừng tiến trình nền](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>Cẩn trọng | Buộc đóng các tiến trình đang chạy trong danh sách có sẵn, gồm OneDrive, Teams, Edge và Game Bar. Hãy lưu công việc đang mở trước khi chạy.<br><br>Cần quyền quản trị. |
| 🟡 [Fast Startup và Hibernate](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Cẩn trọng | Dùng powercfg để tắt Hibernate và đặt HiberbootEnabled = 0. Thao tác này cũng tắt Fast Startup.<br><br>Cần quyền quản trị. |
| 🔴 [Bảo vệ thời gian thực](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>Cảnh báo | Mở mục cài đặt Bảo vệ khỏi virus và mối đe dọa trong Windows Security để bạn kiểm tra bảo vệ thời gian thực tại đó.<br><br>Chọn mục này trong 1-Click. Tại màn xem lại, bấm Mở cài đặt Windows để đến đúng trang.<br><br>Giảm khả năng phát hiện mã độc nếu tắt bảo vệ thời gian thực. |
| 🔴 [Windows Update](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>Cảnh báo | Mở Windows Update trong Cài đặt để bạn xem tùy chọn cập nhật và khởi động lại.<br><br>Chọn mục này trong 1-Click. Tại màn xem lại, bấm Mở cài đặt Windows để đến đúng trang.<br><br>Tạm dừng cập nhật có thể làm máy nhận bản vá bảo mật muộn hơn. |
| 🟡 [Ưu tiên quét Defender](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>Cẩn trọng | Đặt mục tiêu CPU trung bình 20% cho các lần quét của Defender và bật ưu tiên CPU thấp khi quét.<br><br>Cần quyền quản trị. |
| 🟡 [Dịch vụ SysMain](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>Cẩn trọng | Dừng dịch vụ SysMain và đặt kiểu khởi động của dịch vụ thành Disabled.<br><br>Cần quyền quản trị. |
| 🟡 [Chẩn đoán và telemetry](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>Cẩn trọng | Dừng và vô hiệu hóa khởi động cho DiagTrack, dmwappushservice, SysMain và MapsBroker. Đặt AllowTelemetry = 0 và tắt các tác vụ lịch thuộc Customer Experience và Application Experience.<br><br>Cần quyền quản trị. |
| 🔴 [Gỡ ứng dụng mặc định](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>Cảnh báo | Gỡ các gói AppX đã định sẵn cho mọi tài khoản, gồm ứng dụng Xbox, Thời tiết và Clipchamp, đồng thời bỏ gói cấp sẵn cho tài khoản mới. Mục này cũng đổi chính sách Game DVR và cách mở liên kết Game Bar.<br><br>Cần quyền quản trị.<br><br>Gỡ ứng dụng Windows. Có thể cần cài lại ứng dụng để khôi phục tính năng. |

</details>

<details>
<summary>Gaming và độ trễ (20)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🟡 [Buffer chuột và bàn phím](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>Cẩn trọng | Đặt MouseDataQueueSize và KeyboardDataQueueSize về 20 trong Registry của trình điều khiển chuột và bàn phím Windows. Bật Game Mode cho tài khoản hiện tại và yêu cầu bật HAGS bằng HwSchMode = 2.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi. |
| 🔴 [VBS và Memory Integrity](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>Cảnh báo | Mở Cách ly lõi trong Windows Security để bạn xem Tính toàn vẹn bộ nhớ và các điều kiện liên quan.<br><br>Chọn mục này trong 1-Click. Tại màn xem lại, bấm Mở cài đặt Windows để đến đúng trang.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Giảm lớp bảo vệ cách ly của Windows nếu thay đổi Memory Integrity. |
| 🟡 [DirectX Flip Model](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>Cẩn trọng | Ghi các giá trị SwapEffectUpgradeEnable và Win32_AutoFlip trong DirectX, GameConfigStore và DWM để yêu cầu Flip Model cho game chạy cửa sổ phù hợp.<br><br>Cần quyền quản trị. |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>Cẩn trọng | Mở trang Xbox Game Bar trong phần Chơi trò chơi của Cài đặt Windows để bạn xem cấu hình lớp phủ tại đó.<br><br>Chọn mục này trong 1-Click. Tại màn xem lại, bấm Mở cài đặt Windows để đến đúng trang. |
| 🟡 [Ưu tiên CPU cho game](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>Cẩn trọng | Đặt ưu tiên CPU mức High cho các tệp chạy trong danh sách, gồm VALORANT, CS2 và Overwatch. Windows đọc thiết lập theo tên tệp khi game tương ứng khởi chạy.<br><br>Cần quyền quản trị. |
| 🔴 [Bộ định thời HPET](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Cảnh báo | Thử tắt thiết bị HPET tìm thấy và sửa bộ định thời khởi động trong BCD. Xóa giá trị ghi đè platform clock, bật platform tick và tắt dynamic tick.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Tác động đến bộ định thời phần cứng và cấu hình khởi động. |
| 🔴 [Ưu tiên CPU và BCD](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Cảnh báo | Đặt Win32PrioritySeparation = 38 (0x26). Trong BCD, bật platform tick, xóa giá trị ghi đè platform clock và tắt dynamic tick.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Thay đổi cấu hình khởi động BCD. Cần kiểm tra sau khi khởi động lại. |
| 🟡 [Multiplane Overlay](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>Cẩn trọng | Ghi EnableMPO = 0 và OverlayTestMode = 5 trong nhánh Registry MultiplaneOverlay của máy.<br><br>Cần quyền quản trị. |
| 🟡 [Fullscreen Optimizations](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>Cẩn trọng | Ghi thiết lập toàn màn hình và Game DVR, tắt quay ứng dụng, chuyển hướng một số liên kết Game Bar và thử dừng dịch vụ ghi hình Game DVR theo tài khoản.<br><br>Cần quyền quản trị. |
| 🔴 [Chế độ ngắt MSI](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>Cảnh báo | Đặt MSISupported = 1 cho các mục thiết bị PCI khớp trong Registry. Phạm vi có thể gồm thiết bị khác ngoài card đồ họa và card mạng. Hiệu lực tùy thiết bị và driver.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Phạm vi gồm mọi thiết bị PCI khớp. Đổi chế độ ngắt có thể gây mất ổn định. |
| 🟡 [GPU Scheduling](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>Cẩn trọng | Đặt HwSchMode = 2 để yêu cầu bật lập lịch GPU tăng tốc phần cứng. Windows cần GPU và driver tương thích.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi. |
| 🔴 [Power Plan và FPS Boost](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Cảnh báo | Tạo hoặc kích hoạt gói điện hiệu năng, rồi chỉnh CPU, core parking, làm mát và thời gian ngủ khi cắm điện. Mục này còn sửa bộ định thời BCD, ưu tiên tác vụ nền trước, MPO, multimedia, Game DVR, gia tốc chuột và thiết lập nguồn cho kernel.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Profile áp dụng nhiều thay đổi cùng lúc, gồm cả cấu hình khởi động BCD. |
| 🟡 [Unpark CPU](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>Cẩn trọng | Yêu cầu mức tối thiểu 100% lõi không bị park trong gói điện hiện tại, cả khi cắm sạc lẫn dùng pin.<br><br>Cần quyền quản trị. |
| 🟡 [ULPS và PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Cẩn trọng | Đặt các cờ ULPS có sẵn của driver đồ họa về 0, tắt HFS và sửa quản lý điện PCIe link state cùng một số thiết lập nguồn CPU trong gói hiện tại.<br><br>Cần quyền quản trị. |
| 🟡 [Gia tốc chuột](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>Cẩn trọng | Đặt MouseSpeed, MouseThreshold1 và MouseThreshold2 của tài khoản Windows hiện tại về 0 để tắt gia tốc con trỏ.<br><br>Cần quyền quản trị. |
| 🔴 [Đồng bộ TSC](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Cảnh báo | Đặt chính sách đồng bộ bộ đếm thời gian TSC trong BCD thành Enhanced.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Thay đổi cấu hình khởi động BCD. Cần kiểm tra sau khi khởi động lại. |
| 🟡 [Paging của kernel](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>Cẩn trọng | Ghi DisablePagingExecutive = 1 và PowerThrottlingOff = 1 trong Registry Windows.<br><br>Cần quyền quản trị. |
| 🟡 [Multimedia Scheduler](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>Cẩn trọng | Ghi SystemResponsiveness = 0 và NetworkThrottlingIndex = 0xFFFFFFFF nếu có cấu hình multimedia. Với tác vụ Games, đặt GPU Priority = 8, Priority = 6 và lịch chạy mức High.<br><br>Cần quyền quản trị. |
| 🟡 [Độ trễ phục hồi GPU](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/timeout-detection-and-recovery)<br>Cẩn trọng | Đặt TdrDelay = 8 giây cho cơ chế phát hiện GPU quá thời gian phản hồi. Microsoft mô tả giá trị này để kiểm thử và gỡ lỗi driver.<br><br>Cần quyền quản trị. |
| 🟡 [Sticky, Toggle và Filter Keys](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>Cẩn trọng | Ghi lại cờ trợ năng của Sticky Keys, Filter Keys và Toggle Keys cho tài khoản hiện tại để thay đổi cách hoạt động của phím tắt.<br><br>Cần quyền quản trị. |

</details>

<details>
<summary>Talon Suite (10)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🟡 [Dữ liệu chẩn đoán](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>Cẩn trọng | Ghi chính sách dữ liệu chẩn đoán và lịch sử hoạt động của Windows, đồng thời đặt DisableWpbtExecution = 1 cho Windows Platform Binary Table.<br><br>Cần quyền quản trị. |
| 🔴 [Chính sách Copilot và Recall](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-windowsai)<br>Cảnh báo | Đặt TurnOffWindowsCopilot = 1 và DisableAIDataAnalysis = 1 trong các nhánh chính sách của tài khoản và toàn máy.<br><br>Cần quyền quản trị.<br><br>Chính sách có thể ảnh hưởng đến tính năng Copilot và Recall của các tài khoản trên máy. |
| 🟡 [Quảng cáo và hệ thống phát bản cập nhật](https://learn.microsoft.com/en-us/windows/deployment/do/waas-delivery-optimization)<br>Cẩn trọng | Đặt DisableWindowsConsumerFeatures = 1 và đặt chế độ tải của Delivery Optimization về 0, dùng HTTP.<br><br>Cần quyền quản trị. |
| 🟡 [Menu chuột phải cổ điển](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>Cẩn trọng | Thêm thiết lập Explorer theo tài khoản để dùng menu chuột phải cổ điển. Khởi động lại Explorer hoặc đăng nhập lại để kiểm tra.<br><br>Cần quyền quản trị. |
| 🟡 [File Explorer](https://support.microsoft.com/en-us/windows/file-explorer-in-windows-ef370130-1cca-9dc5-e0df-2f7416fe1cb1)<br>Cẩn trọng | Đặt LaunchTo = 1 để File Explorer mở vào This PC và yêu cầu bỏ ghim Gallery khỏi cây điều hướng.<br><br>Cần quyền quản trị. |
| 🟡 [Tìm kiếm và Widgets](https://learn.microsoft.com/en-us/windows/configuration/start/)<br>Cẩn trọng | Ghi thiết lập tìm kiếm Bing và gợi ý trong ô tìm kiếm, đồng thời đặt chính sách Windows Widgets thành tắt.<br><br>Cần quyền quản trị. |
| 🔴 [Scheduled Tasks](https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/disable-scheduledtask)<br>Cảnh báo | Thử tắt tám tác vụ lịch có tên cố định, gồm Compatibility Appraiser, Disk Diagnostic Data Collector và WinSAT.<br><br>Cần quyền quản trị.<br><br>Tắt một số lịch tác vụ của Windows. Việc bảo trì liên quan có thể bị ảnh hưởng. |
| 🟡 [Dịch vụ Windows](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>Cẩn trọng | Dừng DiagTrack, dmwappushservice, SysMain và Windows Search (WSearch), rồi đặt chúng thành không tự khởi động.<br><br>Cần quyền quản trị. |
| 🔴 [Ứng dụng UWP của Talon](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>Cảnh báo | Gỡ các gói AppX đã cài cho mọi tài khoản theo danh sách Talon, gồm Thời tiết, Mixed Reality Portal và Clipchamp.<br><br>Cần quyền quản trị.<br><br>Gỡ ứng dụng Windows. Có thể cần cài lại ứng dụng để khôi phục tính năng. |
| 🟡 [Độ trễ menu và End Task](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>Cẩn trọng | Đặt độ trễ hiện menu về 0, bật mục Kết thúc tác vụ trên thanh tác vụ và hiện phần mở rộng tệp trong File Explorer.<br><br>Cần quyền quản trị. |

</details>

<details>
<summary>Mạng và dọn dẹp (11)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🟡 [Large Send Offload](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>Cẩn trọng | Thử tắt LSO cho IPv4 và IPv6 cùng checksum offload. Với thuộc tính mà driver cung cấp, mục này còn chỉnh Energy Efficient hoặc Green Ethernet, Gigabit Lite, tiết kiệm điện và Interrupt Moderation.<br><br>Cần quyền quản trị. |
| 🟡 [Tối ưu TCP](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>Cẩn trọng | Ghi TCPNoDelay = 1, TcpAckFrequency = 1 và TcpDelAckTicks = 0 cho các interface TCP/IP có trong Registry. Tác động tùy kết nối và giao thức ứng dụng sử dụng.<br><br>Cần quyền quản trị. |
| 🟡 [Tiết kiệm điện adapter](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>Cẩn trọng | Đổi quản lý nguồn để Windows không tự tắt thiết bị mạng, đồng thời tắt các thuộc tính tiết kiệm điện tương ứng nếu driver có cung cấp.<br><br>Cần quyền quản trị. |
| 🟡 [DNS Cloudflare](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>Cẩn trọng | Đặt DNS IPv4 Cloudflare 1.1.1.1 và 1.0.0.1 cho các adapter có trạng thái Up trong Windows.<br><br>Cần quyền quản trị. |
| 🔴 [Đặt lại mạng](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>Cảnh báo | Xóa cache DNS cục bộ và đặt lại Winsock cùng TCP/IP. Windows có thể cần khởi động lại.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Đặt lại mạng có thể làm mất kết nối hoặc thay đổi cấu hình hiện tại. |
| 🟡 [Dọn tệp tạm Windows](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Cẩn trọng | Xóa nội dung có thể dọn trong Temp của tài khoản, Windows Temp và Windows Prefetch. Bỏ qua mục đang khóa hoặc được bảo vệ và báo dung lượng đã giải phóng.<br><br>Cần quyền quản trị. |
| 🔴 [Dọn cache Riot](https://support-valorant.riotgames.com/)<br>Cảnh báo | Dọn Riot Client Logs và Data, cùng thư mục Logs và Crashes trong VALORANT Saved tại Local AppData của tài khoản hiện tại. Hãy đóng Riot Client và VALORANT trước khi dọn.<br><br>Cần quyền quản trị.<br><br>Xóa cache, log và một số dữ liệu cục bộ của Riot Client. |
| 🟡 [Dọn shader cache](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Cẩn trọng | Xóa các cache DX và GL của NVIDIA, AMD và D3DSCache của Windows trong Local AppData. Game có thể tạo lại cache shader khi mở.<br><br>Cần quyền quản trị. |
| 🟡 [Thu gọn working set](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>Cẩn trọng | Dùng EmptyWorkingSet để yêu cầu Windows thu gọn working set của tiến trình có thể truy cập, rồi thu gom bộ nhớ trong tiến trình thực thi của Meowize.<br><br>Cần quyền quản trị. |
| 🟡 [Cài 6 ứng dụng qua Winget](https://github.com/microsoft/winget-cli)<br>Cẩn trọng | Dùng WinGet trong Windows App Installer để cài lần lượt Chrome, Discord, 7-Zip, UniKey, UltraViewer và Zalo. Nhật ký ghi kết quả theo từng gói.<br><br>Cần quyền quản trị. |
| 🟡 [Sửa hệ thống với DISM và SFC](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>Cẩn trọng | Chạy DISM /Online /Cleanup-Image /RestoreHealth. Nếu DISM thành công, chạy tiếp sfc /scannow và ghi đầu ra của lệnh vào nhật ký.<br><br>Cần quyền quản trị. |

</details>

## Công cụ chạy riêng (66)

Mở đúng trang rồi bấm nút ở dòng tác vụ. Chọn ⓘ để xem các bước trong ứng dụng trước khi chạy.

<details>
<summary>Gaming & FPS (20)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🟡 [Buffer chuột và bàn phím](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>Cẩn trọng | Đặt MouseDataQueueSize và KeyboardDataQueueSize về 20 trong Registry của trình điều khiển chuột và bàn phím Windows. Bật Game Mode cho tài khoản hiện tại và yêu cầu bật HAGS bằng HwSchMode = 2.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi. |
| 🔴 [FPS Boost](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Cảnh báo | Tạo hoặc kích hoạt gói điện hiệu năng, rồi chỉnh CPU, core parking, làm mát và thời gian ngủ khi cắm điện. Mục này còn sửa bộ định thời BCD, ưu tiên tác vụ nền trước, MPO, multimedia, Game DVR, gia tốc chuột và thiết lập nguồn cho kernel.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Profile áp dụng nhiều thay đổi cùng lúc, gồm cả cấu hình khởi động BCD. |
| 🟡 [Paging của kernel](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>Cẩn trọng | Đặt DisablePagingExecutive = 1, LargeSystemCache = 0 và PowerThrottlingOff = 1. Khởi động lại trước khi so sánh kết quả.<br><br>Cần quyền quản trị. |
| 🔴 [Đồng bộ TSC](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Cảnh báo | Trong BCD, đặt đồng bộ TSC thành Enhanced, bật platform tick, xóa giá trị ghi đè platform clock và tắt dynamic tick.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Thay đổi cấu hình khởi động BCD. Cần kiểm tra sau khi khởi động lại. |
| 🟡 [Sticky, Toggle và Filter Keys](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>Cẩn trọng | Ghi lại cờ trợ năng của Sticky Keys, Filter Keys và Toggle Keys cho tài khoản hiện tại để thay đổi cách hoạt động của phím tắt.<br><br>Cần quyền quản trị. |
| 🔴 [Bộ định thời HPET](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>Cảnh báo | Thử tắt thiết bị HPET tìm thấy và sửa bộ định thời khởi động trong BCD. Xóa giá trị ghi đè platform clock, bật platform tick và tắt dynamic tick.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Tác động đến bộ định thời phần cứng và cấu hình khởi động. |
| 🟡 [Unpark CPU](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>Cẩn trọng | Yêu cầu mức tối thiểu 100% lõi không bị park trong gói điện hiện tại, cả khi cắm sạc lẫn dùng pin.<br><br>Cần quyền quản trị. |
| 🟡 [Ưu tiên CPU cho game](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>Cẩn trọng | Đặt ưu tiên CPU mức High cho các tệp chạy trong danh sách, gồm VALORANT, CS2 và Overwatch. Windows đọc thiết lập theo tên tệp khi game tương ứng khởi chạy.<br><br>Cần quyền quản trị. |
| 🟡 [Multiplane Overlay](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>Cẩn trọng | Đổi giá trị OverlayTestMode của DWM. Nếu đang là 5 thì chuyển về 0. Các giá trị khác sẽ chuyển thành 5.<br><br>Cần quyền quản trị. |
| 🔴 [Chế độ ngắt MSI](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>Cảnh báo | Đặt MSISupported = 1 cho các mục thiết bị PCI khớp trong Registry. Phạm vi có thể gồm thiết bị khác ngoài card đồ họa và card mạng. Hiệu lực tùy thiết bị và driver.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Phạm vi gồm mọi thiết bị PCI khớp. Đổi chế độ ngắt có thể gây mất ổn định. |
| 🟡 [GPU Scheduling](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>Cẩn trọng | Đặt HwSchMode = 2 để yêu cầu bật lập lịch GPU tăng tốc phần cứng. Windows cần GPU và driver tương thích.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi. |
| 🟡 [Dọn shader cache](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Cẩn trọng | Xóa các cache DX và GL của NVIDIA, AMD và D3DSCache của Windows trong Local AppData. Game có thể tạo lại cache shader khi mở.<br><br>Cần quyền quản trị. |
| 🟡 [Fullscreen Optimizations](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>Cẩn trọng | Ghi thiết lập toàn màn hình và Game DVR, tắt quay ứng dụng, chuyển hướng một số liên kết Game Bar và thử dừng dịch vụ ghi hình Game DVR theo tài khoản.<br><br>Cần quyền quản trị. |
| 🟡 [Lập lịch đa phương tiện](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>Cẩn trọng | Ghi SystemResponsiveness = 0 và NetworkThrottlingIndex = 0xFFFFFFFF nếu có cấu hình multimedia. Với tác vụ Games, đặt GPU Priority = 8, Priority = 6 và lịch chạy mức High.<br><br>Cần quyền quản trị. |
| 🟡 [Gia tốc chuột](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>Cẩn trọng | Đặt MouseSpeed, MouseThreshold1 và MouseThreshold2 của tài khoản Windows hiện tại về 0 để tắt gia tốc con trỏ.<br><br>Cần quyền quản trị. |
| 🔴 [Dọn cache Riot](https://support-valorant.riotgames.com/)<br>Cảnh báo | Dọn Riot Client Logs và Data, cùng thư mục Logs và Crashes trong VALORANT Saved tại Local AppData của tài khoản hiện tại. Hãy đóng Riot Client và VALORANT trước khi dọn.<br><br>Cần quyền quản trị.<br><br>Xóa cache, log và một số dữ liệu cục bộ của Riot Client. |
| 🟡 [Dừng tiến trình nền](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>Cẩn trọng | Buộc đóng các tiến trình đang chạy trong danh sách có sẵn, gồm OneDrive, Teams, Edge và Game Bar. Hãy lưu công việc đang mở trước khi chạy.<br><br>Cần quyền quản trị. |
| 🔴 [VBS và Memory Integrity](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>Cảnh báo | Mở Cách ly lõi trong Windows Security để bạn xem Tính toàn vẹn bộ nhớ và các điều kiện liên quan.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Giảm lớp bảo vệ cách ly của Windows nếu thay đổi Memory Integrity. |
| 🟡 [DirectX Flip Model](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>Cẩn trọng | Ghi các giá trị SwapEffectUpgradeEnable và Win32_AutoFlip trong DirectX, GameConfigStore và DWM để yêu cầu Flip Model cho game chạy cửa sổ phù hợp.<br><br>Cần quyền quản trị. |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>Cẩn trọng | Mở trang Xbox Game Bar trong phần Chơi trò chơi của Cài đặt Windows để bạn xem cấu hình lớp phủ tại đó. |

</details>

<details>
<summary>Hệ thống & Talon (16)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🔴 [Talon Suite](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>Cảnh báo | Chạy chín giai đoạn chỉnh chính sách chẩn đoán và lịch sử, Copilot và Recall, phân phối và gợi ý, File Explorer, trợ năng, Start và Widgets, tác vụ lịch, ứng dụng nền và các giá trị kernel/GPU timeout.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Áp dụng nhiều thay đổi về ứng dụng, dịch vụ và tác vụ hệ thống. |
| 🟡 [Menu chuột phải cổ điển](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>Cẩn trọng | Thêm thiết lập Explorer theo tài khoản để dùng menu chuột phải cổ điển. Khởi động lại Explorer hoặc đăng nhập lại để kiểm tra.<br><br>Cần quyền quản trị. |
| 🟡 [ULPS và PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Cẩn trọng | Đặt các cờ ULPS có sẵn của driver đồ họa về 0, tắt HFS và sửa quản lý điện PCIe link state cùng một số thiết lập nguồn CPU trong gói hiện tại.<br><br>Cần quyền quản trị. |
| 🟡 [Bật lại Defender](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>Cẩn trọng | Yêu cầu bật bảo vệ thời gian thực qua PowerShell của Microsoft Defender, rồi kiểm tra RealTimeProtectionEnabled có trả về true hay không.<br><br>Cần quyền quản trị. |
| 🔴 [Bảo vệ thời gian thực](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>Cảnh báo | Mở mục cài đặt Bảo vệ khỏi virus và mối đe dọa trong Windows Security để bạn kiểm tra bảo vệ thời gian thực tại đó.<br><br>Giảm khả năng phát hiện mã độc nếu tắt bảo vệ thời gian thực. |
| 🟡 [Ưu tiên quét Defender](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>Cẩn trọng | Đặt mục tiêu CPU trung bình 20% cho các lần quét của Defender và bật ưu tiên CPU thấp khi quét.<br><br>Cần quyền quản trị. |
| 🟡 [Dịch vụ SysMain](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>Cẩn trọng | Dừng dịch vụ SysMain và đặt kiểu khởi động của dịch vụ thành Disabled.<br><br>Cần quyền quản trị. |
| 🟡 [Fast Startup và Hibernate](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Cẩn trọng | Dùng powercfg để tắt Hibernate và đặt HiberbootEnabled = 0. Thao tác này cũng tắt Fast Startup.<br><br>Cần quyền quản trị. |
| 🟡 [Chẩn đoán và telemetry](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>Cẩn trọng | Dừng và vô hiệu hóa tối đa 8 dịch vụ có trên máy, gồm DiagTrack, SysMain, Windows Search, MapsBroker và Delivery Optimization (DoSvc).<br><br>Cần quyền quản trị. |
| 🔴 [Gỡ ứng dụng mặc định](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>Cảnh báo | Gỡ các gói AppX đã cài cho mọi tài khoản theo danh sách có sẵn, gồm Phone Link, Thời tiết, Clipchamp và Windows Maps.<br><br>Cần quyền quản trị.<br><br>Gỡ ứng dụng Windows. Có thể cần cài lại ứng dụng để khôi phục tính năng. |
| 🟡 [Thu gọn working set](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>Cẩn trọng | Dùng EmptyWorkingSet để thu gọn working set của tiến trình có thể truy cập và ghi lượng RAM trống trước và sau.<br><br>Cần quyền quản trị. |
| 🟡 [Dọn tệp tạm](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Cẩn trọng | Xóa nội dung có thể dọn trong Temp của tài khoản, Windows Temp và Windows Prefetch. Bỏ qua mục đang khóa hoặc được bảo vệ và báo dung lượng đã giải phóng.<br><br>Cần quyền quản trị. |
| 🔴 [Dọn đĩa nâng cao](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>Cảnh báo | Dọn Temp và Prefetch, tệp Windows Update đã tải, cache Explorer, log Windows, crash dump và tệp Windows Error Reporting. Bỏ qua mục đang khóa hoặc được bảo vệ.<br><br>Cần quyền quản trị.<br><br>Xóa cả bộ nhớ đệm cập nhật, log hệ thống và tệp chẩn đoán. |
| 🟡 [Bật/tắt Hibernate](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>Cẩn trọng | Kiểm tra C:\hiberfil.sys. Nếu có tệp, yêu cầu tắt Hibernate. Nếu chưa có, yêu cầu bật.<br><br>Cần quyền quản trị. |
| 🟡 [Quản lý ứng dụng khởi động](https://learn.microsoft.com/en-us/windows/win32/setupapi/run-and-runonce-registry-keys)<br>Cẩn trọng | Liệt kê các mục Registry Run của tài khoản hiện tại và toàn máy. Bỏ chọn mục cần gỡ, xem lại rồi xác nhận. Meowize sao lưu giá trị ra JSON trước khi xóa. Mục toàn máy cần quyền quản trị. |
| 🔴 [Windows Update](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>Cảnh báo | Mở Windows Update trong Cài đặt để bạn xem tùy chọn cập nhật và khởi động lại.<br><br>Tạm dừng cập nhật có thể làm máy nhận bản vá bảo mật muộn hơn. |

</details>

<details>
<summary>Mạng & Driver (8)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🟡 [Tiết kiệm điện adapter](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>Cẩn trọng | Đổi quản lý nguồn để Windows không tự tắt thiết bị mạng, đồng thời tắt các thuộc tính tiết kiệm điện tương ứng nếu driver có cung cấp.<br><br>Cần quyền quản trị. |
| 🟡 [Tinh chỉnh TCP/IP](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>Cẩn trọng | Ghi TCPNoDelay = 1, TcpAckFrequency = 1 và TcpDelAckTicks = 0 cho các interface TCP/IP có trong Registry. Tác động tùy kết nối và giao thức ứng dụng sử dụng.<br><br>Cần quyền quản trị. |
| 🟡 [Large Send Offload](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>Cẩn trọng | Thử tắt LSO cho IPv4 và IPv6 cùng checksum offload. Với thuộc tính mà driver cung cấp, mục này còn chỉnh Energy Efficient hoặc Green Ethernet, Gigabit Lite, tiết kiệm điện và Interrupt Moderation.<br><br>Cần quyền quản trị. |
| 🟡 [Địa chỉ DNS](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>Cẩn trọng | Áp dụng hai DNS IPv4 của nhà cung cấp đã chọn cho mọi adapter đang hoạt động, đọc lại để xác minh rồi xóa cache DNS cục bộ.<br><br>Chọn nhà cung cấp DNS, bấm Áp dụng rồi xem lại địa chỉ trước khi xác nhận.<br><br>Cần quyền quản trị. |
| 🟢 [Làm mới bộ nhớ đệm DNS](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig)<br>An toàn | Chạy ipconfig /flushdns để xóa bộ đệm phân giải DNS cục bộ của Windows.<br><br>Cần quyền quản trị. |
| 🔴 [Đặt lại mạng](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>Cảnh báo | Đặt lại Winsock và TCP/IP, giải phóng rồi gia hạn địa chỉ IP và xóa cache DNS. Kết nối có thể bị gián đoạn.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Đặt lại mạng có thể làm mất kết nối hoặc thay đổi cấu hình hiện tại. |
| 🔴 [Display Driver Uninstaller](https://www.wagnardsoft.com/)<br>Cảnh báo | Tải Display Driver Uninstaller 18.0.8.6 từ Wagnardsoft và mở tệp sau khi xác minh chữ ký nhà phát hành. Việc gỡ driver được thực hiện riêng trong DDU.<br><br>DDU là công cụ gỡ driver đồ họa. Việc gỡ có thể cần khởi động lại. |
| 🔴 [Khởi động vào UEFI](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/shutdown)<br>Cảnh báo | Sau khi xác nhận, yêu cầu khởi động lại ngay vào màn hình UEFI. Hãy lưu công việc đang mở trước.<br><br>Cần quyền quản trị.<br><br>Khởi động lại máy ngay để vào UEFI. Hãy lưu công việc trước. |

</details>

<details>
<summary>Ứng dụng & Công cụ (7)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🔴 [NVIDIA 581.80 WHQL](https://www.nvidia.com/en-us/drivers/details/257497/)<br>Cảnh báo | Tải đúng phiên bản driver NVIDIA desktop ghi ở mục này. Nếu chữ ký NVIDIA hợp lệ, chạy bộ cài im lặng và chờ mã thoát. Hãy xem danh sách GPU hỗ trợ trước.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Thay driver đồ họa. Màn hình có thể chớp và Windows có thể cần khởi động lại. |
| 🔴 [NVIDIA 566.36 WHQL](https://www.nvidia.com/en-us/drivers/details/237719/)<br>Cảnh báo | Tải đúng phiên bản driver NVIDIA desktop ghi ở mục này. Nếu chữ ký NVIDIA hợp lệ, chạy bộ cài im lặng và chờ mã thoát. Hãy xem danh sách GPU hỗ trợ trước.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Thay driver đồ họa. Màn hình có thể chớp và Windows có thể cần khởi động lại. |
| 🟡 [CPU-Z và HWMonitor](https://www.cpuid.com/)<br>Cẩn trọng | Tải CPU-Z 2.11 và HWMonitor 1.55 từ CPUID, giải nén vào Meowize_Tools trên Desktop rồi mở tệp x64 có chữ ký CPUID hợp lệ. |
| 🟡 [Unpark CPU App](https://coderbag.com/product/quickcpu)<br>Cẩn trọng | Tải Unpark CPU App của CoderBag, giải nén vào Meowize_Tools trên Desktop và mở tệp đã xác minh chữ ký. Bạn chọn thay đổi core parking trong chính công cụ đó. |
| 🟡 [Visual C++ x64](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)<br>Cẩn trọng | Tải Visual C++ x64 Redistributable từ Microsoft, xác minh chữ ký và chạy bộ cài ở chế độ thụ động, tắt tự động khởi động lại.<br><br>Cần quyền quản trị. |
| 🟡 [Cài 3 ứng dụng qua Winget](https://github.com/microsoft/winget-cli)<br>Cẩn trọng | Dùng WinGet trong Windows App Installer để cài lần lượt Google Chrome, Discord và 7-Zip. Xem tiến độ và lỗi từng gói trong nhật ký.<br><br>Cần quyền quản trị. |
| 🟢 [Cấu hình triển khai Office](https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/overview-office-deployment-tool)<br>An toàn | Mở Office Customization Tool của Microsoft trong trình duyệt mặc định để bạn chọn cấu hình triển khai. |

</details>

<details>
<summary>Chẩn đoán (7)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🟢 [Thông tin phần cứng](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/operating-system-classes)<br>An toàn | Dùng Windows CIM để đọc tên CPU, số lõi và luồng, tên GPU, tổng RAM, dung lượng và chỗ trống của ổ C:. Kết quả hiện trong nhật ký. |
| 🟢 [Tình trạng ổ vật lý](https://learn.microsoft.com/en-us/powershell/module/storage/get-physicaldisk)<br>An toàn | Liệt kê tên, loại ổ, dung lượng và HealthStatus của từng ổ vật lý theo kết quả Get-PhysicalDisk. |
| 🟢 [Nhiệt độ vùng ACPI](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/thermal-management-in-windows)<br>An toàn | Đọc các vùng nhiệt ACPI mà máy cung cấp qua WMI rồi đổi số đo sang °C. Cảm biến khả dụng tùy firmware. |
| 🟢 [Kích hoạt Windows](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/sppwmi/softwarelicensingproduct)<br>An toàn | Đọc dữ liệu kích hoạt Windows từ SoftwareLicensingProduct. Nhật ký ghi phiên bản hệ điều hành, trạng thái kích hoạt và năm ký tự cuối của khóa đã cài nếu có. |
| 🟢 [Kiểm tra ổ đĩa và RAM](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/systeminfo)<br>An toàn | Bắt đầu từ 100 điểm và trừ 15 điểm cho mỗi điều kiện đúng. Hai điều kiện là ổ C: còn dưới 15 GB và RAM đang dùng trên 85%. |
| 🟢 [Tương thích phần cứng](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor)<br>An toàn | Đọc tên CPU qua CIM, dò tên Intel, Xeon hoặc Ryzen rồi ghi ghi chú tương ứng vào nhật ký. |
| 🟢 [Snapshot hệ thống](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>An toàn | Yêu cầu tạo và xác minh điểm khôi phục Windows, đồng thời xuất HKLM và HKCU vào C:\Meowize_Backup. Hai bước được thử độc lập.<br><br>Cần quyền quản trị. |

</details>

<details>
<summary>Cứu hộ & Báo cáo (8)</summary>

| Tác vụ | Meowize thực hiện |
| --- | --- |
| 🟢 [Tạo điểm khôi phục](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>An toàn | Bật System Protection trên ổ chứa Windows, yêu cầu điểm khôi phục Meowize kèm thời gian rồi kiểm tra có số thứ tự mới.<br><br>Cần quyền quản trị. |
| 🟢 [Sao lưu Registry](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>An toàn | Xuất HKLM và HKCU thành HKLM.reg và HKCU.reg trong thư mục snapshot Manual mới ở C:\Meowize_Backup.<br><br>Cần quyền quản trị. |
| 🔴 [Khôi phục Registry](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-import)<br>Cảnh báo | Hiện snapshot tương thích mới nhất và đường dẫn trước khi xác nhận. Sau đó kiểm tra phần đầu tệp Registry, sao lưu cấu hình hiện tại và nhập snapshot tương ứng.<br><br>Cần quyền quản trị.<br><br>Có thể cần khởi động lại Windows để áp dụng thay đổi.<br><br>Nhập lại cấu hình Registry của máy hoặc tài khoản từ bản sao lưu. |
| 🟡 [Sửa Windows](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>Cẩn trọng | Chạy DISM /Online /Cleanup-Image /RestoreHealth. Nếu DISM thành công, chạy tiếp sfc /scannow và ghi đầu ra của lệnh vào nhật ký.<br><br>Cần quyền quản trị. |
| 🟢 [Báo cáo HTML](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-html)<br>An toàn | Ghi thông tin CPU, GPU, RAM và Windows vào Meowize_System_Report.html trên Desktop rồi mở bằng trình duyệt mặc định. |
| 🟢 [Xuất nhật ký TXT](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file)<br>An toàn | Mở hộp thoại lưu và ghi nhật ký hiện tại kèm thời gian vào tệp .txt mã hóa UTF-8. |
| 🟢 [Sao chép nhật ký](https://learn.microsoft.com/en-us/dotnet/api/system.windows.clipboard.settext)<br>An toàn | Sao chép toàn bộ nhật ký hiện tại, gồm thời gian từng dòng, vào clipboard Windows. |
| 🟡 [Gói chẩn đoán ZIP](https://learn.microsoft.com/en-us/dotnet/api/system.io.compression.ziparchive)<br>Cẩn trọng | Cho chọn nơi lưu rồi chạy systeminfo và ipconfig /all. Kết quả cùng nhật ký hiện tại được ghi vào ZIP cục bộ. Xem thông tin máy và mạng trước khi chia sẻ tệp. |

</details>
