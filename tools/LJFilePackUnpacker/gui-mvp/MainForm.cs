using System.Diagnostics;
using System.Text;

namespace LJFilePackUnpacker.MvpGui;

internal sealed class MainForm : Form
{
    private const int MaxLogLines = 2000;

    private readonly TextBox _txtInputDir = new();
    private readonly TextBox _txtOutputDir = new();
    private readonly TextBox _txtIndexFile = new();
    private readonly TextBox _txtMappingFile = new();
    private readonly TextBox _txtAndroidLibgame = new();
    private readonly CheckBox _chkVerifyCrc = new() { Text = "启用 CRC32 校验", Checked = true, AutoSize = true };
    private readonly CheckBox _chkOverwrite = new() { Text = "覆盖已存在文件", AutoSize = true };
    private readonly CheckBox _chkDetectType = new() { Text = "启用文件类型检测", Checked = true, AutoSize = true };
    private readonly ComboBox _cmbDecryptMode = new()
    {
        DropDownStyle = ComboBoxStyle.DropDownList,
        Width = 100
    };
    private readonly TextBox _txtDecryptKey = new() { Width = 220 };
    private readonly NumericUpDown _numDiagnosticThreads = new()
    {
        Minimum = 1,
        Maximum = Math.Max(1, Environment.ProcessorCount * 2),
        Value = 1,
        Width = 70
    };
    private readonly CheckBox _chkDiagnosticStreamMode = new() { Text = "诊断 CLI 流式模式", AutoSize = true };
    private readonly Button _btnStart = new() { Text = "一键解包", AutoSize = true };
    private readonly Button _btnStop = new() { Text = "停止", AutoSize = true, Enabled = false };
    private readonly Button _btnOpenOutput = new() { Text = "打开输出目录", AutoSize = true };
    private readonly ProgressBar _progressBar = new() { Style = ProgressBarStyle.Marquee, MarqueeAnimationSpeed = 0 };
    private readonly Label _lblProgress = new() { Text = "就绪", AutoSize = true };
    private readonly Label _lblBackend = new() { Text = "后端: 检测中...", AutoSize = true };
    private readonly RichTextBox _txtLog = new()
    {
        ReadOnly = true,
        DetectUrls = false,
        WordWrap = false,
        Dock = DockStyle.Fill
    };

    private Process? _currentProcess;
    private CancellationTokenSource? _outputPumpCts;

    public MainForm()
    {
        Text = "LJFilePackUnpacker MVP - 一键解包";
        StartPosition = FormStartPosition.CenterScreen;
        MinimumSize = new Size(1080, 760);
        Width = 1180;
        Height = 820;

        _cmbDecryptMode.Items.AddRange(["auto", "lj", "apk"]);
        _cmbDecryptMode.SelectedIndex = 0;

        InitializeLayout();
        WireEvents();
        ApplyDefaultPaths();
        RefreshBackendHint();
    }

