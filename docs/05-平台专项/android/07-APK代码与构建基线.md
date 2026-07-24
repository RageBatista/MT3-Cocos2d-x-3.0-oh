# Android APK 代码与构建基线

> 返回 [Android 文档索引](00-README.md)。本页固定当前 `LocojoyProject/free` 的代码、SDK、JNI、分辨率与构建事实。

## 1. 工程事实源

- Manifest：`client/android/LocojoyProject/AndroidManifest.xml`
- Java：`client/android/LocojoyProject/src/**`
- Native：`client/android/LocojoyProject/jni/Android.mk`、`Application.mk`、`main.cpp`
- 构建：`client/android/LocojoyProject/build.xml`、`project.properties`
- Wrapper：`tools/scripts/Build-Android-Locojoy-WithGate.ps1`
- 公共 SDK：`client/android/common/src/com/locojoy/sdk/**`、`client/android/common/libs/ljsdk_sample.jar`

## 2. 当前构建基线

| 项 | 当前事实 |
| --- | --- |
| 工具链 | `NDK r16 clang + Ant + JDK 8 + Python 2.7` |
| 工程/渠道 | `client/android/LocojoyProject` / `free` |
| `project.properties` | `target=android-22` |
| Manifest | `minSdkVersion=11`、`targetSdkVersion=27` |
| Native | `arm64-v8a`、`android-21`、`c++_shared`、`clang` |
| Debug 输出 | `client/android/LocojoyProject/bin/mt3-debug.apk` |
| Release 输出 | `client/android/LocojoyProject/bin/mt3-release.apk` |

输出约定来自 wrapper 的 `New-AndroidBuildPlan`，不是从旧 APK 目录推测。

## 3. Java 与 SDK 组织

核心入口：

- `com.locojoy.mini.mt3.Mt3Application`
- `com.locojoy.mini.mt3.GameApp`

`com.locojoy.sdk` 当前拆分：

- 源码提供：`GameSDK.java`、`SDKShare.java`
- `ljsdk_sample.jar` 提供：`LocojoySDK`、`LdSdk`、`SdkListener`

任何缺类问题先核对这三项，不从生成目录复制未知 jar 覆盖。

## 4. JNI 与 ARM64 基线

- `Cocos2dxActivity.setPackageName()` 先调用 `nativeInitJniBridge(this)`，再调用 `nativeSetPaths(...)`。
- `JniHelper` 缓存 Activity `ClassLoader`，Native 线程下可用 `loadClass` 兜底。
- `cocos2d-x-2.2.6/cocos2dx/Android.mk` 从当前 2.2.6 树导入 `libxml2`、`libwebp`。
- arm64 预编译库与第三方 so 必须通过 `Assert-AndroidArm64Migration.ps1`。

详细步骤见 [ARM64 适配](09-ARM64适配.md)。

## 5. 资源边界

```text
源目录: client/resource/res/**
打包入口: client/resource/tools/LJFilePack_打包安卓.bat
生成目录: client/android/LocojoyProject/assets/res/**
规则: 生成目录不接受业务手工修改
```

`client/res_android/res/**` 是同步输入，资源删除还需注意 wrapper 当前采用 `robocopy /E`。

## 6. UI 分辨率锚点

`client/FireClient/Application/Framework/ResolutionAdapter.cpp` 当前 Android 基线：

- render：`1080 x 720`
- UI：`1080 x 720`
- `c_max_ui_scale = 2.00f`

UI 专项不得通过改变构建工具链或 APK 输出路径来修复；应回到共享 C++、Lua、布局与运行日志。

## 7. 当前构建门禁

wrapper 在打包后执行：

- APK Entry Count/ZIP64 结构检查；
- arm64 ABI 与必需 so 检查；
- LJFM 资源路径检查；
- 音频 JNI bridge 检查；
- 启动黑屏防护检查；
- `zipalign -c 4` 与 `aapt dump badging`；
- MD5/SHA256 输出。

构建命令见 [构建流程](04-构建流程.md)。

## 8. 历史批次边界

`2026-06-19` 批次冻结的 `build/bin/mt3-release.apk`、哈希、签名与 MuMu 结果已迁入 [Android arm64 free 专项审计](../../09-历史归档/专项审计/Android-arm64-free/2026-06-19-最终发布说明.md)。这些值仅证明当日样本，不覆盖当前 wrapper 的 `bin/mt3-*.apk` 输出约定。
