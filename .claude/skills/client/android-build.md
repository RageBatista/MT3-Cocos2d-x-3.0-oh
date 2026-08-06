---
name: android-build
version: 2.5.0
priority: high
category: client
description: |
  MT3 Android 客户端构建技能（2026-07-05 事实校准版）。
  统一到 Build-Android-Locojoy-WithGate.ps1、free arm64 已验证产物 mt3-debug/mt3-release.apk、
  com.locojoy.sdk 源码/jar 分层，以及“时装切换后仍显示武器”的共享 C++ 基线。
dependencies:
  - cpp-development
  - build-troubleshooting
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 10000
---

# Android 编译技能（MT3 实操对齐）

## 1. 技能目标

完成本技能后，应满足：

- 按当前仓库真实入口完成 `free` 渠道全链路构建。
- 能识别“脚本参数仍保留”和“当前工作树已有实物”之间的漂移。
- 能快速判断 `com.locojoy.sdk` 缺类是源码缺失还是 jar 引用缺失。
- 能区分 Android 平台壳问题与共享 C++ 引擎问题。

## 2. 当前仓库事实（Source of Truth）

### 2.1 已验证入口

- `tools/scripts/Build-Android-Locojoy-WithGate.ps1`
- `client/android/LocojoyProject/build.xml`
- `tools/scripts/Assert-AndroidArm64Migration.ps1`

### 2.2 当前漂移点

- `client/android/LocojoyProject/build/build_monthpayment.xml` 当前工作树不存在。
- `Build-Android-Locojoy-WithGate.ps1` 当前会拒绝 `-Channel monthpayment`，直到 `build_monthpayment.xml` 恢复并重新验收。
- `mt3_apk.bat` 仍保留“输入 2”分支，当前会指向缺失文件，不能视为已验证基线。

### 2.3 当前已验证产物

- `free` 渠道全链路已验证产物：`client/android/LocojoyProject/bin/mt3-debug.apk` / `client/android/LocojoyProject/bin/mt3-release.apk`
- 最近已验证时间：`2026-07-05`
- 原因：主入口固定 `LocojoyProject + arm64-v8a + NDK r16 clang + Ant`

### 2.4 `com.locojoy.sdk` 基线

- 源码保留：`client/android/common/src/com/locojoy/sdk/GameSDK.java`
- 源码保留：`client/android/common/src/com/locojoy/sdk/SDKShare.java`
- jar 提供：`client/android/common/libs/ljsdk_sample.jar`
- 其中 jar 已确认包含：
  - `com.locojoy.sdk.LocojoySDK`
  - `com.locojoy.sdk.LdSdk`
  - `com.locojoy.sdk.SdkListener`

## 3. 环境基线（按脚本与工程实物）

### 3.1 SDK/NDK/JDK

- SDK 根：`D:\android-sdk_r24.1.2-windows\android-sdk-windows`
- NDK 根：`D:\Android\android-sdk-64\ndk\16.1.4479499`
- JDK（主流程）：`C:\Program Files\Java\jdk1.8.0_144`

### 3.2 SDK 必备目录

- `tools`
- `platform-tools`
- `platforms\android-22`
- `build-tools\22.0.1`

### 3.3 其他依赖

- Ant 1.9.x
- `ant-contrib`（放入 `ANT_HOME\lib`）
- Python 2.7（历史脚本依赖）

## 4. 环境修复 SOP

