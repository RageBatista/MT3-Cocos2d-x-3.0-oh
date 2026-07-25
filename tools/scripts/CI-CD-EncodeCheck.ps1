<#
.SYNOPSIS
    CI/CD编码检查脚本 - 验证文件编码符合 AGENTS.md 与 .claude/RULES.md 约束

.DESCRIPTION
    用于在CI/CD流程中自动验证文件编码规范。
    支持验证暂存文件或指定 Git 基线后的变更文件，生成详细报告。
    本脚本要求 PowerShell 7+ (pwsh)；Windows PowerShell 5.1 不用于执行本文件。

.PARAMETER Mode
    检查模式: Staged（暂存文件）, Changed（变更文件）

.PARAMETER TargetBranch
    Changed 模式使用的 Git 基线分支或提交；为空时从 CI 环境推导。

.PARAMETER OutputPath
    报告输出路径

.PARAMETER LogLevel
    日志级别: Quiet, Normal, Verbose

.PARAMETER FailFast
    遇到第一个失败时立即退出

.EXAMPLE
    # 检查暂存文件
    .\tools\scripts\CI-CD-EncodeCheck.ps1 -Mode Staged

.EXAMPLE
    # 检查变更文件（CI环境）
    .\tools\scripts\CI-CD-EncodeCheck.ps1 -Mode Changed -TargetBranch origin/main -FailFast
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Staged', 'Changed')]
    [string]$Mode = 'Staged',

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Quiet', 'Normal', 'Verbose')]
    [string]$LogLevel = 'Normal',

    [Parameter(Mandatory = $false)]
    [string]$TargetBranch = '',

    [Parameter(Mandatory = $false)]
    [switch]$FailFast
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

# 编码规范定义。历史 C/C++/RC 是混合编码区，已有文件按 Git 基线比较
# 编码/BOM 分类；新增文件再应用 VS2013 与 RC 的安全默认值。
$PreserveExistingExtensions = @('.cpp', '.c', '.h', '.hpp', '.rc')
$BomForbiddenExtensions = @('.lua', '.java', '.xml', '.json', '.ini', '.pkg', '.md', '.txt', '.bat', '.cmd', '.sh')
$SupportedExtensions = @($PreserveExistingExtensions + $BomForbiddenExtensions | Select-Object -Unique)

# 全局变量
$Script:RepoRoot = $null
$Script:TotalFiles = 0
$Script:PassedFiles = 0
$Script:FailedFiles = 0
$Script:SkippedFiles = 0
$Script:FailedFilesList = New-Object System.Collections.Generic.List[string]
$Script:BaselineCommit = ''
$Script:BaselinePathMap = @{}

# 日志函数
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    if ($LogLevel -eq 'Quiet' -and $Level -in @('Info', 'Success')) {
        return
    }

    $color = switch ($Level) {
        'Info' { 'White' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        default { 'White' }
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $prefix = switch ($Level) {
        'Info' { '[INFO]' }
        'Success' { '[PASS]' }
        'Warning' { '[WARN]' }
        'Error' { '[FAIL]' }
        default { '[LOG]' }
    }

    Write-Host ("{0} {1} {2}" -f $timestamp, $prefix, $Message) -ForegroundColor $color
}

# 获取仓库根目录
function Get-RepoRoot {
    if (-not [string]::IsNullOrWhiteSpace($Script:RepoRoot)) {
        return $Script:RepoRoot
    }

    try {
        $root = (& git rev-parse --show-toplevel 2>$null)
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($root)) {
            $Script:RepoRoot = (Resolve-Path -LiteralPath $root).Path
            return $Script:RepoRoot
        }
    }
    catch {
        # Fallback to current directory
    }

    $Script:RepoRoot = (Resolve-Path -LiteralPath '.').Path
    return $Script:RepoRoot
}

