---
name: platform-bridge
description: "处理 Win32、Android、iOS 壳层入口、JNI 注册/回调、ObjC++、SDK 运行时生命周期与平台桥接；不用于 NDK/Ant 编译、链接或 APK 打包，也不用于 `gRunGameApplication()` 之后的共享主链。"
---

负责“平台抽象层”。当问题还停留在 Win32 壳层、Android Java/JNI、iOS Objective-C++ 桥接或 SDK 接入时，优先用本技能。

## 何时使用

- Win32 `main.cpp`、Launcher、进程启动或壳层窗口问题
- Android `Application`、`Activity`、JNI、渠道 SDK、WebView 或资源容器问题
- iOS `AppDelegate`、`ViewController`、`GameSdk`、生命周期或桥接回调问题
- 需要梳理三端如何把控制权交给共享 C++ 主链

## 不使用

- 已经进入共享 C++ 主链、FireClient 业务流程或入世界之后的问题，改用 `application-core-flow`
- 只涉及 NDK/Ant 工具链、JNI 原生编译/链接、APK 打包或 ABI 产物门禁时，改用 `android-r10e-build`
- 只涉及资源热更新、补丁结构、版本索引或下载器校验时，改用 `resource-packaging-pipeline`

## 输入校验

- 先确认故障仍停留在 Win32 壳层、Android Java/JNI、iOS ObjC++ 或 SDK 回调层
- 先拿到首个阻塞锚点：入口文件、生命周期回调、JNI 方法、渠道登录桥接或相关日志
- 先判断是否同时涉及 Android 构建链或平台下载器

## 先做什么

1. 先运行 `scripts/probe-platform-handoff.ps1`，快速确认 Win32 / Android / iOS 的入口文件和控制权交接骨架是否还在；需要供后续脚本或审计链直接消费时，可追加 `-Json`
2. 先确认问题是否仍在平台壳层；一旦进入 `gRunGameApplication()` 之后的共享主链，转 `application-core-flow`
3. Android r16/Ant 构建、NDK 或 JNI 原生编译问题，转 `android-r10e-build`；只有同时涉及运行时注册/回调契约时才组合两个技能
4. 平台下载器、热更新、补丁校验或版本包加载问题，联动 `resource-packaging-pipeline`
5. 需要平台矩阵和入口文件时，再读 `references/platform-matrix.md`

## 关键锚点

- `client/MT3Win32App/main.cpp`
- `client/android/common`
- `client/android/LocojoyProject`
- `client/android/JoysdkProject`
- `client/android/YijieProject`
- `client/FireClient/FireClient/main.m`
- `client/FireClient/FireClient/FireClientAppDelegate.mm`
- `client/FireClient/FireClient/FireClientViewController.mm`

## 失败处理

- 若症状已经跨入共享主链，不要继续在壳层和共享层同时下补丁
- 若平台问题实际由构建链、资源发布链或渲染链触发，立即转给相应技能而不是留在壳层硬修

## 输出与验证

- 输出至少包含：平台层锚点、控制权交接位置、主故障域判断、下一步验证路径
- 需要快速对齐三端入口时，优先附上 `scripts/probe-platform-handoff.ps1` 的 `STATUS/SUMMARY/DETAIL/NEXT`
- 若需要机器可读结果，优先使用 `probe-platform-handoff.ps1 -Json`
- 改动后至少验证一个真实平台生命周期或桥接链路，如启动、登录回调、JNI 进出栈或下载器回调

## 资源与上下文预算

- 默认先跑 `scripts/probe-platform-handoff.ps1`，再只读当前平台目录、入口文件和最近一层桥接代码
- `references/platform-matrix.md` 仅在需要跨平台对照时展开

## 需要时再读

- `references/platform-matrix.md`
