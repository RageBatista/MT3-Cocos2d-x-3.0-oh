# 从零构建（CEGUI 0.7.9-r5）

目标：在全新环境或清理后，完整复现本目录下的构建产物。

---

## 0. 进入编译环境

```powershell
cmd /c "call %VS120COMNTOOLS%..\\..\\VC\\vcvarsall.bat x86 && set"
```

> 若使用 VS2010，请使用对应的 `vcvarsall.bat` 环境。

---

## 0.1 构建日志记录（必填）

请先打开并填写：

- 参见本文档附录A：构建日志模板

---

## 1. 编译 CEGUI.sln

```powershell
cmd /c "call %VS120COMNTOOLS%..\\..\\VC\\vcvarsall.bat x86 && msbuild tools\\CEGUI-0.7.9-r5\\projects\\premake\\CEGUI.sln /m /p:Configuration=Release /p:Platform=Win32"
```

可选构建：

```powershell
msbuild ... /p:Configuration=Debug
msbuild ... /p:Configuration=Release_Static
msbuild ... /p:Configuration=ReleaseWithSymbols
```

---

## 2. 运行时 DLL 部署

```powershell
Copy-Item e:\MT3\tools\CEGUI-0.7.9-r5\dependencies\bin\*.dll e:\MT3\tools\CEGUI-0.7.9-r5\bin\ -Force
```

---

## 3. 可选：Samples 构建

```powershell
msbuild tools\CEGUI-0.7.9-r5\projects\premake\CEGUISamples.sln /m /p:Configuration=Release /p:Platform=Win32
```

> Samples 依赖 `freeglut.lib` / D3D9 / Ogre 等外部库，请在构建前确认环境。

---

## 4. 构建完成后的复现校验

- `docs/05-产物校验-Output-Verification.md`（含自动校验脚本）
- 参见本文档附录A：构建日志模板

---

## 5. 清理与重建

### 5.1 MSBuild Clean

```powershell
msbuild tools\CEGUI-0.7.9-r5\projects\premake\CEGUI.sln /t:Clean /m /p:Configuration=Release /p:Platform=Win32
msbuild tools\CEGUI-0.7.9-r5\projects\premake\CEGUI.sln /t:Clean /m /p:Configuration=Debug /p:Platform=Win32
```

### 5.2 手工清理（可选）

```powershell
Remove-Item e:\MT3\tools\CEGUI-0.7.9-r5\bin -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item e:\MT3\tools\CEGUI-0.7.9-r5\lib -Recurse -Force -ErrorAction SilentlyContinue
```

### 5.3 重新构建

```powershell
msbuild tools\CEGUI-0.7.9-r5\projects\premake\CEGUI.sln /m /p:Configuration=Release /p:Platform=Win32
```

---

## 6. 常见问题

### 6.1 DevIL / FreeImage / Corona 链接失败

<!-- 修正日期: 2026-01-28 -->
<!-- 原错误: **原因**：依赖库未内置。 -->
<!-- 原错误: **处理**: 关闭 `config.lua` 中对应模块开关，或提供外部库并更新库路径。 -->

**原因**：config.lua中模块开关未启用或路径配置错误。
**处理**：

- 检查 `config.lua` 中对应模块开关是否已启用
- 验证库路径配置是否正确指向 `dependencies/` 目录
- 确认 `dependencies/lib/dynamic/` 中存在对应库文件

### 6.2 Ogre 编译失败

**原因**：OGRE SDK 路径无效或未安装。  
**处理**：

- 修改 `projects/premake/config.lua` 中 `OGRE_PATHS` 与 `BOOST_PYTHON_PATHS`
- 或在 VS 中卸载 `CEGUIOgreRenderer` 项目

### 6.3 Direct3D9 链接失败

**原因**：缺少 DXSDK June 2010 的 `d3dx9` / `dxerr`。  
**处理**：安装 DXSDK 或禁用 D3D9 渲染器。

### 6.4 v100 工具集缺失

**现象**：VS2013 打开工程后提示 toolset 不存在或编译失败。  
**处理**：安装 v100 工具集或使用 VS2010。

### 6.5 Samples 构建失败

**原因**：缺少 `freeglut.lib` 或 Ogre 依赖。  
**处理**：补齐 freeglut / Ogre SDK，或不构建 Samples。

---

## 附录A：构建日志模板

### A.1 构建日志模板

- 构建日期：
- 操作系统：
- VS 版本：
- Toolset：v100 / v120
- DirectX SDK：已安装 / 未安装
- Ogre SDK：已安装 / 未安装

#### 命令记录

```
msbuild tools\CEGUI-0.7.9-r5\projects\premake\CEGUI.sln /m /p:Configuration=Release /p:Platform=Win32
```

#### 构建结果

<!-- 修正日期: 2026-01-28 -->
<!-- 新增: CEGUICocos2DRenderer.dll 校验项 -->

- CEGUIBase.dll：成功 / 失败
- CEGUIOpenGLRenderer.dll：成功 / 失败
- CEGUIDirect3D9Renderer.dll：成功 / 失败
- CEGUICocos2DRenderer.dll：成功 / 失败 *(Cocos2D渲染器)*
- CEGUIOgreRenderer.dll：成功 / 失败
- CEGUIExpatParser.dll：成功 / 失败
- CEGUIFalagardWRBase.dll：成功 / 失败
- CEGUISILLYImageCodec.dll：成功 / 失败
- CEGUITGAImageCodec.dll：成功 / 失败
- CEGUISTBImageCodec.dll：成功 / 失败
- CEGUILuaScriptModule.dll：成功 / 失败

### A.2 校验清单

- [ ] `bin/CEGUIBase.dll`
- [ ] `bin/CEGUIOpenGLRenderer.dll`
- [ ] `bin/CEGUIDirect3D9Renderer.dll`
- [ ] `bin/CEGUIExpatParser.dll`
- [ ] `bin/CEGUIFalagardWRBase.dll`
- [ ] `bin/CEGUISILLYImageCodec.dll`
- [ ] `bin/CEGUITGAImageCodec.dll`
- [ ] `bin/CEGUISTBImageCodec.dll`
- [ ] `bin/CEGUILuaScriptModule.dll`

- [ ] `dependencies/bin/*.dll` 已拷贝至 `bin/`

- [ ] `config.h` 默认 XMLParser = Expat
- [ ] `config.h` 默认 ImageCodec = SILLY
