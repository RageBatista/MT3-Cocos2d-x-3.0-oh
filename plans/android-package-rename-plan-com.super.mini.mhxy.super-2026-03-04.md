# Android 包名迁移实施方案（`com.super.mini.mhxy.super`）

更新时间：2026-03-04  
适用工程：`client/android/LocojoyProject`（Ant 构建链）

## 1. 目标与范围

将 Android 客户端包名从：

- `com.locojoy.mini.mt3.locojoy`

迁移为：

- `com.super.mini.mhxy.super`

并保证：

1. 工程可成功编译打包（`ndk-build + ant`）。
2. 新包可安装、启动、热更新、登录/注册。
3. 第三方 SDK（微信/QQ/渠道）回调与后台配置同步。

## 2. 影响面清单（必须同步）

## 2.1 工程代码与清单

1. `AndroidManifest.xml`
- `manifest package`
- `.wxapi.WXEntryActivity` 声明与真实 Java 包路径

2. Java 源码里对 `R` 的硬编码 import
- `import com.locojoy.mini.mt3.locojoy.R;`

3. 自动生成目录
- `gen/com/locojoy/mini/mt3/locojoy/*`（清理后重生，不手工改）

## 2.2 第三方平台配置（高风险）

1. 微信开放平台
- Android 包名
- 签名（SHA1）
- 回调 Activity 规则（`<新包名>.wxapi.WXEntryActivity`）

2. QQ/应用宝/渠道后台
- 包名白名单
- 签名指纹

3. 统计/客服 SDK 后台
- 若有按包名分应用，需新增新包应用并替换 key/配置

## 2.3 发布与安装行为

1. 新旧包名不同，Android 视为两个独立应用。
2. 旧包不会覆盖升级，需单独卸载或并存测试。
3. 新包首次安装后，热更新缓存路径会变为：
- `/storage/emulated/0/Android/data/com.super.mini.mhxy.super/...`

## 3. 实施步骤（可直接执行）

## 步骤 A：改前基线快照

```powershell
cd E:\MT3
rg -n "com\.locojoy\.mini\.mt3\.locojoy" client\android\LocojoyProject -S
```

保存输出作为改前清单。

## 步骤 B：修改 Manifest 包名

文件：

- `client/android/LocojoyProject/AndroidManifest.xml`

将：

- `package="com.locojoy.mini.mt3.locojoy"`

改为：

- `package="com.super.mini.mhxy.super"`

## 步骤 C：修正 Java 的 `R` 引用

在 `src` 下批量替换：

- `import com.locojoy.mini.mt3.locojoy.R;`

改为：

- `import com.super.mini.mhxy.super.R;`

建议命令：

```powershell
cd E:\MT3
rg -l "import com\.locojoy\.mini\.mt3\.locojoy\.R;" client\android\LocojoyProject\src -S
```

## 步骤 D：处理 `WXEntryActivity` 路径一致性

当前工程已有多个 `wxapi/WXEntryActivity.java` 变体，必须保证：

1. Manifest 声明的 `android:name=".wxapi.WXEntryActivity"` 能解析到当前包名下的类。
2. 物理文件路径与 `package xxx.wxapi;` 一致。

建议采用单一标准：

- Java 包：`com.super.mini.mhxy.super.wxapi`
- 文件路径：`src/com/super/mini/mhxy/super/wxapi/WXEntryActivity.java`

并移除无关渠道的冲突 `wxapi` 类，避免多回调类混淆。

## 步骤 E：清理自动生成产物

```powershell
cd E:\MT3\client\android\LocojoyProject
Remove-Item -Recurse -Force .\gen\com\locojoy\mini\mt3\locojoy -ErrorAction SilentlyContinue
ant clean
```

## 步骤 F：重新编译打包

```powershell
cd E:\MT3\client\android\LocojoyProject
ndk-build clean
ndk-build NDK_DEBUG=0 -j4
ant clean debug
```

若需发行包：

```powershell
ant release
```

（前提：`ant.properties` 的签名配置路径有效）

## 步骤 G：安装验证

```powershell
adb uninstall com.super.mini.mhxy.super
adb install -r E:\MT3\client\android\LocojoyProject\bin\mt3-debug.apk
adb shell pm list packages | findstr /I "com.super.mini.mhxy.super"
```

## 4. 验收清单（必须全绿）

1. 包名检查

```powershell
aapt dump badging E:\MT3\client\android\LocojoyProject\bin\mt3-debug.apk | findstr /I "package: name="
```

期望：`package: name='com.super.mini.mhxy.super'`

2. 代码残留检查

```powershell
cd E:\MT3
rg -n "com\.locojoy\.mini\.mt3\.locojoy" client\android\LocojoyProject -S
```

期望：仅允许历史文档/非当前渠道目录残留；主渠道代码与 Manifest 不得残留。

3. 功能链路

1. 启动与热更新正常。
2. 登录/注册正常。
3. 微信/QQ回调正常（如使用）。
4. 支付（如接入）正常拉起并回调。

## 5. 常见失败与处理

1. `INSTALL_FAILED_UPDATE_INCOMPATIBLE`
- 原因：同包名签名不一致。
- 处理：先卸载旧包再安装新包。

2. 微信回调失败
- 原因：`wxapi.WXEntryActivity` 包路径与 Manifest/后台不一致。
- 处理：统一包路径 + 同步开放平台包名和签名。

3. 编译报 `R` 找不到
- 原因：`R` import 仍指向旧包。
- 处理：全量替换后 `ant clean` 重建。

## 6. 回滚方案

1. 回滚代码到改包名前提交。
2. 恢复第三方平台后台配置为旧包名。
3. 重新打旧包并验证安装。

---

执行建议：先做一版 `debug` 迁移验证（启动/热更/登录）通过后，再切 `release` 与渠道联调。
