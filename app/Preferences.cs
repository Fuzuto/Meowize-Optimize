using System.IO;
using System.Text.Json;

namespace AioOptimize;

internal enum ExitPreference { Ask, Save, Discard }
internal sealed record Profile(string? Language = null, ExitPreference Exit = ExitPreference.Ask, WindowState? Window = null);

internal sealed class Preferences
{
    private readonly string _path;
    internal Profile Value { get; private set; }

    internal Preferences(bool preview)
    {
        var fixture = preview ? Environment.GetEnvironmentVariable("MEOWIZE_PREVIEW_PROFILE") : null;
        _path = fixture is not null && Path.IsPathFullyQualified(fixture)
            ? fixture
            : Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Meowize",
                preview ? "preview.json" : "preferences.json");
        try
        {
            Value = File.Exists(_path) && new FileInfo(_path).Length < 32768
                ? JsonSerializer.Deserialize<Profile>(File.ReadAllText(_path)) ?? new() : new();
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException or JsonException)
        {
            Value = new();
        }
        if (!Enum.IsDefined(Value.Exit))
            Value = Value with { Exit = ExitPreference.Ask };
    }

    internal void Save(Profile value)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(_path)!);
        var temporary = _path + "." + Guid.NewGuid().ToString("N") + ".tmp";
        try
        {
            File.WriteAllText(temporary, JsonSerializer.Serialize(value));
            File.Move(temporary, _path, overwrite: true);
            Value = value;
        }
        finally
        {
            if (File.Exists(temporary))
                File.Delete(temporary);
        }
    }
}
