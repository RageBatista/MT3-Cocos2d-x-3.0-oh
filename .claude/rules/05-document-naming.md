# MT3 项目文档命名规范

**版本**: 1.0
**生效日期**: 2026-01-05
**适用范围**: MT3 项目所有文档

---

## 📋 命名规范总则

### 规则 1: 技术文档命名规范

**格式**: `编号-中文标题-English-Title.md`

**编号规则**:
- 2位数字编号 (01-99)
- 按照逻辑顺序排列
- 同类文档编号连续

**示例**:
```
✅ 01-快速启动指南-Quick-Start-Guide.md
✅ 02-项目概述-Project-Overview.md
✅ 03-技术体系总结-Technology-Stack-Summary.md
✅ 11-关键技术文档-Key-Technical-Documents.md
```

**错误示例**:
```
❌ quick-start.md (缺少编号和中文)
❌ 01-快速启动指南.md (缺少英文标题)
❌ Quick-Start-Guide.md (缺少编号和中文)
❌ 1-快速启动指南-Quick-Start-Guide.md (编号应为两位数)
```

---

### 规则 2: 分析报告命名规范

**格式**: `日期-中文标题-English-Title.md`

**日期格式**:
- YYYY-MM-DD (例如: 2026-01-05)
- 使用报告生成/完成日期

**示例**:
```
✅ 2026-01-05-文档审计报告-Document-Audit-Report.md
✅ 2026-01-05-CEGUI分析与优化报告-CEGUI-Analysis-And-Optimization-Report.md
✅ 2025-12-30-图像编辑器分析报告-Image-Editor-Analysis-Report.md
```

**错误示例**:
```
❌ DOCUMENT_AUDIT_REPORT.md (缺少日期和中文)
❌ 文档审计报告.md (缺少日期和英文)
❌ 2026-01-05-Document-Audit-Report.md (缺少中文)
❌ DOCUMENT_AUDIT_REPORT_2026-01-05.md (日期应在前面)
```

---

### 规则 3: 特殊文档命名规范

#### 3.1 索引文档
**格式**: `编号-文档索引-Documentation-Index.md` 或 `INDEX.md`

**示例**:
```
✅ 13-文档索引-Documentation-Index.md
✅ INDEX.md (根目录索引)
✅ 00-文档索引-Documentation-Index.md (子目录索引)
```

#### 3.2 快速参考文档
**格式**: `编号-快速参考-Quick-Reference.md` 或 `QUICK_REFERENCE.md`

**示例**:
```
✅ QUICK_REFERENCE.md (根目录)
✅ 编辑器快速参考-Editor-Quick-Reference.md (子目录)
```

#### 3.3 README 文档
**格式**: `README.md` 或 `README-特定主题.md`

**示例**:
```
✅ README.md
✅ README-BUILD-SCRIPTS.md
```

#### 3.4 CHANGELOG 文档
**格式**: `日期-变更日志-Changelog.md` 或 `CHANGELOG.md`

**示例**:
```
✅ CHANGELOG.md (项目总变更日志)
✅ 2026-01-05-文档更新日志-Document-Changelog.md (特定主题变更日志)
```

---

## 📁 目录结构规范

### docs/ 根目录

**技术文档**: 使用 `编号-中文-English.md` 格式
```
docs/
├── 01-快速启动指南-Quick-Start-Guide.md
├── 02-项目概述-Project-Overview.md
├── 03-技术体系总结-Technology-Stack-Summary.md
├── ...
├── 13-文档索引-Documentation-Index.md
└── 21-BinLayoutStudio优化与拓展方案-BinLayoutStudio-Enhancement-Roadmap.md
```

**分析报告**: 使用 `日期-中文-English.md` 格式
```
docs/
├── 2026-01-05-文档审计报告-Document-Audit-Report.md
├── 2026-01-05-文档整理完成报告-Document-Cleanup-Completion-Report.md
├── 2026-01-05-文档整理最终报告-Document-Cleanup-Final-Report.md
├── 2026-01-05-文档更新日志-Document-Changelog.md
└── 2026-01-05-工作流重复分析-Workflows-Duplication-Analysis.md
```

**特殊文档**:
```
docs/
├── INDEX.md
├── QUICK_REFERENCE.md
└── CHANGELOG.md (可选)
```

---

### 子目录文档规范

#### docs/android/
```
docs/android/
├── 00-文档索引-Documentation-Index.md (可选)
├── 01-快速开始-Quick-Start.md
├── 02-SDK配置-SDK-Configuration.md
├── 03-环境配置指南-Environment-Setup-Guide.md
└── ...
```

