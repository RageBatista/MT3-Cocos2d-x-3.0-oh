# iOS Upgrade30 构建交接

状态：`READY_FOR_XCODE_BUILD`

## 基线

- Cocos2d-x：`cocos2d-x-3.0-oh`
- CEGUI：`tools/CEGUI-0.7.9-r5`
- 架构：`arm64`
- iOS Deployment Target：`12.0`
- 主工程：`client/FireClient/FireClient-Upgrade30.xcodeproj`

## Windows 静态准备结果

- 已生成 `FireClient-Upgrade30.xcodeproj`、`engine-Upgrade30.xcodeproj` 和 `CEGUI-0.7.9-r5.xcodeproj`。
- 已将 iOS 入口切换为 `CCEAGLView + cocos2d::GLView`，Legacy226 代码由条件宏保留。
- 已恢复 Cocos 3.0 iOS 工程及其 iOS vendor 输入，并按 `.REMOVED.git-id` 记录的 Git blob SHA 校验。
- FMOD 兼容输入已隔离到 `client/ios/vendor/fmod`，未继续从 Legacy226 工程路径链接。
- Windows 只执行工程、路径、宏和 vendor 静态门禁，不声明已执行 `xcodebuild`。

静态门禁：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\scripts\Build-iOS-MT3.ps1 `
  -EngineProfile Upgrade30 -StaticGateOnly
```

预期结果：`iOS static gate: PASS (64/64 checks passed)`。

## macOS 环境切换

1. 安装完整 Xcode，并切换 Command Line Tools 到目标 Xcode：

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-path
```

2. 确认所选 Xcode 提供 iOS SDK、支持 `arm64`，并允许项目以 `IPHONEOS_DEPLOYMENT_TARGET=12.0` 构建。
3. 安装 PowerShell 7，使 `pwsh` 可执行 canonical 脚本。
4. 真机构建前导入 Apple Developer 证书和描述文件；签名信息仅通过命令参数或 CI Secret 注入。

## canonical 构建

先在 macOS 重跑静态门禁：

```bash
pwsh -NoProfile -File ./tools/scripts/Build-iOS-MT3.ps1 \
  -EngineProfile Upgrade30 -StaticGateOnly
```

免签编译与链接验证：

```bash
pwsh -NoProfile -File ./tools/scripts/Build-iOS-MT3.ps1 \
  -EngineProfile Upgrade30 \
  -Configuration Debug \
  -TargetDevice Device \
  -Architectures arm64 \
  -DeploymentTarget 12.0 \
  -SkipCodeSign
```

签名 Release 构建：

```bash
pwsh -NoProfile -File ./tools/scripts/Build-iOS-MT3.ps1 \
  -EngineProfile Upgrade30 \
  -Configuration Release \
  -TargetDevice Device \
  -Architectures arm64 \
  -DeploymentTarget 12.0 \
  -DevelopmentTeam TEAM_ID \
  -CodeSignIdentity "Apple Development: NAME (TEAM_ID)" \
  -ProvisioningProfile PROFILE_UUID
```

## 回滚点

- 继续使用 `-EngineProfile Legacy226` 可回到原 `FireClient.xcodeproj`、`engine.xcodeproj` 和 `dependencies/cegui` 链路。
- Upgrade30 工程由 `tools/scripts/Generate-iOS-Upgrade30-Projects.ps1` 生成，可删除生成工程后重新生成。
- `client/ios/vendor/fmod` 是独立兼容副本，回滚时不修改 `cocos2d-x-2.2.6` 原文件。
