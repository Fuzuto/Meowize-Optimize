# 機能ガイド

[Meowize](README.ja.md) · [English](features.en.md) · **日本語** · [한국어](features.ko.md) · [Tiếng Việt](features.vi.md) · [简体中文](features.zh-CN.md)

## 1-Click (51)

1-Click でこの項目を選び、「確認して実行」を選択します。

**完了後にシャットダウン** · 条件を満たすと、45 秒のシャットダウンカウントダウンが始まります。 カウントダウン中はログの「**シャットダウンを取り消す**」で中止できます。

<details>
<summary>保護とシステム (10)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🟢 [システムスナップショット](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>安全 | 新しい Windows 復元ポイントを作成して確認し、HKLM と HKCU を C:\Meowize_Backup に書き出します。二つの処理は個別に試行します。<br><br>管理者権限が必要です。 |
| 🟢 [レジストリ分岐のバックアップ](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>安全 | 二つのレジストリ分岐 HKLM\SYSTEM\CurrentControlSet\Control と HKCU\Software\Microsoft\Windows\CurrentVersion を、D: があれば D:\Meowize_Backup に、なければ C:\Meowize_Backup\BranchExports に書き出します。<br><br>管理者権限が必要です。 |
| 🟡 [バックグラウンドプロセスを終了](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>注意 | OneDrive、Teams、Edge、Game Bar など、定義済みリストの実行中プロセスを強制終了します。先に作業を保存してください。<br><br>管理者権限が必要です。 |
| 🟡 [高速スタートアップと休止状態](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | powercfg で休止状態を無効にし、HiberbootEnabled を 0 に設定します。高速スタートアップも無効になります。<br><br>管理者権限が必要です。 |
| 🔴 [リアルタイム保護](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>警告 | Windows セキュリティの「ウイルスと脅威の防止」の設定を開きます。リアルタイム保護はその画面で確認します。<br><br>1-Click でこの項目を選び、確認画面の「Windows の設定を開く」から該当ページを表示します。<br><br>リアルタイム保護を無効にすると、マルウェアの検出能力が低下します。 |
| 🔴 [Windows Update](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>警告 | 設定の Windows Update を開きます。更新や再起動に関する選択肢をその画面で確認できます。<br><br>1-Click でこの項目を選び、確認画面の「Windows の設定を開く」から該当ページを表示します。<br><br>更新を一時停止すると、セキュリティ修正の適用が遅れる場合があります。 |
| 🟡 [Defender のスキャン優先度](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>注意 | Defender のスキャン時の平均 CPU 使用率目標を 20% に設定し、低い CPU 優先度でのスキャンを有効にします。<br><br>管理者権限が必要です。 |
| 🟡 [SysMain サービス](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>注意 | SysMain を停止し、スタートアップの種類を「無効」に設定します。<br><br>管理者権限が必要です。 |
| 🟡 [診断とテレメトリ](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>注意 | DiagTrack、dmwappushservice、SysMain、MapsBroker を停止して無効にします。AllowTelemetry を 0 に設定し、該当するカスタマー エクスペリエンスおよびアプリケーション エクスペリエンスのタスクを無効にします。<br><br>管理者権限が必要です。 |
| 🔴 [組み込みアプリを削除](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>警告 | Xbox アプリ、天気、Clipchamp などを全ユーザーから削除し、新規プロファイル用のプロビジョニングも解除します。Game DVR のポリシーと Game Bar のプロトコル ハンドラーも変更します。<br><br>管理者権限が必要です。<br><br>Windows アプリを削除すると、機能の復元に再インストールが必要な場合があります。 |

</details>

<details>
<summary>ゲームと遅延 (20)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🟡 [マウスとキーボードのバッファー](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>注意 | Windows のクラス ドライバー設定で MouseDataQueueSize と KeyboardDataQueueSize を 20 にします。このユーザーのゲーム モードを有効にし、HwSchMode = 2 で HAGS を要求します。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。 |
| 🔴 [VBS とメモリ整合性](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>警告 | Windows セキュリティの「コア分離」を開きます。メモリ整合性と利用条件はその画面で確認できます。<br><br>1-Click でこの項目を選び、確認画面の「Windows の設定を開く」から該当ページを表示します。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>メモリ整合性を変更すると、Windows の分離による保護が弱まることがあります。 |
| 🟡 [DirectX フリップモデル](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>注意 | DirectX、GameConfigStore、DWM の SwapEffectUpgradeEnable と Win32_AutoFlip を設定し、対象のウィンドウ表示ゲームで Flip Model の使用を要求します。<br><br>管理者権限が必要です。 |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>注意 | Windows のゲーム設定にある Xbox Game Bar を開きます。オーバーレイの設定はその画面で確認できます。<br><br>1-Click でこの項目を選び、確認画面の「Windows の設定を開く」から該当ページを表示します。 |
| 🟡 [ゲームの CPU 優先度](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>注意 | VALORANT、CS2、Overwatch など、リストにあるゲームの実行ファイルに高い CPU 優先度を設定します。該当ゲームの起動時に参照されます。<br><br>管理者権限が必要です。 |
| 🔴 [HPET タイマー](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | 検出した HPET デバイスの無効化を試み、BCD の起動タイマーを変更します。プラットフォーム クロックの上書きを解除し、プラットフォーム ティックを有効、動的ティックを無効にします。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>ハードウェアタイマーと起動設定に影響します。 |
| 🔴 [CPU 優先度と BCD](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | Win32PrioritySeparation を 38（0x26）に変更します。BCD ではプラットフォーム ティックを有効にし、クロックの上書きを解除して動的ティックを無効にします。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>BCD の起動設定を変更します。再起動後に確認してください。 |
| 🟡 [マルチプレーンオーバーレイ](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>注意 | コンピューター側の MultiplaneOverlay レジストリに EnableMPO = 0 と OverlayTestMode = 5 を書き込みます。<br><br>管理者権限が必要です。 |
| 🟡 [全画面表示の最適化](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>注意 | 全画面表示と Game DVR の設定を書き込み、アプリの録画を無効にします。指定の Game Bar リンク先を変更し、ユーザーごとの録画サービスの停止を試みます。<br><br>管理者権限が必要です。 |
| 🔴 [MSI 割り込みモード](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>警告 | レジストリ内の該当する PCI デバイスに MSISupported = 1 を設定します。GPU やネットワークアダプター以外の PCI デバイスにも及ぶ場合があります。対応はドライバーと機器に依存します。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>該当する PCI デバイスの割り込みを変更すると不安定になることがあります。 |
| 🟡 [ハードウェア GPU スケジューリング](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>注意 | HwSchMode = 2 を設定してハードウェア アクセラレータによる GPU スケジューリングを要求します。対応する GPU とドライバーが必要です。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。 |
| 🔴 [FPS Boost プロファイル](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>警告 | パフォーマンス用電源プランを作成または有効化し、AC 電源時の CPU、コア パーキング、冷却、スリープの設定を変更します。BCD タイマー、前景優先度、MPO、マルチメディア、Game DVR、マウス加速、カーネル電源設定も変更します。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>BCD の起動設定を含む複数の変更を一括適用します。 |
| 🟡 [CPU コアパーキングを解除](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>注意 | 現在の電源プランで、AC 電源時とバッテリー時の両方においてパーキングされないコアの最小割合を 100% に設定します。<br><br>管理者権限が必要です。 |
| 🟡 [ULPS と PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | 既存のグラフィックス ドライバーの ULPS フラグを 0 にし、HFS を無効にします。現在の電源プランで PCIe リンク状態と一部の CPU 電源設定も変更します。<br><br>管理者権限が必要です。 |
| 🟡 [マウス加速](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>注意 | 現在の Windows ユーザーの MouseSpeed、MouseThreshold1、MouseThreshold2 を 0 にし、ポインターの加速を無効にします。<br><br>管理者権限が必要です。 |
| 🔴 [TSC 同期](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | BCD のタイムスタンプ カウンター同期ポリシーを Enhanced に設定します。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>BCD の起動設定を変更します。再起動後に確認してください。 |
| 🟡 [カーネルページング](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>注意 | Windows レジストリで DisablePagingExecutive = 1 と PowerThrottlingOff = 1 を設定します。<br><br>管理者権限が必要です。 |
| 🟡 [マルチメディアスケジューラー](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>注意 | マルチメディア プロファイルがある場合は SystemResponsiveness = 0 と NetworkThrottlingIndex = 0xFFFFFFFF を設定します。Games タスクでは GPU 優先度 8、優先度 6、スケジューリング High を要求します。<br><br>管理者権限が必要です。 |
| 🟡 [GPU 回復の待機時間](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/timeout-detection-and-recovery)<br>注意 | Windows の GPU タイムアウト検出の TdrDelay を 8 秒に設定します。Microsoft はこの値をドライバーのテストとデバッグ用として案内しています。<br><br>管理者権限が必要です。 |
| 🟡 [固定キー、切り替えキー、フィルターキー](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>注意 | ユーザーごとの Sticky Keys、Filter Keys、Toggle Keys のアクセシビリティ フラグを変更し、ショートカットの動作を調整します。<br><br>管理者権限が必要です。 |

</details>

<details>
<summary>Talon Suite (10)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🟡 [診断データ](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>注意 | 診断データとアクティビティ履歴の Windows ポリシーを設定し、Windows Platform Binary Table に対する DisableWpbtExecution を 1 にします。<br><br>管理者権限が必要です。 |
| 🔴 [Copilot と Recall のポリシー](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-windowsai)<br>警告 | ユーザーとコンピューターのポリシーに TurnOffWindowsCopilot = 1 と DisableAIDataAnalysis = 1 を設定します。<br><br>管理者権限が必要です。<br><br>これらのポリシーは、Windows の複数のアカウントで Copilot と Recall に影響することがあります。 |
| 🟡 [おすすめと更新プログラムの配信](https://learn.microsoft.com/en-us/windows/deployment/do/waas-delivery-optimization)<br>注意 | DisableWindowsConsumerFeatures を 1 にし、配信の最適化のダウンロード モードを HTTP のみの 0 に設定します。<br><br>管理者権限が必要です。 |
| 🟡 [従来のコンテキストメニュー](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>注意 | クラシック コンテキスト メニュー用のユーザー別 Explorer 上書きを追加します。Explorer を再起動するか、サインインし直して確認してください。<br><br>管理者権限が必要です。 |
| 🟡 [エクスプローラーの設定](https://support.microsoft.com/en-us/windows/file-explorer-in-windows-ef370130-1cca-9dc5-e0df-2f7416fe1cb1)<br>注意 | LaunchTo = 1 でエクスプローラーを「PC」で開くように設定し、ナビゲーション ツリーからギャラリーを外す設定を書き込みます。<br><br>管理者権限が必要です。 |
| 🟡 [検索とウィジェット](https://learn.microsoft.com/en-us/windows/configuration/start/)<br>注意 | Bing と検索ボックスの候補に関する設定を書き込み、Windows ウィジェットのポリシーを無効にします。<br><br>管理者権限が必要です。 |
| 🔴 [スケジュールされたタスク](https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/disable-scheduledtask)<br>警告 | Compatibility Appraiser、Disk Diagnostic Data Collector、WinSAT など、指定された 8 個のスケジュール タスクの無効化を試みます。<br><br>管理者権限が必要です。<br><br>スケジュールタスクを無効にすると、関連する Windows のメンテナンスに影響します。 |
| 🟡 [Windows サービス](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>注意 | DiagTrack、dmwappushservice、SysMain、Windows Search（WSearch）を停止し、自動起動を無効にします。<br><br>管理者権限が必要です。 |
| 🔴 [Talon のアプリ一覧](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>警告 | 天気、Mixed Reality Portal、Clipchamp など、Talon の固定リストと一致する AppX パッケージを全ユーザーから削除します。<br><br>管理者権限が必要です。<br><br>Windows アプリを削除すると、機能の復元に再インストールが必要な場合があります。 |
| 🟡 [メニューの遅延とタスクの終了](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>注意 | メニュー表示の遅延を 0 にし、タスクバーの「タスクの終了」とエクスプローラーの拡張子表示を有効にします。<br><br>管理者権限が必要です。 |

</details>

<details>
<summary>ネットワークとクリーンアップ (11)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🟡 [Large Send Offload](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>注意 | IPv4 と IPv6 の LSO およびチェックサム オフロードの無効化を試みます。利用できる場合は、省電力 Ethernet、Gigabit Lite、省電力モード、割り込み調整なども変更します。<br><br>管理者権限が必要です。 |
| 🟡 [TCP/IP の調整](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>注意 | レジストリにある TCP/IP インターフェイスごとに TCPNoDelay = 1、TcpAckFrequency = 1、TcpDelAckTicks = 0 を設定します。影響は接続とアプリの通信方式に依存します。<br><br>管理者権限が必要です。 |
| 🟡 [ネットワークの省電力](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>注意 | Windows がデバイスの電源を切らないようにアダプターの電源管理を変更します。ドライバーが提供する対応の省電力プロパティも無効にします。<br><br>管理者権限が必要です。 |
| 🟡 [Cloudflare DNS](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>注意 | Windows が Up と報告するアダプターに Cloudflare の IPv4 DNS 1.1.1.1 と 1.0.0.1 を設定します。<br><br>管理者権限が必要です。 |
| 🔴 [ネットワークをリセット](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>警告 | ローカルの DNS キャッシュを消去し、Winsock と TCP/IP をリセットします。Windows の再起動が必要な場合があります。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>ネットワークが切断されたり、設定が変更されたりする場合があります。 |
| 🟡 [一時ファイルを削除](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>注意 | ユーザーの Temp、Windows Temp、Windows Prefetch の削除可能な項目を消去します。ロック中や保護された項目はスキップし、解放容量を報告します。<br><br>管理者権限が必要です。 |
| 🔴 [Riot クライアントのキャッシュを削除](https://support-valorant.riotgames.com/)<br>警告 | 現在のユーザーの Local AppData にある Riot Client の Logs と Data、VALORANT の Saved 内の Logs と Crashes を対象にします。先に Riot Client と VALORANT を終了してください。<br><br>管理者権限が必要です。<br><br>キャッシュ、ログ、一部の Riot Client ローカルデータを削除します。 |
| 🟡 [シェーダーキャッシュを削除](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>注意 | Local AppData にある NVIDIA と AMD の DX・GL キャッシュ、および Windows の D3DSCache を消去します。ゲーム起動時にキャッシュが再作成される場合があります。<br><br>管理者権限が必要です。 |
| 🟡 [ワーキングセットを整理](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>注意 | EmptyWorkingSet でアクセス可能なプロセスのワーキング セット縮小を要求し、処理用プロセスでガベージ コレクションを行います。<br><br>管理者権限が必要です。 |
| 🟡 [WinGet で 6 本のアプリを導入](https://github.com/microsoft/winget-cli)<br>注意 | Windows のアプリ インストーラーに含まれる WinGet で Chrome、Discord、7-Zip、UniKey、UltraViewer、Zalo を順番に導入します。結果はパッケージごとに記録されます。<br><br>管理者権限が必要です。 |
| 🟡 [DISM と SFC で Windows を修復](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>注意 | DISM /Online /Cleanup-Image /RestoreHealth を実行し、成功した場合に sfc /scannow を実行します。コマンドの出力はログに記録されます。<br><br>管理者権限が必要です。 |

</details>

## 個別ツール (66)

対象のページを開き、項目のボタンを選択します。実行前に ⓘ で詳細を確認できます。

<details>
<summary>ゲームと FPS (20)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🟡 [マウスとキーボードのバッファー](https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-hid-client-drivers)<br>注意 | Windows のクラス ドライバー設定で MouseDataQueueSize と KeyboardDataQueueSize を 20 にします。このユーザーのゲーム モードを有効にし、HwSchMode = 2 で HAGS を要求します。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。 |
| 🔴 [FPS Boost プロファイル](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>警告 | パフォーマンス用電源プランを作成または有効化し、AC 電源時の CPU、コア パーキング、冷却、スリープの設定を変更します。BCD タイマー、前景優先度、MPO、マルチメディア、Game DVR、マウス加速、カーネル電源設定も変更します。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>BCD の起動設定を含む複数の変更を一括適用します。 |
| 🟡 [カーネルページング](https://learn.microsoft.com/en-us/windows/win32/memory/memory-management)<br>注意 | DisablePagingExecutive = 1、LargeSystemCache = 0、PowerThrottlingOff = 1 を設定します。結果の比較は再起動後に行ってください。<br><br>管理者権限が必要です。 |
| 🔴 [TSC 同期](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | BCD で TSC 同期を Enhanced に設定し、プラットフォーム ティックを有効にします。クロックの上書きを解除し、動的ティックを無効にします。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>BCD の起動設定を変更します。再起動後に確認してください。 |
| 🟡 [固定キー、切り替えキー、フィルターキー](https://support.microsoft.com/en-us/windows/windows-keyboard-shortcuts-for-accessibility-021bcb62-45c8-e4ef-1e4f-41b8c1fc87fd)<br>注意 | ユーザーごとの Sticky Keys、Filter Keys、Toggle Keys のアクセシビリティ フラグを変更し、ショートカットの動作を調整します。<br><br>管理者権限が必要です。 |
| 🔴 [HPET タイマー](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/bcdedit--set)<br>警告 | 検出した HPET デバイスの無効化を試み、BCD の起動タイマーを変更します。プラットフォーム クロックの上書きを解除し、プラットフォーム ティックを有効、動的ティックを無効にします。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>ハードウェアタイマーと起動設定に影響します。 |
| 🟡 [CPU コアパーキングを解除](https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/static-configuration-options-for-core-parking)<br>注意 | 現在の電源プランで、AC 電源時とバッテリー時の両方においてパーキングされないコアの最小割合を 100% に設定します。<br><br>管理者権限が必要です。 |
| 🟡 [ゲームの CPU 優先度](https://learn.microsoft.com/en-us/windows/win32/procthread/scheduling-priorities)<br>注意 | VALORANT、CS2、Overwatch など、リストにあるゲームの実行ファイルに高い CPU 優先度を設定します。該当ゲームの起動時に参照されます。<br><br>管理者権限が必要です。 |
| 🟡 [マルチプレーンオーバーレイ](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/multiplane-overlay-support)<br>注意 | DWM の OverlayTestMode を切り替えます。現在の値が 5 なら 0、それ以外なら 5 を設定します。<br><br>管理者権限が必要です。 |
| 🔴 [MSI 割り込みモード](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts)<br>警告 | レジストリ内の該当する PCI デバイスに MSISupported = 1 を設定します。GPU やネットワークアダプター以外の PCI デバイスにも及ぶ場合があります。対応はドライバーと機器に依存します。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>該当する PCI デバイスの割り込みを変更すると不安定になることがあります。 |
| 🟡 [ハードウェア GPU スケジューリング](https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/)<br>注意 | HwSchMode = 2 を設定してハードウェア アクセラレータによる GPU スケジューリングを要求します。対応する GPU とドライバーが必要です。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。 |
| 🟡 [シェーダーキャッシュを削除](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>注意 | Local AppData にある NVIDIA と AMD の DX・GL キャッシュ、および Windows の D3DSCache を消去します。ゲーム起動時にキャッシュが再作成される場合があります。<br><br>管理者権限が必要です。 |
| 🟡 [全画面表示の最適化](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>注意 | 全画面表示と Game DVR の設定を書き込み、アプリの録画を無効にします。指定の Game Bar リンク先を変更し、ユーザーごとの録画サービスの停止を試みます。<br><br>管理者権限が必要です。 |
| 🟡 [マルチメディア スケジューラ](https://learn.microsoft.com/en-us/windows/win32/procthread/multimedia-class-scheduler-service)<br>注意 | マルチメディア プロファイルがある場合は SystemResponsiveness = 0 と NetworkThrottlingIndex = 0xFFFFFFFF を設定します。Games タスクでは GPU 優先度 8、優先度 6、スケジューリング High を要求します。<br><br>管理者権限が必要です。 |
| 🟡 [マウス加速](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow)<br>注意 | 現在の Windows ユーザーの MouseSpeed、MouseThreshold1、MouseThreshold2 を 0 にし、ポインターの加速を無効にします。<br><br>管理者権限が必要です。 |
| 🔴 [Riot クライアントのキャッシュを削除](https://support-valorant.riotgames.com/)<br>警告 | 現在のユーザーの Local AppData にある Riot Client の Logs と Data、VALORANT の Saved 内の Logs と Crashes を対象にします。先に Riot Client と VALORANT を終了してください。<br><br>管理者権限が必要です。<br><br>キャッシュ、ログ、一部の Riot Client ローカルデータを削除します。 |
| 🟡 [バックグラウンドプロセスを終了](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/stop-process)<br>注意 | OneDrive、Teams、Edge、Game Bar など、定義済みリストの実行中プロセスを強制終了します。先に作業を保存してください。<br><br>管理者権限が必要です。 |
| 🔴 [VBS とメモリ整合性](https://support.microsoft.com/en-us/windows/security/windows-security/device-security-in-the-windows-security-app)<br>警告 | Windows セキュリティの「コア分離」を開きます。メモリ整合性と利用条件はその画面で確認できます。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>メモリ整合性を変更すると、Windows の分離による保護が弱まることがあります。 |
| 🟡 [DirectX フリップモデル](https://learn.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-flip-model)<br>注意 | DirectX、GameConfigStore、DWM の SwapEffectUpgradeEnable と Win32_AutoFlip を設定し、対象のウィンドウ表示ゲームで Flip Model の使用を要求します。<br><br>管理者権限が必要です。 |
| 🟡 [Game Bar Presence](https://support.xbox.com/en-US/help/games-apps/game-setup-and-play/get-to-know-game-bar-on-windows-10)<br>注意 | Windows のゲーム設定にある Xbox Game Bar を開きます。オーバーレイの設定はその画面で確認できます。 |

</details>

<details>
<summary>システムと Talon (16)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🔴 [Talon Suite](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>警告 | 診断と履歴のポリシー、Copilot と Recall、配信と候補、エクスプローラー、アクセシビリティ、スタートとウィジェット、スケジュール タスク、バックグラウンド アプリ、カーネルと GPU タイムアウトを 9 段階で設定します。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>アプリ、サービス、システムタスクを一括で変更します。 |
| 🟡 [従来のコンテキストメニュー](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_registry_provider)<br>注意 | クラシック コンテキスト メニュー用のユーザー別 Explorer 上書きを追加します。Explorer を再起動するか、サインインし直して確認してください。<br><br>管理者権限が必要です。 |
| 🟡 [ULPS と PCIe](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | 既存のグラフィックス ドライバーの ULPS フラグを 0 にし、HFS を無効にします。現在の電源プランで PCIe リンク状態と一部の CPU 電源設定も変更します。<br><br>管理者権限が必要です。 |
| 🟡 [Defender を再有効化](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>注意 | Microsoft Defender の PowerShell を使ってリアルタイム保護を有効にし、RealTimeProtectionEnabled が true かを確認します。<br><br>管理者権限が必要です。 |
| 🔴 [リアルタイム保護](https://learn.microsoft.com/en-us/windows/security/operating-system-security/system-security/windows-defender-security-center/windows-defender-security-center)<br>警告 | Windows セキュリティの「ウイルスと脅威の防止」の設定を開きます。リアルタイム保護はその画面で確認します。<br><br>リアルタイム保護を無効にすると、マルウェアの検出能力が低下します。 |
| 🟡 [Defender のスキャン優先度](https://learn.microsoft.com/en-us/defender-endpoint/mdav-scan-best-practices)<br>注意 | Defender のスキャン時の平均 CPU 使用率目標を 20% に設定し、低い CPU 優先度でのスキャンを有効にします。<br><br>管理者権限が必要です。 |
| 🟡 [SysMain サービス](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service)<br>注意 | SysMain を停止し、スタートアップの種類を「無効」に設定します。<br><br>管理者権限が必要です。 |
| 🟡 [高速スタートアップと休止状態](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | powercfg で休止状態を無効にし、HiberbootEnabled を 0 に設定します。高速スタートアップも無効になります。<br><br>管理者権限が必要です。 |
| 🟡 [診断とテレメトリ](https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization)<br>注意 | DiagTrack、SysMain、Windows Search、MapsBroker、配信の最適化（DoSvc）など、存在するサービスを最大 8 個停止して無効にします。<br><br>管理者権限が必要です。 |
| 🔴 [組み込みアプリを削除](https://learn.microsoft.com/en-us/powershell/module/appx/remove-appxpackage)<br>警告 | スマートフォン連携、天気、Clipchamp、Windows マップなど、固定リストに一致する AppX パッケージを全ユーザーからアンインストールします。<br><br>管理者権限が必要です。<br><br>Windows アプリを削除すると、機能の復元に再インストールが必要な場合があります。 |
| 🟡 [ワーキングセットを整理](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-emptyworkingset)<br>注意 | EmptyWorkingSet でアクセス可能なプロセスのワーキング セットを縮小し、前後の空き RAM をログに記録します。<br><br>管理者権限が必要です。 |
| 🟡 [一時ファイルを削除](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>注意 | ユーザーの Temp、Windows Temp、Windows Prefetch の削除可能な項目を消去します。ロック中や保護された項目はスキップし、解放容量を報告します。<br><br>管理者権限が必要です。 |
| 🔴 [ディスクの詳細クリーンアップ](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)<br>警告 | 通常の Temp と Prefetch に加え、Windows Update のダウンロード、Explorer キャッシュ、Windows ログ、クラッシュ ダンプ、エラー報告を整理します。ロック中や保護対象はスキップします。<br><br>管理者権限が必要です。<br><br>更新プログラムのキャッシュ、システムログ、診断ファイルを削除します。 |
| 🟡 [休止状態の切り替え](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options)<br>注意 | C:\hiberfil.sys があるかを確認します。ファイルがあれば休止状態を無効にし、なければ有効にします。<br><br>管理者権限が必要です。 |
| 🟡 [スタートアップアプリ](https://learn.microsoft.com/en-us/windows/win32/setupapi/run-and-runonce-registry-keys)<br>注意 | 現在のユーザーとコンピューターのレジストリ Run 項目を表示します。削除する項目のチェックを外し、確認してください。値は削除前に JSON へ保存され、コンピューターの項目には管理者権限が必要です。 |
| 🔴 [Windows Update](https://learn.microsoft.com/en-us/windows/deployment/update/waas-manage-updates-wufb)<br>警告 | 設定の Windows Update を開きます。更新や再起動に関する選択肢をその画面で確認できます。<br><br>更新を一時停止すると、セキュリティ修正の適用が遅れる場合があります。 |

</details>

<details>
<summary>ネットワークとドライバー (8)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🟡 [ネットワークの省電力](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapterpowermanagement)<br>注意 | Windows がデバイスの電源を切らないようにアダプターの電源管理を変更します。ドライバーが提供する対応の省電力プロパティも無効にします。<br><br>管理者権限が必要です。 |
| 🟡 [TCP/IP の調整](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics)<br>注意 | レジストリにある TCP/IP インターフェイスごとに TCPNoDelay = 1、TcpAckFrequency = 1、TcpDelAckTicks = 0 を設定します。影響は接続とアプリの通信方式に依存します。<br><br>管理者権限が必要です。 |
| 🟡 [Large Send Offload](https://learn.microsoft.com/en-us/powershell/module/netadapter/set-netadapteradvancedproperty)<br>注意 | IPv4 と IPv6 の LSO およびチェックサム オフロードの無効化を試みます。利用できる場合は、省電力 Ethernet、Gigabit Lite、省電力モード、割り込み調整なども変更します。<br><br>管理者権限が必要です。 |
| 🟡 [DNS アドレス](https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress)<br>注意 | 選択したプロバイダーの IPv4 DNS アドレス 2 件をすべての有効なアダプターに適用します。設定を読み戻して確認し、DNS キャッシュを消去します。<br><br>DNS プロバイダーを選んで「適用」を押し、確認画面でアドレスを確認します。<br><br>管理者権限が必要です。 |
| 🟢 [DNS キャッシュを消去](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig)<br>安全 | ipconfig /flushdns を使ってローカルの Windows DNS キャッシュを消去します。<br><br>管理者権限が必要です。 |
| 🔴 [ネットワークをリセット](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-winsock)<br>警告 | Winsock と TCP/IP をリセットし、IP リースの解放と更新を行い、DNS キャッシュを消去します。接続が中断される場合があります。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>ネットワークが切断されたり、設定が変更されたりする場合があります。 |
| 🔴 [Display Driver Uninstaller](https://www.wagnardsoft.com/)<br>警告 | Wagnardsoft から Display Driver Uninstaller 18.0.8.6 を取得し、発行元の署名を確認して開きます。ドライバーの削除は DDU 側で操作します。<br><br>DDU はディスプレイドライバーを削除します。再起動が必要な場合があります。 |
| 🔴 [UEFI で再起動](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/shutdown)<br>警告 | 確認後にすぐ UEFI ファームウェアへの再起動を要求します。先に作業を保存してください。<br><br>管理者権限が必要です。<br><br>すぐに UEFI へ再起動します。作業内容を先に保存してください。 |

</details>

<details>
<summary>アプリとツール (7)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🔴 [NVIDIA 581.80 WHQL](https://www.nvidia.com/en-us/drivers/details/257497/)<br>警告 | この行に表示された版の NVIDIA デスクトップ ドライバーを取得します。NVIDIA の署名が有効ならサイレント インストーラーを起動し、終了コードを確認します。事前に対応 GPU を確認してください。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>画面がちらつく場合があります。Windows の再起動が必要になることがあります。 |
| 🔴 [NVIDIA 566.36 WHQL](https://www.nvidia.com/en-us/drivers/details/237719/)<br>警告 | この行に表示された版の NVIDIA デスクトップ ドライバーを取得します。NVIDIA の署名が有効ならサイレント インストーラーを起動し、終了コードを確認します。事前に対応 GPU を確認してください。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>画面がちらつく場合があります。Windows の再起動が必要になることがあります。 |
| 🟡 [CPU-Z と HWMonitor](https://www.cpuid.com/)<br>注意 | CPUID から CPU-Z 2.11 と HWMonitor 1.55 を取得し、デスクトップの Meowize_Tools に展開します。有効な CPUID 署名のある x64 実行ファイルを開きます。 |
| 🟡 [Unpark CPU App](https://coderbag.com/product/quickcpu)<br>注意 | CoderBag の Unpark CPU App を取得し、デスクトップの Meowize_Tools に展開して、署名を確認した実行ファイルを開きます。コア パーキングはツール内で設定します。 |
| 🟡 [Visual C++ x64](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)<br>注意 | Microsoft から Visual C++ x64 再頒布可能パッケージを取得し、発行元の署名を検証してパッシブ モードで実行します。自動再起動は無効です。<br><br>管理者権限が必要です。 |
| 🟡 [WinGet で 3 本のアプリを導入](https://github.com/microsoft/winget-cli)<br>注意 | Windows のアプリ インストーラーに含まれる WinGet で Google Chrome、Discord、7-Zip を順番に導入します。進捗とエラーはログで確認できます。<br><br>管理者権限が必要です。 |
| 🟢 [Office の展開設定](https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/overview-office-deployment-tool)<br>安全 | 既定のブラウザーで Microsoft の Office カスタマイズ ツールを開きます。展開設定はサイト上で選択します。 |

</details>

<details>
<summary>診断 (7)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🟢 [ハードウェア情報](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/operating-system-classes)<br>安全 | Windows CIM で CPU 名、コアとスレッド数、GPU 名、メモリ総量、C: の容量と空き容量を読み取り、ログに表示します。 |
| 🟢 [物理ディスクの状態](https://learn.microsoft.com/en-us/powershell/module/storage/get-physicaldisk)<br>安全 | Get-PhysicalDisk が報告する各物理ディスクの名前、メディアの種類、容量、HealthStatus を表示します。 |
| 🟢 [ACPI 温度](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/thermal-management-in-windows)<br>安全 | PC が WMI 経由で公開する ACPI サーマル ゾーンを読み、各測定値を摂氏に変換します。利用できるセンサーはファームウェアによって異なります。 |
| 🟢 [Windows のライセンス認証](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/sppwmi/softwarelicensingproduct)<br>安全 | SoftwareLicensingProduct から Windows のライセンス情報を読み取ります。エディション、認証状態、取得できる場合はキーの末尾 5 文字をログに記録します。 |
| 🟢 [ディスクとメモリの確認](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/systeminfo)<br>安全 | 100 点から始め、該当条件ごとに 15 点引きます。C: の空きが 15 GB 未満か、RAM 使用率が 85% を超えているかを確認します。 |
| 🟢 [ハードウェアの互換性](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor)<br>安全 | CIM で CPU 型番を読み、名前の一致判定に応じて Intel、Xeon、Ryzen の注意事項をログに表示します。 |
| 🟢 [システムスナップショット](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>安全 | 新しい Windows 復元ポイントを作成して確認し、HKLM と HKCU を C:\Meowize_Backup に書き出します。二つの処理は個別に試行します。<br><br>管理者権限が必要です。 |

</details>

<details>
<summary>回復とレポート (8)</summary>

| 項目 | Meowize の動作 |
| --- | --- |
| 🟢 [復元ポイントを作成](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/checkpoint-computer?view=powershell-5.1)<br>安全 | Windows ドライブのシステム保護を有効にし、時刻付きの Meowize 復元ポイントを作成します。シーケンス番号を照合して新規作成を確認します。<br><br>管理者権限が必要です。 |
| 🟢 [レジストリをバックアップ](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export)<br>安全 | HKLM と HKCU を、C:\Meowize_Backup 内の新しい Manual スナップショットに HKLM.reg と HKCU.reg として書き出します。<br><br>管理者権限が必要です。 |
| 🔴 [レジストリを復元](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-import)<br>警告 | 確認前に最新の互換スナップショットとパスを表示します。.reg のヘッダーを確認し、現在のレジストリをバックアップしてから対象をインポートします。<br><br>管理者権限が必要です。<br><br>この変更を反映するには、Windows の再起動が必要な場合があります。<br><br>バックアップからコンピューターまたはアカウントのレジストリ設定を取り込みます。 |
| 🟡 [DISM と SFC で Windows を修復](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sfc)<br>注意 | DISM /Online /Cleanup-Image /RestoreHealth を実行し、成功した場合に sfc /scannow を実行します。コマンドの出力はログに記録されます。<br><br>管理者権限が必要です。 |
| 🟢 [HTML システムレポート](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-html)<br>安全 | CPU、GPU、RAM、Windows の情報をデスクトップの Meowize_System_Report.html に保存し、既定のブラウザーで開きます。 |
| 🟢 [ログを出力](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file)<br>安全 | 保存ダイアログを開き、時刻付きのアクティビティ ログを UTF-8 の .txt ファイルに書き出します。 |
| 🟢 [ログをコピー](https://learn.microsoft.com/en-us/dotnet/api/system.windows.clipboard.settext)<br>安全 | 時刻を含む現在のアクティビティ ログを Windows のクリップボードにコピーします。 |
| 🟡 [診断 ZIP](https://learn.microsoft.com/en-us/dotnet/api/system.io.compression.ziparchive)<br>注意 | 保存先を選択し、systeminfo と ipconfig /all の結果および現在の Meowize ログをローカル ZIP にまとめます。共有前に機器とネットワーク情報を確認してください。 |

</details>