    private void InitializeLayout()
    {
        TableLayoutPanel root = new()
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 5,
            Padding = new Padding(10)
        };
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        TableLayoutPanel pathPanel = new()
        {
            ColumnCount = 4,
            RowCount = 5,
            Dock = DockStyle.Top,
            AutoSize = true
        };
        pathPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 110));
        pathPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        pathPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 90));
        pathPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 90));

        AddPathRow(pathPanel, 0, "资源目录", _txtInputDir, "浏览", "清空", OnBrowseInputDir, () => _txtInputDir.Clear());
        AddPathRow(pathPanel, 1, "输出目录", _txtOutputDir, "浏览", "清空", OnBrowseOutputDir, () => _txtOutputDir.Clear());
        AddPathRow(pathPanel, 2, "索引文件", _txtIndexFile, "浏览", "清空", OnBrowseIndexFile, () => _txtIndexFile.Clear());
        AddPathRow(pathPanel, 3, "映射文件", _txtMappingFile, "浏览", "清空", OnBrowseMappingFile, () => _txtMappingFile.Clear());
        AddPathRow(pathPanel, 4, "Android SO", _txtAndroidLibgame, "浏览", "清空", OnBrowseAndroidLibgame, () => _txtAndroidLibgame.Clear());

        FlowLayoutPanel optionPanel = new()
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            WrapContents = true
        };
        optionPanel.Controls.Add(_chkVerifyCrc);
        optionPanel.Controls.Add(_chkOverwrite);
        optionPanel.Controls.Add(_chkDetectType);

        FlowLayoutPanel advancedPanel = new()
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            WrapContents = true
        };
        advancedPanel.Controls.Add(new Label { Text = "解密模式", AutoSize = true, Padding = new Padding(0, 8, 0, 0) });
        advancedPanel.Controls.Add(_cmbDecryptMode);
        advancedPanel.Controls.Add(new Label { Text = "解密 Key", AutoSize = true, Padding = new Padding(12, 8, 0, 0) });
        advancedPanel.Controls.Add(_txtDecryptKey);
        advancedPanel.Controls.Add(new Label { Text = "诊断线程", AutoSize = true, Padding = new Padding(12, 8, 0, 0) });
        advancedPanel.Controls.Add(_numDiagnosticThreads);
        advancedPanel.Controls.Add(_chkDiagnosticStreamMode);
        advancedPanel.Controls.Add(_lblBackend);

        TableLayoutPanel actionPanel = new()
        {
            Dock = DockStyle.Top,
            ColumnCount = 3,
            RowCount = 2,
            AutoSize = true
        };
        actionPanel.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        actionPanel.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        actionPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        actionPanel.Controls.Add(_btnStart, 0, 0);
        actionPanel.Controls.Add(_btnStop, 1, 0);
        actionPanel.Controls.Add(_btnOpenOutput, 0, 1);
        actionPanel.SetColumnSpan(_btnOpenOutput, 2);
        actionPanel.Controls.Add(_progressBar, 2, 0);
        actionPanel.Controls.Add(_lblProgress, 2, 1);

        GroupBox logGroup = new()
        {
            Text = "运行日志",
            Dock = DockStyle.Fill
        };
        logGroup.Controls.Add(_txtLog);

        root.Controls.Add(pathPanel, 0, 0);
        root.Controls.Add(optionPanel, 0, 1);
        root.Controls.Add(advancedPanel, 0, 2);
        root.Controls.Add(actionPanel, 0, 3);
        root.Controls.Add(logGroup, 0, 4);

        Controls.Add(root);
    }

    private static void AddPathRow(
        TableLayoutPanel panel,
        int row,
        string labelText,
        TextBox textBox,
        string browseText,
        string clearText,
        EventHandler browseHandler,
        Action clearAction)
    {
        Label label = new()
        {
            Text = labelText,
            AutoSize = true,
            Anchor = AnchorStyles.Left,
            Margin = new Padding(0, 8, 8, 0)
        };
        textBox.Dock = DockStyle.Fill;
        textBox.Margin = new Padding(0, 4, 8, 4);

        Button browseButton = new() { Text = browseText, Width = 82 };
        browseButton.Click += browseHandler;

        Button clearButton = new() { Text = clearText, Width = 82 };
        clearButton.Click += (_, _) => clearAction();

        panel.Controls.Add(label, 0, row);
        panel.Controls.Add(textBox, 1, row);
        panel.Controls.Add(browseButton, 2, row);
        panel.Controls.Add(clearButton, 3, row);
    }

    private void WireEvents()
    {
        _btnStart.Click += async (_, _) => await StartUnpackAsync();
        _btnStop.Click += (_, _) => StopUnpack();
        _btnOpenOutput.Click += (_, _) => OpenOutputDirectory();
    }

    private void ApplyDefaultPaths()
    {
        _txtInputDir.Text = Path.Combine("client", "resource", "res1");
        _txtOutputDir.Text = Path.Combine("tools", "LJFilePackUnpacker", "output");
    }

    private void RefreshBackendHint()
    {
        UnpackCliInfo? cliInfo = UnpackCliSupport.ResolveCli(AppContext.BaseDirectory);
        _lblBackend.Text = cliInfo is null
            ? "后端: 未找到 CLI"
            : "后端: " + cliInfo.DisplayName;
    }

    private void OnBrowseInputDir(object? sender, EventArgs e)
    {
        using FolderBrowserDialog dialog = new() { Description = "选择包含 fl.ljpi/fl.ljzip 与 *.ljfp 的资源目录" };
        if (dialog.ShowDialog(this) == DialogResult.OK)
        {
            _txtInputDir.Text = dialog.SelectedPath;
        }
    }

    private void OnBrowseOutputDir(object? sender, EventArgs e)
    {
        using FolderBrowserDialog dialog = new() { Description = "选择解包输出目录" };
        if (dialog.ShowDialog(this) == DialogResult.OK)
        {
            _txtOutputDir.Text = dialog.SelectedPath;
        }
    }

    private void OnBrowseIndexFile(object? sender, EventArgs e)
    {
        using OpenFileDialog dialog = new()
        {
            Filter = "LJ 索引文件 (*.ljpi;*.ljzip)|*.ljpi;*.ljzip|所有文件 (*.*)|*.*",
            CheckFileExists = true
        };
        if (dialog.ShowDialog(this) == DialogResult.OK)
        {
            _txtIndexFile.Text = dialog.FileName;
        }
    }

    private void OnBrowseMappingFile(object? sender, EventArgs e)
    {
        using OpenFileDialog dialog = new()
        {
            Filter = "映射文件 (*.ljpm;*.map;*.txt)|*.ljpm;*.map;*.txt|所有文件 (*.*)|*.*",
            CheckFileExists = true
        };
        if (dialog.ShowDialog(this) == DialogResult.OK)
        {
            _txtMappingFile.Text = dialog.FileName;
        }
    }

    private void OnBrowseAndroidLibgame(object? sender, EventArgs e)
    {
        using OpenFileDialog dialog = new()
        {
            Filter = "Android libgame.so (libgame.so)|libgame.so|共享库 (*.so)|*.so|所有文件 (*.*)|*.*",
            CheckFileExists = true
        };
        if (dialog.ShowDialog(this) == DialogResult.OK)
        {
            _txtAndroidLibgame.Text = dialog.FileName;
        }
    }

    private async Task StartUnpackAsync()
    {
        if (_currentProcess is { HasExited: false })
        {
            return;
        }

        string inputDir = _txtInputDir.Text.Trim();
        string outputDir = _txtOutputDir.Text.Trim();
        string? indexFile = GetOptionalPath(_txtIndexFile.Text);
        string? mappingFile = GetOptionalPath(_txtMappingFile.Text);
        string? androidLibgamePath = GetOptionalPath(_txtAndroidLibgame.Text);

        if (string.IsNullOrWhiteSpace(inputDir) || !Directory.Exists(inputDir))
        {
            MessageBox.Show(this, "请输入有效的资源目录。", "参数错误", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        if (string.IsNullOrWhiteSpace(outputDir))
        {
            MessageBox.Show(this, "请输入输出目录。", "参数错误", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        if (indexFile is not null && !File.Exists(indexFile))
        {
            MessageBox.Show(this, "指定的索引文件不存在。", "参数错误", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        if (mappingFile is not null && !File.Exists(mappingFile))
        {
            MessageBox.Show(this, "指定的映射文件不存在。", "参数错误", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        if (androidLibgamePath is not null && !File.Exists(androidLibgamePath))
        {
            MessageBox.Show(this, "指定的 Android libgame.so 不存在。", "参数错误", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        UnpackCliInfo? cliInfo = UnpackCliSupport.ResolveCli(AppContext.BaseDirectory);
        RefreshBackendHint();
        if (cliInfo is null)
        {
            MessageBox.Show(this, "未找到 ljfp-unpack.exe 或 ljfp-unpack-diag.exe，请先执行构建脚本。", "启动失败", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        UnpackLaunchRequest request = new()
        {
            InputDirectory = inputDir,
            OutputDirectory = outputDir,
            IndexFile = indexFile,
            MappingFile = mappingFile,
            VerifyCrc = _chkVerifyCrc.Checked,
            OverwriteExisting = _chkOverwrite.Checked,
            DetectFileType = _chkDetectType.Checked,
            DecryptMode = _cmbDecryptMode.Text,
            DecryptKey = GetOptionalPath(_txtDecryptKey.Text),
            AndroidLibgamePath = androidLibgamePath,
            DiagnosticThreadCount = (int)_numDiagnosticThreads.Value,
            DiagnosticStreamMode = _chkDiagnosticStreamMode.Checked
        };

        if (!UnpackCliSupport.TryCreateLaunchPlan(cliInfo, request, out UnpackLaunchPlan? plan, out string? errorMessage))
        {
            MessageBox.Show(this, errorMessage ?? "无法生成解包命令。", "参数不兼容", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        Directory.CreateDirectory(outputDir);

        AppendLog("后端: " + plan!.Cli.DisplayName);
        foreach (string note in plan.Notes)
        {
            AppendLog(note, highlight: true);
        }
        AppendLog($"$ {plan.Cli.FileName} {UnpackCliSupport.FormatCommandPreview(plan.Arguments)}");

        Process process = new()
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = plan.Cli.ExecutablePath,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8,
                CreateNoWindow = true
            },
            EnableRaisingEvents = true
        };

        foreach (string argument in plan.Arguments)
        {
            process.StartInfo.ArgumentList.Add(argument);
        }

        _currentProcess = process;
        _outputPumpCts = new CancellationTokenSource();

        SetRunningState(true);
        SetProgressBusy("解包执行中...");

        try
        {
            if (!process.Start())
            {
                throw new InvalidOperationException("启动进程失败。");
            }

            Task stdoutTask = PumpOutputAsync(process.StandardOutput, isError: false, _outputPumpCts.Token);
            Task stderrTask = PumpOutputAsync(process.StandardError, isError: true, _outputPumpCts.Token);

            await process.WaitForExitAsync();
            _outputPumpCts.Cancel();

            await Task.WhenAll(stdoutTask, stderrTask);

            if (process.ExitCode == 0)
            {
                SetProgressDone("解包完成");
                AppendLog("解包完成。");
            }
            else
            {
                SetProgressDone($"解包失败，退出码 {process.ExitCode}");
                AppendLog($"解包失败，退出码 {process.ExitCode}", isError: true);
            }
        }
        catch (Exception ex)
        {
            SetProgressDone("执行异常");
            AppendLog("执行异常: " + ex.Message, isError: true);
        }
        finally
        {
            _outputPumpCts?.Dispose();
            _outputPumpCts = null;
            _currentProcess?.Dispose();
            _currentProcess = null;
            SetRunningState(false);
            RefreshBackendHint();
        }
    }

    private static string? GetOptionalPath(string value)
    {
        string trimmed = value.Trim();
        return string.IsNullOrWhiteSpace(trimmed) ? null : trimmed;
    }

    private async Task PumpOutputAsync(StreamReader reader, bool isError, CancellationToken token)
    {
        StringBuilder segment = new();
        char[] buffer = new char[256];

        try
        {
            while (!token.IsCancellationRequested)
            {
                int read = await reader.ReadAsync(buffer, token);
                if (read <= 0)
                {
                    break;
                }

                for (int i = 0; i < read; i++)
                {
                    char ch = buffer[i];
                    if (ch == '\r' || ch == '\n')
                    {
                        if (segment.Length > 0)
                        {
                            HandleOutputSegment(segment.ToString(), isError);
                            segment.Clear();
                        }
                        continue;
                    }

                    segment.Append(ch);
                }
            }

            if (segment.Length > 0)
            {
                HandleOutputSegment(segment.ToString(), isError);
            }
        }
        catch (OperationCanceledException)
        {
            // ignore
        }
    }

    private void HandleOutputSegment(string rawText, bool isError)
    {
        string text = rawText.Trim();
        if (string.IsNullOrEmpty(text))
        {
            return;
        }

        if (UnpackCliSupport.TryParseProgress(text, out UnpackProgressSnapshot snapshot))
        {
            UpdateProgress(snapshot.Percent, snapshot.Current, snapshot.Total);
            return;
        }

        AppendLog(text, isError);
    }

    private void UpdateProgress(int percent, int current, int total)
    {
        if (InvokeRequired)
        {
            BeginInvoke(new Action(() => UpdateProgress(percent, current, total)));
            return;
        }

        _progressBar.Style = ProgressBarStyle.Continuous;
        _progressBar.MarqueeAnimationSpeed = 0;
        _progressBar.Minimum = 0;
        _progressBar.Maximum = 100;
        _progressBar.Value = Math.Clamp(percent, 0, 100);
        _lblProgress.Text = $"进度: {percent}% ({current}/{total})";
    }

    private void AppendLog(string message, bool isError = false, bool highlight = false)
    {
        if (InvokeRequired)
        {
            BeginInvoke(new Action(() => AppendLog(message, isError, highlight)));
            return;
        }

        _txtLog.SelectionColor = isError
            ? Color.DarkRed
            : highlight
                ? Color.DarkGoldenrod
                : Color.Black;
        _txtLog.AppendText($"[{DateTime.Now:HH:mm:ss}] {message}{Environment.NewLine}");
        TrimLogIfNeeded();
        _txtLog.ScrollToCaret();
    }

    private void TrimLogIfNeeded()
    {
        string[] lines = _txtLog.Lines;
        if (lines.Length <= MaxLogLines)
        {
            return;
        }

        int removeCount = lines.Length - MaxLogLines;
        int removeLength = 0;

        for (int i = 0; i < removeCount; i++)
        {
            removeLength += lines[i].Length + Environment.NewLine.Length;
        }

        _txtLog.Select(0, Math.Min(removeLength, _txtLog.TextLength));
        _txtLog.SelectedText = string.Empty;
    }

    private void SetRunningState(bool isRunning)
    {
        if (InvokeRequired)
        {
            BeginInvoke(new Action(() => SetRunningState(isRunning)));
            return;
        }

        _btnStart.Enabled = !isRunning;
        _btnStop.Enabled = isRunning;
    }

    private void SetProgressBusy(string status)
    {
        if (InvokeRequired)
        {
            BeginInvoke(new Action(() => SetProgressBusy(status)));
            return;
        }

        _progressBar.Style = ProgressBarStyle.Marquee;
        _progressBar.MarqueeAnimationSpeed = 30;
        _lblProgress.Text = status;
    }

    private void SetProgressDone(string status)
    {
        if (InvokeRequired)
        {
            BeginInvoke(new Action(() => SetProgressDone(status)));
            return;
        }

        if (_progressBar.Style != ProgressBarStyle.Continuous)
        {
            _progressBar.Style = ProgressBarStyle.Continuous;
            _progressBar.Minimum = 0;
            _progressBar.Maximum = 100;
        }

        _progressBar.Value = 100;
        _lblProgress.Text = status;
    }

    private void StopUnpack()
    {
        try
        {
            if (_currentProcess is { HasExited: false })
            {
                _currentProcess.Kill(entireProcessTree: true);
                AppendLog("已发送停止信号。", highlight: true);
            }
        }
        catch (Exception ex)
        {
            AppendLog("停止失败: " + ex.Message, isError: true);
        }
    }

    private void OpenOutputDirectory()
    {
        string outputDir = _txtOutputDir.Text.Trim();
        if (string.IsNullOrWhiteSpace(outputDir))
        {
            return;
        }

        Directory.CreateDirectory(outputDir);
        Process.Start(new ProcessStartInfo
        {
            FileName = outputDir,
            UseShellExecute = true
        });
    }
}
