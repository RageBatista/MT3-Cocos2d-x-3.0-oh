# 环境准备（CEGUI 0.7.9-r5）

---

## 1. 推荐工具链

- Visual Studio 2010（原始解决方案格式 11.00）
<!-- 修正日期: 2026-01-28 -->
<!-- 原错误: 若使用 VS2013：需要安装 **v100 工具集** -->

- 若使用 VS2013：使用 **v120 工具集**

> 当前 `CEGUI.sln` 标识为 VS2010，`CEGUIOgreRenderer.vcxproj` 明确指定 `<PlatformToolset>v100</PlatformToolset>`。

---

## 2. 可选组件

- DirectX SDK (June 2010)：用于 `CEGUIDirect3D9Renderer`
- OGRE SDK：用于 `CEGUIOgreRenderer`（默认开启）

---

## 3. 环境检查（PowerShell）

```powershell
# v100 工具集检查（VS2013 场景）
cmd /c "dir \"%ProgramFiles(x86)%\\MSBuild\\Microsoft.Cpp\\v4.0\\Platforms\\Win32\\PlatformToolsets\\v100\""

# DirectX SDK (June 2010)
if ($env:DXSDK_DIR) { Test-Path "$env:DXSDK_DIR\Lib\x86\d3dx9.lib" }
```

---

## 4. OGRE 依赖路径注意

`config.lua` 中 OGRE 路径为示例：

- `D:\orge_program\orgebuild`
- `D:\orge_program\boost\boost`

如果路径不存在，请：

1. 修改 `projects/premake/config.lua` 中 OGRE 路径
2. 或在 VS 中禁用 `CEGUIOgreRenderer`

---

## 5. premake 说明

如需重新生成工程：

- 使用 `projects/premake/README` 中的 `premake-3.7-custom`
- 重新生成后会覆盖 `cegui/include/config.h`

建议：**只有在确实需要时才运行 premake**。