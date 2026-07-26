# Android 客户端功能规格书（代码基线版）

> 文档版本：3.1.0  
> 最后更新：2026-07-26  
> 数据来源：`client/android/**`、`AndroidManifest.xml`、`Application.mk`、`GameApp.java`、`GameSDK.java`、`SDKShare.java`、JNI 入口代码

---

## 1. 范围

Android 客户端当前包含以下目录类型：

### 1.1 源码/构建目录

- `client/android/common`
- `client/android/LocojoyProject`
- `client/android/JoysdkProject`
- `client/android/YijieProject`

历史说明：`client/android/LocojoyProject64` 目录已从仓库删除，不再作为免费服或 MuMu 兼容输出目录。

### 1.2 已签名产物目录

历史签名产物目录 `client/android/梦屿西游`、`client/android/梦屿西游x64_sign` 已不在当前工作树中；APK 产物统一由 `LocojoyProject/bin/` 输出且不入库。

本文以 1.1 节四个目录作为当前源码与构建基线。

## 2. 渠道与 Manifest 基线

| 工程 | 角色 | package | versionCode | versionName | minSdk | targetSdk |
|---|---|---|---:|---|---:|---:|
| `common` | 公共壳工程 | `com.locojoy.mini.mt3.common` | 1 | 0.1 | 11 | 17 |
| `LocojoyProject` | 乐游渠道主线 | `com.locojoy.mini.mt3.locojoy` | 1 | 0.0.1 | 11 | 27 |
| `LocojoyProject64`（已删除） | 历史 64 位分支，目录已不存在 | `com.locojoy.mini.mt3.locojoy` | 1 | 0.0.1 | 11 | 17 |
| `JoysdkProject` | JoySDK 渠道 | `com.locojoy.mini.mt3.joysdk` | 101 | 1.0.1 | 11 | 17 |
| `YijieProject` | 易接渠道 | `com.locojoy.wojmt3.yj` | 101 | 1.0.1 | 11 | 17 |

## 3. Native 启动链

### 3.1 Java 侧入口

实际入口链如下：

```text
Mt3Application.attachBaseContext()
  -> MultiDex.install(this)
  -> GameApp.onCreate()
  -> setUpBreakpad()
  -> SDKShare.init()
  -> MQManager.init()
  -> GameSDK.init()
  -> nativeStartResourceUpdate()
```

### 3.2 Java 关键组件真实包路径

| 组件 | 实际类路径 | 说明 |
|---|---|---|
| `Mt3Application` | `com.locojoy.mini.mt3.Mt3Application` | Application 入口，负责 MultiDex |
| `GameApp` | `com.locojoy.mini.mt3.GameApp` | 主 Activity |
| `GameSDK` | `com.locojoy.sdk.GameSDK` | 渠道 SDK 包装与 JNI 回调 |
| `SDKShare` | `com.locojoy.sdk.SDKShare` | ShareSDK 封装 |
| `WavRecorder` | `com.locojoy.mini.mt3.WavRecorder` | 语音录制 |
| `HTML5WebView` | `GameApp` 内部引用 | 公告 / 更新 WebView |

### 3.3 JNI 侧入口

主线 JNI 入口仍在各渠道工程 `jni/main.cpp` 中，负责：

- `JNI_OnLoad`
- Breakpad 初始化桥接
- `Cocos2dxRenderer.nativeInit`
- 调用共享 C++ 主链 `gRunGameApplication()`

## 4. 功能能力基线

### 4.1 共享能力

Android 主线当前明确具备：

- 资源更新
- 渠道登录 / 支付 / 账号切换
- ShareSDK 一键分享
- MeiQia 客服
- 语音录制（`WavRecorder`）
- 公告 / 更新 WebView
- 位置能力（Baidu `LocationClient`）
- TalkingDataAppCpa 初始化

### 4.2 `GameSDK` 的 JNI 回调

`GameSDK.java` 当前明确声明并触发：

