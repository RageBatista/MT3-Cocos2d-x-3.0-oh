# Android 登录注册 URL 链路

> 返回 [Android 文档索引](00-README.md)。本页只负责登录/注册配置从源资源到运行时请求的链路。

## 1. 唯一业务配置源

```text
client/resource/res/cfg/clientsetting_android.ini
```

关键键：

- `HttpServerAddressPlatForm`
- `HttpSdkLoginUrl`
- `HttpSdkRegisterUrl`

业务修改必须发生在源文件，不直接修改哈希资源或 APK 工程生成目录。

## 2. 从源文件到 APK

```text
client/resource/res/cfg/clientsetting_android.ini
  -> LJFilePack_打包安卓.bat
  -> client/res_android/res/2863654426
  -> wrapper -SyncRes
  -> client/android/LocojoyProject/assets/res/2863654426
```

资源边界：

```text
源目录: client/resource/res/**
打包入口: client/resource/tools/LJFilePack_打包安卓.bat
生成目录: client/android/LocojoyProject/assets/res/**
规则: 生成目录不接受业务手工修改
```

`2863654426` 是 `cfg/clientsetting_android.ini` 的打包名；具体映射以生成后的 `fl.ljpi` 为准。

## 3. 运行时读取与请求

1. `GameApp.java` 在启动/更新阶段复制关键索引与哈希配置。
2. `GameApplication::GetIniFileName()` 选择明文或哈希 ini。
3. `GameApplication::InitIni()` 读取登录/注册网址；键为空时按代码中的平台地址规则兜底。
4. `LoginManager::LoginAccount()` 与 `RegisterAccount()` 获取 `GameApplication` 中的地址并发送请求。
5. `switchaccountdialog.lua` 触发登录/注册；`LuaFireClient.cpp` 提供 Lua 到 C++ 导出。

代码锚点：

- `client/android/LocojoyProject/src/com/locojoy/mini/mt3/GameApp.java`
- `client/FireClient/Application/Framework/GameApplication.cpp`
- `client/FireClient/Application/Manager/LoginManager.cpp`
- `client/FireClient/Application/Framework/LuaFireClient.cpp`
- `client/resource/res/script/logic/switchaccountdialog.lua`

## 4. 发布前一致性检查

```powershell
$paths = @(
  'client/resource/res/cfg/clientsetting_android.ini',
  'client/res_android/res/2863654426',
  'client/android/LocojoyProject/assets/res/2863654426'
)
$paths | ForEach-Object {
  $item = Get-Item -LiteralPath $_
  [PSCustomObject]@{ Path = $_; Length = $item.Length; MD5 = (Get-FileHash -LiteralPath $_ -Algorithm MD5).Hash }
}
```

三份文件应同长度、同哈希。不要把旧文档中的冻结 MD5 当作当前值；每次打包均从工作树重新计算。

关键代码检查：

```powershell
rg -n "HttpSdkLoginUrl|HttpSdkRegisterUrl|getSdkLoginAddress|getSdkRegisterAddress" client/FireClient/Application/Framework/GameApplication.cpp client/FireClient/Application/Manager/LoginManager.cpp
rg -n "LoginAccount\(|RegisterAccount\(" client/resource/res/script/logic/switchaccountdialog.lua client/FireClient/Application/Framework/LuaFireClient.cpp
```

## 5. 热更新发布

若通过热更新切换配置，同一版本目录必须发布由本轮资源链生成的 `2863654426`，并与 `ver.ljvi`、`fl.ljpi` 成套验证。完整流程见 [资源打包与热更新发布指南](../../03-开发指南/06-资源打包与热更新发布指南.md)。

## 6. 排错顺序

1. 比较三份配置哈希。
2. 核对 `fl.ljpi` 中的哈希映射。
3. 核对 Lua 调用与 tolua 导出。
4. 核对 `GameApplication` 的地址读取/兜底日志。
5. 核对服务端路由与网络状态。

构建或安装问题转 [排错手册](06-排错手册.md)。
