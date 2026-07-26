# iOS客户端功能规格书（基线版）

> 文档版本：2.0.1  
> 最后更新：2026-07-26
> 历史基线：`docs/09-历史归档/专项审计/2026-03-04-客户端三端代码基线审计.md`
> 数据来源：`FireClient.xcodeproj`、`main.m`、`FireClientAppDelegate.mm`、iPhone/iPad 目录

---

## 1. 范围

iOS 客户端核心路径：

- `client/FireClient/FireClient.xcodeproj/project.pbxproj`
- `client/FireClient/FireClient/`
- `client/FireClient/Application/platform/ios/`
- `client/res_ios/`

工作区快照：
- `client/FireClient/FireClient`：1,318 文件，227.54 MB
- `client/res_ios`：803 文件，765.91 MB

---

## 2. 启动链路（代码实测口径）

1. 入口函数：`client/FireClient/FireClient/main.m:6` `main(...)`
2. UIKit 启动：`main.m:9` `UIApplicationMain(...)`
3. AppDelegate 启动回调：`FireClientAppDelegate.mm:124` `application:didFinishLaunchingWithOptions:`
4. 设置 `rootViewController` 并显示主窗口：`FireClientAppDelegate.mm:197-206`、`:208`
5. 非 `UPDATE_ENGINE_ENABLE` 分支直接调用：`FireClientAppDelegate.mm:224-225` `gRunGameApplication()`
6. 安装崩溃收集：`FireClientAppDelegate.mm:228-229` `installCrashHandler()`
7. 初始化 ShareSDK 与 MeiQia：`FireClientAppDelegate.mm:257`、`:310`
8. 生命周期回调存在：
   - `applicationDidEnterBackground:`（`:519`）
   - `applicationWillEnterForeground:`（`:560`）
   - `applicationWillTerminate:`（`:620`）
9. 在 `UPDATE_ENGINE_ENABLE` 分支中，更新界面结束后会再次进入：`FireClientAppDelegate.mm:443` `gRunGameApplication()`

---

## 3. Xcode 工程实际配置

- Native Target：`FireClient`（`project.pbxproj:4239`）
- Bundle Identifier：`com.locojoy.immt3`（`project.pbxproj:4932`、`5070`）
- `IPHONEOS_DEPLOYMENT_TARGET`：存在 `5.1` 与 `6.1`
- `SDKROOT`：`iphoneos`
- `TARGETED_DEVICE_FAMILY`：`"1,2"`
- `VALID_ARCHS`：
  - `armv7 armv7s arm64`
  - `armv7 arm64`

---

## 4. iOS 平台目录事实

- iPhone 入口相关：`client/FireClient/FireClient/iPhone/`
  - `FireClientAppDelegate_iPhone.h/.m`
  - `MainWindow_iPhone.xib`
- iPad 入口相关：`client/FireClient/FireClient/iPad/`
  - `FireClientAppDelegate_iPad.h/.m`
  - `MainWindow_iPad.xib`
- 平台补充实现：`client/FireClient/Application/platform/ios/WavRecorder.mm`

---

## 5. 与共享层边界

- iOS 启动层负责 UIKit 生命周期、SDK 路由、平台回调。
- 业务主循环统一进入 `gRunGameApplication()`，共享核心仍在：
  - `client/FireClient/Application/`
  - `client/resource/res/script/`

---

## 6. 快速复核命令

```powershell
Select-String -Path client/FireClient/FireClient/main.m -Pattern 'main|UIApplicationMain'
Select-String -Path client/FireClient/FireClient/FireClientAppDelegate.mm -Pattern 'didFinishLaunchingWithOptions|gRunGameApplication|applicationDidEnterBackground|applicationWillEnterForeground|applicationWillTerminate'
Select-String -Path client/FireClient/FireClient.xcodeproj/project.pbxproj -Pattern 'PBXNativeTarget|PRODUCT_BUNDLE_IDENTIFIER|IPHONEOS_DEPLOYMENT_TARGET|SDKROOT|TARGETED_DEVICE_FAMILY|VALID_ARCHS'
```

---

## 7. 维护规则

- 本规格书不再维护不可验证的“功能数量”统计。
- Xcode 构建参数与入口文件变更后，必须同步更新本文件与基线审计报告日期。