# 获取相对路径
function Get-RelativePath {
    param([string]$AbsolutePath)

    $repoRoot = Get-RepoRoot
    if ($AbsolutePath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $AbsolutePath.Substring($repoRoot.Length).TrimStart('\', '/')
    }

    return $AbsolutePath
}

# 检测UTF-8 BOM
function Test-HasUtf8Bom {
    param([byte[]]$Bytes)

    return (
        $Bytes.Length -ge 3 -and
        $Bytes[0] -eq 0xEF -and
        $Bytes[1] -eq 0xBB -and
        $Bytes[2] -eq 0xBF
    )
}

# 检测是否为UTF-8
function Test-IsUtf8 {
    param([byte[]]$Bytes)

    $decoder = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        [void]$decoder.GetString($Bytes)
        return $true
    }
    catch {
        return $false
    }
}

function Test-ContainsNonAsciiText {
    param([string]$Text)

    for ($index = 0; $index -lt $Text.Length; $index++) {
        if ([int]$Text[$index] -gt 127) {
            return $true
        }
    }
    return $false
}

function Test-ContainsHighByte {
    param([byte[]]$Bytes)

    foreach ($value in $Bytes) {
        if ($value -gt 127) {
            return $true
        }
    }
    return $false
}

# 获取可稳定比较的编码/BOM分类。无BOM且不是严格UTF-8的内容只归入
# legacy-or-binary；该分类用于阻止显著转码，不猜测具体历史代码页。
function Get-EncodingProfile {
    param([byte[]]$Bytes)

    $candidate = 'legacy-or-binary'
    $hasBom = $false
    $isUtf8 = $false
    $hasNonAscii = $false

    if (
        $Bytes.Length -ge 4 -and
        $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE -and
        $Bytes[2] -eq 0x00 -and $Bytes[3] -eq 0x00
    ) {
        $candidate = 'utf32-le-bom'
        $hasBom = $true
        $utf32Le = [System.Text.UTF32Encoding]::new($false, $true, $true)
        $text = $utf32Le.GetString($Bytes, 4, $Bytes.Length - 4)
        $hasNonAscii = Test-ContainsNonAsciiText -Text $text
    }
    elseif (
        $Bytes.Length -ge 4 -and
        $Bytes[0] -eq 0x00 -and $Bytes[1] -eq 0x00 -and
        $Bytes[2] -eq 0xFE -and $Bytes[3] -eq 0xFF
    ) {
        $candidate = 'utf32-be-bom'
        $hasBom = $true
        $utf32Be = [System.Text.UTF32Encoding]::new($true, $true, $true)
        $text = $utf32Be.GetString($Bytes, 4, $Bytes.Length - 4)
        $hasNonAscii = Test-ContainsNonAsciiText -Text $text
    }
    elseif (Test-HasUtf8Bom -Bytes $Bytes) {
        $candidate = 'utf8-bom'
        $hasBom = $true
        $isUtf8 = $true
        $strictUtf8Bom = [System.Text.UTF8Encoding]::new($true, $true)
        $text = $strictUtf8Bom.GetString($Bytes, 3, $Bytes.Length - 3)
        $hasNonAscii = Test-ContainsNonAsciiText -Text $text
    }
    elseif ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE) {
        $candidate = 'utf16-le-bom'
        $hasBom = $true
        $utf16Le = [System.Text.UnicodeEncoding]::new($false, $true, $true)
        $text = $utf16Le.GetString($Bytes, 2, $Bytes.Length - 2)
        $hasNonAscii = Test-ContainsNonAsciiText -Text $text
    }
    elseif ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFE -and $Bytes[1] -eq 0xFF) {
        $candidate = 'utf16-be-bom'
        $hasBom = $true
        $utf16Be = [System.Text.UnicodeEncoding]::new($true, $true, $true)
        $text = $utf16Be.GetString($Bytes, 2, $Bytes.Length - 2)
        $hasNonAscii = Test-ContainsNonAsciiText -Text $text
    }
    elseif (Test-IsUtf8 -Bytes $Bytes) {
        $candidate = 'utf8-no-bom'
        $isUtf8 = $true
        $text = [System.Text.Encoding]::UTF8.GetString($Bytes)
        $hasNonAscii = Test-ContainsNonAsciiText -Text $text
    }
    else {
        $hasNonAscii = Test-ContainsHighByte -Bytes $Bytes
    }

    return [pscustomobject]@{
        Candidate = $candidate
        HasBom = $hasBom
        IsUtf8 = $isUtf8
        HasNonAscii = $hasNonAscii
    }
}

