using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using static AioOptimize.Localizer;

namespace AioOptimize;

internal sealed record WorkerEvent(string Kind, string? Text, string? Level, double? Value, JsonElement Data);
internal sealed record WorkerResult(string Status, string Text);

internal static class CommandRunner
{
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };
    private static string SystemTool(string name) => Path.Combine(Environment.SystemDirectory, name);

    internal static async Task<WorkerResult> RunAsync(string id, object? input, Action<WorkerEvent> onEvent, bool confirmed = false)
    {
        var script = Path.Combine(AppContext.BaseDirectory, "Backend", "Run-Task.ps1");
        var powerShell = SystemTool(@"WindowsPowerShell\v1.0\powershell.exe");
        if (!File.Exists(powerShell))
            return new("error", T("WorkerMissing"));

        using var entryPoint = OpenVerifiedScript("Run-Task.ps1");
        using var legacy = OpenVerifiedScript("Legacy.ps1");
        using var operations = OpenVerifiedScript("Operations.ps1");
        using var downloads = OpenVerifiedScript("Downloads.ps1");

        var start = StartInfo(powerShell);
        // A downloaded ZIP can mark the bundled scripts as remote. Scope the policy to this verified worker.
        foreach (var argument in new[] { "-NoLogo", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", script, "-TaskId", id })
            start.ArgumentList.Add(argument);
        if (confirmed)
            start.ArgumentList.Add("-Confirmed");
        if (input is not null)
        {
            var data = Convert.ToBase64String(JsonSerializer.SerializeToUtf8Bytes(input));
            if (data.Length > 24000)
                return new("error", T("TaskDataLimit"));
            start.ArgumentList.Add("-Request");
            start.ArgumentList.Add(data);
        }

        using var process = Process.Start(start) ?? throw new InvalidOperationException(T("PowerShellStart"));
        var errors = process.StandardError.ReadToEndAsync();
        WorkerEvent? final = null;
        while (await process.StandardOutput.ReadLineAsync() is { } line)
        {
            if (string.IsNullOrWhiteSpace(line))
                continue;
            WorkerEvent? frame = null;
            if (line.StartsWith("THPO\t", StringComparison.Ordinal))
            {
                try
                {
                    frame = JsonSerializer.Deserialize<WorkerEvent>(line[5..], JsonOptions);
                }
                catch (JsonException)
                {
                    onEvent(new("log", T("WorkerReadError"), "warn", null, default));
                }
            }
            else
            {
                onEvent(new("log", line, "info", null, default));
            }

            if (frame?.Kind == "result")
                final = frame;
            else if (frame is not null)
                onEvent(frame);
        }
        await process.WaitForExitAsync();
        var diagnostic = await errors;
        if (!string.IsNullOrWhiteSpace(diagnostic))
            onEvent(new("log", diagnostic.Trim(), "warn", null, default));
        if (final is null)
        {
            var firstLine = diagnostic.Trim().Split('\n', 2)[0].Trim();
            var startupError = T("MissingResult", process.ExitCode);
            return new("error", firstLine.Length > 0 ? startupError + "\n" + firstLine : startupError);
        }
        var status = final.Level ?? "error";
        if (process.ExitCode != 0 && status == "ok")
            status = "error";
        var summary = status switch
        {
            "ok" => "Completed",
            "check" => "WorkerVerify",
            "partial" => "WorkerErrors",
            _ => "WorkerDone"
        };
        return new(status, string.IsNullOrEmpty(final.Text) ? T(summary) : final.Text);
    }

    private static FileStream OpenVerifiedScript(string file)
    {
        var path = Path.Combine(AppContext.BaseDirectory, "Backend", file);
        using var expected = Assembly.GetExecutingAssembly().GetManifestResourceStream("AioOptimize.Backend." + file);
        if (expected is null || !File.Exists(path))
            throw new InvalidDataException(T("BackendMissing", file));

        // Keep the verified files open for reading until PowerShell exits.
        var stream = File.OpenRead(path);
        try
        {
            if (!SHA256.HashData(stream).AsSpan().SequenceEqual(SHA256.HashData(expected)))
                throw new InvalidDataException(T("BackendChanged", file));
            return stream;
        }
        catch
        {
            stream.Dispose();
            throw;
        }
    }

    internal static async Task<string> CaptureAsync(string file, params string[] args)
    {
        var start = StartInfo(SystemTool(file));
        start.StandardOutputEncoding = null;
        start.StandardErrorEncoding = null;
        foreach (var argument in args)
            start.ArgumentList.Add(argument);
        using var process = Process.Start(start) ?? throw new InvalidOperationException(T("OpenFileError", file));
        var output = process.StandardOutput.ReadToEndAsync();
        var errors = process.StandardError.ReadToEndAsync();
        await process.WaitForExitAsync();
        if (process.ExitCode != 0)
            throw new InvalidOperationException($"{file} ({process.ExitCode}) {await errors}");
        return await output;
    }

    private static ProcessStartInfo StartInfo(string path) => new(path)
    {
        WorkingDirectory = Environment.SystemDirectory,
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        StandardOutputEncoding = Encoding.UTF8,
        StandardErrorEncoding = Encoding.UTF8,
        UseShellExecute = false,
        CreateNoWindow = true
    };
}