#### docs/workflows/
```
docs/workflows/
├── 00-编译步骤工作计划-Build-Steps-Workflow.md
├── 01-知识沉淀流程-Knowledge-Capture-Workflow.md
├── MT3编译快速指南-MT3-Build-Quick-Guide.md
└── ...
```

#### docs/research/
```
docs/research/
├── README.md (说明 research 目录用途)
├── 2025-12-28-SpriteEditor构建审计-SpriteEditor-Build-Audit/
│   └── report.md
└── ...
```

#### docs/archive/
```
docs/archive/
├── README.md (说明归档策略)
├── 旧版文档/
└── 中间版本/
```

---

### tools/ 子目录文档规范

#### tools/CEGUI-0.7.9-r5/docs/
```
tools/CEGUI-0.7.9-r5/docs/
├── 00-文档索引-Documentation-Index.md
├── 01-CEGUI编译构建流程-CEGUI-Build-Workflow.md
├── 02-环境准备-Environment-Setup.md
├── 03-依赖清单-Dependency-Inventory.md
├── ...
├── 11-VS2013 v120适配清单-VS2013-v120-Adaptation.md
└── README.md
```

**分析报告** (在工具根目录):
```
tools/CEGUI-0.7.9-r5/
├── 2026-01-05-CEGUI分析与优化报告-CEGUI-Analysis-And-Optimization-Report.md
└── docs/
```

---

## 🔄 重命名执行清单

### 已执行的重命名

#### docs/ 目录
- ✅ `DOCUMENT_AUDIT_REPORT_2026-01-05.md` → `2026-01-05-文档审计报告-Document-Audit-Report.md`
- ✅ `DOCUMENT_CHANGELOG.md` → `2026-01-05-文档更新日志-Document-Changelog.md`
- ✅ `DOCUMENT_CLEANUP_COMPLETION_REPORT.md` → `2026-01-05-文档整理完成报告-Document-Cleanup-Completion-Report.md`
- ✅ `DOCUMENT_CLEANUP_FINAL_REPORT.md` → `2026-01-05-文档整理最终报告-Document-Cleanup-Final-Report.md`
- ✅ `WORKFLOWS_DUPLICATION_ANALYSIS.md` → `2026-01-05-工作流重复分析-Workflows-Duplication-Analysis.md`

#### tools/CEGUI-0.7.9-r5/
- ✅ `CEGUI_ANALYSIS_AND_OPTIMIZATION_REPORT.md` → `2026-01-05-CEGUI分析与优化报告-CEGUI-Analysis-And-Optimization-Report.md`

### 待执行的重命名

#### 根目录 → docs/research/ 或 docs/analysis/

**图像编辑器分析** (创建日期: 2025-12-30):
```bash
# 移动到 docs/research/image-editor/
mv "IMAGE_EDITOR_ANALYSIS_COMPLETE.md" \
   "docs/research/image-editor/2025-12-30-图像编辑器分析完成-Image-Editor-Analysis-Complete.md"

mv "IMAGE_EDITOR_CODE_STRUCTURE_ANALYSIS.md" \
   "docs/research/image-editor/2025-12-30-图像编辑器代码结构分析-Image-Editor-Code-Structure-Analysis.md"

mv "IMAGE_EDITOR_ARCHITECTURE_DIAGRAMS.md" \
   "docs/research/image-editor/2025-12-30-图像编辑器架构图-Image-Editor-Architecture-Diagrams.md"

mv "IMAGE_EDITOR_DOCUMENTATION_INDEX.md" \
   "docs/research/image-editor/2025-12-30-图像编辑器文档索引-Image-Editor-Documentation-Index.md"

mv "IMAGE_EDITOR_QUICK_REFERENCE.md" \
   "docs/research/image-editor/图像编辑器快速参考-Image-Editor-Quick-Reference.md"

mv "README_IMAGE_EDITOR_ANALYSIS.md" \
   "docs/research/image-editor/README.md"
```

**效果编辑器分析** (需要确认日期):
```bash
# 移动到 docs/research/effect-editor/
mv "EffectEditor_Architecture_Analysis.md" \
   "docs/research/effect-editor/2025-XX-XX-效果编辑器架构分析-Effect-Editor-Architecture-Analysis.md"

mv "EffectEditor_Quick_Reference.md" \
   "docs/research/effect-editor/效果编辑器快速参考-Effect-Editor-Quick-Reference.md"
```

