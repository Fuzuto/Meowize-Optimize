using System.IO;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Win32;
using Wpf.Ui.Controls;
using Button = Wpf.Ui.Controls.Button;
using PasswordBox = System.Windows.Controls.PasswordBox;
using TextBlock = System.Windows.Controls.TextBlock;
using TextBox = System.Windows.Controls.TextBox;
using static AioOptimize.Localizer;

namespace AioOptimize;

internal static class KeyGate
{
    private sealed record GateFile(string? OnlineUrl, Verifier Offline);
    private sealed record Verifier(string Salt, string Hash)
    {
        internal bool IsValid()
        {
            try
            {
                return Convert.FromBase64String(Salt).Length is >= 16 and <= 64 && Convert.FromBase64String(Hash).Length == 32;
            }
            catch (Exception exception) when (exception is ArgumentNullException or FormatException)
            {
                return false;
            }
        }

        internal bool Check(string password) => CryptographicOperations.FixedTimeEquals(
            Rfc2898DeriveBytes.Pbkdf2(password.Trim(), Convert.FromBase64String(Salt), 210000, HashAlgorithmName.SHA256, 32),
            Convert.FromBase64String(Hash));
    }

    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };
    private const string RegistryPath = @"Software\AioOptimize\KeyGate";

    internal static async Task<bool> AuthorizeAsync(Window window)
    {
        var path = Path.Combine(AppContext.BaseDirectory, "keygate.json");
        if (!File.Exists(path))
            return true;
        if (new FileInfo(path).Length > 8192)
            throw new InvalidDataException(T("KeyGateTooLarge"));
        var config = JsonSerializer.Deserialize<GateFile>(await File.ReadAllTextAsync(path), JsonOptions);
        if (config?.Offline is null || !config.Offline.IsValid())
            throw new InvalidDataException(T("KeyGateInvalid"));

        var online = await FetchAsync(config.OnlineUrl);
        var key = online ?? config.Offline;
        var token = SHA256.HashData(JsonSerializer.SerializeToUtf8Bytes(new { config.OnlineUrl, Active = key, config.Offline }));
        if (Remembers(token))
            return true;

        var dialog = new Window
        {
            Title = T("KeyGate"), Width = 405, SizeToContent = SizeToContent.Height,
            WindowStartupLocation = WindowStartupLocation.CenterScreen, ResizeMode = ResizeMode.NoResize,
            FontFamily = window.FontFamily
        };
        dialog.SetResourceReference(Window.BackgroundProperty, "Surface");
        dialog.SetResourceReference(Window.ForegroundProperty, "TextMain");
        var stack = new StackPanel { Margin = new(22) };
        var title = new TextBlock { Text = T("KeyGate"), FontSize = 24, FontWeight = FontWeights.SemiBold };
        stack.Children.Add(title);
        var state = new TextBlock { Text = T(online is null ? "KeyOffline" : "KeyOnline"), Margin = new(0, 4, 0, 12) };
        state.SetResourceReference(TextBlock.ForegroundProperty, "TextMuted");
        stack.Children.Add(state);
        var secret = new PasswordBox { MaxLength = 512, MinHeight = 34 };
        var visible = new TextBox { MaxLength = 512, MinHeight = 34, Visibility = Visibility.Collapsed };
        var show = new CheckBox { Content = T("ShowPassword"), Margin = new(0, 7, 0, 5) };
        var remember = new CheckBox { Content = T("RememberDevice"), IsChecked = true };
        var passwordLabel = new Label { Content = T("Password"), Target = secret };
        stack.Children.Add(passwordLabel);
        stack.Children.Add(secret);
        stack.Children.Add(visible);
        stack.Children.Add(show);
        stack.Children.Add(remember);
        var error = new TextBlock { Margin = new(0, 9, 0, 0), TextWrapping = TextWrapping.Wrap };
        error.SetResourceReference(TextBlock.ForegroundProperty, "Error");
        stack.Children.Add(error);
        var footer = new WrapPanel { HorizontalAlignment = HorizontalAlignment.Right, Margin = new(0, 14, 0, 0) };
        var close = new Button { Content = T("Close"), IsCancel = true, Margin = new(5, 0, 0, 0) };
        var submit = new Button { Content = T("Verify"), IsDefault = true, Appearance = ControlAppearance.Primary, Margin = new(5, 0, 0, 0) };
        var contact = new Button { Content = T("CopyLink"), ToolTip = ProjectIdentity.GitHubUrl,
            HorizontalAlignment = HorizontalAlignment.Left, Margin = new(0, 9, 0, 0) };
        contact.Click += (_, _) =>
        {
            try { Clipboard.SetText(ProjectIdentity.GitHubUrl); }
            catch (System.Runtime.InteropServices.ExternalException) { error.Text = T("ClipboardBusy"); }
        };
        stack.Children.Add(contact);
        footer.Children.Add(close);
        footer.Children.Add(submit);
        stack.Children.Add(footer);
        dialog.Content = stack;
        dialog.Loaded += (_, _) => secret.Focus();
        show.Checked += (_, _) =>
        {
            visible.Text = secret.Password;
            secret.Clear();
            secret.Visibility = Visibility.Collapsed;
            visible.Visibility = Visibility.Visible;
            passwordLabel.Target = visible;
            visible.Focus();
        };
        show.Unchecked += (_, _) =>
        {
            secret.Password = visible.Text;
            visible.Clear();
            visible.Visibility = Visibility.Collapsed;
            secret.Visibility = Visibility.Visible;
            passwordLabel.Target = secret;
            secret.Focus();
        };

        var attempts = 0;
        submit.Click += async (_, _) =>
        {
            var password = show.IsChecked == true ? visible.Text : secret.Password;
            if (string.IsNullOrWhiteSpace(password))
            {
                error.Text = T("EnterPassword");
                return;
            }
            submit.IsEnabled = false;
            var accepted = await Task.Run(() => key.Check(password) || (!ReferenceEquals(key, config.Offline) && config.Offline.Check(password)));
            if (!dialog.IsVisible)
                return;
            if (accepted)
            {
                if (remember.IsChecked == true)
                    Remember(token);
                dialog.DialogResult = true;
                return;
            }
            attempts++;
            error.Text = T("PasswordAttempts", attempts);
            if (attempts >= 5)
            {
                System.Windows.MessageBox.Show(dialog, T("OutOfAttempts"), dialog.Title);
                dialog.DialogResult = false;
                return;
            }
            submit.IsEnabled = true;
            if (visible.IsVisible) { visible.Focus(); visible.SelectAll(); }
            else { secret.Focus(); secret.SelectAll(); }
        };
        return dialog.ShowDialog() == true;
    }

    private static async Task<Verifier?> FetchAsync(string? url)
    {
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || uri.Scheme != Uri.UriSchemeHttps ||
            !uri.IsDefaultPort || uri.UserInfo.Length != 0)
            return null;
        using var client = new HttpClient(new HttpClientHandler { AllowAutoRedirect = false })
        {
            Timeout = TimeSpan.FromSeconds(3.5),
            MaxResponseContentBufferSize = 8192
        };
        try
        {
            var verifier = JsonSerializer.Deserialize<Verifier>(await client.GetStringAsync(uri), JsonOptions);
            return verifier?.IsValid() == true ? verifier : null;
        }
        catch (Exception exception) when (exception is HttpRequestException or OperationCanceledException or JsonException)
        {
            return null;
        }
    }

    private static bool Remembers(byte[] token)
    {
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(RegistryPath);
            return key?.GetValue("Token") is byte[] bytes && CryptographicOperations.FixedTimeEquals(
                ProtectedData.Unprotect(bytes, null, DataProtectionScope.CurrentUser), token);
        }
        catch (Exception exception) when (exception is CryptographicException or IOException or UnauthorizedAccessException)
        {
            return false;
        }
    }

    private static void Remember(byte[] token)
    {
        try
        {
            using var key = Registry.CurrentUser.CreateSubKey(RegistryPath);
            key?.SetValue("Token", ProtectedData.Protect(token, null, DataProtectionScope.CurrentUser), RegistryValueKind.Binary);
        }
        catch (Exception exception) when (exception is CryptographicException or IOException or UnauthorizedAccessException) { }
    }
}
