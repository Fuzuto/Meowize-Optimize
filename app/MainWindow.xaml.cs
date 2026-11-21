using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Globalization;
using System.Security.Principal;
using System.Text;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Markup;
using Wpf.Ui.Controls;
using Button = Wpf.Ui.Controls.Button;
using TextBlock = System.Windows.Controls.TextBlock;
using static AioOptimize.Localizer;

namespace AioOptimize;

public partial class MainWindow : FluentWindow
{
    private sealed record Page(string Id, string Menu, string Title, string Description, string Symbol);
    private sealed record ActivityRow(string Time, string Text, string Level);
    private sealed record Provider(string Name, string Preferred, string Alternate, string Source);

    private static readonly Page[] Pages =
    [
        new("batch", "1-Click", "BatchTitle", "BatchDesc", "Flash24"),
        new("gaming", "GamingTitle", "GamingTitle", "GamingDesc", "Games24"),
        new("system", "SystemTitle", "SystemTitle", "SystemDesc", "Settings24"),
        new("network", "NetworkTitle", "NetworkTitle", "NetworkDesc", "Wifi124"),
        new("apps", "AppsTitle", "AppsTitle", "AppsDesc", "Apps24"),
        new("dashboard", "Diagnostics", "DiagnosticsTitle", "DiagnosticsDesc", "Pulse24"),
        new("repair", "RepairTitle", "RepairTitle", "RepairDesc", "Shield24")
    ];
    private static readonly (string Id, string Title, string Symbol)[] Groups =
    [
        ("core", "CoreGroup", "Shield24"),
        ("gaming", "GamingGroup", "Games24"),
        ("talon", "Talon Suite", "Settings24"),
        ("network", "NetworkGroup", "Wifi124")
    ];
    private static readonly Provider[] Providers =
    [
        new("Cloudflare", "1.1.1.1", "1.0.0.1", "https://developers.cloudflare.com/1.1.1.1/"),
        new("Google", "8.8.8.8", "8.8.4.4", "https://developers.google.com/speed/public-dns"),
        new("Quad9", "9.9.9.9", "149.112.112.112", "https://quad9.net/"),
        new("AdGuard", "94.140.14.14", "94.140.15.15", "https://adguard-dns.io/"),
        new("OpenDNS", "208.67.222.222", "208.67.220.220", "https://www.opendns.com/")
    ];

    private readonly Catalog _catalog;
    private readonly Preferences _preferences;
    private readonly HashSet<string> _selection;
    private readonly ObservableCollection<ActivityRow> _activity = [];
    private readonly Dictionary<string, CheckBox> _checks = new(StringComparer.Ordinal);
    private readonly Dictionary<string, TextBlock> _groupCounts = new(StringComparer.Ordinal);
    private readonly HashSet<string> _expandedGroups = new(StringComparer.Ordinal) { "core" };
    private readonly Dictionary<string, string> _machine = new(StringComparer.Ordinal);
    private readonly List<TextBlock> _navLabels = [];
    private readonly bool _preview;
    private readonly bool _admin;
    private string _page = "batch";
    private string _activePreset = "Default";
    private TextBlock? _selectionNumber;
    private ProgressBar? _selectionBar;
    private StackPanel? _presetButtons;
    private int _dns;
    private bool _hidePopups;
    private bool _busy;
    private bool _stopping;
    private bool _suppressCheckboxEvents;
    private bool? _customLogVisibility;
    private bool _logVisible;
    private bool _windowReady;
    private bool _hardwareReady;
    private bool _resettingFilters;
    private bool _light;
    private bool _handoffClosing;
    private bool _exitDialogOpen;

