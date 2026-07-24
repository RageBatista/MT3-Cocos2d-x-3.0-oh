# iOS 发布前闸门清单

> 返回 [客户端打包指南](../01-客户端打包指南.md)。本页区分源码静态核验与 Xcode/设备实测，不引用已移除的自动化脚本。

## 1. 更新入口

- [ ] `UpdateEngine::Run()` 能从 iOS 更新界面启动。
- [ ] 更新完成能返回游戏控制器并进入共享 C++ 主链。

```powershell
rg -n "UpdateEngine::Run|onNotifyEnd|ReturnToGame|returnToGameController|gRunGameApplication" client/FireClient/FireClient/UpdateEngineViewController.mm client/FireClient/FireClient/FireClientAppDelegate.mm
```

## 2. 热更新站点与索引

- [ ] `g_JsonSite`、版本、渠道和 `index.html` 拼接符合本轮环境。
- [ ] 发布目录中的 `ver.ljvi`、`fl.ljpi` 成对且与 iOS 包体资源一致。

```powershell
rg -n "g_JsonSite|RequestUpdateJson|versionCaption|channelCaption|index.html" common/updateengine/UpdateManagerEx.cpp common/platform/utils/UpdateUtil.h
```

## 3. iOS 配置源与哈希资源

- [ ] 只修改 `client/resource/res/cfg/clientsetting_ios.ini`。
- [ ] 核对 `HttpServerAddressPlatForm`、`HttpSdkLoginUrl`、`HttpSdkRegisterUrl`、`HttpServerListUrl`。
- [ ] `client/res_ios/res/1912606767` 与源配置同哈希。
- [ ] 服务端 iOS 热更目录发布 `1912606767`，不使用 Android 的 `2863654426` 替代。

```powershell
$src = (Get-FileHash -LiteralPath client/resource/res/cfg/clientsetting_ios.ini -Algorithm MD5).Hash
$packed = (Get-FileHash -LiteralPath client/res_ios/res/1912606767 -Algorithm MD5).Hash
[PSCustomObject]@{ Source = $src; Packed = $packed; Match = ($src -eq $packed) }
```

资源与热更新总流程见 [资源打包与热更新发布指南](../../03-开发指南/06-资源打包与热更新发布指南.md)。

## 4. 登录/注册共享链

- [ ] `LuaFireClient.cpp` 仍导出 `LoginAccount`、`RegisterAccount`。
- [ ] `LoginManager` 从 `GameApplication` 获取 SDK 登录/注册网址。

```powershell
rg -n -F 'tolua_function(tolua_S,"LoginAccount"' client/FireClient/Application/Framework/LuaFireClient.cpp
rg -n -F 'tolua_function(tolua_S,"RegisterAccount"' client/FireClient/Application/Framework/LuaFireClient.cpp
rg -n "getSdkLoginAddress|getSdkRegisterAddress|LoginAccount\(|RegisterAccount\(" client/FireClient/Application/Manager/LoginManager.cpp client/FireClient/Application/Framework/GameApplication.cpp
```

## 5. 共享引擎与 ABI

- [ ] 共享 `engine/**` 改动已用 iOS 工具链重编 `engine.xcodeproj`。
- [ ] `FireClient` 链接的是本轮重编的 `libengine.a`，不是旧产物。
- [ ] 公共头文件/对象布局变化已按下游顺序全链重编。

```powershell
rg -n "libengine.a|engine.xcodeproj" client/FireClient/FireClient.xcodeproj/project.pbxproj
rg -n "nuspritemanager.cpp in Sources" engine/engine.xcodeproj/project.pbxproj
```

## 6. ATS 与渠道配置

- [ ] 当前目标使用的 `Info.plist` 已核对 ATS/HTTP 策略。
- [ ] Bundle ID、版本号、渠道 SDK、URL、支付环境与发布参数一致。

```powershell
rg -n -g "*.plist" "NSAppTransportSecurity|NSAllowsArbitraryLoads|NSExceptionDomains" client/FireClient/FireClient
rg -n "INFOPLIST_FILE|PRODUCT_BUNDLE_IDENTIFIER|CURRENT_PROJECT_VERSION|MARKETING_VERSION" client/FireClient/FireClient.xcodeproj/project.pbxproj
```

## 7. 签名与 Archive

- [ ] 使用目标证书、Team、Provisioning Profile 和分发方式。
- [ ] Archive/导出过程无签名、entitlement、重复库或架构错误。
- [ ] 保存 Archive、导出日志、IPA 哈希和签名信息摘要；不提交证书私钥或密码。

## 8. 设备验收

- [ ] 冷启动可完成热更新并进入登录页。
- [ ] 注册、登录、选服、入世界通过。
- [ ] 角色、坐骑、武器与时装显示正常。
- [ ] 连续启动/进入至少 3 次，无新增崩溃。
- [ ] 保存设备日志与崩溃栈；模拟器结果不替代真机商发验收。

## 9. 回滚准备

- [ ] 上一版 IPA、配置、资源索引和服务端热更目录可恢复。
- [ ] 回滚后能重新安装/升级并完成冷启动、登录与入世界。
- [ ] 共享 C++ 回滚时同步回退并重编 iOS 引擎与客户端产物。
