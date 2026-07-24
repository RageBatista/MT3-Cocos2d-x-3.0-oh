# Android 构建兼容工作流（NDK r16 clang + Ant）

> 版本: 2.0.0
> 更新: 2026-07-12
> 状态: `manual`；需要本机 JDK 8、完整旧 Android SDK、NDK r16 clang 与 Ant
> 声明式目录: `.codex/workflows/workflow-engine.json` sidecar 中的 `android-build`

本文件是 Claude 兼容人工视图。唯一 canonical 入口是 `tools/scripts/Build-Android-Locojoy-WithGate.ps1`；不要把 `ndk-build`、`ant` 或渠道脚本拆出来当作新的主入口。

## 1. 入口与工作树门禁

在仓库根目录运行：

```powershell
$entryRelative = "tools/scripts/Build-Android-Locojoy-WithGate.ps1"
$entry = Join-Path (Get-Location) $entryRelative

& git ls-files --error-unmatch -- $entryRelative 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Android canonical entry is not tracked: $entryRelative" }
if (-not (Test-Path -LiteralPath $entry -PathType Leaf)) { throw "Android canonical entry is missing: $entry" }

& powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $entry `
  -ProjectDir "client/android/LocojoyProject" `
  -Channel free `
  -BuildType Debug `
  -PlanOnly `
  -Json
if ($LASTEXITCODE -ne 0) { throw "Android PlanOnly gate failed" }
```

`PlanOnly` 必须先确认：JDK 8、完整旧 SDK、NDK r16、Ant、ABI、资源源和 LFS 输入。不要通过 `-NoLfsCheck` 绕过失败。

## 2. 执行构建

仅在计划门禁通过后运行 canonical 脚本：

```powershell
& powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $entry `
  -ProjectDir "client/android/LocojoyProject" `
  -Channel free `
  -BuildType Debug `
  -Clean `
  -SyncRes `
  -ResSourceDir "client/res_android/res" `
  -RequireArm64InApk
if ($LASTEXITCODE -ne 0) { throw "Android canonical build failed" }
```

- LFS 指针存在时，先按脚本输出执行精确 `git lfs pull/checkout`；只有明确要由入口脚本恢复时才加 `-HydrateLfs`。
- Release 签名必须使用调用方提供的 keystore/alias；凭证不得写入文档、仓库或命令历史。
- 点卡服 `monthpayment` 只有在对应构建入口恢复并重新验收后才能启用。

## 3. 验证与失败分流

至少记录以下证据：

1. canonical 脚本的 PlanOnly JSON 与最终退出码。
2. APK 路径、大小、`aapt dump badging`、`zipalign -c` 与 ABI gate。
3. 安装/启动验证；若出现 `FATAL EXCEPTION`、`SIGSEGV`、`0xC0000005` 或闪退，转 `runtime-crash-workflow`，不要归入构建失败。
4. 若失败点是 JDK/SDK/NDK/Ant、C/C++ 编译或链接，保留在本工作流并定位首个失败命令。

## 关联入口

- [Android 构建技能](../skills/client/android-build.md)
- [Android 编译完整指南](../../docs/05-平台专项/android/00-README.md)
- [错误诊断兼容视图](error-diagnosis-workflow.md)
