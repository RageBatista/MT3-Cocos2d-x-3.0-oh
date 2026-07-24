# CEGUI 0.7.1 + Cocos2d-x 2.2.6 Shadow 人工工作流

> 版本: 2.0.0
> 更新: 2026-07-12
> 状态: `manual/external-source`
> 声明式目录: workflow catalog sidecar 中的 `cocos-cegui-shadow-migration`；资源绑定检查另见 `cegui-layout-integration`

本文件不再沿用历史版本或“一键稳定构建”结论。当前 MT3 锚点是运行时工作区中的 `tools/CEGUI-0.7.1`，以及已跟踪的 `cocos2d-x-2.2.6` shadow。前者在 clean checkout 可能不存在且可能未跟踪，因此任何编译前必须先过路径、Git 跟踪状态和人工来源门禁。

## 1. Cocos shadow 与门禁脚本

在仓库根目录使用 PowerShell：

```powershell
$repoRoot = (Resolve-Path .).Path
$cocosRelative = "cocos2d-x-2.2.6"
$cocosRoot = Join-Path $repoRoot $cocosRelative
$sourceGateRelative = "tools/scripts/Assert-Cocos226SourceGate.ps1"
$sourceGate = Join-Path $repoRoot $sourceGateRelative

& git ls-files --error-unmatch -- $sourceGateRelative 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Cocos source gate is not tracked: $sourceGateRelative" }
if (-not (Test-Path -LiteralPath $sourceGate -PathType Leaf)) { throw "Cocos source gate is missing: $sourceGate" }

$trackedCocosFiles = @(& git ls-files -- "$cocosRelative/**")
if ($trackedCocosFiles.Count -eq 0) { throw "Cocos2d-x 2.2.6 shadow is not tracked" }
if (-not (Test-Path -LiteralPath $cocosRoot -PathType Container)) { throw "Cocos2d-x 2.2.6 shadow is missing: $cocosRoot" }

& powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $sourceGate -Json
if ($LASTEXITCODE -ne 0) { throw "Cocos2d-x 2.2.6 source gate failed" }
```

## 2. CEGUI 外部源码人工门禁

```powershell
$ceguiRelative = "tools/CEGUI-0.7.1"
$ceguiRoot = Join-Path $repoRoot $ceguiRelative
$ceguiProject = Join-Path $ceguiRoot "projects/premake/BaseSystem/CEGUIBase.vcxproj"
$trackedCeguiFiles = @(& git ls-files -- "$ceguiRelative/**")
$manualExternalSourceApproved = $false

if (-not (Test-Path -LiteralPath $ceguiRoot -PathType Container)) {
    throw "EXTERNAL_REQUIRED: CEGUI 0.7.1 source tree is absent from this checkout"
}
if ($trackedCeguiFiles.Count -eq 0 -and -not $manualExternalSourceApproved) {
    throw "MANUAL_REQUIRED: CEGUI 0.7.1 is workspace-local/untracked; review provenance and diff before approval"
}
if (-not (Test-Path -LiteralPath $ceguiProject -PathType Leaf)) {
    throw "CEGUIBase project is missing: $ceguiProject"
}
```

只有人工核对来源、版本、`git status --short -- tools/CEGUI-0.7.1` 和目标工程后，才可在当前会话显式把 `$manualExternalSourceApproved` 设为 `$true`。不得把缺失的外部树伪装成 tracked/active 工作流。

## 3. 手工构建（门禁通过后）

```powershell
$msbuild = "C:/Program Files (x86)/MSBuild/12.0/Bin/MSBuild.exe"
if (-not (Test-Path -LiteralPath $msbuild -PathType Leaf)) { throw "MSBuild 12.0 is missing: $msbuild" }
if (-not $manualExternalSourceApproved -and $trackedCeguiFiles.Count -eq 0) { throw "CEGUI manual source gate was not approved" }

& $msbuild $ceguiProject /t:Build /p:Configuration=Debug /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo
if ($LASTEXITCODE -ne 0) { throw "CEGUI 0.7.1 Debug build failed" }
```

Release 构建使用同一项目与 `Configuration=Release`，但不得根据历史“错误数量”批量排除源文件。先以当前工程、首个编译/链接错误和 Cocos renderer 依赖为证据。

## 4. 下游验证

1. 记录 CEGUI 工程、配置、工具集、退出码和实际 `.lib/.dll` 路径；不写死历史体积。
2. 若改动影响 Cocos shadow，先重编 Cocos，再重编 `engine -> FireClient -> MT3`，禁止混用旧 ABI 产物。
3. MT3 产物存在后运行已跟踪的 `tools/scripts/Assert-Cocos226BinaryGate.ps1`；执行前同样先做 `git ls-files` 与 `Test-Path`。
4. 布局、Scheme、LookNFeel 或 WidgetLook 问题转 `cegui-layout-integration`，不要把 XML 资源错误归为 CEGUI 库编译失败。
5. 运行时崩溃转 `runtime-crash-workflow`；纯 LNK/MSB/C 编译错误留在构建诊断。

## 关联视图

- [Windows 构建工作流](windows-build-workflow.md)
- [错误诊断兼容视图](error-diagnosis-workflow.md)
- [工作流索引](README.md)
