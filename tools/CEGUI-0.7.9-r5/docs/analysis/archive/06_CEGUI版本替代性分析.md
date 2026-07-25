# CEGUI 0.7.9-r5 替代 CEGUI-0.7.1 可行性分析

**分析日期**: 2026-01-02
**分析目的**: 确定 CEGUI 0.7.9-r5 是否可以完美替代 CEGUI-0.7.1

---

## 执行摘要

### 结论

| 评估维度 | 结果 | 说明 |
|---------|------|------|
| **API 兼容性** | ✅ 兼容 | 0.7.1 → 0.7.9 是小版本升级，API 保持兼容 |
| **头文件完整性** | ✅ 完整 | CEImagesetEditor 使用的所有头文件都存在 |
| **依赖库可用性** | ✅ 可用 | 依赖库已用 VS2013 (v120) 编译 |
| **预编译库** | ❌ 缺失 | **0.7.9-r5 没有 CEGUI 核心预编译库** |
| **编译可行性** | ⚠️ 需编译 | 需要修改 PlatformToolset 后重新编译 |

### 最终结论

> **CEGUI 0.7.9-r5 可以替代 CEGUI-0.7.1，但需要重新编译 CEGUI 核心库。**
>
> **推荐方案**：
> 1. 继续使用 CEGUI-0.7.1（已有预编译库，直接可用）
> 2. 或编译 CEGUI 0.7.9-r5 核心库（需要额外工作，但版本更新）

---

## 1. 版本对比

### 1.1 基本信息

| 属性 | CEGUI-0.7.1 | CEGUI 0.7.9-r5 |
|-----|-------------|----------------|
| 版本号 | 0.7.1 | 0.7.9 (r5) |
| 发布日期 | ~2016 | 2014-06-23 |
| 源码位置 | tools/CEGUI-0.7.1/ | tools/CEGUI-0.7.9-r5/ |
| 项目格式 | VS2010 | VS2010 (需改为 VS2013) |

### 1.2 版本差异说明

```
CEGUI 0.7.1 ──────────────────────────────────────────────> CEGUI 0.7.9-r5
    │                                                       │
    │  ←── 8 个小版本更新 (0.7.2 ~ 0.7.9)                    │
    │                                                       │
    v                                                       v
  较旧版本                                              较新版本
    │                                                       │
    │                                                       │
  Bug 修复                                           更多 Bug 修复
  稳定使用                                           功能改进
  有预编译库                                         无预编译库
```

---

## 2. 文件结构对比

### 2.1 目录结构

```
CEGUI-0.1.1/                        CEGUI 0.7.9-r5/
├── cegui/                          ├── cegui/
│   ├── include/                    │   ├── include/
│   └── src/                        │   └── src/
├── lib/ ⭐预编译库                  ├── dependencies/ ⭐依赖库
│   ├── CEGUIBase.lib               │   ├── include/
│   ├── CEGUIBase_d.lib             │   ├── lib/
│   ├── CEGUIOpenGLRenderer.lib     │   └── bin/
│   └── ...                         ├── projects/
├── dependencies/                   │   └── premake/
│   ├── include/                    └── docs/
│   └── lib/
├── projects/
│   └── premake/
└── bin/
    └── tolua++*.dll
```

### 2.2 关键差异

| 组件 | CEGUI-0.7.1 | CEGUI 0.7.9-r5 |
|-----|-------------|----------------|
| **CEGUI 核心库 (.lib)** | ✅ 有预编译 | ❌ 无，需编译 |
| **依赖库** | 有 | ✅ 更完整 |
| **文档** | 基础 | ✅ 已生成完整文档 |
| **项目文件** | VS2010 | VS2010 (需改 v120) |

---

## 3. API 兼容性分析

### 3.1 CEImagesetEditor 使用的 CEGUI API

CEImagesetEditor 仅使用以下 CEGUI 模块：