    internal MainWindow(bool preview, WindowState state, Preferences preferences)
    {
        _preview = preview;
        _preferences = preferences;
        _light = state.Light;
        _customLogVisibility = state.ShowLog;
        using var identity = WindowsIdentity.GetCurrent();
        _admin = new WindowsPrincipal(identity).IsInRole(WindowsBuiltInRole.Administrator);
        _catalog = Catalog.Load();
        var batchIds = _catalog.Batch.Select(item => item.Id).ToHashSet(StringComparer.Ordinal);
        _selection = state.Selection is null
            ? new(_catalog.Preset("Default"), StringComparer.Ordinal)
            : new(state.Selection.Where(batchIds.Contains), StringComparer.Ordinal);
        _activePreset = state.Selection is null ? "Default" : state.Preset ?? "";
        _dns = Math.Clamp(state.Dns, 0, Providers.Length - 1);
        _hidePopups = state.HidePopups;
        InitializeComponent();

        Activity.ItemsSource = _activity;
        AutoShutdown.IsChecked = state.AutoShutdown;
        AdminButton.IsEnabled = !preview && !_admin;
        var workArea = SystemParameters.WorkArea;
        Width = Math.Min(1280, workArea.Width - 12);
        Height = Math.Min(860, workArea.Height - 12);

        foreach (var page in Pages)
        {
            var label = new TextBlock { Text = T(page.Menu), Margin = new(10, 0, 0, 0),
                VerticalAlignment = VerticalAlignment.Center, TextTrimming = TextTrimming.CharacterEllipsis };
            _navLabels.Add(label);
            var row = new DockPanel { LastChildFill = true };
            var icon = Symbol(page.Symbol, 19);
            DockPanel.SetDock(icon, Dock.Left);
            row.Children.Add(icon);
            row.Children.Add(label);
            var item = new ListBoxItem { Content = row, Tag = page.Id, ToolTip = label.Text };
            AutomationProperties.SetName(item, label.Text);
            AutomationProperties.SetAutomationId(item, "Nav_" + page.Id);
            Navigation.Items.Add(item);
        }
        Navigation.SelectedIndex = Math.Max(0, Array.FindIndex(Pages, page => page.Id == state.Page));
        RefreshLocale();
        ApplyContrast();
        SourceInitialized += (_, _) => UpdateBackdrop();
        SystemParameters.StaticPropertyChanged += SystemSettingsChanged;
        Closed += (_, _) => SystemParameters.StaticPropertyChanged -= SystemSettingsChanged;
        Loaded += async (_, _) =>
        {
            _windowReady = true;
            if (_preview)
            {
                AddActivity(T("PreviewStarted"), "info");
            }
            AddActivity(T("CatalogLoaded"), "ok");
            await LoadHardwareAsync();
        };
        Activated += async (_, _) =>
        {
            if (_windowReady && !_busy)
                await LoadHardwareAsync();
        };
    }

    private void Navigate(object sender, SelectionChangedEventArgs e)
    {
        if (Navigation.SelectedItem is not ListBoxItem { Tag: string id })
            return;
        if (_page != id)
        {
            _resettingFilters = true;
            SearchTasks.Clear();
            SeverityFilter.SelectedIndex = 0;
            _resettingFilters = false;
            _page = id;
        }
        RenderPage();
        PageScroll.ScrollToHome();
        if (_windowReady && !_busy)
            _ = LoadHardwareAsync();
        if (_windowReady)
            Enter(PageBody, 7, 175);
    }

    private bool HasFilter => !string.IsNullOrWhiteSpace(SearchTasks.Text) || SeverityFilter.SelectedIndex > 0;