**精灵编辑器分析** (需要确认日期):
```bash
# 移动到 docs/research/sprite-editor/
mv "SpriteEditor_Architecture_Analysis.md" \
   "docs/research/sprite-editor/2025-XX-XX-精灵编辑器架构分析-Sprite-Editor-Architecture-Analysis.md"

mv "SpriteEditor_Complete_Workflow_Analysis.md" \
   "docs/research/sprite-editor/2025-XX-XX-精灵编辑器完整工作流分析-Sprite-Editor-Complete-Workflow-Analysis.md"

mv "SpriteEditor_Dialogs_and_Helpers_Analysis.md" \
   "docs/research/sprite-editor/2025-XX-XX-精灵编辑器对话框和辅助类分析-Sprite-Editor-Dialogs-And-Helpers-Analysis.md"
```

**其他文档**:
```bash
# README-BUILD-SCRIPTS.md 保持不变 (符合规范)
# codex.md 需要确认用途后决定
```

---

## 🔍 命名规范检查清单

### 技术文档检查
- [ ] 是否有 2 位数字编号？
- [ ] 是否包含中文标题？
- [ ] 是否包含英文标题？
- [ ] 中英文之间是否用 `-` 分隔？
- [ ] 文件扩展名是否为 `.md`？

### 分析报告检查
- [ ] 是否以日期开头 (YYYY-MM-DD)？
- [ ] 是否包含中文标题？
- [ ] 是否包含英文标题？
- [ ] 日期、中英文之间是否用 `-` 分隔？
- [ ] 文件扩展名是否为 `.md`？

### 目录组织检查
- [ ] 技术文档是否在正确的 docs/ 子目录？
- [ ] 分析报告是否在 docs/ 或 docs/research/？
- [ ] 临时/过时文档是否已归档到 docs/archive/？
- [ ] 每个子目录是否有 README.md 说明？

---

## 📝 自动化脚本

### PowerShell 重命名脚本模板

```powershell
# 批量重命名技术文档
function Rename-TechnicalDoc {
    param(
        [string]$OldName,
        [string]$Number,
        [string]$ChineseTitle,
        [string]$EnglishTitle
    )

    $NewName = "$Number-$ChineseTitle-$EnglishTitle.md"
    Rename-Item $OldName $NewName
    Write-Host "✅ Renamed: $OldName → $NewName"
}

# 批量重命名分析报告
function Rename-AnalysisReport {
    param(
        [string]$OldName,
        [string]$Date,
        [string]$ChineseTitle,
        [string]$EnglishTitle
    )

    $NewName = "$Date-$ChineseTitle-$EnglishTitle.md"
    Rename-Item $OldName $NewName
    Write-Host "✅ Renamed: $OldName → $NewName"
}
```

### Bash 重命名脚本模板

```bash
#!/bin/bash
# 批量重命名技术文档
rename_technical_doc() {
    local old_name="$1"
    local number="$2"
    local chinese_title="$3"
    local english_title="$4"

    local new_name="${number}-${chinese_title}-${english_title}.md"
    mv "$old_name" "$new_name"
    echo "✅ Renamed: $old_name → $new_name"
}

# 批量重命名分析报告
rename_analysis_report() {
    local old_name="$1"
    local date="$2"
    local chinese_title="$3"
    local english_title="$4"

    local new_name="${date}-${chinese_title}-${english_title}.md"
    mv "$old_name" "$new_name"
    echo "✅ Renamed: $old_name → $new_name"
}
```

---

## ✅ 执行验证

### 验证命令

```bash
# 检查 docs/ 目录技术文档命名
find docs/ -maxdepth 1 -name "*.md" | grep -E "^docs/[0-9]{2}-.*-.*\.md$"

# 检查 docs/ 目录分析报告命名
find docs/ -maxdepth 1 -name "*.md" | grep -E "^docs/[0-9]{4}-[0-9]{2}-[0-9]{2}-.*-.*\.md$"

# 检查不符合规范的文件
find docs/ -maxdepth 1 -name "*.md" | grep -vE "(^docs/[0-9]{2}-.*-.*\.md$|^docs/[0-9]{4}-[0-9]{2}-[0-9]{2}-.*-.*\.md$|^docs/(INDEX|README|QUICK_REFERENCE|CHANGELOG).*\.md$)"
```

---

**规范版本**: 1.0
**最后更新**: 2026-01-05
**维护者**: MT3 开发团队
**状态**: ✅ 生效中
