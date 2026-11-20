using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Text.Json;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Threading;
using Wpf.Ui.Controls;
using Button = Wpf.Ui.Controls.Button;
using TextBlock = System.Windows.Controls.TextBlock;
using static AioOptimize.Localizer;

namespace AioOptimize;

public partial class MainWindow
{
    private sealed record StartupEntry(string Scope, string Name, string Value);

    private static readonly Dictionary<string, string> SettingsPages = new(StringComparer.Ordinal)
    {
        ["Defender"] = "windowsdefender://threatsettings/",
        ["btnDisableDefender"] = "windowsdefender://threatsettings/",
        ["DisableVBS"] = "windowsdefender://coreisolation/",
        ["btnDisableVBS"] = "windowsdefender://coreisolation/",
        ["BlockPresence"] = "ms-settings:gaming-gamebar",
        ["btnBlockPresence"] = "ms-settings:gaming-gamebar",
        ["WinUpdate"] = "ms-settings:windowsupdate",
        ["btnWinUpdate"] = "ms-settings:windowsupdate"
    };

    private DispatcherTimer? _shutdownTimer;
    private DateTimeOffset? _shutdownDeadline;
    private Button? _shutdownCancel;
    private Mutex? _mutationLock;
    private Task? _hardwareProbe;
    private DateTimeOffset _lastHardwareProbe;
    private bool _checkingTaskAvailability;

