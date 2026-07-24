# 平台桥接矩阵

## Win32

- 入口：`client/MT3Win32App/main.cpp`
- 壳层职责：进程拉起、窗口容器、把控制权交给共享主链
- 若继续深入共享层初始化和登录逻辑，切到 `application-core-flow`

## Android

### 关键目录

- `client/android/common`
- `client/android/LocojoyProject`
- `client/android/JoysdkProject`
- `client/android/YijieProject`

### 常见锚点

- `Mt3Application.java`
- `GameApp.java`
- 各渠道 `jni/main.cpp`
- `com.locojoy.sdk.GameSDK`
- `com.locojoy.sdk.SDKShare`

### 适用问题

- 生命周期、SDK 登录、JNI 回调、WebView、渠道差异、Java/C++ 桥接

## iOS

### 关键锚点

- `client/FireClient/FireClient/main.m`
- `FireClientAppDelegate.mm`
- `FireClientViewController.mm`
- `GameSdk.h`
- `GameSdk.mm`

### 适用问题

- App 生命周期、视图控制器、Objective-C++ 到 C++ 的桥接、平台 SDK 容器层

## 边界规则

- 已进入 `gRunGameApplication()` 与 FireClient 主业务链，改用 `application-core-flow`
- 已经确认是更新下载、补丁挂载或资源校验问题，联动 `resource-packaging-pipeline`