| 头文件 | 用途 | 0.7.1 | 0.7.9-r5 |
|--------|------|-------|----------|
| `CEGUI.h` | 主头文件 | ✅ | ✅ |
| `CEGUISystem.h` | 系统核心 | ✅ | ✅ |
| `CEGUIWindow.h` | 窗口基类 | ✅ | ✅ |
| `CEGUIImageset.h` | 图像集 | ✅ | ✅ |
| `CEGUIString.h` | 字符串 | ✅ | ✅ |
| `CEGUIcolour.h` | 颜色 | ✅ | ✅ |
| `CEGUIProperty.h` | 属性系统 | ✅ | ✅ |
| `CEGUIWindowRenderer.h` | 渲染器 | ✅ | ✅ |
| `CEGUIWindowFactory.h` | 工厂 | ✅ | ✅ |
| `elements/CEGUIFrameWindow.h` | 框架窗口 | ✅ | ✅ |
| `RendererModules/OpenGL/CEGUIOpenGLRenderer.h` | OpenGL 渲染 | ✅ | ✅ |
| `CEGUIXMLHandler.h` | XML 处理 | ✅ | ✅ |

**结论**: ✅ **所有头文件在两个版本中都存在**

### 3.2 API 签名兼容性

0.7.x 系列版本遵循 **API 兼容性承诺**：
- 公共 API 在 0.7.x 版本间保持稳定
- 新增功能通过新 API 添加，不修改现有 API
- 仅修复 Bug 和性能问题

---

## 4. 编译配置对比

### 4.1 当前状态

| 项目 | PlatformToolset | 预编译库 CRT | 状态 |
|-----|-----------------|-------------|------|
| CEImagesetEditor | v120 (VS2013) | MSVCR120.dll | ✅ 目标 |
| CEGUI-0.7.1 预编译库 | 未知 | MSVCR120.dll* | ✅ 可用 |
| CEGUI-0.7.1 依赖库 | v120 | MSVCR120.dll | ✅ 可用 |
| CEGUI 0.7.9-r5 项目 | v100 (VS2010) | - | ⚠️ 需修改 |
| CEGUI 0.7.9-r5 依赖库 | v120 | MSVCR120.dll | ✅ 可用 |

*CEGUI-0.7.1 的预编译库 CRT 版本需要验证

### 4.2 编译要求对比

```
CEGUI-0.1.1 (当前使用):
├── 有预编译 CEGUIBase.lib / CEGUIBase_d.lib
├── 有预编译 CEGUIOpenGLRenderer.lib
├── 直接可用于 CEImagesetEditor
└── ✅ 无需编译，开箱即用

CEGUI 0.7.9-r5 (升级方案):
├── ❌ 无 CEGUI 核心预编译库
├── ✅ 有完整的依赖库 (dependencies/)
├── 需要修改项目 PlatformToolset v100 → v120
├── 需要编译以下模块:
│   ├── CEGUIBase
│   ├── CEGUIOpenGLRenderer
│   ├── CEGUIExpatParser
│   ├── CEGUIFalagardWRBase
│   ├── CEGUISILLYImageCodec
│   └── tolua++
└── ⚠️ 需要编译才能使用
```

---

## 5. 替代方案评估

### 方案 A：继续使用 CEGUI-0.7.1

**优点**:
- ✅ 已有预编译库，直接可用
- ✅ 经过验证，稳定运行
- ✅ 无需额外编译工作

**缺点**:
- ⚠️ 版本较旧 (0.7.1 vs 0.7.9)
- ⚠️ 缺少后续版本的 Bug 修复

**工作量**: ⭐ 无需额外工作

### 方案 B：升级到 CEGUI 0.7.9-r5

**优点**:
- ✅ 版本更新 (0.7.9)
- ✅ 更多 Bug 修复和改进
- ✅ 完整的依赖库 (VS2013 编译)

**缺点**:
- ❌ 需要修改项目配置 (v100 → v120)
- ❌ 需要编译 CEGUI 核心库
- ⚠️ 需要验证兼容性

**工作量**: ⭐⭐⭐ 需要编译和验证

---

## 6. 编译 CEGUI 0.7.9-r5 步骤

如果选择升级方案 B，需要执行以下步骤：

### 6.1 修改项目工具集

批量修改所有 `.vcxproj` 文件：

```xml
<!-- 从 -->
<PlatformToolset>v100</PlatformToolset>
<!-- 改为 -->
<PlatformToolset>v120</PlatformToolset>
```

