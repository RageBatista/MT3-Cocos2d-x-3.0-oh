# CEGUI 0.7.9 集成到 MT3 项目实施方案

> **创建日期**: 2026-01-07
> **目标**: 将 CEGUI 从 0.7.1 升级到 0.7.9-r5
> **状态**: 待执行

---

## 1. 执行摘要

### 1.1 升级目标

| 项目 | 当前版本 | 目标版本 |
|------|---------|----------|
| CEGUI | 0.7.1 (自定义) | 0.7.9-r5 |
| 位置 | `dependencies/cegui/` | 从 `tools/CEGUI-0.7.9-r5/` 合并 |

### 1.2 关键约束

- **保持静态库构建模式** (`cegui.lib`)
- **保留 MT3 自定义模块** (LJXMLParser, Cocos2DRenderer 等)
- **使用 VS2013 v120 工具集**
- **保持与 Cocos2d-x 2.0 的兼容性**

---

## 2. 版本差异分析

### 2.1 目录结构对比

| 模块类型 | dependencies (0.7.1) | tools (0.7.9-r5) | 差异 |
|----------|---------------------|------------------|------|
| XMLParserModules | 7个 | 8个 | +RapidXMLParser |
| RendererModules | 7个 | 9个 | +Direct3D11, +Null |
| 其他 | - | minizip | 新增 |

### 2.2 MT3 自定义模块

需要保留的自定义文件：

| 文件 | 位置 | 大小差异 | 操作 |
|------|------|---------|------|
| `CEGUILJXMLParser.cpp` | XMLParserModules/LJXMLParser/ | 7480 vs 5723 bytes | 保留 MT3 版本 |
| `CEGUILJXMLParserHelper.cpp` | XMLParserModules/LJXMLParser/ | 相同 | 可使用 0.7.9 |
| `CEGUILJXMLParserModule.cpp` | XMLParserModules/LJXMLParser/ | 相同 | 可使用 0.7.9 |
| Cocos2D 渲染器 | RendererModules/Cocos2D/ | 待比较 | 需评估 |

### 2.3 版本头文件

```
dependencies/cegui/CEGUI/include/CEGUIVersion.h
tools/CEGUI-0.7.9-r5/cegui/include/CEGUIVersion.h
```

---

## 3. 实施步骤

### 阶段 1: 准备工作

#### 1.1 备份现有 CEGUI

```powershell
# 创建备份目录
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "dependencies/cegui_backup_$timestamp"

# 复制整个目录
Copy-Item -Path "dependencies/cegui" -Destination $backupDir -Recurse

Write-Host "备份完成: $backupDir"
```

#### 1.2 保存 MT3 自定义模块

需要保留的文件清单：
- `dependencies/cegui/CEGUI/src/XMLParserModules/LJXMLParser/CEGUILJXMLParser.cpp`
- `dependencies/cegui/CEGUI/include/XMLParserModules/LJXMLParser/*.h`
- `dependencies/cegui/project/win32/cegui.win32.vcxproj` (项目配置)
- `dependencies/cegui/CEGUI/include/config.h` (MT3 配置)

### 阶段 2: 复制 0.7.9 源代码

#### 2.1 复制核心源代码

```powershell
# 复制 0.7.9 的核心源代码目录 (排除自定义模块)
$source = "tools/CEGUI-0.7.9-r5/cegui/src"
$dest = "dependencies/cegui/CEGUI/src"

# 复制核心文件 (排除 LJXMLParser 和 Cocos2D)
$excludeDirs = @("LJXMLParser", "Cocos2D")

Get-ChildItem -Path $source -Exclude $excludeDirs -Recurse | 
    Where-Object { $_.FullName -notmatch "LJXMLParser|Cocos2D" } |
    Copy-Item -Destination { 
        $destPath = $_.FullName.Replace($source, $dest)
        $destDir = Split-Path $destPath -Parent
        if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force }
        $destPath
    } -Force
```

#### 2.2 复制头文件

```powershell
$source = "tools/CEGUI-0.7.9-r5/cegui/include"
$dest = "dependencies/cegui/CEGUI/include"

# 类似处理，保留自定义配置
```

