using System.ComponentModel;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text.Json;
using System.Windows.Data;
using System.Windows.Markup;

namespace AioOptimize;

internal sealed record AppLanguage(string Code, string NativeName, string EnglishName, string Country)
{
    public string DisplayName => NativeName == EnglishName ? NativeName : $"{NativeName}  ·  {EnglishName}";
    public string Flag => $"pack://application:,,,/Assets/Flags/{Country}.png";
}

public sealed class Localizer : INotifyPropertyChanged
{
    internal static readonly AppLanguage[] Languages =
    [
        new("en-US", "English", "English", "us"),
        new("ja-JP", "日本語", "Japanese", "jp"),
        new("ko-KR", "한국어", "Korean", "kr"),
        new("vi-VN", "Tiếng Việt", "Vietnamese", "vn"),
        new("zh-CN", "简体中文", "Simplified Chinese", "cn")
    ];

    private readonly Dictionary<string, string[]> _ui = Read<Dictionary<string, string[]>>("Ui");
    private readonly Dictionary<string, TaskCopy> _tasks = Read<Dictionary<string, TaskCopy>>("Tasks");
    private int _language;
    internal static Localizer Current { get; } = new();
    internal static string Code => Languages[Current._language].Code;
    internal static bool Supports(string? code) => Languages.Any(language => language.Code == code);
    internal static bool IsVietnamese => Code == "vi-VN";
    public event PropertyChangedEventHandler? PropertyChanged;
    public string this[string key] => _ui.TryGetValue(key, out var values) ? values[_language] : key;

    internal static void Use(string code)
    {
        var index = Math.Max(0, Array.FindIndex(Languages, language => language.Code == code));
        CultureInfo.CurrentUICulture = CultureInfo.GetCultureInfo(Languages[index].Code);
        if (Current._language == index)
            return;
        Current._language = index;
        Current.PropertyChanged?.Invoke(Current, new PropertyChangedEventArgs("Item[]"));
    }

    internal static string T(string key, params object?[] args)
    {
        var template = Current[key];
        return args.Length == 0 ? template : string.Format(CultureInfo.GetCultureInfo(Code), template, args);
    }

    internal static TaskCopy CopyFor(string id) => Current._tasks[id];

    internal static string TaskText(string[] values) =>
        values[Current._language == 4 ? 3 : Current._language];

    internal static TData Read<TData>(string file)
    {
        using var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream($"AioOptimize.Localization.{file}.json")
            ?? throw new InvalidDataException($"Missing localization resource {file}.");
        return JsonSerializer.Deserialize<TData>(stream, new JsonSerializerOptions { PropertyNameCaseInsensitive = true })
            ?? throw new InvalidDataException($"Invalid localization resource {file}.");
    }
}

internal sealed record TaskCopy(string[] Title, string[] Description, string[]? RiskNote, string Kind, string Source);

[MarkupExtensionReturnType(typeof(object))]
public sealed class TrExtension(string key) : MarkupExtension
{
    public override object ProvideValue(IServiceProvider serviceProvider) =>
        new Binding($"[{key}]") { Source = Localizer.Current, Mode = BindingMode.OneWay }.ProvideValue(serviceProvider);
}
