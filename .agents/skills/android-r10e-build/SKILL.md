---
name: android-r10e-build
description: "MT3 Android 客户端构建技能。处理 NDK、Ant、渠道工程、JNI 原生编译/链接、APK 打包或 Android 工具链兼容问题；不用于 JNI 注册/回调与 Activity 运行时生命周期、共享 C++ 主链、纯渲染或纯资源发布。"
---

当前免费服主线固定为 `JDK 8 + NDK r16 clang + Ant + Python 2.7`。技能名中的 r10e 只保留历史兼容，禁止把 r10e/GCC 或 Gradle 当作当前 arm64 主线。

## 何时使用

- Android native/JNI 编译、Ant 打包、签名、zipalign、APK 结构或 ABI 门禁失败
- 渠道工程差异、JDK/SDK/NDK 漂移、`aapt`/Ant 不可见
- 需要确认 Locojoy 免费服构建入口、顺序、产物与发布前校验

## 不使用

- 共享 C++ 登录入世界或业务逻辑问题，用 `application-core-flow`
- JNI 注册/回调、Activity/Application 生命周期或渠道 SDK 运行时桥接，用 `platform-bridge`
- CEGUI/UI/纯渲染问题，用 `cegui-layout-integration` 或 `rendering-pipeline`
- 热更新、版本索引、资源包发布问题，用 `resource-packaging-pipeline`

## 输入校验

1. 先区分 `构建失败`、`运行时闪退`、`UI 比例`、`网络/热更`，一轮只处理一个主故障域。
2. 确认 JDK8、完整旧 SDK、NDK r16 clang、Ant、aapt 与首个失败命令。
3. 收集构建日志、`adb logcat`、APK 门禁或渠道差异中的首个阻塞证据。
4. 信息不足时用 `../mt3-project-guidelines/references/high-frequency-fact-packs.md` 的 Android 模板。
5. 先跑快速体检：

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\android-r10e-build\scripts\verify-android-r10e-env.ps1 -Json
```

## 关键边界

- 唯一 canonical wrapper 是 `tools/scripts/Build-Android-Locojoy-WithGate.ps1`；先看它的 `-PlanOnly -Json`，不从旧 bat 或历史目录猜主线。
- 当前只验证 `client/android/LocojoyProject` 的 `free` 渠道；`monthpayment` 因 `build_monthpayment.xml` 缺失必须拒绝。
- Java/Ant 打包必须 JDK8；JDK9+，特别是 JDK17，会使旧 `source/target 1.5` 失败。
- `ANDROID_HOME/ANDROID_SDK_ROOT` 必须是含 `tools/ant/build.xml`、`platform-tools`、`build-tools/22.0.1` 与 `platforms/android-22` 的完整旧 SDK。
- native 主线使用 NDK r16 clang；禁止回退 r10e/GCC，禁止用 Gradle 替换 Ant。
- 业务资源源头是 `client/resource/res/**`；`client/res_android/res` 是 staging，`client/android/LocojoyProject/assets/res/**` 是生成物，禁止手改。
- Release 密码只从 `MT3_ANDROID_*` 环境变量、CI Secret 或显式参数注入，禁止提交到 `ant.properties`。

## 最短流程

1. 跑环境体检与 JDK8/arm64 门禁。
2. 用 canonical wrapper 的 `-PlanOnly -Json` 核对工程、工具链、ABI、输出路径与资源条件。
3. 资源有改动时先通过 runtime-local LJFilePack 链生成 `client/res_android/res`，再启用 `-SyncRes`。
4. 执行 canonical 构建；脚本负责 `ndk-build -> ant -> APK structure/ABI -> zipalign/aapt`。
5. 核对 APK、哈希、badging；运行时任务再做安装、logcat 与登录入世界回归。

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_144"
$env:ANDROID_HOME = "D:\android-sdk_r24.1.2-windows\android-sdk-windows"
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-Android-Locojoy-WithGate.ps1 `
  -ProjectDir "client/android/LocojoyProject" -BuildType Debug -Channel free -Jobs 4 `
  -SyncRes -ResSourceDir "client/res_android/res" `
  -NdkBuildPath "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd" `
  -JdkHome $env:JAVA_HOME -AndroidSdkRoot $env:ANDROID_HOME -RequireArm64InApk
```

日常增量不加 `-Clean`；ABI/工具链漂移、脏中间产物或发版验收才清理。Release 命令与签名注入见 `references/android-build-details.md`。

## 失败处理

- JDK17、不完整 SDK、Gradle 或错误 NDK 漂移：先恢复固定工具链，不改业务代码。
- `tools/ant/build.xml` 或 platform-tools 缺失：切换到完整旧 SDK，不在工程内绕过门禁。
- `com.locojoy.sdk` 缺类：检查 `client/android/common/libs/ljsdk_sample.jar` 与 `libs` 接入。
- APK entry 超限、ZIP64、ABI/so 缺失：停止投放，按 canonical gate 的首错处理。
- 运行时崩溃先保留 logcat，再切 `platform-bridge` 或 `application-core-flow`；不要顺手改 UI、网络和退出流程。

## 输出与验证

- 输出：主故障域、工具链状态、首个阻塞点、canonical 命令、产物与验证结果。
- 构建类至少验证 wrapper 退出码、APK 存在、structure/ABI gate、`zipalign -c` 或 `aapt dump badging`。
- 登录链任务还需首屏正常、连续 3 次进入且 logcat 无新增 `FATAL EXCEPTION/SIGSEGV/UnsatisfiedLinkError`。
- 机器可读体检优先使用 `verify-android-r10e-env.ps1 -Json`。

## 资源与上下文预算

- 默认只读当前日志、canonical wrapper、目标渠道工程和首个阻塞证据。
- 环境基线、完整 Debug/Release 命令、SDK 类与故障矩阵按需读 `references/android-build-details.md`。

## 需要时再读

- `references/android-build-details.md`
- `.claude/BUILD_GUIDE.md`
- `.claude/skills/client/android-build.md`
- `docs/05-平台专项/android/07-APK代码与构建基线.md`
- `docs/05-平台专项/android/08-MeiqiaSdk-dx兼容修复.md`
