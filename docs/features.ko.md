# 기능 가이드

[Meowize](README.ko.md) · [English](features.en.md) · [日本語](features.ja.md) · **한국어** · [Tiếng Việt](features.vi.md) · [简体中文](features.zh-CN.md)

## 1-Click (51)

1-Click에서 이 항목을 선택한 뒤 검토 후 실행을 누르세요.

**완료 후 종료** · 조건이 충족되면 45초 종료 카운트다운을 시작합니다. 카운트다운 중 작업 로그의 **종료 취소**를 눌러 중단할 수 있습니다.

<details>
<summary>안전 및 시스템 (10)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🟢 [시스템 스냅샷](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>안전 | 새 Windows 복원 지점을 만들고 확인하며 HKLM과 HKCU를 C:\Meowize_Backup에 내보냅니다. 두 작업은 각각 시도합니다.<br><br>관리자 권한이 필요합니다. |
| 🟢 [레지스트리 분기 백업](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>안전 | 레지스트리의 HKLM\SYSTEM\CurrentControlSet\Control 및 HKCU\Software\Microsoft\Windows\CurrentVersion을 D: 드라이브가 있으면 D:\Meowize_Backup에, 그 외에는 C:\Meowize_Backup\BranchExports에 내보냅니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [백그라운드 프로세스 종료](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>주의 | OneDrive, Teams, Edge, Game Bar 등 정해진 목록의 실행 중인 프로세스를 강제 종료합니다. 먼저 작업을 저장하세요.<br><br>관리자 권한이 필요합니다. |
| 🟡 [빠른 시작 및 최대 절전](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>주의 | powercfg로 최대 절전 모드를 끄고 HiberbootEnabled를 0으로 설정합니다. 빠른 시작도 꺼집니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [실시간 보호](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>경고 | Windows 보안의 바이러스 및 위협 방지 설정을 엽니다. 해당 화면에서 실시간 보호 상태를 확인할 수 있습니다.<br><br>1-Click에서 이 항목을 선택하세요. 검토 화면에서 Windows 설정 열기를 누르면 관련 페이지로 이동합니다.<br><br>실시간 보호를 끄면 악성 코드 탐지 기능이 약해집니다. |
| 🔴 [Windows Update](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>경고 | 설정의 Windows 업데이트 페이지를 열어 업데이트와 다시 시작 옵션을 확인할 수 있게 합니다.<br><br>1-Click에서 이 항목을 선택하세요. 검토 화면에서 Windows 설정 열기를 누르면 관련 페이지로 이동합니다.<br><br>업데이트를 일시 중지하면 보안 패치가 늦어질 수 있습니다. |
| 🟡 [Defender 검사 우선순위](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>주의 | Defender 검사 시 평균 CPU 사용률 목표를 20%로 설정하고 낮은 CPU 우선순위로 검사하도록 요청합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [SysMain 서비스](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>주의 | SysMain을 중지하고 시작 유형을 사용 안 함으로 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [진단 및 원격 분석](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>주의 | DiagTrack, dmwappushservice, SysMain, MapsBroker를 중지하고 자동 시작을 해제합니다. AllowTelemetry를 0으로 설정하고 해당 고객 환경 및 앱 환경 예약 작업을 끕니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [기본 제공 앱 제거](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>경고 | Xbox 앱, 날씨, Clipchamp 등 지정된 AppX 앱을 모든 사용자에서 제거하고 새 프로필용 프로비저닝도 제거합니다. Game DVR 정책과 Game Bar 링크 처리도 변경합니다.<br><br>관리자 권한이 필요합니다.<br><br>Windows 앱을 제거하면 기능을 복원하기 위해 다시 설치해야 할 수 있습니다. |

</details>

<details>
<summary>게임 및 지연 시간 (20)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🟡 [마우스 및 키보드 버퍼](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>주의 | Windows 클래스 드라이버의 레지스트리에서 MouseDataQueueSize와 KeyboardDataQueueSize를 20으로 설정합니다. 현재 계정의 게임 모드를 켜고 HwSchMode = 2로 HAGS를 요청합니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다. |
| 🔴 [VBS 및 메모리 무결성](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>경고 | Windows 보안의 코어 격리를 엽니다. 해당 화면에서 메모리 무결성과 요구 사항을 확인할 수 있습니다.<br><br>1-Click에서 이 항목을 선택하세요. 검토 화면에서 Windows 설정 열기를 누르면 관련 페이지로 이동합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>메모리 무결성을 변경하면 Windows 격리 보호가 약해질 수 있습니다. |
| 🟡 [DirectX 플립 모델](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>주의 | DirectX, GameConfigStore 및 DWM의 SwapEffectUpgradeEnable과 Win32_AutoFlip을 설정해 지원되는 창 모드 게임에 Flip Model을 요청합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>주의 | Windows 게임 설정에서 Xbox Game Bar 페이지를 열어 오버레이 설정을 확인할 수 있게 합니다.<br><br>1-Click에서 이 항목을 선택하세요. 검토 화면에서 Windows 설정 열기를 누르면 관련 페이지로 이동합니다. |
| 🟡 [게임 CPU 우선순위](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>주의 | VALORANT, CS2, Overwatch 등 목록의 게임 실행 파일에 높은 CPU 우선순위를 설정합니다. Windows가 해당 게임을 시작할 때 설정을 읽습니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [HPET 타이머](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>경고 | 감지된 HPET 장치를 비활성화하고 BCD 부팅 타이머를 변경합니다. 플랫폼 클록 재정의를 지우고 플랫폼 틱을 켜며 동적 틱을 끕니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>하드웨어 타이머와 부팅 설정에 영향을 줍니다. |
| 🔴 [CPU 우선순위 및 BCD](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>경고 | Win32PrioritySeparation을 38(0x26)로 설정합니다. BCD에서 플랫폼 틱을 켜고 플랫폼 클록 재정의를 지우며 동적 틱을 끕니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>BCD 부팅 설정이 변경됩니다. 다시 시작한 후 확인하세요. |
| 🟡 [멀티플레인 오버레이](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>주의 | 시스템 MultiplaneOverlay 레지스트리에 EnableMPO = 0과 OverlayTestMode = 5를 기록합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [전체 화면 최적화](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>주의 | 전체 화면 및 Game DVR 설정을 기록하고 앱 캡처를 끕니다. 지정된 Game Bar 링크를 바꾸고 사용자별 Game DVR 캡처 서비스 중지를 시도합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [MSI 인터럽트 모드](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>경고 | 레지스트리에서 일치하는 PCI 장치에 MSISupported = 1을 설정합니다. 그래픽 카드와 네트워크 어댑터 외 PCI 장치도 대상이 될 수 있습니다. 장치와 드라이버 지원에 따라 달라집니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>일치하는 PCI 장치의 인터럽트 변경으로 불안정해질 수 있습니다. |
| 🟡 [하드웨어 GPU 스케줄링](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>주의 | HwSchMode = 2로 하드웨어 가속 GPU 스케줄링을 요청합니다. Windows에서 지원되는 그래픽 하드웨어와 호환 드라이버가 필요합니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다. |
| 🔴 [FPS Boost 프로필](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>경고 | 성능 전원 옵션을 만들거나 활성화하고 전원 연결 시 CPU, 코어 파킹, 냉각 및 절전 시간을 조정합니다. BCD 타이머, 전경 스케줄링, MPO, 멀티미디어 우선순위, Game DVR, 마우스 가속 및 커널 전원 설정도 변경합니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>BCD 부팅 설정을 포함해 여러 변경 사항을 한꺼번에 적용합니다. |
| 🟡 [CPU 코어 파킹 해제](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>주의 | 현재 전원 관리 옵션에서 전원 연결 시와 배터리 사용 시 모두 파킹되지 않는 코어의 최소 비율을 100%로 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [ULPS 및 PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>주의 | 그래픽 드라이버의 기존 ULPS 플래그를 0으로 설정하고 HFS를 끕니다. 현재 전원 옵션에서 PCIe 링크 상태 및 일부 CPU 전원 설정을 바꿉니다。<br><br>관리자 권한이 필요합니다. |
| 🟡 [마우스 가속](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>주의 | 현재 Windows 계정의 MouseSpeed, MouseThreshold1, MouseThreshold2를 0으로 설정해 포인터 가속을 끕니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [TSC 동기화](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>경고 | BCD 타임스탬프 카운터 동기화 정책을 Enhanced로 설정합니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>BCD 부팅 설정이 변경됩니다. 다시 시작한 후 확인하세요. |
| 🟡 [커널 페이징](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>주의 | Windows 레지스트리에 DisablePagingExecutive = 1과 PowerThrottlingOff = 1을 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [멀티미디어 스케줄러](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>주의 | 멀티미디어 프로필이 있으면 SystemResponsiveness = 0과 NetworkThrottlingIndex = 0xFFFFFFFF를 설정합니다. Games 작업에는 GPU 우선순위 8, 우선순위 6, High 스케줄링을 요청합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [GPU 복구 지연](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/timeout-detection-and-recovery)<br>주의 | Windows GPU 시간 초과 감지의 TdrDelay를 8초로 설정합니다. Microsoft는 이 값을 드라이버 테스트 및 디버깅 용도로 문서화합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [고정 키, 토글 키 및 필터 키](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>주의 | 현재 사용자의 고정 키, 필터 키, 토글 키 접근성 플래그를 변경해 바로 가기 동작을 조정합니다.<br><br>관리자 권한이 필요합니다. |

</details>

<details>
<summary>Talon Suite (10)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🟡 [진단 데이터](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>주의 | 진단 데이터와 활동 기록에 관한 Windows 정책을 기록하고 Windows Platform Binary Table에 DisableWpbtExecution = 1을 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [Copilot 및 Recall 정책](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-windowsai)<br>경고 | 사용자 및 시스템 정책에 TurnOffWindowsCopilot = 1과 DisableAIDataAnalysis = 1을 기록합니다.<br><br>관리자 권한이 필요합니다.<br><br>이 정책은 여러 Windows 계정의 Copilot 및 Recall 기능에 영향을 줄 수 있습니다. |
| 🟡 [프로모션 및 업데이트 배달](https://learn.microsoft.com/en-us/windows/deployment/do/waas-delivery-optimization)<br>주의 | DisableWindowsConsumerFeatures를 1로, 배달 최적화 다운로드 모드를 HTTP 전용인 0으로 지정합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [클래식 상황에 맞는 메뉴](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>주의 | 클래식 오른쪽 클릭 메뉴용 사용자별 Explorer 재정의를 추가합니다. Explorer를 다시 시작하거나 다시 로그인한 뒤 확인하세요.<br><br>관리자 권한이 필요합니다. |
| 🟡 [파일 탐색기 설정](https://support.microsoft.com/en-us/windows/file-explorer-in-windows-ef370130-1cca-9dc5-e0df-2f7416fe1cb1)<br>주의 | LaunchTo = 1로 파일 탐색기가 내 PC에서 열리도록 설정하고 탐색 트리에서 갤러리 고정을 해제하도록 요청합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [검색 및 위젯](https://learn.microsoft.com/en-us/windows/configuration/start/)<br>주의 | Bing 및 검색 상자 제안 설정을 기록하고 Windows 위젯 정책을 사용 안 함으로 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [예약된 작업](https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/disable-scheduledtask)<br>경고 | Compatibility Appraiser, 디스크 진단 데이터 수집기, WinSAT 등 지정된 예약 작업 8개를 비활성화하려고 시도합니다.<br><br>관리자 권한이 필요합니다.<br><br>예약 작업을 비활성화하면 관련 Windows 유지 관리에 영향을 줄 수 있습니다. |
| 🟡 [Windows 서비스](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>주의 | DiagTrack, dmwappushservice, SysMain, Windows Search(WSearch)를 중지하고 시작 유형을 사용 안 함으로 바꿉니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [Talon 앱 목록](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>경고 | 날씨, Mixed Reality Portal, Clipchamp 등 Talon의 고정 목록에 해당하는 설치된 AppX 패키지를 모든 사용자에서 제거합니다.<br><br>관리자 권한이 필요합니다.<br><br>Windows 앱을 제거하면 기능을 복원하기 위해 다시 설치해야 할 수 있습니다. |
| 🟡 [메뉴 지연 및 작업 끝내기](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>주의 | 메뉴 표시 지연을 0으로 설정하고 작업 표시줄의 작업 끝내기 및 파일 탐색기의 확장명 표시를 켭니다.<br><br>관리자 권한이 필요합니다. |

</details>

<details>
<summary>네트워크 및 정리 (11)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🟡 [대용량 전송 오프로드](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>주의 | IPv4·IPv6 LSO와 체크섬 오프로드를 끄려고 합니다. 드라이버에서 제공하는 Energy Efficient/Green Ethernet, Gigabit Lite, 절전 및 인터럽트 조절 속성도 변경합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [TCP/IP 조정](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>주의 | 레지스트리의 TCP/IP 인터페이스에 TCPNoDelay = 1, TcpAckFrequency = 1, TcpDelAckTicks = 0을 기록합니다. 효과는 연결과 앱의 통신 방식에 따라 다릅니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [네트워크 절전](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>주의 | Windows가 장치 전원을 끄지 않도록 어댑터 전원 관리를 변경합니다. 드라이버에서 제공하는 관련 절전 속성도 끕니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [Cloudflare DNS](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>주의 | Windows가 연결됨(Up)으로 표시하는 어댑터에 Cloudflare IPv4 DNS 1.1.1.1과 1.0.0.1을 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [네트워크 재설정](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>경고 | 로컬 DNS 캐시를 지우고 Winsock과 TCP/IP를 재설정합니다. Windows를 다시 시작해야 할 수 있습니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>네트워크 연결이 끊어지거나 구성이 바뀔 수 있습니다. |
| 🟡 [임시 파일 정리](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>주의 | 현재 사용자의 Temp, Windows Temp 및 Prefetch에서 삭제 가능한 항목을 지웁니다. 잠겼거나 보호된 항목은 건너뛰고 확보한 용량을 표시합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [Riot 클라이언트 캐시 정리](https://support-valorant.riotgames.com/)<br>경고 | 현재 계정의 Local AppData 아래 Riot Client의 Logs·Data와 VALORANT Saved의 Logs·Crashes를 정리합니다. Riot Client와 VALORANT를 먼저 종료하세요.<br><br>관리자 권한이 필요합니다.<br><br>캐시, 로그 및 일부 로컬 Riot Client 데이터를 삭제합니다. |
| 🟡 [셰이더 캐시 정리](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>주의 | Local AppData의 NVIDIA 및 AMD DX·GL 캐시와 Windows D3DSCache를 비웁니다. 게임을 실행할 때 셰이더 캐시가 다시 만들어질 수 있습니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [작업 집합 정리](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>주의 | EmptyWorkingSet으로 접근 가능한 프로세스의 작업 집합을 축소하도록 요청하고 작업 프로세스에서 가비지 컬렉션을 수행합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [WinGet으로 앱 6개 설치](https://github.com/microsoft/winget-cli)<br>주의 | Windows 앱 설치 관리자의 WinGet으로 Chrome, Discord, 7-Zip, UniKey, UltraViewer, Zalo를 순서대로 설치합니다. 패키지별 결과는 로그에서 확인할 수 있습니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [DISM 및 SFC로 Windows 복구](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>주의 | DISM /Online /Cleanup-Image /RestoreHealth를 실행합니다. 성공하면 sfc /scannow를 실행하고 명령 출력을 로그에 표시합니다.<br><br>관리자 권한이 필요합니다. |

</details>

## 개별 도구 (66)

해당 페이지를 열고 작업 행의 버튼을 사용하세요. 실행 전 ⓘ를 누르면 동작을 확인할 수 있습니다.

<details>
<summary>게임 및 FPS (20)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🟡 [마우스 및 키보드 버퍼](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>주의 | Windows 클래스 드라이버의 레지스트리에서 MouseDataQueueSize와 KeyboardDataQueueSize를 20으로 설정합니다. 현재 계정의 게임 모드를 켜고 HwSchMode = 2로 HAGS를 요청합니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다. |
| 🔴 [FPS Boost 프로필](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>경고 | 성능 전원 옵션을 만들거나 활성화하고 전원 연결 시 CPU, 코어 파킹, 냉각 및 절전 시간을 조정합니다. BCD 타이머, 전경 스케줄링, MPO, 멀티미디어 우선순위, Game DVR, 마우스 가속 및 커널 전원 설정도 변경합니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>BCD 부팅 설정을 포함해 여러 변경 사항을 한꺼번에 적용합니다. |
| 🟡 [커널 페이징](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>주의 | DisablePagingExecutive = 1, LargeSystemCache = 0, PowerThrottlingOff = 1을 설정합니다. 다시 시작한 뒤 결과를 비교하세요.<br><br>관리자 권한이 필요합니다. |
| 🔴 [TSC 동기화](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>경고 | BCD에서 TSC 동기화를 Enhanced로 설정하고 플랫폼 틱을 켭니다. 플랫폼 클록 재정의를 지우고 동적 틱을 끕니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>BCD 부팅 설정이 변경됩니다. 다시 시작한 후 확인하세요. |
| 🟡 [고정 키, 토글 키 및 필터 키](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>주의 | 현재 사용자의 고정 키, 필터 키, 토글 키 접근성 플래그를 변경해 바로 가기 동작을 조정합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [HPET 타이머](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>경고 | 감지된 HPET 장치를 비활성화하고 BCD 부팅 타이머를 변경합니다. 플랫폼 클록 재정의를 지우고 플랫폼 틱을 켜며 동적 틱을 끕니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>하드웨어 타이머와 부팅 설정에 영향을 줍니다. |
| 🟡 [CPU 코어 파킹 해제](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>주의 | 현재 전원 관리 옵션에서 전원 연결 시와 배터리 사용 시 모두 파킹되지 않는 코어의 최소 비율을 100%로 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [게임 CPU 우선순위](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>주의 | VALORANT, CS2, Overwatch 등 목록의 게임 실행 파일에 높은 CPU 우선순위를 설정합니다. Windows가 해당 게임을 시작할 때 설정을 읽습니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [멀티플레인 오버레이](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>주의 | DWM의 OverlayTestMode 값을 전환합니다. 현재 값이 5이면 0, 그 외에는 5로 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [MSI 인터럽트 모드](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>경고 | 레지스트리에서 일치하는 PCI 장치에 MSISupported = 1을 설정합니다. 그래픽 카드와 네트워크 어댑터 외 PCI 장치도 대상이 될 수 있습니다. 장치와 드라이버 지원에 따라 달라집니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>일치하는 PCI 장치의 인터럽트 변경으로 불안정해질 수 있습니다. |
| 🟡 [하드웨어 GPU 스케줄링](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>주의 | HwSchMode = 2로 하드웨어 가속 GPU 스케줄링을 요청합니다. Windows에서 지원되는 그래픽 하드웨어와 호환 드라이버가 필요합니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다. |
| 🟡 [셰이더 캐시 정리](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>주의 | Local AppData의 NVIDIA 및 AMD DX·GL 캐시와 Windows D3DSCache를 비웁니다. 게임을 실행할 때 셰이더 캐시가 다시 만들어질 수 있습니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [전체 화면 최적화](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>주의 | 전체 화면 및 Game DVR 설정을 기록하고 앱 캡처를 끕니다. 지정된 Game Bar 링크를 바꾸고 사용자별 Game DVR 캡처 서비스 중지를 시도합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [멀티미디어 스케줄러](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>주의 | 멀티미디어 프로필이 있으면 SystemResponsiveness = 0과 NetworkThrottlingIndex = 0xFFFFFFFF를 설정합니다. Games 작업에는 GPU 우선순위 8, 우선순위 6, High 스케줄링을 요청합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [마우스 가속](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>주의 | 현재 Windows 계정의 MouseSpeed, MouseThreshold1, MouseThreshold2를 0으로 설정해 포인터 가속을 끕니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [Riot 클라이언트 캐시 정리](https://support-valorant.riotgames.com/)<br>경고 | 현재 계정의 Local AppData 아래 Riot Client의 Logs·Data와 VALORANT Saved의 Logs·Crashes를 정리합니다. Riot Client와 VALORANT를 먼저 종료하세요.<br><br>관리자 권한이 필요합니다.<br><br>캐시, 로그 및 일부 로컬 Riot Client 데이터를 삭제합니다. |
| 🟡 [백그라운드 프로세스 종료](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>주의 | OneDrive, Teams, Edge, Game Bar 등 정해진 목록의 실행 중인 프로세스를 강제 종료합니다. 먼저 작업을 저장하세요.<br><br>관리자 권한이 필요합니다. |
| 🔴 [VBS 및 메모리 무결성](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>경고 | Windows 보안의 코어 격리를 엽니다. 해당 화면에서 메모리 무결성과 요구 사항을 확인할 수 있습니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>메모리 무결성을 변경하면 Windows 격리 보호가 약해질 수 있습니다. |
| 🟡 [DirectX 플립 모델](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>주의 | DirectX, GameConfigStore 및 DWM의 SwapEffectUpgradeEnable과 Win32_AutoFlip을 설정해 지원되는 창 모드 게임에 Flip Model을 요청합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>주의 | Windows 게임 설정에서 Xbox Game Bar 페이지를 열어 오버레이 설정을 확인할 수 있게 합니다. |

</details>

<details>
<summary>시스템 및 Talon (16)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🔴 [Talon Suite](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>경고 | 진단 및 활동 정책, Copilot·Recall, 배달 및 제안, Explorer, 접근성, 시작 및 위젯, 예약 작업, 백그라운드 앱, 커널 및 GPU 시간 초과를 9단계로 조정합니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>앱, 서비스 및 시스템 작업을 한꺼번에 변경합니다. |
| 🟡 [클래식 상황에 맞는 메뉴](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>주의 | 클래식 오른쪽 클릭 메뉴용 사용자별 Explorer 재정의를 추가합니다. Explorer를 다시 시작하거나 다시 로그인한 뒤 확인하세요.<br><br>관리자 권한이 필요합니다. |
| 🟡 [ULPS 및 PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>주의 | 그래픽 드라이버의 기존 ULPS 플래그를 0으로 설정하고 HFS를 끕니다. 현재 전원 옵션에서 PCIe 링크 상태 및 일부 CPU 전원 설정을 바꿉니다。<br><br>관리자 권한이 필요합니다. |
| 🟡 [Defender 다시 켜기](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>주의 | Microsoft Defender PowerShell로 실시간 보호를 켜고 RealTimeProtectionEnabled가 true인지 확인합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [실시간 보호](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>경고 | Windows 보안의 바이러스 및 위협 방지 설정을 엽니다. 해당 화면에서 실시간 보호 상태를 확인할 수 있습니다.<br><br>실시간 보호를 끄면 악성 코드 탐지 기능이 약해집니다. |
| 🟡 [Defender 검사 우선순위](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>주의 | Defender 검사 시 평균 CPU 사용률 목표를 20%로 설정하고 낮은 CPU 우선순위로 검사하도록 요청합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [SysMain 서비스](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>주의 | SysMain을 중지하고 시작 유형을 사용 안 함으로 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [빠른 시작 및 최대 절전](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>주의 | powercfg로 최대 절전 모드를 끄고 HiberbootEnabled를 0으로 설정합니다. 빠른 시작도 꺼집니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [진단 및 원격 분석](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>주의 | DiagTrack, SysMain, Windows Search, MapsBroker, 배달 최적화(DoSvc) 등 설치된 서비스 최대 8개를 중지하고 사용하지 않도록 설정합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [기본 제공 앱 제거](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>경고 | 휴대폰과 연결, 날씨, Clipchamp, Windows 지도 등 정해진 목록과 일치하는 AppX 패키지를 모든 사용자에서 제거합니다.<br><br>관리자 권한이 필요합니다.<br><br>Windows 앱을 제거하면 기능을 복원하기 위해 다시 설치해야 할 수 있습니다. |
| 🟡 [작업 집합 정리](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>주의 | EmptyWorkingSet으로 접근 가능한 프로세스의 작업 집합을 줄이고 전후의 사용 가능한 RAM을 기록합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [임시 파일 정리](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>주의 | 현재 사용자의 Temp, Windows Temp 및 Prefetch에서 삭제 가능한 항목을 지웁니다. 잠겼거나 보호된 항목은 건너뛰고 확보한 용량을 표시합니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [고급 디스크 정리](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>경고 | 기본 Temp와 Prefetch 외에도 Windows 업데이트 다운로드, Explorer 캐시, Windows 로그, 충돌 덤프 및 오류 보고 파일을 정리합니다. 잠기거나 보호된 항목은 건너뜁니다.<br><br>관리자 권한이 필요합니다.<br><br>업데이트 캐시, 시스템 로그 및 진단 파일을 삭제합니다. |
| 🟡 [최대 절전 전환](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>주의 | C:\hiberfil.sys 파일이 있는지 확인합니다. 있으면 최대 절전 모드를 끄고, 없으면 켭니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [시작 앱](https://learn.microsoft.com/en-us/windows/win32/setupapi/run-and-runonce-registry-keys)<br>주의 | 현재 사용자와 컴퓨터의 레지스트리 Run 항목을 표시합니다. 제거할 항목을 선택 해제하고 검토 후 확인하세요. 제거 전에 값을 JSON으로 백업하며 컴퓨터 항목에는 관리자 권한이 필요합니다. |
| 🔴 [Windows Update](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>경고 | 설정의 Windows 업데이트 페이지를 열어 업데이트와 다시 시작 옵션을 확인할 수 있게 합니다.<br><br>업데이트를 일시 중지하면 보안 패치가 늦어질 수 있습니다. |

</details>

<details>
<summary>네트워크 및 드라이버 (8)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🟡 [네트워크 절전](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>주의 | Windows가 장치 전원을 끄지 않도록 어댑터 전원 관리를 변경합니다. 드라이버에서 제공하는 관련 절전 속성도 끕니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [TCP/IP 조정](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>주의 | 레지스트리의 TCP/IP 인터페이스에 TCPNoDelay = 1, TcpAckFrequency = 1, TcpDelAckTicks = 0을 기록합니다. 효과는 연결과 앱의 통신 방식에 따라 다릅니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [대용량 전송 오프로드](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>주의 | IPv4·IPv6 LSO와 체크섬 오프로드를 끄려고 합니다. 드라이버에서 제공하는 Energy Efficient/Green Ethernet, Gigabit Lite, 절전 및 인터럽트 조절 속성도 변경합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [DNS 주소](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>주의 | 선택한 공급자의 IPv4 DNS 주소 두 개를 모든 활성 어댑터에 적용합니다. 설정값을 다시 읽어 확인한 뒤 로컬 DNS 캐시를 비웁니다.<br><br>DNS 공급자를 선택하고 적용을 누른 뒤 주소를 확인하세요.<br><br>관리자 권한이 필요합니다. |
| 🟢 [DNS 캐시 비우기](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig)<br>안전 | ipconfig /flushdns를 실행해 Windows의 로컬 DNS 확인자 캐시를 비웁니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [네트워크 재설정](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>경고 | Winsock과 TCP/IP를 재설정하고 IP 임대를 해제·갱신한 뒤 DNS 캐시를 비웁니다. 연결이 끊길 수 있습니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>네트워크 연결이 끊어지거나 구성이 바뀔 수 있습니다. |
| 🔴 [Display Driver Uninstaller](https://www.wagnardsoft.com/)<br>경고 | Wagnardsoft에서 Display Driver Uninstaller 18.0.8.6을 다운로드하고 게시자 서명 확인 후 엽니다. 드라이버 제거는 DDU에서 별도로 진행합니다.<br><br>DDU는 디스플레이 드라이버를 제거합니다. 다시 시작해야 할 수 있습니다. |
| 🔴 [UEFI로 다시 시작](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/shutdown)<br>경고 | 확인 후 즉시 UEFI 펌웨어로 재시작하도록 요청합니다. 실행 전에 작업을 저장하세요.<br><br>관리자 권한이 필요합니다.<br><br>즉시 UEFI로 다시 시작합니다. 먼저 작업을 저장하세요. |

</details>

<details>
<summary>앱 및 도구 (7)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🔴 [NVIDIA 581.80 WHQL](https://www.nvidia.com/en-us/drivers/details/257497/)<br>경고 | 이 행에 표시된 NVIDIA 데스크톱 드라이버 버전을 다운로드합니다. NVIDIA 서명이 유효하면 무인 설치를 실행하고 종료 코드를 기다립니다. 먼저 지원 GPU 목록을 확인하세요.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>화면이 깜박일 수 있습니다. Windows를 다시 시작해야 할 수 있습니다. |
| 🔴 [NVIDIA 566.36 WHQL](https://www.nvidia.com/en-us/drivers/details/237719/)<br>경고 | 이 행에 표시된 NVIDIA 데스크톱 드라이버 버전을 다운로드합니다. NVIDIA 서명이 유효하면 무인 설치를 실행하고 종료 코드를 기다립니다. 먼저 지원 GPU 목록을 확인하세요.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>화면이 깜박일 수 있습니다. Windows를 다시 시작해야 할 수 있습니다. |
| 🟡 [CPU-Z 및 HWMonitor](https://www.cpuid.com/)<br>주의 | CPUID에서 CPU-Z 2.11과 HWMonitor 1.55를 받아 바탕 화면의 Meowize_Tools에 압축을 풉니다. CPUID 서명을 확인한 x64 실행 파일을 엽니다. |
| 🟡 [Unpark CPU App](https://coderbag.com/product/quickcpu)<br>주의 | CoderBag의 Unpark CPU App을 다운로드해 바탕 화면의 Meowize_Tools에 압축을 풀고 서명을 검증한 실행 파일을 엽니다. 코어 파킹 설정은 해당 도구에서 선택합니다. |
| 🟡 [Visual C++ x64](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)<br>주의 | Microsoft에서 Visual C++ x64 재배포 가능 패키지를 내려받아 게시자 서명을 확인합니다. 자동 재시작 없이 수동 개입을 최소화한 모드로 설치합니다.<br><br>관리자 권한이 필요합니다. |
| 🟡 [WinGet으로 앱 3개 설치](https://github.com/microsoft/winget-cli)<br>주의 | Windows 앱 설치 관리자의 WinGet으로 Google Chrome, Discord, 7-Zip을 순서대로 설치합니다. 진행 상황과 패키지 오류는 작업 로그에서 확인하세요.<br><br>관리자 권한이 필요합니다. |
| 🟢 [Office 배포 설정](https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/overview-office-deployment-tool)<br>안전 | 기본 브라우저에서 Microsoft Office 사용자 지정 도구를 엽니다. 사이트에서 배포 설정을 선택합니다. |

</details>

<details>
<summary>진단 (7)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🟢 [하드웨어 정보](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/operating-system-classes)<br>안전 | Windows CIM으로 CPU 이름과 코어·스레드 수, GPU 이름, 총 메모리, C: 드라이브의 용량과 여유 공간을 읽어 로그에 표시합니다. |
| 🟢 [물리 디스크 상태](https://learn.microsoft.com/en-us/powershell/module/storage/get-physicaldisk)<br>안전 | Get-PhysicalDisk가 보고하는 물리 디스크의 이름, 미디어 유형, 용량 및 HealthStatus를 표시합니다. |
| 🟢 [ACPI 온도](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/thermal-management-in-windows)<br>안전 | PC가 WMI를 통해 제공하는 ACPI 열 영역을 읽어 섭씨로 변환합니다. 사용 가능한 센서는 펌웨어에 따라 다릅니다. |
| 🟢 [Windows 정품 인증](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/sppwmi/softwarelicensingproduct)<br>안전 | SoftwareLicensingProduct에서 Windows 정품 인증 정보를 읽습니다. Windows 에디션과 인증 상태, 가능한 경우 제품 키 끝 다섯 자리를 기록합니다. |
| 🟢 [디스크 및 메모리 검사](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/systeminfo)<br>안전 | 100점에서 시작해 조건당 15점을 뺍니다. C: 여유 공간이 15GB 미만인지, RAM 사용량이 85%를 초과하는지 확인합니다. |
| 🟢 [하드웨어 호환성](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor)<br>안전 | CIM으로 CPU 모델명을 읽고 이름 일치 여부에 따라 Intel, Xeon, Ryzen 관련 참고 사항을 표시합니다. |
| 🟢 [시스템 스냅샷](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>안전 | 새 Windows 복원 지점을 만들고 확인하며 HKLM과 HKCU를 C:\Meowize_Backup에 내보냅니다. 두 작업은 각각 시도합니다.<br><br>관리자 권한이 필요합니다. |

</details>

<details>
<summary>복구 및 보고서 (8)</summary>

| 작업 | Meowize의 동작 |
| --- | --- |
| 🟢 [복원 지점 만들기](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>안전 | Windows 드라이브의 시스템 보호를 켜고 시각을 포함한 Meowize 복원 지점을 요청합니다. 새 시퀀스 번호가 생성됐는지 확인합니다.<br><br>관리자 권한이 필요합니다. |
| 🟢 [레지스트리 백업](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>안전 | C:\Meowize_Backup 아래 새 Manual 스냅샷에 HKLM과 HKCU를 HKLM.reg 및 HKCU.reg로 내보냅니다.<br><br>관리자 권한이 필요합니다. |
| 🔴 [레지스트리 복원](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-import)<br>경고 | 확인 전에 가장 최근 호환 스냅샷과 경로를 표시합니다. 레지스트리 파일 헤더를 확인하고 현재 레지스트리를 백업한 뒤 가져옵니다.<br><br>관리자 권한이 필요합니다.<br><br>이 변경을 적용하려면 Windows를 다시 시작해야 할 수 있습니다.<br><br>백업에서 컴퓨터 또는 계정의 레지스트리 설정을 가져옵니다. |
| 🟡 [DISM 및 SFC로 Windows 복구](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>주의 | DISM /Online /Cleanup-Image /RestoreHealth를 실행합니다. 성공하면 sfc /scannow를 실행하고 명령 출력을 로그에 표시합니다.<br><br>관리자 권한이 필요합니다. |
| 🟢 [HTML 시스템 보고서](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-html)<br>안전 | CPU, GPU, RAM 및 Windows 정보를 바탕 화면의 Meowize_System_Report.html로 저장한 뒤 기본 브라우저에서 엽니다. |
| 🟢 [활동 로그 내보내기](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file)<br>안전 | 저장 대화 상자를 열고 시간 정보가 포함된 현재 작업 로그를 UTF-8 .txt 파일에 저장합니다. |
| 🟢 [로그 복사](https://learn.microsoft.com/en-us/dotnet/api/system.windows.clipboard.settext)<br>안전 | 시간 정보가 포함된 현재 작업 로그를 Windows 클립보드에 복사합니다. |
| 🟡 [진단 ZIP](https://learn.microsoft.com/en-us/dotnet/api/system.io.compression.ziparchive)<br>주의 | 저장 경로를 지정한 뒤 systeminfo와 ipconfig /all의 출력 및 현재 Meowize 로그를 로컬 ZIP에 담습니다. 공유 전에 장치·네트워크 정보를 확인하세요. |

</details>
