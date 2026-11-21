using System.IO;
using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace AioOptimize;

[JsonConverter(typeof(JsonStringEnumConverter<TaskRisk>))]
internal enum TaskRisk { Unrated, Safe, Caution, Warning }

internal sealed record Operation(
    string Id, string Title, string Description, string Page, string Category, string Mode,
    string Impact, bool Admin, bool Restart, bool Selected, int SourceLine, int DisplayOrder, TaskRisk Risk, string? RiskNote)
{
    internal string DisplayTitle => Localizer.IsVietnamese ? Title : Localizer.TaskText(Localizer.CopyFor(Id).Title);
    internal string DisplayDescription => Localizer.IsVietnamese ? Description : Localizer.TaskText(Localizer.CopyFor(Id).Description);
    internal string DisplayDetails => Localizer.DetailsFor(Id);
    internal string? DisplayRiskNote => Localizer.IsVietnamese ? RiskNote :
        Localizer.CopyFor(Id).RiskNote is { } note ? Localizer.TaskText(note) : null;
    internal TaskCopy Reference => Localizer.CopyFor(Id);
}

internal sealed record Catalog(Operation[] Batch, Operation[] Tools)
{
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

    internal static Catalog Load()
    {
        using Stream stream = Assembly.GetExecutingAssembly().GetManifestResourceStream("AioOptimize.Catalog.json")
            ?? throw new InvalidDataException(Localizer.T("CatalogReadError"));
        var catalog = JsonSerializer.Deserialize<Catalog>(stream, JsonOptions)
            ?? throw new InvalidDataException(Localizer.T("CatalogReadError"));
        var entries = catalog.Batch.Concat(catalog.Tools).ToArray();
        if (catalog.Batch.Length != 51 || catalog.Tools.Length != 66 ||
            entries.Select(entry => entry.Id).Distinct(StringComparer.Ordinal).Count() != entries.Length ||
            entries.Any(entry => !Localizer.HasDetails(entry.Id) ||
                entry.Mode is not ("legacy" or "worker" or "desktop" or "settings") ||
                entry.Risk is not (TaskRisk.Safe or TaskRisk.Caution or TaskRisk.Warning) ||
                entry.Risk == TaskRisk.Warning && string.IsNullOrWhiteSpace(entry.RiskNote)))
        {
            throw new InvalidDataException(Localizer.T("CatalogReadError"));
        }
        return catalog;
    }

    internal string[] Preset(string name) => Batch
        .Where(item => name switch
        {
            "All" => true,
            "Gaming" => item.Category is "Safe_Core" or "Gaming" or "Network" or "Clean",
            "Talon" => item.Category is "Safe_Core" or "Talon" or "Clean" || item.Id is "Hibernate" or "WinUpdate",
            "Technician" => item.Id is not ("Defender" or "SfcDism" or "WingetApps"),
            "Default" => item.Selected,
            _ => false
        })
        .Select(item => item.Id)
        .ToArray();
}

internal sealed record WindowState(string Page = "batch", string[]? Selection = null, int Dns = 0, bool AutoShutdown = false,
    bool HidePopups = true, bool Light = false, string? Language = null, string? Preset = null, bool? ShowLog = null)
{
    internal string Encode() => Convert.ToBase64String(JsonSerializer.SerializeToUtf8Bytes(this));

    internal static WindowState? Read(string? encoded)
    {
        if (string.IsNullOrEmpty(encoded) || encoded.Length > 6000)
            return null;
        try
        {
            return JsonSerializer.Deserialize<WindowState>(Convert.FromBase64String(encoded));
        }
        catch (Exception exception) when (exception is FormatException or JsonException)
        {
            return null;
        }
    }
}
