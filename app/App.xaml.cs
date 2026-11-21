using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using Wpf.Ui.Appearance;
using Wpf.Ui.Controls;
using Button = Wpf.Ui.Controls.Button;
using Image = System.Windows.Controls.Image;
using TextBlock = System.Windows.Controls.TextBlock;
using static AioOptimize.Localizer;

namespace AioOptimize;

internal static class ProjectIdentity
{
    internal const string Maintainer = "Lê Hiếu Trung (FuryZ)";
    internal const string GitHubUrl = "https://github.com/Fuzuto";
}

public partial class App : Application
{
    private ResourceDictionary? _lightPalette;

    protected override async void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        try
        {
            var preview = e.Args.Contains("--preview", StringComparer.Ordinal);
            var resume = e.Args.FirstOrDefault(argument => argument.StartsWith("--resume=", StringComparison.Ordinal));
            var preferences = new Preferences(preview);
            var resumedState = WindowState.Read(resume?[9..]);
            var state = resumedState ?? preferences.Value.Window ?? new();
            var review = resumedState is null ? null :
                e.Args.FirstOrDefault(argument => argument.StartsWith("--review=", StringComparison.Ordinal))?[9..];
            SetTheme(state.Light);
            var storedLanguage = Supports(state.Language) && resume is not null ? state.Language : preferences.Value.Language;
            if (!Supports(storedLanguage))
            {
                var firstLanguage = ChooseLanguage();
                if (firstLanguage is null)
                {
                    Shutdown();
                    return;
                }
                Use(firstLanguage);
                try { preferences.Save(preferences.Value with { Language = firstLanguage }); }
                catch (Exception exception) when (exception is System.IO.IOException or UnauthorizedAccessException)
                {
                    System.Windows.MessageBox.Show(T("SettingsSaveError", exception.Message), "Meowize");
                }
            }
            else
            {
                Use(storedLanguage!);
            }

            var window = new MainWindow(preview, state, preferences, review);
            MainWindow = window;
            if (!preview && !await KeyGate.AuthorizeAsync(window))
            {
                Shutdown();
                return;
            }
            ShutdownMode = ShutdownMode.OnMainWindowClose;
            window.Show();
        }
        catch (Exception exception)
        {
            System.Windows.MessageBox.Show(exception.Message, "Meowize", System.Windows.MessageBoxButton.OK, MessageBoxImage.Error);
            Shutdown(1);
        }
    }

    internal void SetTheme(bool light)
    {
        if (light && _lightPalette is null)
        {
            _lightPalette = new ResourceDictionary { Source = new Uri("pack://application:,,,/Theme.Light.xaml") };
            Resources.MergedDictionaries.Add(_lightPalette);
        }
        else if (!light && _lightPalette is not null)
        {
            Resources.MergedDictionaries.Remove(_lightPalette);
            _lightPalette = null;
        }
        if (SystemParameters.HighContrast)
        {
            ApplicationThemeManager.ApplySystemTheme();
            return;
        }
        ApplicationThemeManager.Apply(light ? ApplicationTheme.Light : ApplicationTheme.Dark, WindowBackdropType.None, false);
        var primary = light ? Color.FromRgb(103, 67, 46) : Color.FromRgb(241, 209, 175);
        ApplicationAccentColorManager.Apply(primary, primary,
            light ? Color.FromRgb(119, 80, 58) : Color.FromRgb(249, 222, 194),
            light ? Color.FromRgb(83, 55, 40) : Color.FromRgb(223, 180, 142));
    }

    internal static ComboBox LanguagePicker()
    {
        var options = new Style(typeof(ComboBoxItem), Current.TryFindResource(typeof(ComboBoxItem)) as Style);
        options.Setters.Add(new Setter(AutomationProperties.NameProperty, new Binding(nameof(AppLanguage.DisplayName))));
        options.Setters.Add(new Setter(AutomationProperties.AutomationIdProperty,
            new Binding(nameof(AppLanguage.Code)) { StringFormat = "Region_{0}" }));
        var picker = new ComboBox { ItemsSource = Languages, ItemTemplate = (DataTemplate)Current.FindResource("RegionRow"),
            ItemContainerStyle = options, SelectedValuePath = nameof(AppLanguage.Code), SelectedValue = Code, MinHeight = 36 };
        AutomationProperties.SetName(picker, T("Language"));
        AutomationProperties.SetAutomationId(picker, "LanguagePicker");
        return picker;
    }

    private static string? ChooseLanguage()
    {
        var window = new FluentWindow
        {
            Title = T("ChooseLanguage"), Width = 450, SizeToContent = SizeToContent.Height,
            ResizeMode = ResizeMode.NoResize, WindowStartupLocation = WindowStartupLocation.CenterScreen,
            ExtendsContentIntoTitleBar = true, UseLayoutRounding = true, FontFamily = new FontFamily("Segoe UI")
        };
        window.SetResourceReference(Window.BackgroundProperty, "Surface");
        window.SetResourceReference(Window.ForegroundProperty, "TextMain");
        window.Icon = new BitmapImage(new Uri("pack://application:,,,/Assets/Meowize.ico"));
        var frame = new DockPanel();
        frame.SetResourceReference(Panel.BackgroundProperty, "Surface");
        var titleBar = new TitleBar { Title = "Meowize", Height = 40, ShowMinimize = false, ShowMaximize = false };
        DockPanel.SetDock(titleBar, Dock.Top);
        frame.Children.Add(titleBar);
        var body = new StackPanel { Margin = new(24, 16, 24, 22) };
        var mark = new Border { Width = 56, Height = 56, CornerRadius = new(16), HorizontalAlignment = HorizontalAlignment.Left,
            Margin = new(0, 0, 0, 14), Padding = new(5), Background = new SolidColorBrush(Color.FromRgb(241, 209, 175)) };
        var logo = new Image { Source = new BitmapImage(new Uri("pack://application:,,,/Assets/Meowize.png")) };
        RenderOptions.SetBitmapScalingMode(logo, BitmapScalingMode.HighQuality);
        mark.Child = logo;
        body.Children.Add(mark);
        body.Children.Add(new TextBlock { Text = T("ChooseLanguage"), FontSize = 25, FontWeight = FontWeights.SemiBold,
            TextWrapping = TextWrapping.Wrap });
        var picker = new ListBox { Background = Brushes.Transparent, BorderThickness = new(0), Margin = new(0, 11, 0, 12),
            ItemContainerStyle = (Style)Current.FindResource("NavigationItem") };
        AutomationProperties.SetName(picker, T("Language"));
        AutomationProperties.SetAutomationId(picker, "FirstRunRegions");
        var template = (DataTemplate)Current.FindResource("RegionRow");
        foreach (var language in Languages)
        {
            var item = new ListBoxItem { Content = language, ContentTemplate = template };
            AutomationProperties.SetName(item, language.DisplayName);
            AutomationProperties.SetAutomationId(item, "Region_" + language.Code);
            picker.Items.Add(item);
        }
        picker.SelectedIndex = 0;
        body.Children.Add(picker);
        var next = new Button { Content = T("Continue"), IsDefault = true, Appearance = ControlAppearance.Primary,
            Padding = new(16, 7, 16, 7), CornerRadius = new(17), HorizontalAlignment = HorizontalAlignment.Right };
        AutomationProperties.SetAutomationId(next, "LanguageContinue");
        next.Click += (_, _) => window.DialogResult = true;
        body.Children.Add(next);
        frame.Children.Add(body);
        window.Content = frame;
        window.Loaded += (_, _) => picker.Focus();
        return window.ShowDialog() == true ? ((picker.SelectedItem as ListBoxItem)?.Content as AppLanguage)?.Code ?? "en-US" : null;
    }
}
