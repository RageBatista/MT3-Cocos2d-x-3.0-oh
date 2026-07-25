# MT3 工具链子树规则

> **定位**: `tools/` 目录覆盖构建脚本、资源打包、SpriteEditor/图集算法、PFS/更新链和 CEGUI 相关工具；默认叠加根 `AGENTS.md` 与 `../.claude/RULES.md`。

## 首轮路由

- `scripts/**`：仓库主线 PowerShell 构建与审计脚本，优先当作固定入口处理。
- `engine/**`：SpriteEditor、PFS、资源处理工具；打包算法和更新链优先在这里排查。
- `CEGUI-*`、`TexturePacker_CEGUI`、`free-tex-packer`、`packtool`：图集、UI 工具和离线处理链。
- `Tools.sln`：Windows 工具集合入口；只在工具工程本身需要构建时使用。

## 本目录硬边界

- 工具链问题先看脚本输出、输入资源、生成产物和调用入口，再定根因；不要把“最小修改脚本”当目标，优先修真正失真的入口或算法。
- 构建脚本、审计脚本和工具文档默认使用 `UTF-8 no BOM`；修改既有文件时保持原编码。
- 资源发布、PFS、补丁结构问题优先归入 `resource-packaging-pipeline`；SpriteEditor 合图、矩形排布、`pack.ini` 归入 `sprite-pack-algorithm`；CEGUI/渲染器问题归入 `rendering-pipeline`。
- 不要把工具脚本改造和业务源码修复混成一次提交；先修工具链，再回业务。

## 首轮验证入口

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release
powershell -ExecutionPolicy Bypass -File .\scripts\Build-Android-Locojoy-WithGate.ps1 -ProjectDir "client/android/LocojoyProject" -BuildType Debug -Channel free -Jobs 4 -CleanIntermediates -RequireArm64InApk
Get-Item .\Tools.sln
```

## 常用技能

- `resource-packaging-pipeline`
- `sprite-pack-algorithm`
- `rendering-pipeline`
