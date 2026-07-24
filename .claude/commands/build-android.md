---
name: build-android
version: 1.2.0
description: 编译 Android 客户端 APK（Locojoy，带结构门禁）
linked-skill: client/android-build
linked-agent: build-expert
allowed-tools:
  - Bash
---

# Android 客户端编译命令

如本轮包含资源改动，先在 `client/resource/res/**` 修改源资源，再执行资源打包脚本；`client/android/LocojoyProject/assets/res/**` 禁止手动修改：

```powershell
cmd /c "cd /d E:\MT3\client\resource\tools && LJFilePack_打包安卓.bat"
```

**关联技能**: [android-build](../skills/client/android-build.md)
**关联代理**: [build-expert](../agents/build-expert.md)

优先使用仓库脚本，统一执行 `ndk-build -> ant debug/release -> APK 结构门禁 -> ABI 门禁 -> zipalign`。

## 推荐命令

```powershell
# 免费服（默认）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-Android-Locojoy-WithGate.ps1 -ProjectDir "client/android/LocojoyProject" -BuildType Debug -Channel free -Jobs 4 -CleanIntermediates -NdkBuildPath "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd" -JdkHome "C:\Program Files\Java\jdk1.8.0_144" -AndroidSdkRoot "D:\android-sdk_r24.1.2-windows\android-sdk-windows" -RequireArm64InApk

# 需要把打包后的 client/res_android/res 同步到 assets/res 时（assets/res 仍禁止手改）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-Android-Locojoy-WithGate.ps1 -ProjectDir "client/android/LocojoyProject" -BuildType Debug -Channel free -SyncRes -RequireArm64InApk
```

## 前置条件

- NDK 为 `r16 clang`（当前已验证 `D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd`）
- Ant 可用（默认可走 `D:\apache-ant-1.9.7\bin\ant.bat`）
- SDK `build-tools/22.0.1`、`platforms/android-22` 存在

## 产物

- 免费服 Debug：`client/android/LocojoyProject/bin/mt3-debug.apk`
- 免费服 Release：`client/android/LocojoyProject/bin/mt3-release.apk`
- 点卡服当前未恢复/未验证；脚本会拒绝 `-Channel monthpayment`。

执行后会输出 APK 路径、大小、MD5、SHA256 和结构门禁结果。
