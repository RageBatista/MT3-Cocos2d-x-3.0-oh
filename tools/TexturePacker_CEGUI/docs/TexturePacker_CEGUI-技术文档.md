# TexturePacker_CEGUI 技术文档

> **版本**: 1.3.0 | **更新日期**: 2026-03-02 | **状态**: 方案 C 落地设计（融合 free-tex-packer 功能逻辑）  
> **目标目录**: `client/resource/res/ui/imagesets/`（运行时相对路径：`resource/res/ui/imagesets/`）

---

## 目录

1. [概述](#1-概述)
2. [架构设计](#2-架构设计)
3. [核心接口](#3-核心接口)
4. [使用指南](#4-使用指南)
5. [技术边界](#5-技术边界)
6. [项目实施代码结构](#6-项目实施代码结构)
7. [技术架构详解](#7-技术架构详解)
8. [技术栈方案](#8-技术栈方案)
9. [GUI 依赖与集成](#9-gui-依赖与集成)
10. [实施计划与验收标准](#10-实施计划与验收标准)
11. [方案 C 落地实现详设](#11-方案-c-落地实现详设)
12. [方案 C 构建与依赖矩阵](#12-方案-c-构建与依赖矩阵)

---

## 1. 概述

### 1.1 工具功能描述

`TexturePacker_CEGUI` 是面向 MT3 客户端 UI 资源的专用图集处理工具，用于将 UI 碎图批量打包并生成 CEGUI 0.7.1 可直接加载的 `.imageset` 文件，最终产物写入：

- `client/resource/res/ui/imagesets/<atlas>.png`（或 `.tga`）
- `client/resource/res/ui/imagesets/<atlas>.imageset`

该工具定位为 `resource/res/ui/imagesets` 资源链路的标准化入口，替代人工拼图与手写 XML。

### 1.2 现状基线（2026-03-02）

对当前仓库扫描结果：

| 指标 | 数值 |
|------|------|
| `.imageset` 文件数 | 611 |
| `.png` 文件数 | 597 |
| 包含 `TexturePacker` 注释的 `.imageset` | 486 |
| 含 `AutoScaled` 属性的 `.imageset` | 550 |

说明：

- 当前 `imagesets` 目录历史来源较多，格式存在轻微差异（XML 声明、有无注释、属性顺序等）。
- 新工具需要输出**统一格式**并保持 CEGUI 0.7.1 兼容。

### 1.3 主要特性（规划）

| 特性 | 说明 |
|------|------|
| **单图集打包** | 指定图集名称执行一次打包与导出 |
| **批量打包** | 根据配置清单一次构建多个图集 |
| **CEGUI 输出** | 自动生成 `.imageset`，无需人工编辑 |
| **确定性输出** | 同输入同参数下输出稳定，便于版本管理 |
| **校验能力** | 构建后验证 XML 合法性与文件引用关系 |
| **安全覆盖** | 支持备份后覆盖写入，支持失败回滚 |

### 1.4 技术栈（建议实现）

```yaml
执行层: PowerShell 5.1+
打包引擎: builtin-shelf-packer（内置 C++ 打包算法）
配置格式: JSON
输出编码: UTF-8 (无 BOM)
目标格式: CEGUI 0.7.1 Imageset XML
```

推荐原则：

1. 核心打包链路优先 CLI 化（可脚本、可 CI、可批量）。  
2. GUI 仅作为操作外壳，不承载核心规则。  
3. 核心规则由同一配置驱动，避免 GUI/CLI 双份逻辑分叉。

---

## 2. 架构设计

### 2.1 模块划分

| 模块 | 职责 |
|------|------|
| `ManifestLoader` | 读取全局配置与图集清单 |
| `BuiltinPacker` | 执行内置 shelf 打包并回写帧信息 |
| `FrameNormalizer` | 标准化帧数据（坐标、尺寸、命名） |
| `ImagesetEmitter` | 生成 `.imageset` XML |
| `OutputWriter` | 输出 `png/tga + .imageset` 到目标目录 |
| `Validator` | 校验 XML 与资源引用一致性 |
| `BatchRunner` | 串行/批量执行与失败处理 |

### 2.2 目录约定（建议）

```
tools/TexturePacker_CEGUI/
├── docs/                         # 技术文档
├── configs/                      # 打包配置（*.json）
├── scripts/                      # 执行脚本（*.ps1）
├── workspace/                    # 临时工作目录
└── out/                          # 中间产物（可清理）

client/resource/res/ui/imagesets/ # 最终输出目录
```

### 2.3 数据流

```
输入碎图目录
   │
   ▼
读取图集配置(JSON)
   │
   ▼
调用 builtin-shelf-packer 生成图集与帧元数据
   │
   ▼
帧数据标准化（坐标/名称/排序）
   │
   ▼
生成 .imageset (CEGUI 0.7.1)
   │
   ▼
写入 client/resource/res/ui/imagesets/
   │
   ▼
执行校验（XML + 文件存在 + 引用检查）
```

---

## 3. 核心接口

### 3.1 命令行接口（已落地）

```powershell
.\tools\TexturePacker_CEGUI\bin\release\TexturePacker_CEGUI.exe `
  --pack `
  --src=.\art\ui\common_pack `
  --out=.\client\resource\res\ui\imagesets `
  --atlas=common_pack `
  --max-width=2048 `
  --max-height=2048 `
  --border-padding=2 `
  --shape-padding=2 `
  --allow-trim `
  --power-of-two
```

参数说明：

| 参数 | 必填 | 说明 |
|------|------|------|
| `--pack` | 是 | 启用正式命令行打包模式 |
| `--src=<dir>` | 是 | 源图片目录 |
| `--out=<dir>` | 否 | 输出目录，默认 `client/resource/res/ui/imagesets` |
| `--atlas=<name>` | 否 | 图集基础名称，默认 `ui_atlas` |
| `--max-width=<int>` | 否 | 图集最大宽度，默认 `2048` |
| `--max-height=<int>` | 否 | 图集最大高度，默认 `2048` |
| `--border-padding=<int>` | 否 | 边距，默认 `2` |
| `--shape-padding=<int>` | 否 | 切片间距，默认 `2` |
| `--native-horz-res=<int>` | 否 | imageset 原生水平分辨率，默认 `1024` |
| `--native-vert-res=<int>` | 否 | imageset 原生垂直分辨率，默认 `768` |
| `--allow-trim` | 否 | 开启透明边裁剪 |
| `--allow-rotation` | 否 | 参数保留，当前实现按不旋转处理 |
| `--power-of-two` | 否 | 图集尺寸向上取 POT |
| `--no-auto-split` | 否 | 关闭自动拆分页；超限直接失败 |

### 3.2 配置对象（用于后续批量化扩展）

```json
{
  "global": {
    "packerBackend": "builtin-shelf",
    "outputRoot": "client/resource/res/ui/imagesets",
    "allowRotation": false,
    "allowTrim": false,
    "autoSplit": true,
    "shapePadding": 2,
    "borderPadding": 2,
    "autoScaled": false
  },
  "atlases": [
    {
      "name": "common_pack",
      "sourceDir": "art/ui/common_pack",
      "format": "png",
      "nativeHorzRes": 1024,
      "nativeVertRes": 512,
      "includePatterns": ["*.png", "*.tga"],
      "excludePatterns": ["*_bak.*", "*_old.*"]
    }
  ]
}
```

### 3.3 `.imageset` 输出规范

根节点约束：

| 属性 | 说明 |
|------|------|
| `Name` | 图集名称，与输出文件名一致（不含扩展名） |
| `Imagefile` | 图集贴图文件名（如 `common_pack.png`） |
| `NativeHorzRes` | 原生水平分辨率 |
| `NativeVertRes` | 原生垂直分辨率 |
| `AutoScaled` | 默认 `false` |

子节点约束：

- 每个切片输出一个 `<Image />`
- 字段为 `Name / XPos / YPos / Width / Height`
- 默认不输出旋转与裁剪偏移字段（与当前项目资源习惯一致）

示例：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Imageset Name="allnumber" Imagefile="allnumber.png" NativeHorzRes="256" NativeVertRes="256" AutoScaled="false">
    <Image Name="number0" XPos="2" YPos="202" Width="43" Height="48"/>
    <Image Name="number1" XPos="49" YPos="2" Width="34" Height="48"/>
</Imageset>
```

### 3.4 生成约束

1. 输出编码统一为 UTF-8 无 BOM。  
2. 自动拆分页命名规则：单页为 `<atlas>.*`，多页为 `<atlas>_1.*`、`<atlas>_2.*`。  
3. 图集中 `Image` 名称必须唯一。  
4. 默认不旋转；`allowTrim` 可选开启透明边裁剪。  
5. 输出文件名必须与 `.imageset` 的 `Name`/`Imagefile` 自洽。

### 3.5 退出码约定（CLI）

| 退出码 | 含义 |
|--------|------|
| `0` | 成功 |
| `11` | `--smoke-ui` 失败 |
| `12` | `--smoke-pack` 失败 |
| `21` | `--pack` 参数错误 |
| `22` | `--pack` 执行失败 |

---

## 4. 使用指南

### 4.1 环境要求

```yaml
操作系统: Windows 10/11
Shell: PowerShell 5.1+
外部工具: 无（内置 builtin-shelf-packer）
项目约束: 不影响 v120 客户端编译链，仅处理资源文件
```

### 4.2 单图集构建流程

1. 准备源碎图目录（如 `art/ui/common_pack/`）。
2. 执行 `--pack`：

```powershell
.\tools\TexturePacker_CEGUI\bin\release\TexturePacker_CEGUI.exe `
  --pack `
  --src=.\art\ui\common_pack `
  --out=.\client\resource\res\ui\imagesets `
  --atlas=common_pack
```

3. 确认输出：
    - `client/resource/res/ui/imagesets/common_pack.png`
    - `client/resource/res/ui/imagesets/common_pack.imageset`

### 4.3 自动拆分页流程（容量超限）

```powershell
.\tools\TexturePacker_CEGUI\bin\release\TexturePacker_CEGUI.exe `
  --pack `
  --src=.\art\ui\big_pack `
  --out=.\client\resource\res\ui\imagesets `
  --atlas=big_pack `
  --max-width=1024 `
  --max-height=1024
```

当单图集无法容纳全部切片时，会自动输出：

- `big_pack_1.png` + `big_pack_1.imageset`
- `big_pack_2.png` + `big_pack_2.imageset`
- ...

### 4.4 校验命令（建议）

XML 可解析性检查：

```powershell
Get-ChildItem client/resource/res/ui/imagesets -Filter *.imageset | ForEach-Object {
    [xml](Get-Content -Raw -Encoding UTF8 $_.FullName) | Out-Null
}
```

`.imageset -> Imagefile` 存在性检查：

```powershell
Get-ChildItem client/resource/res/ui/imagesets -Filter *.imageset | ForEach-Object {
    $xml = [xml](Get-Content -Raw -Encoding UTF8 $_.FullName)
    $imageFile = $xml.Imageset.Imagefile
    $imagePath = Join-Path $_.DirectoryName $imageFile
    if (-not (Test-Path $imagePath)) {
        Write-Host "[MISS] $($_.Name) -> $imageFile"
    }
}
```

与 `scheme` 联动检查（按文件名）：

```powershell
rg -n "<Imageset Filename=\".*\\.imageset\"" client/resource/res/ui/schemes
```

### 4.5 回滚策略

1. 构建前将目标文件复制到 `tools/TexturePacker_CEGUI/workspace/backup/<timestamp>/`。  
2. 构建失败或校验失败时，覆盖恢复备份文件。  
3. 回滚后重新执行验证命令，确保目录状态一致。

---

## 5. 技术边界

### 5.1 不支持的功能（当前规划）

| 功能 | 说明 |
|------|------|
| **自动改写 looknfeel** | 不自动修改 `looknfeel` 内部 `imageset/image` 引用 |
| **自动改写 scheme** | 不自动新增/删除 `scheme` 的 `<Imageset Filename=.../>` |
| **九宫格拆分** | 不替代 `tools/SplitImageset` 的后处理职责 |
| **跨平台纹理压缩** | 不负责 ETC/PVR/ASTC 压缩链路 |

### 5.2 已知限制

| 限制 | 影响 |
|------|------|
| 大图集尺寸过大（如 >4096） | 可能引起低端设备显存压力 |
| 重名切片 | 会导致 `.imageset` 中 `Image Name` 冲突 |
| 源图尺寸不规范 | 可能造成排版效率低、空白浪费大 |
| 手工改动历史文件风格不一致 | 首次统一时可能产生较大 diff |

### 5.3 扩展建议

1. 增加增量构建（基于输入哈希跳过未变更图集）。  
2. 接入 CI 资源检查任务（PR 阶段自动校验 `.imageset`）。  
3. 增加 GUI 前端（供技术美术可视化选择源目录与参数）。  
4. 增加 `scheme/looknfeel` 引用差异报告（仅报告，不自动改写）。

---

## 6. 项目实施代码结构

### 6.1 建议目录布局（V1 + V2）

```
tools/TexturePacker_CEGUI/
├── docs/
│   └── TexturePacker_CEGUI-技术文档.md
├── configs/
│   ├── atlas.build.json                  # 主配置（图集清单）
│   ├── atlas.schema.json                 # 配置结构约束（可选）
│   └── profiles/
│       ├── dev.json                      # 开发环境参数覆盖
│       ├── ci.json                       # CI 环境参数覆盖
│       └── release.json                  # 发布参数覆盖
├── templates/
│   ├── CEGUI.imageset.mustache           # 默认导出模板（受控变量）
│   └── custom/                           # 可选自定义导出模板
├── project/
│   ├── samples/                          # 工程文件样例（*.tpcgproj）
│   └── schema/
│       └── tpcgproj.schema.json          # 工程文件结构约束
├── scripts/
│   ├── smoke-test.ps1                    # 冒烟入口（UI + 打包）
│   ├── validate-imageset.ps1             # 独立校验入口
│   ├── rollback-atlas.ps1                # 回滚工具
│   ├── export-build-report.ps1           # 构建报告导出
│   └── lib/
│       ├── Config.ps1                    # 配置加载与合并
│       ├── TexturePackerInvoker.cpp      # 内置打包调用与执行
│       ├── FrameNormalizer.ps1           # 帧信息标准化
│       ├── ImagesetWriter.ps1            # .imageset 写出
│       ├── TemplateExporter.ps1          # 模板导出引擎（V2）
│       ├── IdenticalDetector.ps1         # 同图检测与复用（V2）
│       ├── PackerStrategy.ps1            # 策略组合/优选（V2）
│       ├── Validator.ps1                 # 校验逻辑
│       ├── Backup.ps1                    # 备份与恢复
│       └── Logger.ps1                    # 日志与退出码
├── tests/
│   ├── fixtures/
│   │   ├── source-sample/                # 测试输入碎图
│   │   └── expected-imageset/            # 期望输出
│   ├── smoke/
│   │   └── smoke-pack.ps1                # 冒烟测试
│   └── regression/
│       └── compare-imageset.ps1          # 回归比较
├── workspace/
│   ├── backup/                           # 覆盖前备份
│   ├── temp/                             # 中间文件
│   └── logs/                             # 日志
└── gui/                                  # 可选 GUI 项目
    └── TexturePacker.CEGUI.Gui/
```

### 6.2 核心脚本职责拆分

| 文件 | 职责 | 输入 | 输出 |
|------|------|------|------|
| `TexturePacker_CEGUI.exe --pack` | 主流程调度 | 参数 + 目录 | 图集文件 + 退出码 |
| `TexturePackerInvoker.cpp` | 调用内置打包器 | 图集任务 | `png + tp.xml + imageset` |
| `ImagesetWriter.ps1` | 生成 XML | 标准化帧数据 | `.imageset` |
| `TemplateExporter.ps1` | 模板渲染导出（V2） | `FrameInfo[] + 模板` | 自定义文本产物 |
| `IdenticalDetector.ps1` | 同图检测与克隆映射（V2） | 帧图像签名 | 去重映射关系 |
| `PackerStrategy.ps1` | 打包策略优选（V2） | 候选策略集 | 最优策略结果 |
| `Validator.ps1` | 完整性校验 | 输出目录 | 校验报告 |
| `Backup.ps1` | 备份/恢复 | 目标文件 | 备份目录/恢复结果 |

### 6.3 推荐数据模型（逻辑）

```yaml
BuildConfig:
  global: 全局参数
  profiles: ProfileMap
  atlases: AtlasTask[]

PackOptions:
  width/height: 画布尺寸
  fixedSize: 固定尺寸
  powerOfTwo: 2次幂约束
  padding: 切片边距
  extrude: 边缘挤出像素
  allowRotation: 允许旋转
  allowTrim: 允许透明裁剪
  trimMode: trim/crop
  alphaThreshold: 裁剪阈值(0-255)
  detectIdentical: 同图检测
  packer: 策略类型(MaxRectsBin/MaxRectsPacker/Optimal)
  packerMethod: 策略方法

AtlasTask:
  name: 图集名
  sourceDir: 源目录
  outputImage: 输出图像路径
  outputImageset: 输出imageset路径
  nativeHorzRes/nativeVertRes: 原生分辨率
  includePatterns/excludePatterns: 文件匹配规则
  options: PackOptions

ProjectState:
  version: 工程版本
  recentProjects: 最近工程列表
  selectedProfile: 当前配置档(dev/ci/release)
  selectedAtlases: 当前勾选图集

FrameInfo:
  name: 切片名
  x/y/w/h: 坐标与尺寸
  rotated: 是否旋转
  trimmed: 是否裁剪
  spriteSourceSize/sourceSize: 原图回写信息
  duplicateOf: 被复用源切片(可选)

BuildResult:
  atlas: 图集名
  status: success/failed
  message: 错误或告警信息
  strategy: 采用的打包策略
  efficiency: 占用率
  outputs: 输出文件列表
```

### 6.4 命名与分层约束

1. `scripts/lib` 禁止直接访问 UI 层对象。  
2. GUI 层只调用 `TexturePackerInvoker` 或命令行 `--pack` 入口。  
3. 所有输出路径统一通过 `Config.ps1` 计算，禁止硬编码。  
4. 规则改动优先在 `FrameNormalizer` 与 `Validator` 实现，保证单点维护。
5. 与导出格式相关的逻辑统一在 `TemplateExporter`，避免散落在 UI 层。

### 6.5 参考 free-tex-packer 的功能映射增强

| free-tex-packer 能力 | 参考点 | 方案 C 落地模块 |
|------|------|------|
| 参数中心化与默认值补齐 | `ui/PackProperties.jsx` | `ConfigLoader + PackOptions` |
| 打包策略/方法可切换 | `packers/* + OptimalPacker` | `PackerStrategy + AtlasBuildPlanner` |
| 同图检测复用 | `PackProcessor.detectIdentical/applyIdentical` | `IdenticalDetector + FrameNormalizer` |
| 裁剪阈值控制 | `utils/Trimmer.js` | `TrimAnalyzer + Validator` |
| 模板化导出 | `exporters/index.js + *.mst` | `TemplateExporter + templates/*.mustache` |
| 工程保存/最近项目 | `platform/electron/Project.js` | `ProjectStore + RecentProjectService` |
| 事件驱动交互 | `Observer.js` | `ToolEventBus + UIEventDispatcher` |
| 图集逆向拆分 | `ui/SheetSplitter.jsx + splitters/*` | `AtlasSplitter(调试工具, V2)` |

---

## 7. 技术架构详解

### 7.1 分层架构

```
┌───────────────────────────────────────────────┐
│ Presentation Layer                            │
│ - CLI: TexturePacker_CEGUI.exe --pack         │
│ - GUI: TexturePacker.CEGUI.Gui (可选)         │
└───────────────────────┬───────────────────────┘
                        │
┌───────────────────────▼───────────────────────┐
│ Application Layer                             │
│ - BatchRunner                                 │
│ - TaskPlanner                                 │
│ - BuildOrchestrator                           │
└───────────────────────┬───────────────────────┘
                        │
┌───────────────────────▼───────────────────────┐
│ Domain Layer                                  │
│ - AtlasTask / FrameInfo / BuildResult         │
│ - 名称规则、坐标规则、输出规则                 │
└───────────────────────┬───────────────────────┘
                        │
┌───────────────────────▼───────────────────────┐
│ Infrastructure Layer                          │
│ - TexturePackerInvoker                        │
│ - FileSystem/Backup                           │
│ - XML Writer/Validator                        │
│ - Logger                                      │
└───────────────────────────────────────────────┘
```

### 7.2 执行时序（单图集）

1. 入口层读取参数并合并配置（含 `profile + atlas options`）。  
2. `TaskPlanner` 解析目标图集任务并补齐默认参数。  
3. `PackerStrategy` 计算候选策略（单策略或自动优选）。  
4. `TexturePackerInvoker` 调用内置 shelf packer。  
5. `IdenticalDetector` 执行同图复用映射（可选）。  
6. `FrameNormalizer` 规范化帧数据（旋转/裁剪回写）。  
7. `ImagesetWriter` 输出标准 `.imageset`。  
8. `TemplateExporter` 生成扩展报告/调试格式（可选）。  
9. `Validator` 执行 XML/引用/唯一性校验。  
10. 成功写入报告并刷新预览；失败触发回滚。

### 7.3 异常处理架构

| 失败点 | 处理策略 | 退出码 |
|--------|----------|--------|
| 配置解析失败 | 立即终止，输出配置路径与字段名 | `1` |
| TexturePacker 失败 | 输出命令与 stderr，保留中间日志 | `2` |
| XML 生成失败 | 终止并恢复备份 | `3` |
| 校验失败 | 标记失败并按策略回滚 | `4` |

### 7.4 可观测性设计

建议日志字段：

```yaml
timestamp: 时间戳
atlas: 图集名称
stage: prepare/pack/emit/validate/rollback
duration_ms: 执行耗时
result: success/failed
error_code: 退出码
message: 详细信息
```

---

## 8. 技术栈方案

### 8.1 方案总览

| 方案 | 核心实现 | 适用阶段 | 结论 |
|------|----------|----------|------|
| **方案 A** | PowerShell + 外部打包器 | 快速验证 | 备选 |
| **方案 B** | C# Console Core + PowerShell Wrapper | 中期工程化 | 备选 |
| **方案 C（已采用）** | C++ 原生工具（wxWidgets + CEGUI） | 深度集成 + 真实预览 | ✅ 当前实施方案 |

### 8.2 方案 A（推荐）细节

```yaml
语言: PowerShell 5.1
执行方式: 脚本 + CLI
XML处理: .NET System.Xml
优点:
  - 与现有工具脚本体系一致
  - 集成 CI 成本低
  - 迭代快
限制:
  - 复杂业务可维护性低于编译型语言
```

### 8.3 方案 B（工程化演进）细节

```yaml
语言: C# (.NET Framework 4.5/4.8)
结构: Core Library + CLI + PowerShell 封装
优点:
  - 单元测试能力更强
  - 可维护性更好
  - 便于 GUI 复用核心服务
限制:
  - 初始工程搭建成本高于脚本
```

### 8.4 当前决策（方案 C）

1. 本项目当前采用方案 C，直接建设 C++ 原生 GUI 工具。  
2. GUI 内部集成 CEGUI OpenGL 渲染链路，提供“真实渲染预览”。  
3. 打包调用使用内置 shelf packer，编排与预览逻辑在 C++ 工程中闭环。  
4. 保留 CLI 模式用于自动化构建与 CI。

---

## 9. GUI 依赖与集成

### 9.1 GUI 定位（方案 C）

GUI 是“操作入口”，核心目标：

1. 降低技术美术使用门槛。  
2. 可视化编辑图集任务参数。  
3. 提供 CEGUI 真实渲染预览（非静态缩略图）。  
4. 展示构建结果、告警与回滚入口。  
5. 与 CLI 配置保持同源，避免双规则。

### 9.2 GUI 项目建议结构（C++ 原生）

```
tools/TexturePacker_CEGUI/
├── src/
│   ├── app/
│   │   ├── TPCEGUIApp.cpp                    # wxApp 启动与依赖检查
│   │   └── RuntimeDependencyChecker.cpp      # 运行时依赖验证
│   ├── framework/
│   │   ├── MainFrame.cpp                     # 主框架窗口
│   │   ├── PreviewCanvas.cpp                 # wxGLCanvas 渲染宿主
│   │   └── DockPanels.cpp                    # 属性/日志/任务面板
│   ├── preview/
│   │   ├── CEGUIRenderHost.cpp               # OpenGLRenderer + System 生命周期
│   │   ├── ImagesetPreviewScene.cpp          # 图集与区域可视化场景
│   │   ├── WidgetPreviewScene.cpp            # 控件真实预览场景
│   │   └── InputInjector.cpp                 # wx 事件到 CEGUI 注入
│   ├── pipeline/
│   │   ├── ToolEventBus.h/.cpp               # 事件总线（参考 Observer）
│   │   └── UIEventDispatcher.cpp             # 线程间消息投递
│   ├── packer/
│   │   ├── TexturePackerInvoker.cpp          # CreateProcess 调用 TP CLI
│   │   ├── AtlasBuildPlanner.cpp             # 批处理任务规划
│   │   ├── PackerStrategy.cpp                # 策略选择与自动优选
│   │   └── BuildWorker.cpp                   # 后台构建线程
│   ├── exporter/
│   │   ├── ImagesetExporter.cpp              # CEGUI 导出器
│   │   └── TemplateExporter.cpp              # 模板导出器（V2）
│   ├── project/
│   │   ├── ProjectStore.cpp                  # 工程读写 (*.tpcgproj)
│   │   └── RecentProjectService.cpp          # 最近工程列表
│   ├── splitter/
│   │   └── AtlasSplitter.cpp                 # 图集逆向拆分调试工具（V2）
│   ├── model/
│   │   ├── AtlasTask.h
│   │   ├── PackOptions.h
│   │   ├── FrameInfo.h
│   │   └── BuildReport.h
│   ├── io/
│   │   ├── ConfigLoader.cpp                  # JSON 配置加载
│   │   ├── ImagesetSerializer.cpp            # .imageset 读写
│   │   └── BackupManager.cpp                 # 备份/回滚
│   └── common/
│       ├── Logger.cpp
│       └── ErrorCodes.h
├── inc/
├── data/                                     # Scheme/LookNFeel/Imageset
├── vc++12/TexturePacker_CEGUI.vcxproj
└── docs/
```

### 9.3 GUI 依赖清单（方案 C）

#### 9.3.1 核心依赖（必须）

| 依赖 | 版本/来源 | 用途 |
|------|-----------|------|
| `Visual Studio 2013 v120` | 项目强制 | 编译工具链 |
| `wxWidgets 3.0.5` | `dependencies/wxWidgets-3.0.5` | 窗口/停靠面板/事件 |
| `CEGUI 0.7.1` | `tools/CEGUI-0.7.1` | UI 系统与真实渲染 |
| `OpenGL32/GLU32` | 系统库 | 渲染上下文 |
| `builtin-shelf-packer` | 内置实现 | 图集打包执行引擎 |

#### 9.3.2 CEGUI 运行时 DLL（参照现有编辑器）

Debug：

- `CEGUIBase_d.dll`
- `CEGUIOpenGLRenderer_d.dll`
- `CEGUIExpatParser_d.dll`
- `CEGUIFalagardWRBase_d.dll`
- `CEGUISILLYImageCodec_d.dll`
- `CEGUITGAImageCodec_d.dll`
- `SILLY_d.dll`

Release：

- `CEGUIBase.dll`
- `CEGUIOpenGLRenderer.dll`
- `CEGUIExpatParser.dll`
- `CEGUIFalagardWRBase.dll`
- `CEGUISILLYImageCodec.dll`
- `CEGUITGAImageCodec.dll`
- `SILLY.dll`

数据文件（运行前校验）：

- `data/CEImagesetEditor.scheme`
- `data/CEImagesetEditor.looknfeel`
- `data/CEImagesetEditor.imageset`
- `data/Imageset.xsd`
- `data/Falagard.xsd`

### 9.4 GUI 与 CLI 的协作接口

| GUI 操作 | CLI 对应 |
|----------|----------|
| 点击“构建当前图集” | `TexturePackerInvoker::Run(task)` |
| 点击“全量构建” | `AtlasBuildPlanner + BuildWorker` |
| 点击“校验” | `Validator::ValidateAll(outputRoot)` |
| 点击“回滚” | `BackupManager::Restore(snapshotId)` |

### 9.5 GUI 功能最小集（V1）

1. 配置文件选择与保存。  
2. 图集列表展示（增删改查）。  
3. 构建按钮（单个/全部）。  
4. CEGUI 真实渲染预览窗口（支持缩放、拖拽、选区）。  
5. 日志窗口与错误详情。  
6. 打开输出目录与备份目录。

### 9.6 GUI 高级能力（V2，参考 free-tex-packer）

| 能力 | UI 表现 | 默认策略（CEGUI 兼容优先） |
|------|------|------|
| 打包参数面板 | `width/height/fixedSize/powerOfTwo/padding/extrude` | 采用项目默认配置，可按图集覆写 |
| 旋转与裁剪控制 | `allowRotation/allowTrim/trimMode/alphaThreshold` | `allowRotation=false`, `allowTrim=false` |
| 同图复用 | `detectIdentical` 开关 + 冲突提示 | 默认 `true` |
| 策略选择 | `packer + packerMethod` 下拉 | 默认 `MaxRectsBin + BestShortSideFit` |
| 工程文件管理 | 新建/打开/保存/另存 + 最近工程 | 使用 `*.tpcgproj` |
| 导出模板 | 内置 CEGUI 模板 + 自定义模板编辑 | V1 仅开放内置，V2 开放自定义 |
| 调试拆分 | 导入旧图集+元数据并高亮切片 | 仅调试用途，不进入生产链路 |

---

## 10. 实施计划与验收标准

### 10.1 迭代计划

| 里程碑 | 内容 | 产出 |
|--------|------|------|
| `M1` | C++ 工程骨架 + wx 主窗体 + 渲染画布 | 可启动 GUI |
| `M2` | CEGUI 初始化与真实渲染预览 | 可加载并预览 imageset |
| `M3` | TexturePacker 集成 + 参数面板 + 单图集构建 | GUI 内可触发打包并调参 |
| `M4` | 批量任务 + 策略优选 + 同图复用 + 校验回滚 | 稳定生产链路 |
| `M5` | 工程文件管理 + 模板导出 + 回归测试 | 可追踪、可审计、可复用 |

### 10.2 验收标准

1. GUI 可稳定加载 CEGUI，并完成真实渲染（`renderGUI`）无崩溃。  
2. 指定图集可重复构建且输出一致。  
3. 批量构建失败时可回滚到构建前状态。  
4. `.imageset` XML 解析与引用校验通过。  
5. 输出目录中无孤儿图集或缺失贴图。  
6. 全流程日志可追踪问题定位（含渲染/打包阶段）。
7. 工程文件（`*.tpcgproj`）可稳定保存/加载并正确恢复参数。

### 10.3 回归用例建议

| 用例 | 预期 |
|------|------|
| CEGUI 依赖缺失启动 | 启动阶段阻断并提示缺失 DLL/数据文件 |
| 预览窗口鼠标交互 | 缩放/拖拽/选区事件与渲染一致 |
| 正常单图集构建 | 退出码 `0`，产物正确 |
| 配置缺字段 | 退出码 `1`，报错明确 |
| TexturePacker 不可用 | 退出码 `2`，给出命令与路径 |
| 输出写入失败 | 回滚成功，退出码 `3/4` |
| 重名切片输入 | 校验失败并给出冲突列表 |
| 同图复用开启 | 输出帧数减少且命名映射正确 |
| trim 阈值变化 | 切片边界变化符合阈值预期 |
| 策略自动优选 | 在同尺寸约束下 sheet 数最少或占用率更高 |
| 工程文件重载 | 参数、图集列表、最近工程状态恢复正确 |

---

## 11. 方案 C 落地实现详设

### 11.1 技术目标

1. 在编辑器中直接渲染 CEGUI 结果，而非仅显示纹理缩略图。  
2. 支持“打包 -> 生成 `.imageset` -> 立即预览”闭环。  
3. 保持与 MT3 现有 CEGUI 0.7.1 运行时一致性。  
4. 在 VS2013 v120 下稳定编译与运行。

### 11.2 启动与初始化时序

```
TPCEGUIApp::OnInit
  -> RuntimeDependencyChecker::Verify()
  -> MainFrame::Create()
  -> PreviewCanvas::InitGLContext()
  -> CEGUIRenderHost::Initialize()
      -> OpenGLRenderer::create()
      -> System::create()
      -> DefaultResourceProvider::setResourceGroupDirectory(...)
      -> SchemeManager::create(...)
      -> createRootWindow + preview windows
  -> AtlasBuildPlanner::LoadConfig()
```

### 11.3 渲染管线设计（真实预览）

#### 11.3.1 渲染宿主

- 使用 `wxGLCanvas + wxGLContext` 作为 OpenGL 容器。
- 每次 `OnPaint/OnIdle` 执行：
  1. `SetCurrent(context)`
  2. `glClear(...)`
  3. `CEGUI::System::getSingleton().renderGUI()`
  4. `SwapBuffers()`

#### 11.3.2 输入注入

- 鼠标移动：`injectMousePosition(x, y)`
- 左右键：`injectMouseButtonDown/Up(...)`
- 滚轮：映射缩放操作并更新预览场景
- 键盘：预留 `injectKeyDown/Up`（后续扩展快捷键）

#### 11.3.3 预览场景层级

| 层级 | 内容 | 说明 |
|------|------|------|
| Layer-0 | 背景网格/透明棋盘 | 观察 alpha 与边界 |
| Layer-1 | Atlas StaticImage | 显示完整图集纹理 |
| Layer-2 | Region Overlay | 区域框、名称、选中态 |
| Layer-3 | Widget Preview | 用 looknfeel 真实绘制控件 |

### 11.4 打包集成设计

#### 11.4.1 TexturePacker 调用

- 通过 `CreateProcessW` 启动外部进程。
- 采集 stdout/stderr，写入 GUI 日志面板。
- 支持 `取消构建`（终止子进程）。

#### 11.4.2 结果回流

1. 打包完成后读取帧元数据。  
2. 执行 `FrameNormalizer`。  
3. 生成 `.imageset`。  
4. 触发 `PreviewScene::ReloadImageset()` 热加载刷新。  
5. 执行校验并出具 `BuildReport`。

### 11.5 线程模型

| 线程 | 职责 |
|------|------|
| UI 主线程 | 渲染、交互、状态展示 |
| BuildWorker 后台线程 | 调用 TexturePacker、解析元数据、写文件 |
| 日志分发队列 | 后台消息安全投递到 UI |

约束：

1. CEGUI 与 OpenGL 对象仅允许在 UI 线程访问。  
2. 后台线程禁止直接操作 `CEGUI::Window`。  
3. 使用消息队列/事件机制回传构建状态。

### 11.6 错误处理与回滚

1. 启动前依赖检查失败：阻断启动，提示缺失项。  
2. 打包失败：保留日志，标记任务失败。  
3. `.imageset` 写入失败：触发回滚并保留异常详情。  
4. 预览加载失败：不影响文件产物，但标记“预览失败”状态。

### 11.7 性能目标

| 指标 | 目标 |
|------|------|
| 预览空闲帧率 | >= 60 FPS（常规编辑场景） |
| 鼠标操作响应 | < 16ms |
| 单图集构建耗时 | 与 CLI 基线差异 < 5% |
| GUI 内存占用（空载） | < 300 MB |

### 11.8 与现有工具复用点

可复用 `tools/CEImagesetEditor-0.7.1` 与 `tools/CELayoutEditor-bulid` 的成熟实践：

1. `OpenGLRenderer::create()` + `System::create()` 初始化顺序。  
2. `DefaultResourceProvider` + `setResourceGroupDirectory` 资源路径模型。  
3. `wxGLCanvas` 事件到 CEGUI 输入注入方式。  
4. 启动时 DLL/数据文件完整性校验机制。  
5. 异常安全销毁顺序（System/Renderer/自定义工厂）。

### 11.9 free-tex-packer 参考实现到方案 C 的代码映射

| 参考实现（free-tex-packer） | 关键逻辑 | 方案 C 对应实现 |
|------|------|------|
| `src/client/PackProcessor.js` | 打包主流程、多策略优选、同图复用 | `AtlasBuildPlanner + PackerStrategy + IdenticalDetector` |
| `src/client/utils/Trimmer.js` | alpha 阈值裁剪 | `TrimAnalyzer` |
| `src/client/utils/TextureRenderer.js` | fixedSize/pot/scale/extrude 逻辑 | `PreviewTextureComposer` |
| `src/client/exporters/index.js` | 模板渲染导出（mustache） | `TemplateExporter`（受控变量） |
| `src/client/ui/PackProperties.jsx` | 参数中心化/默认值 | `PackOptionsPanel + PackOptionsDefaults` |
| `src/client/platform/electron/Project.js` | 工程保存与最近项目 | `ProjectStore + RecentProjectService` |
| `src/client/Observer.js` | 事件总线 | `ToolEventBus` |
| `src/client/ui/SheetSplitter.jsx` | 图集逆向拆分调试 | `AtlasSplitterDialog`（V2） |

### 11.10 参数配置档与兼容策略

定义三档参数配置，避免高级选项破坏 CEGUI 兼容性：

| Profile | 目标 | 关键参数 |
|------|------|------|
| `cegui-safe` | 生产默认 | `allowRotation=false`, `allowTrim=false`, `detectIdentical=true`, `powerOfTwo=false` |
| `cegui-balanced` | 内部优化 | `allowTrim=true`, `trimMode=trim`, `alphaThreshold=0`, `allowRotation=false` |
| `research` | 实验对比 | 可开启 `allowRotation/auto strategy`，但禁止直接发布 |

规则：

1. GUI 默认只能选择 `cegui-safe`，其余 profile 需显式解锁。  
2. 当开启 `allowRotation=true` 时，导出阶段必须给出兼容性警告。  
3. 发布前校验强制检查 `profile == cegui-safe`。

### 11.11 事件驱动执行总线（参考 Observer）

为降低 UI 与构建器耦合，引入统一事件总线：

```text
EVT_IMAGES_CHANGED
EVT_OPTIONS_CHANGED
EVT_START_BUILD
EVT_BUILD_PROGRESS
EVT_BUILD_COMPLETE
EVT_BUILD_FAILED
EVT_PREVIEW_RELOAD
EVT_PROJECT_DIRTY_CHANGED
```

实现约束：

1. UI 线程只发布命令，不直接持有构建器内部状态。  
2. 构建线程仅通过事件回推进度，不直接操作 UI 控件。  
3. 事件负载统一使用 `BuildEventPayload`，便于日志落盘与回放。

### 11.12 工程文件与模板导出的落地格式

工程文件 `*.tpcgproj`（JSON）建议结构：

```json
{
  "meta": { "version": "1.0.0" },
  "profile": "cegui-safe",
  "packOptions": { "width": 2048, "height": 2048, "padding": 2, "detectIdentical": true },
  "atlases": [{ "name": "common_pack", "sourceDir": "art/ui/common_pack" }],
  "recentOutputRoot": "client/resource/res/ui/imagesets"
}
```

模板导出建议：

1. V1 只启用内置 `CEGUI.imageset.mustache`。  
2. V2 允许自定义模板，但变量白名单固定为：`rects/config/appInfo`。  
3. 模板编译失败时，回退到内置模板并阻断写入。

---

## 12. 方案 C 构建与依赖矩阵

### 12.1 编译配置（建议）

```yaml
IDE: Visual Studio 2013
PlatformToolset: v120
Platform: Win32
CharacterSet: Unicode
RuntimeLibrary:
  Debug: /MDd
  Release: /MD
WarningLevel: /W3
PrecompiledHeader: Use (pch.h)
```

### 12.2 包含目录（参考现有编辑器）

```text
..\inc
..\..\CEGUI-0.7.1\cegui\include
..\..\..\dependencies\wxWidgets-3.0.5\include
..\..\..\dependencies\wxWidgets-3.0.5\lib\vc_lib\mswu
..\..\..\common\platform
```

### 12.3 链接库（参考现有编辑器）

核心 CEGUI：

- `CEGUIBase(_d).lib`
- `CEGUIOpenGLRenderer(_d).lib`
- `CEGUIExpatParser(_d).lib`
- `CEGUIFalagardWRBase(_d).lib`
- `CEGUISILLYImageCodec(_d).lib`

wxWidgets：

- `wxbase30u(d).lib`
- `wxbase30u(d)_xml.lib`
- `wxmsw30u(d)_core.lib`
- `wxmsw30u(d)_gl.lib`
- `wxmsw30u(d)_adv.lib`
- `wxpng(d).lib`
- `wxjpeg(d).lib`
- `wxtiff(d).lib`
- `wxzlib(d).lib`
- `wxregexu(d).lib`
- `wxexpat(d).lib`

系统库：

- `opengl32.lib`
- `glu32.lib`
- `winmm.lib`
- `comctl32.lib`
- `rpcrt4.lib`
- `wsock32.lib`
- `oleacc.lib`
- `odbc32.lib`

### 12.4 运行时打包检查清单

1. 可执行文件同目录必须包含 CEGUI 与 SILLY 依赖 DLL。  
2. `data/` 目录中的 scheme/looknfeel/imageset/xsd 必须齐全。  
3. 内置图集打包模块（shelf packer）必须完成初始化。  
4. 启动时必须先执行依赖自检，失败即阻断运行。

### 12.5 交付物定义

| 交付物 | 内容 |
|--------|------|
| `TexturePacker_CEGUI.exe` | 主程序 |
| `CEGUI*.dll` + `SILLY*.dll` | 运行时依赖 |
| `data/` | GUI 渲染资源与 schema |
| `scripts/smoke-test.ps1` | 冒烟测试脚本（UI + 内置打包） |
| `workspace/smoke-out/*` | 冒烟产物样例（png/tp.xml/imageset） |

---

## 附录

### A. 命名规范建议

| 对象 | 规范 |
|------|------|
| 图集文件 | 单页：`<atlas>.png + <atlas>.imageset`；多页：`<atlas>_<n>.png + <atlas>_<n>.imageset` |
| 图集名 | 小写字母/数字/下划线，避免空格与中文 |
| 切片名 | 语义化命名，如 `common_bg2_lt`、`button_ok_normal` |

### B. 交付检查清单

- [ ] `.imageset` XML 可解析  
- [ ] `Imagefile` 文件存在  
- [ ] `Image Name` 无重复  
- [ ] 关键 `scheme/looknfeel` 引用可加载  
- [ ] 编码为 UTF-8 无 BOM  

---

**维护者**: 技术委员会 / 客户端工具链  
**下次审查**: 2026-04-02
