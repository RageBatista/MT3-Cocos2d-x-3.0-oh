# Android 平台文档索引

> 当前主线：`client/android/LocojoyProject`、`free` 渠道、`arm64-v8a`。
> 固定工具链：`NDK r16 clang + Ant + JDK 8 + Python 2.7`。
> Canonical wrapper：`tools/scripts/Build-Android-Locojoy-WithGate.ps1`。

## 1. 固定阅读顺序与职责

完整阅读顺序固定为：

```text
00-README -> 03-环境配置 -> 02-打包前检查清单 -> 01-快速开始
          -> 04-构建流程 -> 05-登录注册URL链路 -> 06-排错手册
          -> 07-APK代码与构建基线 -> 08-MeiqiaSdk-dx兼容修复 -> 09-ARM64适配
```

| 文档 | 唯一职责 |
| --- | --- |
| [01-快速开始](01-快速开始.md) | 给出日常 free 构建的最短可执行路径 |
| [02-打包前检查清单](02-打包前检查清单.md) | 发布前逐项判定是否具备构建、签名和验收条件 |
| [03-环境配置](03-环境配置.md) | 配置并验证固定 Android 工具链 |
| [04-构建流程](04-构建流程.md) | 解释 wrapper 的阶段、输入、输出和门禁 |
| [05-登录注册URL链路](05-登录注册URL链路.md) | 追踪 Android 登录/注册配置从源文件到运行时的链路 |
| [06-排错手册](06-排错手册.md) | 按首错定位环境、Ant/dx、资源、ABI、安装和运行问题 |
| [07-APK代码与构建基线](07-APK代码与构建基线.md) | 固定当前工程、JNI、SDK、分辨率与构建事实 |
| [08-MeiqiaSdk-dx兼容修复](08-MeiqiaSdk-dx兼容修复.md) | 记录 MeiqiaSdk 在旧 dx 链中的专项兼容处理 |
| [09-ARM64适配](09-ARM64适配.md) | 提供可复用的 arm64 依赖、JNI、构建和 ABI 校验步骤 |

每篇专题页只维护表中职责，并回链本索引。

## 2. 当前工程与目录

`client/android/` 当前顶层实物：

- `common/`：Android 公共 Java/JNI/资源承载。
- `LocojoyProject/`：当前 free 主渠道工程。
- `JoysdkProject/`、`YijieProject/`：保留渠道工程，本轮未完成同等级复验。

现场盘点命令：

```powershell
Get-ChildItem -LiteralPath .\client\android -Directory | Select-Object -ExpandProperty Name
Get-ChildItem -LiteralPath .\client\android\LocojoyProject -File | Select-Object -ExpandProperty Name
```

`Build-Android-Locojoy-WithGate.ps1` 当前拒绝非 `free` 渠道；`client/android/LocojoyProject/build/build_monthpayment.xml` 恢复并重新验收前，不把点卡服参数或旧批处理菜单当作可用入口。

## 3. 资源生成边界

```text
源目录: client/resource/res/**
打包入口: client/resource/tools/LJFilePack_打包安卓.bat
生成目录: client/android/LocojoyProject/assets/res/**
规则: 生成目录不接受业务手工修改
```

`client/res_android/res/**` 是中间同步输入。资源差异必须可追溯到源目录、`LJFilePack_打包安卓.bat` 与 wrapper 的 `-SyncRes` 阶段。

## 4. 当前输出与历史样本

- 当前 wrapper 输出：
  - `client/android/LocojoyProject/bin/mt3-debug.apk`
  - `client/android/LocojoyProject/bin/mt3-release.apk`
- `2026-06-19` 批次记录中的 `client/android/LocojoyProject/build/bin/mt3-release.apk` 是当日历史样本，不是现行 wrapper 输出约定。

日期证据统一归档到：

- [2026-06-19 最终发布说明](../../09-历史归档/专项审计/Android-arm64-free/2026-06-19-最终发布说明.md)
- [2026-06-19 回滚说明](../../09-历史归档/专项审计/Android-arm64-free/2026-06-19-回滚说明.md)
- [2026-06-19 APK 与 MuMu 验收](../../09-历史归档/专项审计/Android-arm64-free/2026-06-19-APK重编与MuMu全链路验证.md)

## 5. 事实源

- `client/android/AGENTS.md`
- `.claude/RULES.md`
- `.claude/BUILD_GUIDE.md`
- `tools/scripts/Build-Android-Locojoy-WithGate.ps1`
- `client/android/LocojoyProject/jni/Application.mk`
- `client/resource/tools/LJFilePack_打包安卓.bat`

返回跨平台入口：[客户端打包指南](../01-客户端打包指南.md)。
