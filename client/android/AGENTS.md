# MT3 Android 客户端协作边界

> **定位**: `client/android/` 目录的就近规则；默认叠加根 `AGENTS.md`、`../AGENTS.md`、`../../.claude/RULES.md` 和 `../../.claude/BUILD_GUIDE.md`。

## 首轮路由

- `LocojoyProject/**`：当前免费服主渠道工程，构建主线为 `NDK r16 clang + Ant + JDK8`。
- `common/**`：Android 公共 Java/JNI/资源承载目录，改动需确认各渠道引用关系。
- `JoysdkProject/**`、`YijieProject/**`：保留渠道工程；不要把未复验渠道当作当前 free 主线。

## 资源生成硬边界

- `client/android/LocojoyProject/assets/res/**` 下所有文件均为 Android APK 资源生成产物，来源于 `client/resource/tools/LJFilePack_打包安卓.bat` 资源打包链，严禁手动修改。
- 业务资源源头固定为 `client/resource/res/**`；如需修改资源，必须先修改该源目录，再在 `client/resource/tools` 下执行 `cmd /c LJFilePack_打包安卓.bat`，随后通过构建/同步链刷新 `assets/res`。
- 若提交中包含 `client/android/LocojoyProject/assets/res/**` 差异，必须能追溯到上述脚本或构建同步输出；禁止用手工补丁修正、删除或补齐该目录文件。
- 违反该边界会导致资源索引与实际文件错位、APK 打包失败或运行时读取异常，且问题难以追踪。

## 常用验证入口

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ..\..\tools\scripts\Assert-AndroidJdk8Gate.ps1 -JdkHome "C:\Program Files\Java\jdk1.8.0_144"
powershell -NoProfile -ExecutionPolicy Bypass -File ..\..\tools\scripts\Assert-AndroidArm64Migration.ps1
```

资源改动后的打包入口必须显式走 `cmd.exe`：

```powershell
cmd /c "cd /d E:\MT3\client\resource\tools && LJFilePack_打包安卓.bat"
```