### 4.1 首选预检

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Assert-AndroidJdk8Gate.ps1 -JdkHome "C:\Program Files\Java\jdk1.8.0_144"
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Assert-AndroidArm64Migration.ps1
```

不再使用 Machine 级环境修复脚本；构建入口在当前进程内解析 JDK8、SDK、NDK 与 Ant。

### 4.2 手动修复（无管理员时）

```cmd
setx ANDROID_HOME "D:\android-sdk_r24.1.2-windows\android-sdk-windows"
setx ANDROID_SDK_ROOT "D:\android-sdk_r24.1.2-windows\android-sdk-windows"
setx ANDROID_NDK_HOME "D:\Android\android-sdk-64\ndk\16.1.4479499"
setx NDK_HOME "D:\Android\android-sdk-64\ndk\16.1.4479499"
```

### 4.3 预检命令

```cmd
where java
where javac
where ant
where ndk-build
where aapt
java -version
javac -version
ant -version
```

## 5. 渠道构建命令（标准版）

### 5.0 推荐统一入口（Locojoy）

```powershell
# 免费服（当前已验证）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-Android-Locojoy-WithGate.ps1 -ProjectDir "client/android/LocojoyProject" -BuildType Debug -Channel free -Jobs 4 -CleanIntermediates -NdkBuildPath "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd" -JdkHome "C:\Program Files\Java\jdk1.8.0_144" -AndroidSdkRoot "D:\android-sdk_r24.1.2-windows\android-sdk-windows" -RequireArm64InApk
```

### 5.1 Locojoy 免费服

```cmd
cd /d E:\MT3\client\android\LocojoyProject
mt3_build.bat
cd build
ant -buildfile build.xml release
```

当前基线产物：`bin/mt3-debug.apk` / `bin/mt3-release.apk`

### 5.2 Locojoy 点卡服

当前工作树无 `build/build_monthpayment.xml`，因此：

- `mt3_apk.bat` 的“输入 2”不是当前已验证链路
- `-Channel monthpayment` 不是当前可直接复用基线

若后续恢复该文件，再检查：

- `jdk-folder = C:\Program Files\Java\jdk1.7.0_75`
- `ant -buildfile build_monthpayment.xml release`

### 5.3 Joysdk / Yijie

```cmd
cd /d E:\MT3\client\android\JoysdkProject
mt3_build.bat
cd build
ant release
```

```cmd
cd /d E:\MT3\client\android\YijieProject
mt3_build.bat
cd build
ant release
```

## 6. 验收标准（必须通过）

### 6.1 工具可见性

```cmd
where adb
where aapt
where zipalign
where ndk-build
```

### 6.2 APK 验证

```cmd
aapt dump badging E:\MT3\client\android\LocojoyProject\build\bin\mt3-release.apk
adb install -r E:\MT3\client\android\LocojoyProject\build\bin\mt3-release.apk
```

### 6.3 运行稳定性门禁

涉及登录首屏、UI 比例或“点击进入游戏”链路时，除构建成功外还必须满足：

1. 登录首屏背景显示正常（非拉伸错位）。
2. 点击“进入游戏”连续 3 次稳定进入，无自动退出。
3. `adb logcat` 无新增 `FATAL EXCEPTION` / `SIGSEGV` / `UnsatisfiedLinkError`。

## 7. 常见阻塞点矩阵

| 阻塞点 | 典型现象 | 处理 |
|---|---|---|
| 非管理员写 Machine 变量 | `Requested registry access is not allowed.` | 用管理员 PowerShell 重跑脚本，或改 User 级变量 |
| NDK 不可见 | `ndk-build` 找不到 | 修正 `ANDROID_NDK_HOME/NDK_HOME` + PATH，重开终端 |
| `ant-contrib` 缺失 | `taskdef class net.sf.antcontrib... not found` | 安装 `ant-contrib*.jar` 到 `ANT_HOME\lib` |
| 点卡服入口失效 | `build_monthpayment.xml` 不存在 | 当前主入口会拒绝 `-Channel monthpayment`；先恢复文件并重新验收后再开放 |
| `com.locojoy.sdk` 缺类 | `LocojoySDK/LdSdk/SdkListener` 找不到 | 检查 `ljsdk_sample.jar` 是否存在并被工程正确引用 |
| 找不到 APK | 脚本偏好名与实际产物名不一致 | 以脚本最终回显路径为准，当前 free 基线是 `bin/mt3-debug.apk` / `bin/mt3-release.apk` |

## 8. 编译与运行问题边界

### 8.1 登录/注册 URL 链路（防误改）

Android 登录/注册接口地址固定来自：

1. `client/resource/res/cfg/clientsetting_android.ini`
2. 打包哈希文件 `2863654426`
3. `GameApplication::InitIni()` 读取 `HttpSdkLoginUrl/HttpSdkRegisterUrl`
4. `client/android/LocojoyProject/assets/res/**` 只作为打包生成产物使用，严禁手工修改；URL 或资源改动必须回到 `client/resource/res/**` 后执行 `LJFilePack_打包安卓.bat`。
5. `LoginManager::LoginAccount/RegisterAccount` 发起 HTTP

当前冻结基线（2026-04-06）：

- `HttpServerAddressPlatForm=http://111.228.57.237:88/`
- `HttpSdkLoginUrl=http://111.228.57.237:88/api/sdk/user_login`
- `HttpSdkRegisterUrl=http://111.228.57.237:88/api/sdk/user_register`
- 三份文件 MD5 一致：`D88A6719B1778991107F16BDC0965DB9`

### 8.2 时装切换后武器显示（共享 C++ 规则）

目标行为：切换时装后，仍显示角色武器（时装只替换外观，不读取时装武器资源）。

固定实现位置（不要做 Android 特殊分支）：

1. `engine/sprite/nuspritemanager.cpp`
2. `ResolveWeaponSourceModel`：时装映射到 `role-*`
3. `ResolveWeaponAniUri`：weapon 动画走 `role-*` 资源
4. 时装 `weapon` 层可选（缺失不阻断）
5. `GetComponent`：时装 weapon 组件回退到 `role-*`

已验证记录：

- `2026-04-05` Android MuMu 覆盖安装 `mt3-release.apk` 实测通过
- `2026-04-06` Win32 手工切换时装实测通过
- Lua 临时兜底不属于正式基线，正式行为以共享 C++ 规则为准

## 9. VS Code 注意事项

当前 `.vscode/tasks.json` 若仍指向 `build_with_log.bat`，与仓库现状不一致。

建议：

- 直接使用终端执行本技能中的标准命令。
- 或把任务改成调用 `Build-Android-Locojoy-WithGate.ps1`。

## 10. 维护要求

以下文件发生变化时，必须同步更新本技能：

- `tools/scripts/Build-Android-Locojoy-WithGate.ps1`
- `tools/scripts/Assert-AndroidArm64Migration.ps1`
- `client/android/LocojoyProject/build.xml`
- `client/android/common/src/com/locojoy/sdk/GameSDK.java`
- `client/android/common/src/com/locojoy/sdk/SDKShare.java`
- `client/android/common/libs/ljsdk_sample.jar`

补充：

- 若后续重新引入 `build/build_monthpayment.xml`，需同步恢复点卡服章节。

## 11. 关联文档

- `docs/05-平台专项/android/00_README.md`
- `docs/05-平台专项/android/01_快速开始.md`
- `docs/05-平台专项/android/02_打包前检查清单.md`
- `docs/05-平台专项/android/03_环境配置指南.md`
- `docs/05-平台专项/android/05_登录注册URL全链路.md`
- `docs/05-平台专项/android/06_完整排错手册.md`
- `docs/05-平台专项/android/07_安卓APK代码与构建基线.md`
- `docs/05-平台专项/android/07_MeiqiaSdk-dx兼容修复说明.md`