    private bool MatchesFilter(Operation operation)
    {
        var level = SeverityFilter.SelectedIndex;
        if (level > 0 && operation.Risk != (TaskRisk)level)
            return false;
        var query = SearchKey(SearchTasks.Text.Trim());
        if (query.Length == 0)
            return true;
        var content = SearchKey($"{operation.DisplayTitle} {operation.DisplayDescription} {operation.DisplayDetails}");
        return query.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries)
            .All(word => content.Contains(word, StringComparison.OrdinalIgnoreCase));
    }

    private static string SearchKey(string text) =>
        string.Concat(text.Normalize(NormalizationForm.FormD).Where(letter =>
            CharUnicodeInfo.GetUnicodeCategory(letter) != UnicodeCategory.NonSpacingMark))
            .Replace('đ', 'd').Replace('Đ', 'D');

    private void FilterChanged(object sender, RoutedEventArgs e)
    {
        if (!_windowReady || _resettingFilters)
            return;
        RenderPage();
        PageScroll.ScrollToHome();
    }

    private void ShowNoMatches()
    {
        var label = Label(T("NoMatches"), "BodyText");
        AutomationProperties.SetAutomationId(label, "NoMatchingTasks");
        PageBody.Children.Add(Card(label, new Thickness(15)));
    }

    private void RenderPage()
    {
        var page = Pages.First(item => item.Id == _page);
        PageTitle.Text = T(page.Title);
        PageDescription.Text = T(page.Description);
        PageBody.Children.Clear();
        _checks.Clear();
        _groupCounts.Clear();
        _riskCounts.Clear();
        _selectionNumber = null;
        _selectionBar = null;
        _presetButtons = null;
        if (_page == "batch")
            BuildBatch();
        else
            BuildTools();
        UpdateSelection();
        UpdateControls();
    }

    private void BuildBatch()
    {
        var overview = new Grid();
        overview.ColumnDefinitions.Add(new() { Width = new GridLength(130) });
        overview.ColumnDefinitions.Add(new());
        var summary = new StackPanel { VerticalAlignment = VerticalAlignment.Center };
        summary.Children.Add(Label(T("SelectedTasks"), "MutedText"));
        _selectionNumber = Label("", "BodyText");
        _selectionNumber.FontSize = 31;
        _selectionNumber.FontWeight = FontWeights.SemiBold;
        _selectionNumber.Margin = new(0, 2, 0, 5);
        summary.Children.Add(_selectionNumber);
        _selectionBar = new ProgressBar { Height = 4, Maximum = _catalog.Batch.Length, Margin = new(0, 3, 18, 2) };
        _selectionBar.SetResourceReference(ForegroundProperty, "Accent");
        AutomationProperties.SetName(_selectionBar, T("SelectedTasks"));
        summary.Children.Add(_selectionBar);
        overview.Children.Add(summary);
        var riskCounts = BuildRiskCounts();
        Grid.SetColumn(riskCounts, 1);
        overview.Children.Add(riskCounts);
        var summaryCard = Card(overview, new Thickness(14, 12, 13, 12), new Thickness(0, 0, 0, 12));
        summaryCard.SetResourceReference(Border.BackgroundProperty, "GlassHighlight");
        PageBody.Children.Add(summaryCard);

        var presetHeader = new DockPanel { LastChildFill = true };
        var quickSelect = new StackPanel { Orientation = Orientation.Horizontal };
        DockPanel.SetDock(quickSelect, Dock.Right);
        quickSelect.Children.Add(PresetButton(T("SelectAll"), "All", ControlAppearance.Transparent));
        quickSelect.Children.Add(PresetButton(T("Clear"), "None", ControlAppearance.Transparent));
        presetHeader.Children.Add(quickSelect);
        var presets = new StackPanel { Orientation = Orientation.Horizontal };
        foreach (var (title, id) in new[] { ("Gaming", "Gaming"), ("Talon", "Talon"), (T("Technician"), "Technician") })
            presets.Children.Add(PresetButton(title, id, ControlAppearance.Secondary));
        _presetButtons = presets;
        presetHeader.Children.Add(presets);
        PageBody.Children.Add(Card(presetHeader, new Thickness(7, 6, 2, 6), new Thickness(0, 0, 0, 12)));

        var matching = _catalog.Batch.Where(MatchesFilter).ToArray();
        var filtered = HasFilter;
        if (matching.Length == 0)
            ShowNoMatches();
        foreach (var group in Groups)
        {
            var operations = matching.Where(item => item.Page == group.Id).OrderBy(item => item.DisplayOrder).ToArray();
            if (operations.Length == 0)
                continue;
            var header = new DockPanel { Margin = new(1, 2, 7, 2) };
            var count = Label("", "MutedText");
            count.Margin = new(12, 0, 5, 0);
            DockPanel.SetDock(count, Dock.Right);
            header.Children.Add(count);
            _groupCounts[group.Id] = count;
            var marker = Symbol(group.Symbol, 18);
            marker.SetResourceReference(ForegroundProperty, "Accent");
            marker.Margin = new(1, 0, 9, 0);
            header.Children.Add(marker);
            header.Children.Add(Label(T(group.Title), "SectionLabel"));

            var rows = new StackPanel { Margin = new(2, 0, 2, 3) };
            foreach (var operation in operations)
                rows.Children.Add(BatchRow(operation));

            var expander = new Expander { Header = header, Content = rows, IsExpanded = filtered || _expandedGroups.Contains(group.Id) };
            AutomationProperties.SetName(expander, T(group.Title));
            AutomationProperties.SetAutomationId(expander, "Group_" + group.Id);
            expander.Expanded += (_, _) =>
            {
                if (!filtered)
                    _expandedGroups.Add(group.Id);
                if (_windowReady)
                    Enter(rows, 4, 145);
            };
            expander.Collapsed += (_, _) =>
            {
                if (!filtered)
                    _expandedGroups.Remove(group.Id);
            };
            PageBody.Children.Add(Card(expander, new Thickness(6), new Thickness(0, 0, 0, 8)));
        }
    }

    private UIElement BatchRow(Operation operation)
    {
        var title = LinkedTitle(operation, "BodyText");
        title.FontWeight = FontWeights.SemiBold;
        var detail = Label(operation.Mode == "settings" ? T("WindowsSettingsDetail") : operation.DisplayDescription, "MutedText");
        detail.Margin = new(0, 2, 0, 0);
        var text = new StackPanel { VerticalAlignment = VerticalAlignment.Center, Margin = new(0, 4, 0, 4) };
        text.Children.Add(title);
        text.Children.Add(detail);
        var badge = RiskBadge(operation.Risk, operation.DisplayRiskNote);
        badge.Margin = new(10, 0, 0, 0);
        DockPanel.SetDock(badge, Dock.Right);
        var content = new DockPanel { LastChildFill = true };
        content.Children.Add(badge);
        var info = TaskInfoButton(operation, batch: true);
        DockPanel.SetDock(info, Dock.Right);
        content.Children.Add(info);

        var box = new CheckBox
        {
            IsChecked = _selection.Contains(operation.Id),
            VerticalContentAlignment = VerticalAlignment.Center,
            HorizontalContentAlignment = HorizontalAlignment.Stretch,
            Margin = new(2, 0, 8, 0),
            Padding = new(3),
            MinHeight = 48,
            FocusVisualStyle = (Style)FindResource("UiFocusStyle")
        };
        AutomationProperties.SetAutomationId(box, "Batch_" + operation.Id);
        AutomationProperties.SetName(box, $"{operation.DisplayTitle} · {RiskLevels[operation.Risk].Label}");
        AutomationProperties.SetHelpText(box, RiskHelp(operation));
        box.Checked += (_, _) => ChangeSelection(operation.Id, true);
        box.Unchecked += (_, _) => ChangeSelection(operation.Id, false);
        _checks[operation.Id] = box;
        DockPanel.SetDock(box, Dock.Left);
        content.Children.Add(box);
        content.Children.Add(text);
        var row = new Border { Padding = new(9, 3, 6, 3), BorderThickness = new(0, 1, 0, 0), Child = content };
        row.SetResourceReference(Border.BorderBrushProperty, "Stroke");
        MarkUnavailable(row, text, operation, box);
        return row;
    }

    private Button PresetButton(string title, string id, ControlAppearance appearance)
    {
        var button = ActionButton(title, appearance, (_, _) =>
        {
            if (_busy)
                return;
            _selection.Clear();
            _selection.UnionWith(_catalog.Preset(id).Where(IsAvailable));
            _activePreset = id;
            _suppressCheckboxEvents = true;
            foreach (var field in _checks)
                field.Value.IsChecked = _selection.Contains(field.Key);
            _suppressCheckboxEvents = false;
            UpdateSelection();
        });
        button.Margin = new(0, 0, 7, 0);
        button.Tag = id;
        AutomationProperties.SetAutomationId(button, "Preset_" + id);
        return button;
    }

    private void ChangeSelection(string id, bool selected)
    {
        if (_suppressCheckboxEvents || !IsAvailable(id))
            return;
        if (selected)
            _selection.Add(id);
        else
            _selection.Remove(id);
        _activePreset = "";
        UpdateSelection();
    }

    private void UpdateSelection()
    {
        UpdateRunSummary();
        if (_selectionNumber is not null)
            _selectionNumber.Text = $"{_selection.Count} / {_catalog.Batch.Length}";
        if (_selectionBar is not null)
            SetProgressValue(_selectionBar, _selection.Count);
        foreach (var (risk, counter) in _riskCounts)
            counter.Text = _catalog.Batch.Count(item => item.Risk == risk && _selection.Contains(item.Id)).ToString();
        foreach (var group in _groupCounts)
        {
            var items = _catalog.Batch.Where(item => item.Page == group.Key).ToArray();
            group.Value.Text = $"{items.Count(item => _selection.Contains(item.Id))}/{items.Length}";
        }
        if (_presetButtons is not null)
        {
            foreach (var button in _presetButtons.Children.OfType<Button>())
                button.Appearance = Equals(_activePreset, button.Tag) ? ControlAppearance.Primary : ControlAppearance.Secondary;
        }
        RunButton.IsEnabled = !_busy && _shutdownDeadline is null && _selection.Count > 0;
    }

    private void UpdateRunSummary()
    {
        var hidden = _page == "batch" && HasFilter
            ? _catalog.Batch.Count(item => _selection.Contains(item.Id) && !MatchesFilter(item)) : 0;
        var summary = T("SelectionCount", _selection.Count);
        if (hidden > 0)
            summary += " · " + T("OutsideFilter", hidden);
        RunSummary.Text = _busy ? T("Working") : summary;
    }

    private void BuildTools()
    {
        if (_page == "dashboard")
            PageBody.Children.Add(BuildHardwareCard());
        var items = _catalog.Tools.Where(item => item.Page == _page && MatchesFilter(item)).ToArray();
        if (items.Length == 0)
        {
            ShowNoMatches();
            return;
        }
        if (items.SingleOrDefault(item => item.Id == "btnApplyDns") is { } dns)
            PageBody.Children.Add(BuildDnsCard(dns));
        var rows = new StackPanel();
        foreach (var operation in items.Where(item => item.Id != "btnApplyDns"))
        {
            var title = LinkedTitle(operation, "SectionLabel");
            var detail = Label(operation.Mode == "settings" ? T("WindowsSettingsDetail") : operation.DisplayDescription, "MutedText");
            detail.Margin = new(0, 3, 0, 0);
            var text = new StackPanel { VerticalAlignment = VerticalAlignment.Center, Margin = new(0, 0, 12, 0) };
            text.Children.Add(title);
            text.Children.Add(detail);
            var action = ActionButton(operation.Mode == "settings" ? T("OpenSettings") : OperationLabel(operation.Id),
                ControlAppearance.Secondary, async (_, _) => await HandleOperationAsync(operation));
            AutomationProperties.SetAutomationId(action, operation.Id);
            AutomationProperties.SetName(action, $"{action.Content} {operation.DisplayTitle} · {RiskLevels[operation.Risk].Label}");
            AutomationProperties.SetHelpText(action, RiskHelp(operation));
            var line = new DockPanel { MinHeight = 59, Margin = new(0, 0, 0, 1), LastChildFill = true };
            action.VerticalAlignment = VerticalAlignment.Center;
            DockPanel.SetDock(action, Dock.Right);
            line.Children.Add(action);
            var badge = RiskBadge(operation.Risk, operation.DisplayRiskNote);
            badge.Margin = new(0, 0, 9, 0);
            DockPanel.SetDock(badge, Dock.Right);
            line.Children.Add(badge);
            var info = TaskInfoButton(operation);
            DockPanel.SetDock(info, Dock.Right);
            line.Children.Add(info);
            line.Children.Add(text);
            var row = new Border { Padding = new(13, 4, 13, 4), Child = line };
            if (rows.Children.Count > 0)
            {
                row.BorderThickness = new(0, 1, 0, 0);
                row.SetResourceReference(Border.BorderBrushProperty, "Stroke");
            }
            MarkUnavailable(row, text, operation, action);
            rows.Children.Add(row);
        }
        if (rows.Children.Count > 0)
            PageBody.Children.Add(Card(rows, new Thickness(2)));
    }

    private Border BuildDnsCard(Operation operation)
    {
        var root = new StackPanel();
        var header = new DockPanel { LastChildFill = true };
        var badge = RiskBadge(operation.Risk, operation.DisplayRiskNote);
        DockPanel.SetDock(badge, Dock.Right);
        header.Children.Add(badge);
        var info = TaskInfoButton(operation);
        DockPanel.SetDock(info, Dock.Right);
        header.Children.Add(info);
        header.Children.Add(LinkedTitle(operation, "SectionLabel"));
        root.Children.Add(header);
        var panel = new DockPanel { LastChildFill = true, Margin = new(0, 10, 0, 0) };
        var choose = ActionButton(T("Apply"), ControlAppearance.Primary, async (_, _) => await HandleOperationAsync(operation));
        AutomationProperties.SetAutomationId(choose, operation.Id);
        AutomationProperties.SetName(choose, $"{T("ApplyDns")} · {RiskLevels[operation.Risk].Label}");
        AutomationProperties.SetHelpText(choose, RiskHelp(operation));
        choose.Margin = new(9, 0, 0, 0);
        DockPanel.SetDock(choose, Dock.Right);
        panel.Children.Add(choose);
        var combo = new ComboBox { MinHeight = 36, SelectedIndex = -1 };
        AutomationProperties.SetAutomationId(combo, "DnsProvider");
        AutomationProperties.SetName(combo, T("DnsProvider"));
        foreach (var provider in Providers)
            combo.Items.Add($"{provider.Name}  ·  {provider.Preferred} / {provider.Alternate}");
        combo.SelectedIndex = _dns;
        panel.Children.Add(combo);
        root.Children.Add(panel);
        var details = new Border { Margin = new(0, 8, 0, 0) };
        root.Children.Add(details);
        void ShowProviderReference()
        {
            var provider = Providers[_dns];
            details.Child = ReferenceLink(provider.Name, provider.Source, "Docs", "BodyText", automationId: "Source_DnsProvider");
        }
        combo.SelectionChanged += (_, _) =>
        {
            if (combo.SelectedIndex < 0)
                return;
            _dns = combo.SelectedIndex;
            ShowProviderReference();
        };
        ShowProviderReference();
        var card = Card(root, new Thickness(14), new Thickness(0, 0, 0, 12));
        MarkUnavailable(card, root, operation, choose, combo);
        return card;
    }

    private Border BuildHardwareCard()
    {
        var grid = new UniformGrid { Columns = 2 };
        foreach (var (key, label) in new[] { ("CPU", T("Cpu")), ("GPU", T("Gpu")), ("RAM", T("Ram")), ("OS", "Windows") })
        {
            var block = new StackPanel { Margin = new(0, 0, 10, 7) };
            block.Children.Add(Label(label, "MutedText"));
            block.Children.Add(Label(_machine.GetValueOrDefault(key, _hardwareReady ? T("NoData") : T("Reading")), "SectionLabel"));
            grid.Children.Add(block);
        }
        return Card(grid, new Thickness(14), new Thickness(0, 0, 0, 12));
    }

    private static string OperationLabel(string id) => id switch
    {
        "btnStartupMgr" or "btnOfficeTools" => T("Open"),
        "btnScanHardware" or "btnSmartCheck" or "btnTempCheck" or "btnLicenseCheck" or "btnRunHealthCheck" or "btnHardwareCompat" => T("Check"),
        "btnExportLog" or "btnExportHtml" or "btnDiagZip" => T("Export"),
        "btnCopyLog" => T("Copy"),
        "btnDDU" or "btnAppsDesktop" or "btnUnparkApp" => T("DownloadOpen"),
        "btnDriverNvidia581" or "btnDriverNvidia566" or "btnInstallCpp" or "btnPostInstall" => T("Install"),
        "btnCreatePoint" or "btnSystemSnapshot" => T("Create"),
        "btnBackupSys" => T("Backup"),
        "btnRestoreReg" => T("Restore"),
        _ => T("Run")
    };

    private void WindowSizeChanged(object sender, SizeChangedEventArgs e) => ApplyLayout();

    private void ApplyLayout()
    {
        if (NavigationWidth is null)
            return;
        var compact = (ActualWidth > 0 ? ActualWidth : Width) < 990;
        NavigationWidth.Width = new GridLength(compact ? 72 : 224);
        BrandLabel.Visibility = SupportLabel.Visibility = PreferencesLabel.Visibility =
            compact ? Visibility.Collapsed : Visibility.Visible;
        foreach (var label in _navLabels)
            label.Visibility = compact ? Visibility.Collapsed : Visibility.Visible;

        var wide = (ActualWidth > 0 ? ActualWidth : Width) >= 1130;
        _logVisible = _customLogVisibility ?? wide;
        LogWidth.Width = new GridLength(wide && _logVisible ? 314 : 0);
        LogPanel.Visibility = _logVisible ? Visibility.Visible : Visibility.Collapsed;
        Grid.SetColumn(LogPanel, wide ? 2 : 1);
        Grid.SetZIndex(LogPanel, wide ? 0 : 3);
        LogPanel.HorizontalAlignment = wide ? HorizontalAlignment.Stretch : HorizontalAlignment.Right;
        LogPanel.Width = wide ? double.NaN : Math.Min(340, Math.Max(280, Width - 90));
        ToggleLogButton.ToolTip = T(_logVisible ? "HideLogKey" : "ShowLogKey");
    }

    private void ToggleLog(object sender, RoutedEventArgs e) => FlipLog();

    private void FlipLog()
    {
        _customLogVisibility = !_logVisible;
        ApplyLayout();
        if (_logVisible)
            Enter(LogPanel, 8, 180, horizontal: true);
        else if (LogPanel.IsKeyboardFocusWithin)
            ToggleLogButton.Focus();
    }

    private void WindowKeyDown(object sender, KeyEventArgs e)
    {
        if (e.Key == Key.F && Keyboard.Modifiers == ModifierKeys.Control)
        {
            SearchTasks.Focus();
            SearchTasks.SelectAll();
            e.Handled = true;
        }
        else if (e.Key == Key.L && Keyboard.Modifiers == ModifierKeys.Control)
        {
            FlipLog();
            e.Handled = true;
        }
        else if (e.Key == Key.Escape && _logVisible && ActualWidth < 1130)
        {
            FlipLog();
            e.Handled = true;
        }
    }

    private void SystemSettingsChanged(object? sender, PropertyChangedEventArgs args)
    {
        if (args.PropertyName == nameof(SystemParameters.HighContrast))
            Dispatcher.InvokeAsync(() =>
            {
                ((App)Application.Current).SetTheme(_light);
                ApplyContrast();
                UpdateBackdrop();
            });
    }

    private void ApplyContrast()
    {
        Resources.Clear();
        if (!SystemParameters.HighContrast)
            return;
        foreach (var name in new[] { "AppBackground", "SidebarBackground", "Surface", "SurfaceRaised", "AccentSurface",
            "GlassSurface", "GlassHighlight", "GlassInset", "RiskSafeFill", "RiskCautionFill", "RiskWarningFill" })
            Resources[name] = SystemColors.WindowBrush;
        foreach (var name in new[] { "TextMain", "TextMuted", "Stroke", "GlassRim", "Warning", "Error",
            "RiskSafe", "RiskCaution", "RiskWarning" })
            Resources[name] = SystemColors.WindowTextBrush;
        Resources["Accent"] = SystemColors.HighlightBrush;
        Resources["AccentText"] = SystemColors.HighlightTextBrush;
        Resources["AccentButtonBackground"] = SystemColors.HighlightBrush;
        Resources["AccentButtonBackgroundPointerOver"] = SystemColors.HighlightBrush;
        Resources["AccentButtonBackgroundPressed"] = SystemColors.HighlightBrush;
        Resources["AccentButtonForeground"] = SystemColors.HighlightTextBrush;
        Resources["AccentButtonForegroundPointerOver"] = SystemColors.HighlightTextBrush;
    }

    private static bool MotionAllowed => SystemParameters.ClientAreaAnimation && !SystemParameters.HighContrast;

    private static void Enter(FrameworkElement element, double offset, int duration, bool horizontal = false)
    {
        if (!MotionAllowed)
            return;
        var translation = new TranslateTransform();
        element.RenderTransform = translation;
        var ease = new CubicEase { EasingMode = EasingMode.EaseOut };
        element.BeginAnimation(OpacityProperty, new DoubleAnimation(0.55, 1, TimeSpan.FromMilliseconds(duration)) { EasingFunction = ease });
        translation.BeginAnimation(horizontal ? TranslateTransform.XProperty : TranslateTransform.YProperty,
            new DoubleAnimation(offset, 0, TimeSpan.FromMilliseconds(duration)) { EasingFunction = ease });
    }

    private static void SetProgressValue(ProgressBar bar, double value)
    {
        var previous = bar.Value;
        bar.BeginAnimation(RangeBase.ValueProperty, null);
        bar.Value = value;
        if (MotionAllowed && Math.Abs(previous - value) > 0.1)
            bar.BeginAnimation(RangeBase.ValueProperty, new DoubleAnimation(previous, value, TimeSpan.FromMilliseconds(140))
            {
                FillBehavior = FillBehavior.Stop,
                EasingFunction = new QuadraticEase { EasingMode = EasingMode.EaseOut }
            });
    }

    private static TextBlock Label(string text, string style)
    {
        var label = new TextBlock { Text = text };
        label.SetResourceReference(StyleProperty, style);
        return label;
    }

    private static SymbolIcon Symbol(string name, double size) => new()
    {
        Symbol = Enum.TryParse<SymbolRegular>(name, out var symbol) ? symbol : SymbolRegular.Fluent24,
        FontSize = size,
        VerticalAlignment = VerticalAlignment.Center
    };

    private static Border Card(UIElement content, Thickness padding, Thickness margin = default)
    {
        var surface = new Border { Padding = padding, Margin = margin, Child = content };
        surface.SetResourceReference(StyleProperty, "CardSurface");
        return surface;
    }

    private static Button ActionButton(string title, ControlAppearance appearance, RoutedEventHandler click)
    {
        var button = new Button { Content = title, Appearance = appearance };
        button.SetResourceReference(StyleProperty, "ActionButton");
        button.Click += click;
        return button;
    }
}
