using System.ComponentModel;
using System.IO;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Markup;
using System.Windows.Media;
using Microsoft.Win32;
using Wpf.Ui.Controls;
using TextBlock = System.Windows.Controls.TextBlock;
using static AioOptimize.Localizer;

namespace AioOptimize;

public partial class MainWindow
{
    private void RefreshLocale()
    {
        Language = XmlLanguage.GetLanguage(Code);
        for (var index = 0; index < Pages.Length; index++)
        {
            var label = T(Pages[index].Menu);
            _navLabels[index].Text = label;
            var item = (ListBoxItem)Navigation.Items[index];
            item.ToolTip = label;
            AutomationProperties.SetName(item, label);
        }
        ModeLabel.Text = T(_preview ? "PreviewMode" : "Session");
        AdminLabel.Text = T(_preview ? "Preview" : _admin ? "Admin" : "AdminShort");
        AdminButton.ToolTip = T(_admin ? "AdminEnabled" : "OpenAdmin");
        AutoShutdownReference.Child = ReferenceLink(T("Docs"),
            "https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/shutdown", "Docs", "MutedText",
            automationId: "Source_AutoShutdown");
        if (!_busy && _shutdownDeadline is null)
            StatusLabel.Text = T("Ready");
        if (_shutdownCancel is not null)
            _shutdownCancel.Content = T("CancelShutdown");
        UpdateThemeButton();
        ApplyLayout();
        RenderPage();
    }

    private void ToggleTheme(object sender, RoutedEventArgs e)
    {
        _light = !_light;
        ((App)Application.Current).SetTheme(_light);
        ApplyContrast();
        UpdateBackdrop();
        UpdateThemeButton();
        Enter(Shell, 0, 165);
    }

    private void UpdateThemeButton()
    {
        ThemeIcon.Symbol = _light ? SymbolRegular.WeatherMoon24 : SymbolRegular.WeatherSunny24;
        var label = T(_light ? "DarkTheme" : "LightTheme");
        ThemeToggle.ToolTip = label;
        AutomationProperties.SetName(ThemeToggle, label);
    }

    private void UpdateBackdrop()
    {
        var transparent = !SystemParameters.HighContrast &&
            OperatingSystem.IsWindowsVersionAtLeast(10, 0, 22621) &&
            WindowBackdrop.IsSupported(WindowBackdropType.Acrylic) &&
            Registry.GetValue(@"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize",
                "EnableTransparency", 1) is not 0;
        WindowBackdropType = transparent ? WindowBackdropType.Acrylic : WindowBackdropType.None;
        if (transparent)
            transparent = WindowBackdrop.ApplyBackdrop(this, WindowBackdropType.Acrylic);
        if (transparent)
        {
            Background = Brushes.Transparent;
            var tint = ((Brush)FindResource("AppBackground")).Clone();
            tint.Opacity = _light ? 0.68 : 0.72;
            Shell.Background = tint;
        }
        else
        {
            SetResourceReference(BackgroundProperty, "AppBackground");
            Shell.SetResourceReference(Panel.BackgroundProperty, "AppBackground");
        }
    }

    private WindowState CaptureState() => new(_page, _selection.ToArray(), _dns, AutoShutdown.IsChecked == true, _hidePopups,
        _light, Code, _activePreset, _customLogVisibility);

    private bool SaveBeforeClose()
    {
        var profile = _preferences.Value;
        var policy = profile.Exit;
        var save = policy == ExitPreference.Save;
        var remember = false;
        if (policy == ExitPreference.Ask)
        {
            var body = new StackPanel();
            body.Children.Add(Label(T("SaveExitBody"), "BodyText"));
            var check = new CheckBox { Content = T("DontAsk"), Margin = new(0, 12, 0, 2) };
            AutomationProperties.SetAutomationId(check, "ExitRemember");
            body.Children.Add(check);
            var discarded = false;
            var discard = ActionButton(T("DiscardClose"), ControlAppearance.Secondary, (_, _) => discarded = true);
            AutomationProperties.SetAutomationId(discard, "ExitDiscard");
            save = Dialog(T("SaveExitTitle"), body, T("SaveClose"), T("Cancel"), discard);
            if (!save && !discarded)
                return false;
            remember = check.IsChecked == true;
        }

        if (!save && !remember)
            return true;
        return TrySaveProfile(profile with
        {
            Language = Code,
            Exit = remember ? (save ? ExitPreference.Save : ExitPreference.Discard) : profile.Exit,
            Window = save ? CaptureState() : profile.Window
        });
    }

    private bool TrySaveProfile(Profile profile)
    {
        try
        {
            _preferences.Save(profile);
            return true;
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException)
        {
            Dialog(T("Error"), Label(T("SettingsSaveError", exception.Message), "BodyText"));
            return false;
        }
    }

    private TextBlock LinkedTitle(Operation operation, string style, string prefix = "", bool inReview = false) =>
        ReferenceLink(operation.DisplayTitle, operation.Reference.Source, operation.Reference.Kind, style, prefix,
            (inReview ? "ReviewSource_" : "Source_") + operation.Id, UnavailableReason(operation.Id));

    private TextBlock ReferenceLink(string name, string url, string kind, string style, string prefix = "",
        string? automationId = null, string? contextualHelp = null)
    {
        var heading = Label("", style);
        if (prefix.Length > 0)
            heading.Inlines.Add(new Run(prefix));
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || uri.Scheme != Uri.UriSchemeHttps)
        {
            heading.Inlines.Add(new Run(name));
            return heading;
        }
        var help = $"{T(kind)} · {uri.Host}";
        if (contextualHelp is not null)
            help = $"{contextualHelp}\n{help}";
        var link = new Hyperlink(new Run(name + " ↗"))
        {
            NavigateUri = uri, ToolTip = help, Focusable = true
        };
        link.SetResourceReference(ForegroundProperty, "Accent");
        AutomationProperties.SetName(link, T("OpenReference", name));
        AutomationProperties.SetHelpText(link, help);
        if (automationId is not null)
            AutomationProperties.SetAutomationId(link, automationId);
        link.RequestNavigate += (_, e) =>
        {
            e.Handled = true;
            try { OpenExternal(uri.AbsoluteUri); }
            catch (Win32Exception exception) { AddActivity(T("ReferenceError", exception.Message), "warn"); }
        };
        heading.Inlines.Add(link);
        return heading;
    }
}
