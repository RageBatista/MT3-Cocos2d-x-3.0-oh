# LJFilePack-Pro GUI

Windows 可视化打包入口，调用同目录的 `LJFilePack.exe` 完成实际资源生成。

## 工作流

1. 选择平台、输出模式、源资源目录和版本号。
2. 可选：点击“预检”验证配置、索引和输入目录。
3. 点击“开始打包”，配置、CLI 缓存和产物全部写入用户指定输出目录内部的 `.ljfp-workspace\runs\<run-id>`。
4. 产物校验通过后自动弹出确认框；确认后通过 `.ljfp-workspace\transactions\<transaction-id>` 中的持久事务覆盖正式产物。
5. 发布提交后立即删除临时备份、事务和本次运行目录；工作区为空时一并删除 `.ljfp-workspace`。

CLI 子进程的 `TEMP`、`TMP`、`TMPDIR`、`LOCALAPPDATA` 和 `APPDATA` 均指向本次运行目录中的 `cache`，不会把打包缓存写到用户目录或系统临时目录。正式输出目录按卷标识检查，位于系统卷或经过 junction/symlink 时会在创建工作区前阻止执行。

取消确认会清理本次运行目录。发布期间若进程或系统中断，下次创建打包计划前会读取事务清单：`prepared` 状态回滚旧产物，`committed` 状态保留新产物并继续清理。只有自动回滚本身未完成时才保留事务现场，并在错误信息中给出恢复目录。

Android 正式输出固定使用 `client/res_android/res`。APK 工程中的 `client/android/**/assets/res` 仍由 Android 构建同步链刷新；同步脚本会获取同一个 `publish.lock`，拒绝未完成事务，并显式排除和门禁 `.ljfp-workspace`。正式产物本身也禁止使用该保留名称。

## 构建发布

在仓库根目录执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dependencies\LJFilePack-Pro\scripts\Build-LJFilePackPacker-Gui.ps1
```

默认发布目录：

```text
dependencies/LJFilePack-Pro/dist/LJFilePackPacker-win-x64
```

发布目录同时包含 `ThirdPartyNotices.md`、VC120 x86 运行库和自包含 .NET Desktop Runtime；不要从发布目录删除这些运行时文件。
