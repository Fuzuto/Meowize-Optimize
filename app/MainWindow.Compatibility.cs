using System.Runtime.InteropServices;
using System.Text.Json;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Media;
using static AioOptimize.Localizer;

namespace AioOptimize;

public partial class MainWindow
{
    private static readonly Dictionary<string, string?> CompatibilityDocs = new(StringComparer.Ordinal)
    {
        ["CompatNoNvidia"] = "https://www.nvidia.com/en-us/geforce/drivers/",
        ["CompatNvidia566"] = "https://www.nvidia.com/en-us/drivers/details/237719/",
        ["CompatNoWinget"] = "https://learn.microsoft.com/en-us/windows/package-manager/winget/",
        ["CompatNoDnsTools"] = "https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress",
        ["CompatNoAdapter"] = "https://support.microsoft.com/en-us/windows/experience/connectivity-networking/essential-network-settings-and-tasks-in-windows",
        ["CompatNoRiotCache"] = null,
        ["CompatNoBackup"] = "https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-export",
        ["CompatNoDefender"] = "https://learn.microsoft.com/en-us/powershell/module/defender/set-mppreference",
        ["CompatLegacyFirmware"] = "https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/boot-to-uefi-mode-or-legacy-bios-mode"
    };

    private Dictionary<string, string> _unavailable = new(StringComparer.Ordinal);

    [DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetFirmwareType(out uint firmwareType);

    private bool IsAvailable(string id) => !_unavailable.ContainsKey(id);

    private string? UnavailableReason(string id) => _unavailable.TryGetValue(id, out var key) ? T(key) : null;

    private bool ApplyAvailability(JsonElement data)
    {
        if (data.ValueKind != JsonValueKind.Object)
            return false;
        var blocked = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (var entry in data.EnumerateObject())
        {
            if (entry.Value.ValueKind == JsonValueKind.String && entry.Value.GetString() is { } reason &&
                CompatibilityDocs.ContainsKey(reason))
                blocked[entry.Name] = reason;
        }
        if (GetFirmwareType(out var firmwareType) && firmwareType == 1)
            blocked["btnBios"] = "CompatLegacyFirmware";

        if (blocked.Count == _unavailable.Count && blocked.All(entry => _unavailable.GetValueOrDefault(entry.Key) == entry.Value))
            return false;
        _unavailable = blocked;
        _selection.RemoveWhere(id => !IsAvailable(id));
        return true;
    }

    private void MarkUnavailable(Border row, StackPanel content, Operation operation, params Control[] controls)
    {
        if (!_unavailable.TryGetValue(operation.Id, out var key))
            return;
        var reason = T(key);
        if (!SystemParameters.HighContrast)
        {
            foreach (UIElement child in content.Children)
                child.Opacity = 0.64;
        }
        row.Background ??= Brushes.Transparent;
        row.ToolTip = reason;
        AutomationProperties.SetHelpText(row, reason);
        foreach (var control in controls)
        {
            control.IsEnabled = false;
            control.ToolTip = reason;
            ToolTipService.SetShowOnDisabled(control, true);
            AutomationProperties.SetHelpText(control, reason);
        }
        if (CompatibilityDocs[key] is { } url)
        {
            content.Children.Add(ReferenceLink(T("CompatibilityHelp"), url, "Docs", "MutedText",
                automationId: "Compatibility_" + operation.Id, contextualHelp: reason));
        }
    }
}