    private async void ReviewBatch(object sender, RoutedEventArgs e)
    {
        if (!await ReadyForTaskReviewAsync())
            return;
        var items = _catalog.Batch.Where(item => _selection.Contains(item.Id) && IsAvailable(item.Id)).ToArray();
        if (items.Length == 0)
            return;

        var autoShutdown = AutoShutdown.IsChecked == true;
        var body = new StackPanel();
        body.Children.Add(Label(T(_preview ? "PreviewReview" : "LiveReview"), "BodyText"));
        var warningCount = items.Count(item => item.Risk == TaskRisk.Warning);
        if (warningCount > 0)
        {
            var summary = Label(T("WarningCount", warningCount), "BodyText");
            summary.Margin = new(0, 7, 0, 0);
            summary.SetResourceReference(ForegroundProperty, "RiskWarning");
            AutomationProperties.SetAutomationId(summary, "ReviewWarningCount");
            body.Children.Add(summary);
        }
        if (autoShutdown)
            body.Children.Add(Label(T("CountdownReview"), "MutedText"));
        if (items.Any(item => item.Restart))
            body.Children.Add(Label(T("MayRestart"), "MutedText"));
        var list = new StackPanel { Margin = new(0, 9, 0, 0) };
        for (var index = 0; index < items.Length; index++)
        {
            var item = items[index];
            var reviewRow = new DockPanel { LastChildFill = true, Margin = new(0, 3, 5, 3) };
            var badge = RiskBadge(item.Risk, item.DisplayRiskNote);
            badge.Margin = new(8, 0, 0, 0);
            DockPanel.SetDock(badge, Dock.Right);
            reviewRow.Children.Add(badge);
            var text = LinkedTitle(item, "BodyText", $"{index + 1:00}  ", inReview: true);
            text.VerticalAlignment = VerticalAlignment.Center;
            reviewRow.Children.Add(text);
            list.Children.Add(reviewRow);
            if (item.Risk == TaskRisk.Warning)
            {
                var note = Label(RiskHelp(item), "MutedText");
                note.Margin = new(21, 0, 8, 4);
                list.Children.Add(note);
            }
            if (item.Mode == "settings")
            {
                var launch = ActionButton(T("OpenWindows"), ControlAppearance.Transparent, (_, _) => OpenSetting(item));
                launch.HorizontalAlignment = HorizontalAlignment.Left;
                launch.Margin = new(10, 0, 0, 4);
                list.Children.Add(launch);
            }
            if (item.Id == "BackupReg" && !_preview && !Directory.Exists(@"D:\"))
                list.Children.Add(Label(T("BackupFallback", @"C:\Meowize_Backup\BranchExports"), "MutedText"));
        }
        body.Children.Add(list);

        if (items.Any(item => item.Admin) && !_admin && !_preview)
        {
            body.Children.Insert(0, Label(T("AdminBatch"), "MutedText"));
            if (Dialog(T("ReviewTasks"), body, T("OpenAdmin")))
                RequestAdmin(this, new RoutedEventArgs());
            return;
        }

        if (!Dialog(T("RunTasks", items.Length), body, T(_preview ? "Simulate" : "RunSelected")))
            return;

        await RunBatchAsync(items, autoShutdown);
    }

    private async Task RunBatchAsync(Operation[] items, bool autoShutdown)
    {
        if (items.FirstOrDefault(item => !IsAvailable(item.Id)) is { } unavailable)
        {
            AddActivity($"{unavailable.DisplayTitle} · {UnavailableReason(unavailable.Id)}", "warn");
            return;
        }
        if (!BeginJob(T("TaskCount", items.Length), true, changesMachine: true))
            return;
        var warnings = 0;
        var settings = new List<Operation>();
        var finished = 0;
        var needsRestart = false;
        try
        {
            foreach (var item in items)
            {
                if (_stopping)
                    break;
                StatusLabel.Text = item.DisplayTitle;
                AddActivity(item.DisplayTitle, "info");
                WorkerResult result;
                if (item.Mode == "settings")
                {
                    settings.Add(item);
                    result = new("manual", T("ManualAction"));
                }
                else
                {
                    result = await PerformAsync(item);
                    if (result.Status != "ok")
                        warnings++;
                    needsRestart |= item.Restart && result.Status is "ok" or "check";
                }
                finished++;
                ProgressLabel.Text = $"{finished}/{items.Length}";
                SetProgressValue(JobProgress, 100d * finished / items.Length);
                AddResult(item.DisplayTitle, result);
                if (!_preview && item.Id is ("RestorePoint" or "BackupReg") && result.Status is not "ok")
                {
                    var detail = Label(result.Text + "\n" + T("BackupCheck"), "BodyText");
                    if (!Dialog(T("BackupReview"), detail, T("ContinueTasks"), T("Stop")))
                        _stopping = true;
                }
            }

            var stopped = _stopping;
            EndJob(T(stopped ? "Stopped" : _preview ? "PreviewDone" :
                warnings + settings.Count > 0 ? "CompletedNotices" : "Completed"));
            AddActivity(T("Processed", finished, items.Length), stopped ? "warn" : "ok");
            if (warnings > 0)
                AddActivity(T("CheckCount", warnings), "warn");
            if (settings.Count > 0)
                OfferSettings(settings.ToArray());
            if (needsRestart && !stopped)
                AddActivity(T("RestartNeeded"), "warn");
            if (autoShutdown && !stopped &&
                (warnings + settings.Count == 0 || _preview || Dialog(T("ShutdownBatch"), Label(T("ShutdownPartial"), "BodyText"), T("Countdown"))))
            {
                await ScheduleShutdownAsync();
            }
            else if (!_hidePopups && !stopped)
            {
                Dialog(StatusLabel.Text, Label(T("Processed", finished, items.Length), "BodyText"));
            }
        }
        catch (Exception exception)
        {
            EndJob(T("Error"));
            AddActivity(exception.Message, "error");
        }
    }

    private async Task HandleOperationAsync(Operation item)
    {
        if (!await ReadyForTaskReviewAsync())
            return;
        if (UnavailableReason(item.Id) is { } reason)
        {
            Dialog(item.DisplayTitle, Label(reason, "BodyText"));
            return;
        }
        if (item.Mode == "settings")
        {
            OpenSetting(item);
            return;
        }
        if (item.Id == "btnStartupMgr")
        {
            await ManageStartupAsync();
            return;
        }
        if (item.Admin && !_admin && !_preview)
        {
            if (Dialog(T("Permissions"), DescribeRisk(item, T("AdminForTask", item.DisplayTitle)), T("OpenAdmin")))
                RequestAdmin(this, new RoutedEventArgs());
            return;
        }
        var description = item.DisplayDescription;
        object? input = null;
        if (item.Id == "btnApplyDns")
        {
            var provider = Providers[_dns];
            description = $"{T("DnsForAdapters", provider.Name)}\n{provider.Preferred} / {provider.Alternate}";
            input = new { Index = _dns };
        }
        if (item.Id == "btnRestoreReg" && !_preview)
        {
            var backup = await SelectLatestBackupAsync();
            if (backup is null)
                return;
            description = $"{T("RestoreConfirm", backup.Name)}\n{string.Join("\n", backup.Paths)}\n{T("SnapshotBefore")}";
            input = new { backup.Id };
        }
        if (item.Id == "btnDiagZip")
            description += "\n" + T("ZipPrivacy");
        var confirm = item.Impact == "Change" || item.Id is "btnApplyDns" or "btnDiagZip" or "btnDDU" or "btnAppsDesktop" or "btnUnparkApp";
        if (confirm && !Dialog(item.DisplayTitle, DescribeRisk(item, description + (item.Restart ? "\n" + T("MayRestart") : "")),
            T(_preview ? "Simulate" : "Continue")))
            return;
        if (!BeginJob(item.DisplayTitle, false, changesMachine: item.Impact == "Change"))
            return;
        try
        {
            var result = item.Mode == "desktop" ? await PerformDesktopAsync(item) : await PerformAsync(item, input);
            AddResult(item.DisplayTitle, result);
            EndJob(result.Status switch
            {
                "ok" => T(_preview ? "PreviewDone" : "Completed"),
                "error" => T("Error"),
                _ => T("CheckResult")
            });
            if (!_hidePopups)
                Dialog(item.DisplayTitle, Label(result.Text, "BodyText"));
        }
        catch (Exception exception)
        {
            AddActivity(exception.Message, "error");
            EndJob(T("Error"));
        }
    }

    private Task<WorkerResult> PerformAsync(Operation operation, object? input = null)
    {
        if (_preview)
            return SimulateAsync(operation);
        if (UnavailableReason(operation.Id) is { } reason)
            return Task.FromResult(new WorkerResult("unavailable", reason));
        return CommandRunner.RunAsync(operation.Id, input, WorkerUpdate, confirmed: true);
    }

    private sealed record RegistryBackup(string Id, string Name, string[] Paths);

    private async Task<RegistryBackup?> SelectLatestBackupAsync()
    {
        RegistryBackup? backup = null;
        BeginJob(T("LookingUpBackup"), false);
        try
        {
            var response = await CommandRunner.RunAsync("BackupList", null, update =>
            {
                if (update is { Kind: "data", Data.ValueKind: JsonValueKind.Array })
                    backup = (update.Data.Deserialize<RegistryBackup[]>(new JsonSerializerOptions { PropertyNameCaseInsensitive = true }) ?? []).FirstOrDefault();
            });
            if (response.Status != "ok")
                AddActivity(response.Text, "warn");
        }
        catch (Exception exception)
        {
            AddActivity(exception.Message, "error");
        }
        EndJob(T("Ready"));
        if (backup is null)
            Dialog(T("RestoreRegistry"), Label(T("BackupMissing"), "BodyText"));
        return backup;
    }

    private async Task<WorkerResult> SimulateAsync(Operation operation)
    {
        await Task.Delay(120);
        return new("ok", T("SimulatedTask", operation.DisplayTitle));
    }

    private void WorkerUpdate(WorkerEvent update)
    {
        if (update.Kind == "log" && update.Text is { } line)
            AddActivity(line, update.Level ?? "info");
        if (update.Kind == "progress" && update.Value is { } value && ProgressLabel.Text.Length == 0)
        {
            JobProgress.IsIndeterminate = false;
            SetProgressValue(JobProgress, Math.Clamp(value, 0, 100));
        }
    }

    private async Task<bool> ReadyForTaskReviewAsync()
    {
        if (_busy || _shutdownDeadline is not null || _checkingTaskAvailability)
            return false;
        _checkingTaskAvailability = true;
        try
        {
            await LoadHardwareAsync();
            return IsLoaded && !_busy && _shutdownDeadline is null;
        }
        finally
        {
            _checkingTaskAvailability = false;
        }
    }

    private Task LoadHardwareAsync(bool refresh = false)
    {
        if (_hardwareProbe is { IsCompleted: false })
            return _hardwareProbe;
        var now = DateTimeOffset.UtcNow;
        if (_hardwareReady && (_preview || (!refresh && now - _lastHardwareProbe < TimeSpan.FromSeconds(15))))
            return Task.CompletedTask;
        _lastHardwareProbe = now;
        return _hardwareProbe = ReadHardwareAsync();
    }

    private async Task ReadHardwareAsync()
    {
        var availabilityChanged = false;
        if (_preview)
        {
            _machine["CPU"] = "AMD Ryzen 7 7800X3D";
            _machine["GPU"] = "NVIDIA GeForce RTX 4070";
            _machine["RAM"] = "32 GB";
            _machine["OS"] = "Windows 11 Pro";
        }
        else
        {
            try
            {
                var result = await CommandRunner.RunAsync("HardwareSummary", null, update =>
                {
                    if (update is not { Kind: "data", Data.ValueKind: JsonValueKind.Object })
                        return;
                    foreach (var property in update.Data.EnumerateObject())
                    {
                        if (property.Name == "Availability")
                            availabilityChanged = ApplyAvailability(property.Value);
                        else if (property.Value.ValueKind is JsonValueKind.String or JsonValueKind.Null)
                            _machine[property.Name] = property.Value.GetString() ?? T("NoData");
                    }
                });
                if (result.Status != "ok")
                    AddActivity(result.Text, "warn");
            }
            catch (Exception exception)
            {
                AddActivity(exception.Message, "warn");
            }
        }
        _hardwareReady = true;
        if (IsLoaded && (availabilityChanged || _page == "dashboard"))
            RenderPage();
    }

    private bool BeginJob(string title, bool batch, bool changesMachine = false)
    {
        if (changesMachine && !_preview)
        {
            try
            {
                var gate = new Mutex(false, @"Local\AioOptimize.Changes");
                bool acquired;
                try { acquired = gate.WaitOne(0); }
                catch (AbandonedMutexException) { acquired = true; }
                if (!acquired)
                {
                    gate.Dispose();
                    AddActivity(T("OtherSession"), "warn");
                    return false;
                }
                _mutationLock = gate;
            }
            catch (UnauthorizedAccessException)
            {
                AddActivity(T("LockUnavailable"), "warn");
                return false;
            }
        }
        _busy = true;
        _stopping = false;
        ProgressLabel.Text = batch ? "0/0" : "";
        StatusLabel.Text = title;
        JobProgress.BeginAnimation(ProgressBar.ValueProperty, null);
        JobProgress.Value = 0;
        JobProgress.IsIndeterminate = !batch && MotionAllowed;
        JobProgress.Visibility = Visibility.Visible;
        StopButton.Visibility = batch ? Visibility.Visible : Visibility.Collapsed;
        if (!_logVisible)
        {
            _customLogVisibility = true;
            ApplyLayout();
        }
        UpdateControls();
        return true;
    }

    private void EndJob(string status)
    {
        var refreshAvailability = _mutationLock is not null;
        if (_mutationLock is not null)
        {
            _mutationLock.ReleaseMutex();
            _mutationLock.Dispose();
            _mutationLock = null;
        }
        _busy = false;
        JobProgress.IsIndeterminate = false;
        JobProgress.Visibility = Visibility.Collapsed;
        StopButton.Visibility = Visibility.Collapsed;
        StatusLabel.Text = status;
        UpdateControls();
        if (refreshAvailability)
            _ = LoadHardwareAsync(refresh: true);
    }

    private void UpdateControls()
    {
        var locked = _busy || _shutdownDeadline is not null;
        PageBody.IsEnabled = !locked;
        AutoShutdown.IsEnabled = !locked;
        RunBar.Visibility = _page == "batch" || _busy ? Visibility.Visible : Visibility.Collapsed;
        RunButton.Visibility = _busy ? Visibility.Collapsed : Visibility.Visible;
        RunButton.IsEnabled = !locked && _selection.Count > 0;
        StopButton.IsEnabled = !_stopping;
        AdminButton.IsEnabled = !locked && !_preview && !_admin;
        UpdateRunSummary();
    }

    private void StopAfterStep(object sender, RoutedEventArgs e)
    {
        _stopping = true;
        StopButton.IsEnabled = false;
        AddActivity(T("Stopping"), "warn");
    }

    private void AddResult(string title, WorkerResult result) =>
        AddActivity($"{title} · {result.Text}", result.Status switch { "ok" => "ok", "error" => "error", _ => "warn" });

    private void AddActivity(string text, string level)
    {
        var scroller = Descendant<ScrollViewer>(Activity);
        var autoscroll = scroller is null || scroller.VerticalOffset >= scroller.ScrollableHeight - 6;
        var row = new ActivityRow(DateTime.Now.ToString("HH:mm:ss"), text, level);
        _activity.Add(row);
        if (autoscroll)
            Activity.ScrollIntoView(row);
    }

    private static T? Descendant<T>(DependencyObject root) where T : DependencyObject
    {
        for (var index = 0; index < VisualTreeHelper.GetChildrenCount(root); index++)
        {
            var child = VisualTreeHelper.GetChild(root, index);
            if (child is T typed)
                return typed;
            var nested = Descendant<T>(child);
            if (nested is not null)
                return nested;
        }
        return null;
    }

    private void OpenSetting(Operation item)
    {
        if (_preview)
        {
            AddActivity(T("SimulateSettings", item.DisplayTitle), "info");
            return;
        }
        try
        {
            OpenExternal(SettingsPages[item.Id]);
            AddActivity(T("OpenedSettings", item.DisplayTitle), "info");
        }
        catch (Win32Exception exception)
        {
            AddActivity(T("SettingsError", exception.Message), "warn");
        }
    }

    private void OfferSettings(Operation[] items)
    {
        var sections = new StackPanel();
        sections.Children.Add(Label(T("ManualItems"), "BodyText"));
        foreach (var item in items)
        {
            var button = ActionButton(item.DisplayTitle, ControlAppearance.Secondary, (_, _) => OpenSetting(item));
            button.Margin = new(0, 8, 0, 0);
            sections.Children.Add(button);
        }
        Dialog(T("WindowsSettings"), sections);
    }

    private async Task<WorkerResult> PerformDesktopAsync(Operation operation)
    {
        if (_preview)
        {
            if (operation.Id is "btnCopyLog" or "btnExportLog" or "btnDiagZip")
                return await ExportAsync(operation.Id);
            return await SimulateAsync(operation);
        }

        switch (operation.Id)
        {
            case "btnOfficeTools":
                OpenExternal("https://config.office.com/deploymentsettings");
                return new("ok", T("OfficeOpened"));
            default:
                return await ExportAsync(operation.Id);
        }
    }

    private async Task<WorkerResult> ExportAsync(string id)
    {
        var log = FormatLog();
        if (id == "btnCopyLog")
        {
            Clipboard.SetText(log.Length > 0 ? log : T("EmptyLog"));
            return new("ok", T("ClipboardCopied"));
        }

        var desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
        if (string.IsNullOrEmpty(desktop) || !Directory.Exists(desktop))
            return new("error", T("DesktopMissing"));
        var filename = id == "btnDiagZip" ? "Meowize_Diagnostic.zip" : $"Meowize_Log_{DateTime.Now:yyyyMMdd_HHmmss}.txt";
        var picker = new Microsoft.Win32.SaveFileDialog
        {
            InitialDirectory = desktop,
            FileName = filename,
            DefaultExt = Path.GetExtension(filename),
            Filter = id == "btnDiagZip" ? $"{T("ZipFile")} (*.zip)|*.zip" : $"{T("TextLog")} (*.txt)|*.txt"
        };
        if (picker.ShowDialog(this) != true)
            return new("manual", T("ExportCanceled"));

        if (id == "btnDiagZip")
        {
            var machine = _preview ? T("FixtureMachine") : await CommandRunner.CaptureAsync("systeminfo.exe");
            var network = _preview ? T("FixtureNetwork") : await CommandRunner.CaptureAsync("ipconfig.exe", "/all");
            var temporary = picker.FileName + "." + Guid.NewGuid().ToString("N") + ".tmp";
            try
            {
                using (var zip = ZipFile.Open(temporary, ZipArchiveMode.Create))
                {
                    foreach (var (name, content) in new[] { ("systeminfo.txt", machine), ("ipconfig.txt", network), ("meowize_log.txt", log) })
                    {
                        using var writer = new StreamWriter(zip.CreateEntry(name).Open(), Encoding.UTF8);
                        writer.Write(content);
                    }
                }
                File.Move(temporary, picker.FileName, overwrite: true);
            }
            finally
            {
                File.Delete(temporary);
            }
        }
        else
        {
            await File.WriteAllTextAsync(picker.FileName, log, Encoding.UTF8);
        }
        return new("ok", T("SavedFile", picker.FileName));
    }

    private string FormatLog() => string.Join(Environment.NewLine, _activity.Select(row => $"[{row.Time}] {row.Text}"));

    private void CopyLog(object sender, RoutedEventArgs e)
    {
        try
        {
            var log = FormatLog();
            Clipboard.SetText(log.Length > 0 ? log : T("EmptyLog"));
            AddActivity(T("ClipboardCopied"), "ok");
        }
        catch (System.Runtime.InteropServices.ExternalException)
        {
            AddActivity(T("ClipboardBusy"), "warn");
        }
    }

    private async Task ManageStartupAsync()
    {
        BeginJob(T("ReadingStartup"), false);
        StartupEntry[] entries = [];
        try
        {
            if (_preview)
            {
                entries =
                [
                    new("User", "OneDrive", "OneDrive.exe /background"),
                    new("Machine", "SecurityHealth", "SecurityHealthSystray.exe")
                ];
            }
            else
            {
                var result = await CommandRunner.RunAsync("StartupRead", null, update =>
                {
                    if (update is { Kind: "data", Data.ValueKind: JsonValueKind.Array })
                        entries = update.Data.Deserialize<StartupEntry[]>(new JsonSerializerOptions { PropertyNameCaseInsensitive = true }) ?? [];
                    WorkerUpdate(update);
                });
                if (result.Status != "ok")
                    AddActivity(result.Text, "warn");
            }
            EndJob(T("Ready"));
            if (entries.Length == 0)
            {
                Dialog(T("StartupApps"), Label(T("NoStartup"), "BodyText"));
                return;
            }

            var checks = new List<(StartupEntry Entry, CheckBox Box)>();
            var stack = new StackPanel();
            stack.Children.Add(Label(T("UncheckStartup"), "BodyText"));
            foreach (var entry in entries)
            {
                var check = new CheckBox
                {
                    Content = Label($"{entry.Name}  ·  {T(entry.Scope == "User" ? "ScopeUser" : "ScopeMachine")}\n{entry.Value}", "BodyText"),
                    IsChecked = true,
                    Margin = new(0, 9, 0, 3),
                    IsEnabled = entry.Scope == "User" || _admin || _preview
                };
                AutomationProperties.SetName(check, entry.Name);
                stack.Children.Add(check);
                checks.Add((entry, check));
            }
            if (!Dialog(T("StartupApps"), stack, T("ReviewUnchecked")))
                return;
            var removed = checks.Where(item => item.Box.IsChecked == false).Select(item => item.Entry).ToArray();
            if (removed.Length == 0)
                return;
            if (!Dialog(T("RemoveStartup"), Label(string.Join("\n", removed.Select(entry =>
                $"{entry.Name} ({T(entry.Scope == "User" ? "ScopeUser" : "ScopeMachine")})")), "BodyText"), T("RemoveItems")))
                return;
            if (!BeginJob(T("ApplyingStartup"), false, changesMachine: true))
                return;
            var report = _preview
                ? new WorkerResult("ok", T("SimulatedCount", removed.Length))
                : await CommandRunner.RunAsync("StartupRemove", removed, WorkerUpdate, confirmed: true);
            AddResult(T("StartupApps"), report);
            EndJob(T(report.Status == "ok" ? "Completed" : "CheckResult"));
        }
        catch (Exception exception)
        {
            AddActivity(exception.Message, "error");
            EndJob(T("Error"));
        }
    }

    private async Task ScheduleShutdownAsync()
    {
        if (_shutdownDeadline is not null)
            return;
        if (!_preview)
            await CommandRunner.CaptureAsync("shutdown.exe", "/s", "/t", "45");
        _shutdownDeadline = DateTimeOffset.Now.AddSeconds(45);
        _shutdownCancel ??= ActionButton(T("CancelShutdown"), ControlAppearance.Secondary, async (_, _) => await CancelShutdownAsync());
        _shutdownCancel.Margin = new(0, 8, 0, 0);
        var logFooter = (Grid)LogHint.Parent;
        Grid.SetRow(_shutdownCancel, 3);
        if (!logFooter.Children.Contains(_shutdownCancel))
            logFooter.Children.Add(_shutdownCancel);
        LogHint.Visibility = Visibility.Collapsed;
        _shutdownCancel.Visibility = Visibility.Visible;
        _shutdownTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };
        _shutdownTimer.Tick += (_, _) =>
        {
            if (_shutdownDeadline is not { } deadline || deadline <= DateTimeOffset.Now)
            {
                ClearShutdownStatus();
                return;
            }
            StatusLabel.Text = T("ShutdownIn", Math.Ceiling((deadline - DateTimeOffset.Now).TotalSeconds));
        };
        StatusLabel.Text = T("ShutdownIn", 45);
        ProgressLabel.Text = "";
        _customLogVisibility = true;
        ApplyLayout();
        _shutdownTimer.Start();
        UpdateControls();
        AddActivity(T(_preview ? "SimulatedShutdown" : "ShutdownScheduled"), "warn");
    }

    private async Task CancelShutdownAsync()
    {
        try
        {
            if (!_preview)
                await CommandRunner.CaptureAsync("shutdown.exe", "/a");
            ClearShutdownStatus();
            AddActivity(T("ShutdownCanceled"), "ok");
        }
        catch (Exception exception)
        {
            AddActivity(exception.Message, "error");
        }
    }

    private void ClearShutdownStatus()
    {
        _shutdownTimer?.Stop();
        _shutdownDeadline = null;
        if (_shutdownCancel is not null)
            _shutdownCancel.Visibility = Visibility.Collapsed;
        LogHint.Visibility = Visibility.Visible;
        StatusLabel.Text = T("Ready");
        UpdateControls();
    }

    private void WindowClosing(object? sender, CancelEventArgs e)
    {
        if (_handoffClosing)
            return;
        e.Cancel = true;
        if (_busy)
        {
            AddActivity(T("WaitCurrentTask"), "warn");
            return;
        }
        if (_exitDialogOpen)
            return;
        _exitDialogOpen = true;
        Dispatcher.InvokeAsync(() =>
        {
            try
            {
                if (_busy || (_shutdownDeadline is not null && !_preview &&
                    !Dialog(T("ShutdownClosing"), Label(T("ShutdownContinues"), "BodyText"), T("CloseApp"))))
                    return;
                if (!SaveBeforeClose())
                    return;
                _handoffClosing = true;
                Close();
            }
            finally
            {
                _exitDialogOpen = false;
            }
        });
    }

    private void RequestAdmin(object sender, RoutedEventArgs e)
    {
        if (_admin || _preview || _busy || Environment.ProcessPath is not { } path)
            return;
        try
        {
            var state = CaptureState();
            var start = new ProcessStartInfo(path) { UseShellExecute = true, Verb = "runas" };
            start.ArgumentList.Add("--resume=" + state.Encode());
            using var process = Process.Start(start);
            if (process is not null)
            {
                _handoffClosing = true;
                Close();
            }
        }
        catch (Win32Exception exception)
        {
            AddActivity(exception.NativeErrorCode == 1223 ? T("UacCanceled") : exception.Message, "warn");
        }
    }

    private void ShowPreferences(object sender, RoutedEventArgs e)
    {
        var body = new StackPanel();
        body.Children.Add(Label(T("Language"), "MutedText"));
        var picker = App.LanguagePicker();
        picker.Margin = new(0, 4, 0, 11);
        body.Children.Add(picker);
        var check = new CheckBox { Content = T("HidePopups"), IsChecked = _hidePopups, Margin = new(0, 4, 0, 9) };
        body.Children.Add(check);
        var profile = _preferences.Value;
        var ask = new CheckBox { Content = T("AskAtExit"), IsChecked = profile.Exit == ExitPreference.Ask };
        AutomationProperties.SetAutomationId(ask, "AskAtExit");
        body.Children.Add(ask);
        if (!Dialog(T("Settings"), body, T("Save")))
            return;
        var language = picker.SelectedValue as string ?? Code;
        var policy = ask.IsChecked == true ? ExitPreference.Ask :
            profile.Exit == ExitPreference.Ask ? ExitPreference.Save : profile.Exit;
        if (!TrySaveProfile(profile with { Language = language, Exit = policy }))
            return;
        _hidePopups = check.IsChecked == true;
        Use(language);
        RefreshLocale();
    }

    private void ShowSupport(object sender, RoutedEventArgs e)
    {
        var body = new StackPanel();
        var identity = new StackPanel();
        identity.Children.Add(Label(T("Maintainer"), "MutedText"));
        var maintainer = Label(ProjectIdentity.Maintainer, "SectionLabel");
        maintainer.FontSize = 20;
        maintainer.Margin = new(0, 4, 0, 5);
        AutomationProperties.SetAutomationId(maintainer, "SupportMaintainer");
        identity.Children.Add(maintainer);
        var address = Label(ProjectIdentity.GitHubUrl, "BodyText");
        AutomationProperties.SetAutomationId(address, "SupportGitHubUrl");
        identity.Children.Add(address);
        var actions = new WrapPanel { Margin = new(0, 12, 0, 0) };
        var open = ActionButton(T("OpenGithub"), ControlAppearance.Primary, (_, _) =>
        {
            try { OpenExternal(ProjectIdentity.GitHubUrl); }
            catch (Win32Exception) { AddActivity(T("GithubError"), "warn"); }
        });
        open.Margin = new(0, 0, 8, 3);
        open.Icon = Symbol("Open24", 15);
        AutomationProperties.SetAutomationId(open, "OpenSupportGitHub");
        actions.Children.Add(open);
        var copy = ActionButton(T("CopyLink"), ControlAppearance.Secondary, (_, _) =>
        {
            try
            {
                Clipboard.SetText(ProjectIdentity.GitHubUrl);
                AddActivity(T("ClipboardCopied"), "ok");
            }
            catch (System.Runtime.InteropServices.ExternalException)
            {
                AddActivity(T("ClipboardBusy"), "warn");
            }
        });
        copy.Icon = Symbol("Copy24", 15);
        actions.Children.Add(copy);
        identity.Children.Add(actions);
        body.Children.Add(Card(identity, new Thickness(13), new Thickness(0, 0, 0, 12)));
        body.Children.Add(Label(T("FreeLicense"), "BodyText"));
        body.Children.Add(Label($"© 2026 {ProjectIdentity.Maintainer}", "MutedText"));
        Dialog(T("Support"), body);
    }

    private static void OpenExternal(string target) =>
        Process.Start(new ProcessStartInfo(target) { UseShellExecute = true })?.Dispose();

    private bool Dialog(string title, UIElement content, string? accept = null, string? cancel = null, Button? alternative = null)
    {
        var dialog = new FluentWindow
        {
            Owner = this, Title = title, Width = Math.Min(540, ActualWidth - 50),
            SizeToContent = SizeToContent.Height, ResizeMode = ResizeMode.NoResize,
            WindowStartupLocation = WindowStartupLocation.CenterOwner,
            ShowInTaskbar = false, FontFamily = FontFamily, Language = Language, ExtendsContentIntoTitleBar = true,
            MaxHeight = Math.Max(380, ActualHeight - 52)
        };
        dialog.SetResourceReference(BackgroundProperty, "Surface");
        dialog.SetResourceReference(ForegroundProperty, "TextMain");
        foreach (var key in Resources.Keys)
            dialog.Resources[key] = Resources[key];
        var frame = new DockPanel();
        var titleBar = new TitleBar { Title = "Meowize", Height = 38, ShowMinimize = false, ShowMaximize = false };
        titleBar.SetResourceReference(BackgroundProperty, "SidebarBackground");
        DockPanel.SetDock(titleBar, Dock.Top);
        frame.Children.Add(titleBar);
        var panel = new DockPanel { Margin = new(20, 14, 20, 17) };
        var footer = new WrapPanel { HorizontalAlignment = HorizontalAlignment.Right, Margin = new(0, 14, 0, 0) };
        DockPanel.SetDock(footer, Dock.Bottom);
        var close = ActionButton(accept is null ? T("Close") : cancel ?? T("Back"), ControlAppearance.Secondary, (_, _) => dialog.DialogResult = false);
        close.IsCancel = true;
        close.IsDefault = true;
        AutomationProperties.SetAutomationId(close, "DialogCancel");
        footer.Children.Add(close);
        if (alternative is not null)
        {
            alternative.Margin = new(8, 0, 0, 0);
            alternative.Click += (_, _) => dialog.DialogResult = false;
            footer.Children.Add(alternative);
        }
        if (accept is not null)
        {
            var primary = ActionButton(accept, ControlAppearance.Primary, (_, _) => dialog.DialogResult = true);
            primary.Margin = new(8, 0, 0, 0);
            AutomationProperties.SetAutomationId(primary, "ConfirmPrimary");
            footer.Children.Add(primary);
        }
        panel.Children.Add(footer);
        var header = Label(title, "SectionLabel");
        header.FontSize = 21;
        header.Margin = new(0, 0, 0, 10);
        DockPanel.SetDock(header, Dock.Top);
        panel.Children.Add(header);
        panel.Children.Add(new ScrollViewer
        {
            Content = new Border { Child = content, Padding = new(0, 0, 13, 0) },
            MaxHeight = Math.Max(170, dialog.MaxHeight - 158),
            HorizontalScrollBarVisibility = ScrollBarVisibility.Disabled,
            VerticalScrollBarVisibility = ScrollBarVisibility.Auto
        });
        frame.Children.Add(panel);
        dialog.Content = frame;
        dialog.Loaded += (_, _) =>
        {
            close.Focus();
            Enter(panel, 8, 195);
        };
        return dialog.ShowDialog() == true;
    }
}
