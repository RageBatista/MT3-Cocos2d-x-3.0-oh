using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace LJFilePackUnpacker.MvpGui;

internal enum UnpackCliFlavor
{
    Legacy,
    Diagnostic
}

internal readonly record struct UnpackProgressSnapshot(int Percent, int Current, int Total);

internal sealed record UnpackCliInfo(string ExecutablePath, UnpackCliFlavor Flavor)
{
    public string FileName => Path.GetFileName(ExecutablePath);

    public string DisplayName =>
        Flavor == UnpackCliFlavor.Legacy
            ? $"{FileName}（完整协议）"
            : $"{FileName}（诊断兼容模式）";
}

internal sealed class UnpackLaunchRequest
{
    public string InputDirectory { get; init; } = string.Empty;

    public string OutputDirectory { get; init; } = string.Empty;

    public string? IndexFile { get; init; }

    public string? MappingFile { get; init; }

    public bool VerifyCrc { get; init; } = true;

    public bool OverwriteExisting { get; init; }

    public bool DetectFileType { get; init; } = true;

    public string DecryptMode { get; init; } = "auto";

    public string? DecryptKey { get; init; }

    public string? AndroidLibgamePath { get; init; }

    public int DiagnosticThreadCount { get; init; } = 1;

    public bool DiagnosticStreamMode { get; init; }
}

internal sealed record UnpackLaunchPlan(
    UnpackCliInfo Cli,
    IReadOnlyList<string> Arguments,
    IReadOnlyList<string> Notes);

internal static class UnpackCliSupport
{
    private static readonly Regex ProgressRegex = new(
        @"(?:^|[\s=])(?<percent>\d+(?:\.\d+)?)%\s*\((?<current>\d+)\/(?<total>\d+)\)",
        RegexOptions.Compiled | RegexOptions.CultureInvariant);

    public static UnpackCliInfo? ResolveCli(string baseDirectory)
    {
        foreach (UnpackCliInfo candidate in EnumerateCandidates(baseDirectory))
        {
            if (File.Exists(candidate.ExecutablePath))
            {
                return candidate;
            }
        }

        return null;
    }

    public static bool TryCreateLaunchPlan(
        UnpackCliInfo cli,
        UnpackLaunchRequest request,
        out UnpackLaunchPlan? plan,
        out string? errorMessage)
    {
        errorMessage = null;

        List<string> notes = new();
        IReadOnlyList<string> arguments;

        if (cli.Flavor == UnpackCliFlavor.Legacy)
        {
            arguments = BuildLegacyArguments(request);
        }
        else
        {
            if (!ValidateDiagnosticCompatibility(request, notes, out errorMessage))
            {
                plan = null;
                return false;
            }

            arguments = BuildDiagnosticArguments(request, notes);
        }

        plan = new UnpackLaunchPlan(cli, arguments, notes);
        return true;
    }

    public static string FormatCommandPreview(IEnumerable<string> arguments)
    {
        return string.Join(" ", arguments.Select(QuoteForDisplay));
    }

    public static bool TryParseProgress(string text, out UnpackProgressSnapshot snapshot)
    {
        snapshot = default;

        Match match = ProgressRegex.Match(text);
        if (!match.Success)
        {
            return false;
        }

        if (!double.TryParse(
                match.Groups["percent"].Value,
                NumberStyles.Float,
                CultureInfo.InvariantCulture,
                out double percent))
        {
            return false;
        }

        if (!int.TryParse(match.Groups["current"].Value, NumberStyles.Integer, CultureInfo.InvariantCulture, out int current) ||
            !int.TryParse(match.Groups["total"].Value, NumberStyles.Integer, CultureInfo.InvariantCulture, out int total) ||
            total <= 0)
        {
            return false;
        }

        snapshot = new UnpackProgressSnapshot(
            Math.Clamp((int)Math.Round(percent, MidpointRounding.AwayFromZero), 0, 100),
            current,
            total);
        return true;
    }

    private static IEnumerable<UnpackCliInfo> EnumerateCandidates(string baseDirectory)
    {
        List<UnpackCliInfo> candidates = new();

        AddCandidate(candidates, Path.Combine(baseDirectory, "ljfp-unpack.exe"), UnpackCliFlavor.Legacy);
        AddCandidate(candidates, Path.Combine(baseDirectory, "ljfp-unpack-diag.exe"), UnpackCliFlavor.Diagnostic);

        string repoRoot = Path.GetFullPath(Path.Combine(baseDirectory, "..", "..", "..", "..", ".."));
        string dependencyBuildRoot = Path.Combine(repoRoot, "dependencies", "SuperLJFilePackUnpack", "build", "bin", "Release");
        string dependencyOutRoot = Path.Combine(repoRoot, "dependencies", "SuperLJFilePackUnpack", "out", "mvp_cli_manual");

        AddCandidate(candidates, Path.Combine(dependencyBuildRoot, "ljfp-unpack.exe"), UnpackCliFlavor.Legacy);
        AddCandidate(candidates, Path.Combine(dependencyBuildRoot, "ljfp-unpack-diag.exe"), UnpackCliFlavor.Diagnostic);
        AddCandidate(candidates, Path.Combine(dependencyOutRoot, "ljfp-unpack.exe"), UnpackCliFlavor.Legacy);

        return candidates;
    }

    private static void AddCandidate(List<UnpackCliInfo> candidates, string path, UnpackCliFlavor flavor)
    {
        if (candidates.Any(item => StringComparer.OrdinalIgnoreCase.Equals(item.ExecutablePath, path)))
        {
            return;
        }

        candidates.Add(new UnpackCliInfo(path, flavor));
    }