# 获取BOM策略
function Get-BomPolicy {
    param([string]$Extension)

    if ($PreserveExistingExtensions -contains $Extension) { return 'PreserveExisting' }
    if ($BomForbiddenExtensions -contains $Extension) { return 'Forbidden' }
    return 'N/A'
}

function Invoke-GitByteQuery {
    param([string[]]$Arguments)

    $gitCommand = Get-Command git -ErrorAction Stop
    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $gitCommand.Source
    $startInfo.WorkingDirectory = Get-RepoRoot
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    foreach ($argument in $Arguments) {
        [void]$startInfo.ArgumentList.Add($argument)
    }

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $memory = [System.IO.MemoryStream]::new()
    try {
        $process.StandardOutput.BaseStream.CopyTo($memory)
        $errorText = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        return [pscustomobject]@{
            ExitCode = $process.ExitCode
            Bytes = $memory.ToArray()
            Error = $errorText.Trim()
        }
    }
    finally {
        $memory.Dispose()
        $process.Dispose()
    }
}

function Get-GitBlob {
    param(
        [string]$Commit,
        [string]$GitPath
    )

    $normalizedPath = $GitPath.Replace('\', '/')
    $query = Invoke-GitByteQuery -Arguments @('cat-file', 'blob', "$Commit`:$normalizedPath")
    return [pscustomobject]@{
        Found = ($query.ExitCode -eq 0)
        Bytes = $query.Bytes
        Error = $query.Error
    }
}

function Get-CurrentEncodingBytes {
    param([string]$FilePath)

    $relativePath = (Get-RelativePath -AbsolutePath $FilePath).Replace('\', '/')
    $objectSpec = if ($Mode -eq 'Staged') { ":$relativePath" } else { "HEAD`:$relativePath" }
    $sourceLabel = if ($Mode -eq 'Staged') { 'git-index' } else { 'git-head' }
    $query = Invoke-GitByteQuery -Arguments @('cat-file', 'blob', $objectSpec)
    if ($query.ExitCode -ne 0) {
        throw "无法从 $sourceLabel 读取文件 $relativePath`: $($query.Error)"
    }
    return [pscustomobject]@{
        Bytes = $query.Bytes
        Source = $sourceLabel
    }
}

function Test-PreserveExistingEncoding {
    param(
        [string]$FilePath,
        [byte[]]$Bytes,
        [string]$Extension
    )

    $relativePath = (Get-RelativePath -AbsolutePath $FilePath).Replace('\', '/')
    $current = Get-EncodingProfile -Bytes $Bytes
    if ([string]::IsNullOrWhiteSpace($Script:BaselineCommit)) {
        return [pscustomobject]@{
            Status = 'ERROR'
            Reason = '未初始化 Git 编码比较基线'
            Current = $current
            Baseline = $null
            BaselineLabel = ''
        }
    }
    if (-not $Script:BaselinePathMap.ContainsKey($relativePath)) {
        return [pscustomobject]@{
            Status = 'ERROR'
            Reason = "变更路径缺少 Git 基线映射: $relativePath"
            Current = $current
            Baseline = $null
            BaselineLabel = ''
        }
    }

    $baselinePath = $Script:BaselinePathMap[$relativePath]
    if ([string]::IsNullOrWhiteSpace([string]$baselinePath)) {
        if ($Extension -eq '.rc') {
            $allowedRcEncodings = @('utf16-le-bom', 'utf8-bom')
            if ($allowedRcEncodings -notcontains $current.Candidate) {
                return [pscustomobject]@{
                    Status = 'FAIL'
                    Reason = '新增 .rc 必须使用显式 BOM（优先 UTF-16 LE，也接受 UTF-8 BOM）'
                    Current = $current
                    Baseline = $null
                    BaselineLabel = '(new file)'
                }
            }
        }
        elseif (-not $current.IsUtf8) {
            return [pscustomobject]@{
                Status = 'FAIL'
                Reason = '新增 C/C++ 文件必须使用有效 UTF-8'
                Current = $current
                Baseline = $null
                BaselineLabel = '(new file)'
            }
        }
        elseif ($current.HasNonAscii -and $current.Candidate -ne 'utf8-bom') {
            return [pscustomobject]@{
                Status = 'FAIL'
                Reason = '新增且包含非 ASCII 字符的 C/C++ 文件必须使用 UTF-8 BOM，以兼容 VS2013/cl.exe'
                Current = $current
                Baseline = $null
                BaselineLabel = '(new file)'
            }
        }

        return [pscustomobject]@{
            Status = 'PASS'
            Reason = '新增文件符合编码安全默认值'
            Current = $current
            Baseline = $null
            BaselineLabel = '(new file)'
        }
    }

    $blob = Get-GitBlob -Commit $Script:BaselineCommit -GitPath ([string]$baselinePath)
    if (-not $blob.Found) {
        return [pscustomobject]@{
            Status = 'ERROR'
            Reason = "无法读取 Git 基线文件 $baselinePath`: $($blob.Error)"
            Current = $current
            Baseline = $null
            BaselineLabel = [string]$baselinePath
        }
    }

    $baseline = Get-EncodingProfile -Bytes $blob.Bytes
    if ($baseline.Candidate -eq $current.Candidate) {
        if (
            $Extension -ne '.rc' -and
            $current.Candidate -eq 'utf8-no-bom' -and
            $current.HasNonAscii
        ) {
            return [pscustomobject]@{
                Status = 'FAIL'
                Reason = '已有 C/C++ 文件是含非 ASCII 字符的 UTF-8 no BOM；修改后必须收敛为 UTF-8 BOM'
                Current = $current
                Baseline = $baseline
                BaselineLabel = [string]$baselinePath
            }
        }

        return [pscustomobject]@{
            Status = 'PASS'
            Reason = '编码/BOM 分类与 Git 基线一致'
            Current = $current
            Baseline = $baseline
            BaselineLabel = [string]$baselinePath
        }
    }

    if (
        $Extension -ne '.rc' -and
        $baseline.Candidate -eq 'utf8-no-bom' -and
        $baseline.HasNonAscii -and
        $current.Candidate -eq 'utf8-bom'
    ) {
        return [pscustomobject]@{
            Status = 'PASS'
            Reason = '允许将不兼容 VS2013 的非 ASCII UTF-8 no BOM 源码收敛为 UTF-8 BOM'
            Current = $current
            Baseline = $baseline
            BaselineLabel = [string]$baselinePath
        }
    }

    return [pscustomobject]@{
        Status = 'FAIL'
        Reason = "编码/BOM 分类从 $($baseline.Candidate) 变为 $($current.Candidate)"
        Current = $current
        Baseline = $baseline
        BaselineLabel = [string]$baselinePath
    }
}

# 验证单个文件
function Test-FileEncoding {
    param([string]$FilePath)

    try {
        $currentContent = Get-CurrentEncodingBytes -FilePath $FilePath
        $bytes = $currentContent.Bytes
        $extension = [System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()
        $policy = Get-BomPolicy -Extension $extension
        $profile = Get-EncodingProfile -Bytes $bytes
        $hasBom = $profile.HasBom
        $isUtf8 = $profile.IsUtf8

        $status = 'PASS'
        $reason = ''
        $baselineEncoding = ''

        if ($policy -eq 'PreserveExisting') {
            $comparison = Test-PreserveExistingEncoding -FilePath $FilePath -Bytes $bytes -Extension $extension
            $status = $comparison.Status
            $reason = $comparison.Reason
            $profile = $comparison.Current
            $hasBom = $profile.HasBom
            $isUtf8 = $profile.IsUtf8
            if ($null -ne $comparison.Baseline) {
                $baselineEncoding = "$($comparison.Baseline.Candidate) ($($comparison.BaselineLabel))"
            }
            else {
                $baselineEncoding = $comparison.BaselineLabel
            }
        }
        elseif (-not $isUtf8) {
            $status = 'FAIL'
            $reason = '不是有效的UTF-8编码'
        }
        elseif ($policy -eq 'Forbidden' -and $hasBom) {
            $status = 'FAIL'
            $reason = '不应有BOM标记'
        }
        elseif ($policy -eq 'N/A') {
            $status = 'SKIP'
            $reason = '文件类型不在规范范围内'
        }

        return [pscustomobject]@{
            Status = $status
            Path = Get-RelativePath -AbsolutePath $FilePath
            Extension = $extension
            Policy = $policy
            IsUtf8 = $isUtf8
            HasBom = $hasBom
            CurrentEncoding = $profile.Candidate
            BaselineEncoding = $baselineEncoding
            CurrentSource = $currentContent.Source
            Reason = $reason
        }
    }
    catch {
        return [pscustomobject]@{
            Status = 'ERROR'
            Path = Get-RelativePath -AbsolutePath $FilePath
            Extension = [System.IO.Path]::GetExtension($FilePath)
            Policy = 'N/A'
            IsUtf8 = $false
            HasBom = $false
            CurrentEncoding = ''
            BaselineEncoding = ''
            CurrentSource = if ($Mode -eq 'Staged') { 'git-index' } else { 'git-head' }
            Reason = "读取文件失败: $($_.Exception.Message)"
        }
    }
}

function Invoke-GitPathList {
    param([string[]]$Arguments)

    $raw = @(& git @Arguments 2>$null)
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "git path query failed (exit=$exitCode): git $([string]::Join(' ', $Arguments))"
    }

    $nulSeparated = [string]::Join('', @($raw | ForEach-Object { [string]$_ }))
    if ([string]::IsNullOrEmpty($nulSeparated)) {
        return @()
    }
    return @($nulSeparated.Split([char]0, [System.StringSplitOptions]::RemoveEmptyEntries))
}

function Set-BaselinePathMap {
    param(
        [string]$BaselineCommit,
        [string[]]$NameStatusTokens
    )

    $Script:BaselineCommit = $BaselineCommit
    $Script:BaselinePathMap = @{}
    $changedPaths = New-Object System.Collections.Generic.List[string]

    for ($index = 0; $index -lt $NameStatusTokens.Count;) {
        $status = [string]$NameStatusTokens[$index]
        $index++
        if ([string]::IsNullOrWhiteSpace($status)) {
            continue
        }

        if ($status.StartsWith('R', [System.StringComparison]::Ordinal) -or $status.StartsWith('C', [System.StringComparison]::Ordinal)) {
            if (($index + 1) -ge $NameStatusTokens.Count) {
                throw "Malformed git name-status rename/copy entry: $status"
            }
            $oldPath = ([string]$NameStatusTokens[$index]).Replace('\', '/')
            $newPath = ([string]$NameStatusTokens[$index + 1]).Replace('\', '/')
            $index += 2
            $Script:BaselinePathMap[$newPath] = $oldPath
            [void]$changedPaths.Add($newPath)
            continue
        }

        if ($index -ge $NameStatusTokens.Count) {
            throw "Malformed git name-status entry: $status"
        }
        $path = ([string]$NameStatusTokens[$index]).Replace('\', '/')
        $index++
        if ($status.StartsWith('A', [System.StringComparison]::Ordinal)) {
            $Script:BaselinePathMap[$path] = $null
        }
        else {
            $Script:BaselinePathMap[$path] = $path
        }
        [void]$changedPaths.Add($path)
    }

    return @($changedPaths)
}

function Resolve-SupportedFilePaths {
    param([string[]]$GitPaths)

    $repoRoot = Get-RepoRoot
    $files = New-Object System.Collections.Generic.List[string]
    foreach ($file in $GitPaths) {
        $extension = [System.IO.Path]::GetExtension($file).ToLowerInvariant()
        if ($SupportedExtensions -contains $extension) {
            [void]$files.Add((Join-Path -Path $repoRoot -ChildPath $file))
        }
    }
    return @($files)
}

# 获取暂存文件列表
function Get-StagedFiles {
    $baselineCommit = (& git rev-parse --verify 'HEAD^{commit}' 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($baselineCommit)) {
        throw 'Cannot resolve HEAD as the staged encoding baseline'
    }

    $nameStatusTokens = @(Invoke-GitPathList -Arguments @(
        '-c', 'core.quotepath=false',
        'diff', '--cached', '--name-status', '--find-renames', '--diff-filter=ACMR', '-z', '--'
    ))
    $stagedFiles = @(Set-BaselinePathMap -BaselineCommit $baselineCommit -NameStatusTokens $nameStatusTokens)
    return @(Resolve-SupportedFilePaths -GitPaths $stagedFiles)
}

# 获取变更文件列表（CI环境）
function Get-ChangedFiles {
    # 获取当前分支与目标分支的差异
    $resolvedTargetBranch = $TargetBranch
    if ([string]::IsNullOrWhiteSpace($resolvedTargetBranch)) {
        $resolvedTargetBranch = $env:CI_MERGE_REQUEST_TARGET_BRANCH_NAME
    }
    if ([string]::IsNullOrWhiteSpace($resolvedTargetBranch)) {
        $resolvedTargetBranch = $env:GITHUB_BASE_REF
    }
    if ([string]::IsNullOrWhiteSpace($resolvedTargetBranch)) {
        $resolvedTargetBranch = "origin/main"
    }

    $resolvedTarget = (& git rev-parse --verify --quiet "$resolvedTargetBranch`^{commit}" 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($resolvedTarget)) {
        throw "Target branch/commit cannot be resolved: $resolvedTargetBranch"
    }

    $baselineCommit = (& git merge-base $resolvedTarget HEAD 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($baselineCommit)) {
        throw "Cannot resolve merge-base for encoding comparison: $resolvedTargetBranch...HEAD"
    }

    $nameStatusTokens = @(Invoke-GitPathList -Arguments @(
        '-c', 'core.quotepath=false',
        'diff', '--name-status', '--find-renames', '--diff-filter=ACMR', '-z',
        "$baselineCommit..HEAD", '--'
    ))
    $changedFiles = @(Set-BaselinePathMap -BaselineCommit $baselineCommit -NameStatusTokens $nameStatusTokens)
    return @(Resolve-SupportedFilePaths -GitPaths $changedFiles)
}

# 生成修复建议
function Get-FixSuggestion {
    param(
        [string]$FilePath,
        [string]$Extension,
        [bool]$HasBom
    )

    if ($PreserveExistingExtensions -contains $Extension) {
        return "先运行 encoding-bom-guard 探测原编码/BOM/换行，再按原格式写回"
    }
    elseif ($BomForbiddenExtensions -contains $Extension -and $HasBom) {
        return "使用以下命令移除BOM: `$enc = New-Object System.Text.UTF8Encoding(`$false); `$text = [System.IO.File]::ReadAllText(`"$FilePath`"); [System.IO.File]::WriteAllText(`"$FilePath`", `$text, `$enc)"
    }

    return "请检查文件编码是否为UTF-8"
}

# 生成报告
function Generate-Report {
    param(
        [object[]]$Results,
        [string]$ReportPath
    )

    $reportLines = New-Object System.Collections.Generic.List[string]
    $reportLines.Add("=" * 80)
    $reportLines.Add("CI/CD编码检查报告")
    $reportLines.Add("=" * 80)
    $reportLines.Add("")
    $reportLines.Add("检查时间: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
    $reportLines.Add("检查模式: {0}" -f $Mode)
    $reportLines.Add("仓库根目录: {0}" -f (Get-RepoRoot))
    $reportLines.Add("")
    $reportLines.Add("-" * 80)
    $reportLines.Add("检查结果统计")
    $reportLines.Add("-" * 80)
    $reportLines.Add("总计: {0}" -f $Script:TotalFiles)
    $reportLines.Add("通过: {0}" -f $Script:PassedFiles)
    $reportLines.Add("失败: {0}" -f $Script:FailedFiles)
    $reportLines.Add("跳过: {0}" -f $Script:SkippedFiles)
    $reportLines.Add("")

    if ($Script:FailedFilesList.Count -gt 0) {
        $reportLines.Add("-" * 80)
        $reportLines.Add("失败文件列表")
        $reportLines.Add("-" * 80)
        foreach ($file in $Script:FailedFilesList) {
            $reportLines.Add("  - {0}" -f $file)
        }
        $reportLines.Add("")
    }

    $reportLines.Add("-" * 80)
    $reportLines.Add("详细检查结果")
    $reportLines.Add("-" * 80)
    $reportLines.Add("")

    foreach ($result in $Results) {
        $reportLines.Add(("[{0}] {1}" -f $result.Status, $result.Path))
        $reportLines.Add("  文件类型: {0}" -f $result.Extension)
        $reportLines.Add("  BOM策略: {0}" -f $result.Policy)
        $reportLines.Add("  当前内容源: {0}" -f $result.CurrentSource)
        $reportLines.Add("  是否UTF-8: {0}" -f $result.IsUtf8)
        $reportLines.Add("  是否有BOM: {0}" -f $result.HasBom)
        if (-not [string]::IsNullOrWhiteSpace([string]$result.CurrentEncoding)) {
            $reportLines.Add("  当前编码: {0}" -f $result.CurrentEncoding)
        }
        if (-not [string]::IsNullOrWhiteSpace([string]$result.BaselineEncoding)) {
            $reportLines.Add("  基线编码: {0}" -f $result.BaselineEncoding)
        }
        if (-not [string]::IsNullOrWhiteSpace($result.Reason)) {
            $reportLines.Add("  原因: {0}" -f $result.Reason)
        }
        $reportLines.Add("")
    }

    $reportLines.Add("=" * 80)

    $reportContent = [string]::Join([Environment]::NewLine, $reportLines)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($ReportPath, $reportContent, $utf8NoBom)

    Write-Log "报告已保存: $ReportPath" -Level Success
}

# 主函数
function Main {
    Write-Log "开始CI/CD编码检查..." -Level Info
    Write-Log "检查模式: $Mode" -Level Info

    # 获取文件列表
    $files = @()

    switch ($Mode) {
        'Staged' {
            Write-Log "获取暂存文件列表..." -Level Info
            $files = @(Get-StagedFiles)
        }
        'Changed' {
            Write-Log "获取变更文件列表..." -Level Info
            $files = @(Get-ChangedFiles)
        }
    }

    if ($files.Count -eq 0) {
        Write-Log "没有找到需要检查的文件" -Level Warning
        if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
            Generate-Report -Results @() -ReportPath $OutputPath
        }
        return 0
    }

    Write-Log ("找到 {0} 个文件需要检查" -f $files.Count) -Level Info

    # 检查文件
    $results = @()
    $Script:TotalFiles = $files.Count

    foreach ($file in $files) {
        $result = Test-FileEncoding -FilePath $file
        $results += $result

        switch ($result.Status) {
            'PASS' {
                $Script:PassedFiles++
                Write-Log ("通过: {0}" -f $result.Path) -Level Success
            }
            'FAIL' {
                $Script:FailedFiles++
                $Script:FailedFilesList.Add($result.Path)
                Write-Log ("失败: {0} - {1}" -f $result.Path, $result.Reason) -Level Error

                if ($FailFast) {
                    Write-Log "遇到第一个失败，立即退出" -Level Error
                    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
                        Generate-Report -Results $results -ReportPath $OutputPath
                    }
                    return 1
                }
            }
            'SKIP' {
                $Script:SkippedFiles++
                if ($LogLevel -eq 'Verbose') {
                    Write-Log ("跳过: {0} - {1}" -f $result.Path, $result.Reason) -Level Warning
                }
            }
            'ERROR' {
                $Script:FailedFiles++
                $Script:FailedFilesList.Add($result.Path)
                Write-Log ("错误: {0} - {1}" -f $result.Path, $result.Reason) -Level Error

                if ($FailFast) {
                    Write-Log "遇到第一个错误，立即退出" -Level Error
                    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
                        Generate-Report -Results $results -ReportPath $OutputPath
                    }
                    return 1
                }
            }
        }

    }

    # 输出统计
    Write-Log "" -Level Info
    Write-Log "检查完成" -Level Info
    Write-Log ("总计: {0} | 通过: {1} | 失败: {2} | 跳过: {3}" -f `
        $Script:TotalFiles, $Script:PassedFiles, $Script:FailedFiles, $Script:SkippedFiles) -Level Info

    # 生成报告
    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Generate-Report -Results $results -ReportPath $OutputPath
    }

    # 返回退出码
    if ($Script:FailedFiles -gt 0) {
        Write-Log "编码检查失败，请修复上述问题后重试" -Level Error
        return 1
    }

    Write-Log "编码检查通过！" -Level Success
    return 0
}

# 执行主函数
$exitCode = Main
exit $exitCode