### 6.2 编译命令

```batch
cd E:\MT3\tools\CEGUI-0.7.9-r5\projects\premake

:: 编译 Debug 版本
msbuild CEGUI.sln /t:Rebuild /p:Configuration=Debug /p:Platform=Win32 /p:PlatformToolset=v120 /v:minimal

:: 编译 Release 版本
msbuild CEGUI.sln /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /v:minimal
```

### 6.3 编译产物

编译后会生成：

```
projects/premake/bin/
├── Debug/
│   ├── CEGUIBase_d.dll
│   ├── CEGUIBase_d.lib
│   ├── CEGUIOpenGLRenderer_d.dll
│   ├── CEGUIOpenGLRenderer_d.lib
│   └── ...
└── Release/
    ├── CEGUIBase.dll
    ├── CEGUIBase.lib
    ├── CEGUIOpenGLRenderer.dll
    ├── CEGUIOpenGLRenderer.lib
    └── ...
```

---

## 7. 集成到 CEImagesetEditor

### 7.1 修改项目配置

在 `vc++9/CEImagesetEditor.vcxproj` 中：

```xml
<!-- 修改 CEGUI 环境变量 -->
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <CEGUI>E:\MT3\tools\CEGUI-0.7.9-r5</CEGUI>
</PropertyGroup>

<!-- 或使用旧版本 -->
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
  <CEGUI>E:\MT3\tools\CEGUI-0.7.1</CEGUI>
</PropertyGroup>
```

### 7.2 运行时 DLL

确保输出目录包含所有必需 DLL：

```
bin/debug/
├── CEImagesetEditor_d.exe
├── CEGUIBase_d.dll
├── CEGUIOpenGLRenderer_d.dll
├── CEGUIExpatParser_d.dll
├── CEGUIFalagardWRBase_d.dll
├── CEGUISILLYImageCodec_d.dll
├── expat_d.dll (来自 dependencies/bin/)
├── freetype_d.dll
├── pcre_d.dll
├── SILLY_d.dll
├── lua_d.dll
├── zlib_d.dll
└── ... 其他依赖 DLL
```

---

## 8. 风险评估

### 8.1 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|-----|------|------|---------|
| 编译错误 | 中 | 中 | 已有 dependencies 库，主要是 CEGUI 核心代码 |
| API 不兼容 | 低 | 高 | 0.7.x 系列 API 兼容 |
| 运行时问题 | 低 | 中 | 充分测试 |

### 8.2 时间成本

| 任务 | 预估时间 |
|-----|---------|
| 修改 PlatformToolset | 5 分钟 |
| 编译 CEGUI 核心库 | 10-20 分钟 |
| 解决编译问题 | 0-2 小时 |
| 集成测试 | 1 小时 |
| **总计** | **2-4 小时** |

---

## 9. 最终建议

### 推荐方案：**继续使用 CEGUI-0.7.1**

**理由**:
1. ✅ 已有预编译库，开箱即用
2. ✅ 已验证可正常工作
3. ⏱️ 无需额外编译时间
4. 🎯 CEImagesetEditor 功能简单，不依赖新版本特性

### 升级时机

仅在以下情况考虑升级到 0.7.9-r5：
1. CEGUI-0.7.1 出现无法解决的 Bug
2. 需要 0.7.9 版本的新功能
3. 有充足的开发时间进行编译和测试

---

## 10. 总结

| 评估维度 | CEGUI-0.7.1 | CEGUI 0.7.9-r5 |
|---------|-------------|----------------|
| **版本** | 0.7.1 (较旧) | 0.7.9 (较新) |
| **预编译库** | ✅ 有 | ❌ 无 |
| **依赖库** | ✅ 有 | ✅ 完整 |
| **API 兼容** | ✅ 基准 | ✅ 兼容 |
| **即用性** | ✅ 开箱即用 | ⚠️ 需编译 |
| **推荐度** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

**结论**: CEGUI 0.7.9-r5 **可以替代** CEGUI-0.1.1，但需要重新编译。对于当前需求，**推荐继续使用 CEGUI-0.7.1**。

---

**文档版本**: 1.0
**最后更新**: 2026-01-02