### 阶段 3: 合并自定义模块

#### 3.1 保留 MT3 版本的 LJXMLParser

`CEGUILJXMLParser.cpp` 保持 MT3 版本不变，因为包含特定的资源加载逻辑。

#### 3.2 评估 Cocos2D 渲染器

比较两个版本的 Cocos2D 渲染器：
- 如果 0.7.9 版本有重要修复，合并到 MT3 版本
- 如果 MT3 有特定修改，保留并应用 0.7.9 的 API 更新

### 阶段 4: 更新项目配置

#### 4.1 更新 vcxproj 文件

修改 `dependencies/cegui/project/win32/cegui.win32.vcxproj`：

1. 添加新增的源文件（如 minizip）
2. 更新 include 路径
3. 检查预处理器定义

#### 4.2 更新 config.h

合并 0.7.9 的配置选项到 MT3 的 config.h

### 阶段 5: 编译测试

#### 5.1 编译 CEGUI

```powershell
# 设置 VS2013 环境
cmd /c "call `"%VS120COMNTOOLS%..\..\VC\vcvarsall.bat`" x86"

# 编译 CEGUI
msbuild dependencies/cegui/project/win32/cegui.win32.vcxproj `
    /t:Rebuild `
    /p:Configuration=Release `
    /p:Platform=Win32 `
    /p:PlatformToolset=v120 `
    /m
```

#### 5.2 编译 MT3 主项目

```powershell
msbuild client/MT3Win32App/mt3.win32.vcxproj `
    /t:Build `
    /p:Configuration=Release `
    /p:Platform=Win32 `
    /p:PlatformToolset=v120 `
    /m
```

### 阶段 6: 功能验证

- [ ] MT3 编译成功
- [ ] MT3 启动正常
- [ ] UI 界面显示正确
- [ ] Lua 脚本交互正常
- [ ] 无运行时崩溃

---

## 4. 风险评估

### 4.1 高风险

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| API 不兼容 | 编译失败 | 逐步合并，保留旧代码 |
| 运行时崩溃 | 功能不可用 | 完整备份，可快速回滚 |
| Cocos2d-x 集成问题 | 渲染异常 | 保留 MT3 版本渲染器 |

### 4.2 中风险

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| Lua 绑定变化 | 脚本错误 | 验证 tolua++ 接口 |
| XML 解析差异 | 资源加载失败 | 保留 LJXMLParser |

### 4.3 低风险

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| 编译警告增加 | 无功能影响 | 后续优化 |

---

## 5. 回滚方案

如果升级失败，执行以下回滚步骤：

```powershell
# 1. 删除失败的升级
Remove-Item -Path "dependencies/cegui" -Recurse -Force

# 2. 恢复备份
$backupDir = "dependencies/cegui_backup_XXXXXXXXXX"  # 使用实际备份目录
Move-Item -Path $backupDir -Destination "dependencies/cegui"

# 3. 清理编译产物
Remove-Item -Path "client/MT3Win32App/Release.win32/cegui.lib" -Force

# 4. 重新编译
msbuild dependencies/cegui/project/win32/cegui.win32.vcxproj /t:Rebuild ...
```

---

## 6. 执行确认

在执行升级前，请确认：

- [ ] 已备份 `dependencies/cegui/` 目录
- [ ] 已保存 MT3 自定义模块
- [ ] 已理解回滚方案
- [ ] 有足够时间进行测试

---

## 附录: 文件路径

| 描述 | 路径 |
|------|------|
| MT3 CEGUI 目录 | `dependencies/cegui/` |
| 0.7.9 源码目录 | `tools/CEGUI-0.7.9-r5/cegui/` |
| MT3 CEGUI 项目文件 | `dependencies/cegui/project/win32/cegui.win32.vcxproj` |
| MT3 LJXMLParser | `dependencies/cegui/CEGUI/src/XMLParserModules/LJXMLParser/` |

---

**报告生成**: Claude AI
**审核状态**: 待确认执行
