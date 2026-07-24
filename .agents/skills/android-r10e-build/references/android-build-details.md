# Android r16/Ant 构建细节

## 当前工程与工具链实物

- canonical wrapper：`tools/scripts/Build-Android-Locojoy-WithGate.ps1`
- 前置门禁：`tools/scripts/Assert-AndroidJdk8Gate.ps1`、`Assert-AndroidArm64Migration.ps1`
- APK 门禁：`Assert-ApkInstallableStructure.ps1`、`Assert-ApkAbiContents.ps1`
- 主工程：`client/android/LocojoyProject/build.xml`
- 共享层：`client/android/common`
- 其他渠道：`client/android/JoysdkProject`、`client/android/YijieProject`
- `client/android/LocojoyProject64` 已废弃，不作为免费服或 MuMu 输出目录。
- `client/android` 无 Gradle wrapper、`build.gradle` 或 `settings.gradle`；不得凭空引入 Gradle 主线。

当前工作机已验证环境：

- JDK：`C:\Program Files\Java\jdk1.8.0_144`
- Ant SDK：`D:\android-sdk_r24.1.2-windows\android-sdk-windows`
- NDK：`D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd`
- APK：`client/android/LocojoyProject/bin/mt3-debug.apk` 或 `mt3-release.apk`

只有 `D:\Android\android-sdk-64` 时缺少 Ant SDK 实物，不能作为 `ANDROID_HOME`。

## SDK 恢复基线

- `client/android/common/src/com/locojoy/sdk/GameSDK.java`
- `client/android/common/src/com/locojoy/sdk/SDKShare.java`
- `client/android/common/libs/ljsdk_sample.jar`

jar 提供 `com.locojoy.sdk.LocojoySDK`、`LdSdk`、`SdkListener`。缺类时先检查 jar 与工程 `libs`，不要写空壳类绕过编译。

## PlanOnly 预检

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-Android-Locojoy-WithGate.ps1 `
  -ProjectDir "client/android/LocojoyProject" -BuildType Debug -Channel free `
  -JdkHome $env:JAVA_HOME -AndroidSdkRoot $env:ANDROID_HOME -PlanOnly -Json
```

PlanOnly 应确认：Ant 工程、JDK8、完整 SDK、NDK r16、free 渠道、arm64 输入、输出 APK 与各 gate。

## Release 免费服

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_144"
$env:ANDROID_HOME = "D:\android-sdk_r24.1.2-windows\android-sdk-windows"
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:MT3_ANDROID_KEYSTORE = "E:\MT3\client\chuhancommon\android_adt"
$env:MT3_ANDROID_KEY_ALIAS = "LJ"
$env:MT3_ANDROID_KEYSTORE_PASSWORD = "<本机或 CI Secret 注入>"
$env:MT3_ANDROID_KEY_ALIAS_PASSWORD = "<本机或 CI Secret 注入>"
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-Android-Locojoy-WithGate.ps1 `
  -ProjectDir "client/android/LocojoyProject" -BuildType Release -Channel free -Jobs 4 `
  -SyncRes -ResSourceDir "client/res_android/res" `
  -NdkBuildPath "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd" `
  -JdkHome $env:JAVA_HOME -AndroidSdkRoot $env:ANDROID_HOME -RequireArm64InApk
```

`monthpayment` 当前未恢复。wrapper 应拒绝它，直到 `client/android/LocojoyProject/build/build_monthpayment.xml` 恢复并重新验收。

## 顺序与资源约束

1. 清理构建：`ndk-build clean -> ndk-build -> ant clean debug/release`。
2. 增量构建不带 `-Clean`。
3. 资源改动先从 `client/resource/res/**` 生成 `client/res_android/res`。
4. wrapper 用 `-SyncRes` 将 staging 同步到 APK 工程生成目录。
5. 不手改 `client/android/LocojoyProject/assets/res/**`。
6. 构建后依次核对 structure、arm64 ABI/必需 so、zipalign 与 badging。

## 常见失败矩阵

| 现象 | 直接处理 |
|---|---|
| `java -version` 为 17 | 修正 `JAVA_HOME`/PATH 或显式传 `-JdkHome` |
| `source/target 5 is no longer supported` | 切回 JDK8，不改业务源码 |
| 缺 `tools/ant/build.xml` | `ANDROID_HOME` 指向完整旧 SDK |
| `SDK Platform Tools component is missing` | 补齐/切换含 platform-tools 的 SDK |
| `ndk-build` 不可见 | 校验 NDK r16 路径或显式 `-NdkBuildPath` |
| `net.sf.antcontrib` 缺失 | 校验 Ant `lib` 中 ant-contrib jar |
| 点卡服入口失效 | 保持阻断，先恢复并验收 monthpayment build 文件 |
| `com.locojoy.sdk` 缺类 | 校验 `ljsdk_sample.jar` 与 `libs` |
| APK structure/ABI gate 失败 | 停止投放，按首个 entry/ZIP64/so 错误修复 |

## 构建后验证

```powershell
Get-Item .\client\android\LocojoyProject\bin\mt3-debug.apk
Get-FileHash .\client\android\LocojoyProject\bin\mt3-debug.apk -Algorithm SHA256
& "D:\android-sdk_r24.1.2-windows\android-sdk-windows\build-tools\22.0.1\aapt.exe" dump badging .\client\android\LocojoyProject\bin\mt3-debug.apk
```

需要安装/运行时回归时再执行 `adb install -r` 与 `adb logcat`。登录链必须连续 3 次稳定进入，且无新增 fatal、SIGSEGV 或 JNI 链接错误。

## 深度文档

- `.claude/BUILD_GUIDE.md`
- `.claude/skills/client/android-build.md`
- `docs/05-平台专项/android/07-APK代码与构建基线.md`
- `docs/05-平台专项/android/08-MeiqiaSdk-dx兼容修复.md`