    private static IReadOnlyList<string> BuildLegacyArguments(UnpackLaunchRequest request)
    {
        List<string> arguments =
        [
            request.InputDirectory,
            request.OutputDirectory
        ];

        if (!request.VerifyCrc)
        {
            arguments.Add("--no-verify");
        }

        if (request.OverwriteExisting)
        {
            arguments.Add("--overwrite");
        }

        if (!request.DetectFileType)
        {
            arguments.Add("--no-detect");
        }

        if (!string.IsNullOrWhiteSpace(request.IndexFile))
        {
            arguments.Add("--index=" + request.IndexFile);
        }

        if (!string.IsNullOrWhiteSpace(request.MappingFile))
        {
            arguments.Add("--mapping=" + request.MappingFile);
        }

        string decryptMode = NormalizeDecryptMode(request.DecryptMode);
        if (!string.Equals(decryptMode, "auto", StringComparison.Ordinal))
        {
            arguments.Add("--decrypt-mode=" + decryptMode);
        }

        if (!string.IsNullOrWhiteSpace(request.DecryptKey))
        {
            arguments.Add("--decrypt-key=" + request.DecryptKey);
        }

        if (!string.IsNullOrWhiteSpace(request.AndroidLibgamePath))
        {
            arguments.Add("--android-libgame=" + request.AndroidLibgamePath);
        }

        return arguments;
    }

    private static IReadOnlyList<string> BuildDiagnosticArguments(
        UnpackLaunchRequest request,
        ICollection<string> notes)
    {
        List<string> arguments =
        [
            request.InputDirectory,
            request.OutputDirectory
        ];

        bool needsMappingSlot =
            !string.IsNullOrWhiteSpace(request.MappingFile) ||
            !string.IsNullOrWhiteSpace(request.DecryptKey) ||
            request.DiagnosticThreadCount > 1 ||
            request.DiagnosticStreamMode;

        bool needsDecryptKeySlot =
            !string.IsNullOrWhiteSpace(request.DecryptKey) ||
            request.DiagnosticThreadCount > 1 ||
            request.DiagnosticStreamMode;

        bool needsThreadSlot = request.DiagnosticThreadCount > 1 || request.DiagnosticStreamMode;

        if (needsMappingSlot)
        {
            arguments.Add(request.MappingFile ?? string.Empty);
        }

        if (needsDecryptKeySlot)
        {
            arguments.Add(request.DecryptKey ?? string.Empty);
        }

        if (needsThreadSlot)
        {
            arguments.Add(request.DiagnosticThreadCount.ToString(CultureInfo.InvariantCulture));
        }

        if (request.DiagnosticStreamMode)
        {
            arguments.Add("1");
            notes.Add("诊断 CLI 已启用流式模式，便于大目录排障。");
        }

        if (!string.IsNullOrWhiteSpace(request.AndroidLibgamePath))
        {
            arguments.Add("--android-libgame=" + request.AndroidLibgamePath);
        }

        return arguments;
    }

    private static bool ValidateDiagnosticCompatibility(
        UnpackLaunchRequest request,
        ICollection<string> notes,
        out string? errorMessage)
    {
        errorMessage = null;

        if (!string.IsNullOrWhiteSpace(request.IndexFile))
        {
            string inputDirectory = Path.GetFullPath(request.InputDirectory)
                .TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            string indexFile = Path.GetFullPath(request.IndexFile);
            string? parentDirectory = Path.GetDirectoryName(indexFile)?
                .TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            string fileName = Path.GetFileName(indexFile);

            bool usesDefaultIndexName =
                fileName.Equals("fl.ljpi", StringComparison.OrdinalIgnoreCase) ||
                fileName.Equals("fl.ljzip", StringComparison.OrdinalIgnoreCase);

            if (!usesDefaultIndexName ||
                !StringComparer.OrdinalIgnoreCase.Equals(parentDirectory, inputDirectory))
            {
                errorMessage =
                    "当前只找到 ljfp-unpack-diag.exe，它不支持自定义索引文件路径。请把索引文件放回输入目录并命名为 fl.ljpi/fl.ljzip，或先构建 legacy CLI。";
                return false;
            }

            notes.Add("诊断 CLI 将在输入目录内自动读取 fl.ljpi/fl.ljzip。");
        }

        if (!request.VerifyCrc)
        {
            notes.Add("诊断 CLI 当前固定启用 CRC32 校验，已忽略“关闭 CRC32 校验”。");
        }

        if (request.OverwriteExisting)
        {
            notes.Add("诊断 CLI 当前固定禁止覆盖已存在文件，已忽略“覆盖已存在文件”。");
        }

        if (!request.DetectFileType)
        {
            notes.Add("诊断 CLI 当前固定启用文件类型检测，已忽略“禁用文件类型检测”。");
        }

        string decryptMode = NormalizeDecryptMode(request.DecryptMode);
        if (!string.Equals(decryptMode, "auto", StringComparison.Ordinal))
        {
            notes.Add("诊断 CLI 当前不支持显式切换解密模式，已回退为自动模式。");
        }

        return true;
    }

    private static string NormalizeDecryptMode(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return "auto";
        }

        string normalized = value.Trim().ToLowerInvariant();
        return normalized switch
        {
            "lj" => "lj",
            "apk" => "apk",
            _ => "auto"
        };
    }

    private static string QuoteForDisplay(string value)
    {
        if (string.IsNullOrEmpty(value))
        {
            return "\"\"";
        }

        bool needsQuotes = value.Any(ch => char.IsWhiteSpace(ch) || ch == '"');
        if (!needsQuotes)
        {
            return value;
        }

        StringBuilder builder = new();
        builder.Append('"');
        foreach (char ch in value)
        {
            if (ch == '"')
            {
                builder.Append("\\\"");
            }
            else
            {
                builder.Append(ch);
            }
        }

        builder.Append('"');
        return builder.ToString();
    }
}