- `loginCb(...)`
- `payCb(...)`
- `logoutCb(...)`
- `switchAccountCb(...)`
- `exitSdkCb()`
- `YYBLoginCb(...)`

说明：Android 渠道登录不是只返回账号和 session，还包含应用宝特化回调分支。

### 4.3 `GameApp` 中的 WebView 能力

`GameApp.java` 当前直接提供：

- `openUpdateview`
- `closeUpdateView`
- `hideUpdateview`
- `resumeUpdateview`

内部通过 `HTML5WebView` 加载 `getHttpNoticeUrl()` 返回的公告地址。

## 5. 权限基线

Android 权限不再适合写成“统一 28 项”。当前真实口径如下：

| 工程 | 原始声明条数 | 唯一权限数 | 说明 |
|---|---:|---:|---|
| `LocojoyProject` | 21 | 21 | 精简权限集 |
| `LocojoyProject64` | 历史记录 | 历史记录 | 已废弃，不作为当前权限基线 |
| `JoysdkProject` | 30 | 29 | 与 64 位分支同级口径 |
| `YijieProject` | 30 | 29 | 与 JoySDK 同级口径 |

相对 `LocojoyProject`，后三者额外出现的权限包括：

- `android.permission.MOUNT_UNMOUNT_FILESYSTEMS`
- `android.permission.WRITE_INTERNAL_STORAGE`
- `android.permission.READ_PHONE_STATE`
- `android.permission.GET_TASKS`
- `android.permission.READ_LOGS`
- `android.permission.BATTERY_STATS`
- `android.permission.MANAGE_ACCOUNTS`
- `android.permission.ACCESS_MOCK_LOCATION`

## 6. 构建系统与 ABI

### 6.1 主线工具链（LocojoyProject 免费服主线）

- NDK：`r16b (16.1.4479499)`，工具链 `clang`
- 构建系统：`ndk-build + Ant + JDK 8`
- STL：`c++_shared`
- C++ 标准：`-std=c++11`

### 6.2 `Application.mk` 基线

主线 `LocojoyProject/jni/Application.mk` 当前为：

- `APP_STL := c++_shared`
- `APP_CPPFLAGS := -frtti -std=c++11`
- `APP_ABI := arm64-v8a`
- `APP_PLATFORM := android-21`
- `NDK_TOOLCHAIN_VERSION := clang`

legacy 渠道（`common`、`JoysdkProject`、`YijieProject`）仍保留历史配置：

- `APP_STL := gnustl_static`、`APP_ABI := armeabi-v7a`、`NDK_TOOLCHAIN_VERSION := 4.8`
- 这些渠道未随主线迁移，使用前需单独复验，不得当作当前 free 主线口径。

### 6.3 历史 `LocojoyProject64` 特例

历史 `LocojoyProject64/jni/Application.mk` 曾额外包含：

- `ifeq ($(APP_ABI),arm64-v8a) NDK_TOOLCHAIN_VERSION := 4.9`

当前免费服不再使用该目录；arm64 主线以 `client/android/LocojoyProject/jni/Application.mk` 和 `Build-Android-Locojoy-WithGate.ps1` 为准。

## 7. 资源与目录事实

- 业务资源源头固定为 `client/resource/res/**`。
- `client/resource/tools/LJFilePack_打包安卓.bat` 是 Android 资源打包入口；执行后生成/刷新 Android 打包资源，再由构建/同步链进入 APK 工程。
- `client/res_android/res/**` 是打包后的 Android 资源同步输入，不是业务手改源头。
- `client/android/LocojoyProject/assets/res/**` 是 APK 工程内生成产物，严禁手动修改；各渠道工程的 `assets/res` 是否在工作区存在，取决于同步和打包阶段，不应把其缺失直接解释为“渠道不可构建”。

## 8. 维护规则

以下任一变更都必须同步更新本文：

- `AndroidManifest.xml`
- `Application.mk`
- `GameApp.java`
- `GameSDK.java`
- `SDKShare.java`
- 渠道目录增减
- 64 位工具链分支变化
