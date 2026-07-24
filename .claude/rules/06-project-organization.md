# MT3 项目脚本和文档管理规范

**版本**: 1.0
**生效日期**: 2026-01-05
**适用范围**: MT3 项目所有目录

---

## 📋 总则

### 核心原则

1. **根目录整洁**: 根目录只保留 README.md, AGENTS.md, codex.md 三个文档
2. **脚本集中管理**: 所有脚本统一存放在 `scripts/` 目录
3. **文档集中管理**: 所有文档统一存放在 `docs/` 目录
4. **子目录同规则**: 每个子目录也遵守相同的规则

---

## 🗂️ 目录结构规范

### 项目根目录

```
MT3/
├── README.md                    # ✅ 项目主文档
├── AGENTS.md                    # ✅ AI 助手配置
├── codex.md                     # ✅ 项目知识库
├── scripts/                     # ✅ 统一脚本管理目录
│   ├── build/                   # 编译相关脚本
│   ├── deploy/                  # 部署相关脚本
│   ├── dev/                     # 开发辅助脚本
│   ├── ci/                      # CI/CD 脚本
│   ├── temp/                    # 临时脚本（定期清理）
│   └── README.md                # 脚本目录说明
├── docs/                        # ✅ 统一文档管理目录
├── client/                      # 客户端代码
├── server/                      # 服务端代码
├── tools/                       # 开发工具
├── dependencies/                # 依赖库
└── ...
```

**禁止**:
- ❌ 根目录直接放置 .ps1, .bat, .sh, .cmd 脚本
- ❌ 根目录直接放置除 README.md, AGENTS.md, codex.md 外的 .md, .txt 文档
- ❌ 根目录放置临时文件

---

## 🔧 scripts/ 目录结构

### 分类规范

```
scripts/
├── README.md                    # 脚本目录说明文档
├── build/                       # 编译脚本
│   ├── README.md
│   ├── build_mt3_v120_complete.bat
│   ├── Build-MT3-v120.ps1
│   ├── clean_build.bat
│   └── copy_runtime_dlls.bat
├── check/                       # 检查脚本
│   ├── README.md
│   ├── check_build_tools.bat
│   ├── check_env.bat
│   └── verify_android_sdk.bat
├── deploy/                      # 部署脚本
│   ├── README.md
│   └── CopyVersion.bat
├── dev/                         # 开发辅助脚本
│   └── README.md
├── ci/                          # CI/CD 脚本
│   └── README.md
├── temp/                        # 临时脚本（每月清理）
│   └── .gitignore
└── archived/                    # 归档脚本
    └── README.md
```

### 分类标准

| 目录 | 用途 | 示例 |
|------|------|------|
| `build/` | 编译、构建相关 | build_*.bat, Build-*.ps1 |
| `check/` | 环境检查、验证 | check_*.bat, verify_*.bat |
| `deploy/` | 部署、发布、版本管理 | deploy*.bat, CopyVersion.bat |
| `dev/` | 开发辅助工具 | format_code.sh, generate_docs.py |
| `ci/` | CI/CD 流程 | jenkins.sh, github-actions.yml |
| `temp/` | 临时脚本（定期清理） | temp_*.*, test_*.* |
| `archived/` | 归档的旧脚本 | old_build_*.bat |

---

## 📚 docs/ 目录规范

### 根目录文档规范

**允许保留在根目录**:
- ✅ `README.md` - 项目主文档
- ✅ `AGENTS.md` - AI 助手配置
- ✅ `codex.md` - 项目知识库

**必须移到 docs/**:
- ❌ 所有其他 .md 文档
- ❌ 所有 .txt 文档（除非是配置文件）
- ❌ 所有 PDF, DOC 等文档

### docs/ 内部结构

```
docs/
├── README.md                    # 文档目录说明
├── INDEX.md                     # 文档索引
├── QUICK_REFERENCE.md           # 快速参考
├── 01-快速启动指南-Quick-Start-Guide.md
├── 02-项目概述-Project-Overview.md
├── ...
├── 2026-01-05-文档审计报告-Document-Audit-Report.md
├── android/                     # Android 相关文档
├── windows/                     # Windows 相关文档
├── workflows/                   # 工作流文档
├── research/                    # 研究和分析文档
└── archive/                     # 归档文档
```

---

## 🔄 子目录管理规范

### 通用规则

每个子目录（client/, server/, tools/ 等）都遵守以下规则：

#### 1. 文档管理

```
client/
├── README.md                    # ✅ 子目录主文档
├── docs/                        # ✅ 子目录文档集中管理
│   ├── README.md
│   ├── 01-架构说明-Architecture.md
│   ├── 02-开发指南-Development-Guide.md
│   └── ...
├── src/                         # 源代码
├── tests/                       # 测试
└── ...
```

**禁止**:
- ❌ 子目录根部放置除 README.md 外的其他文档
- ❌ 文档散落在各个子目录

#### 2. 脚本管理

```
client/
├── scripts/                     # ✅ 子目录脚本集中管理
│   ├── README.md
│   ├── build/
│   ├── test/
│   └── ...
├── docs/
└── ...
```

**禁止**:
- ❌ 子目录根部直接放置脚本
- ❌ 脚本散落在各个子目录

#### 3. 特殊情况

**允许例外** (项目标准配置文件):
- ✅ `.gitignore`
- ✅ `package.json`, `pom.xml`, `build.gradle`
- ✅ `.editorconfig`, `.prettierrc`
- ✅ `CMakeLists.txt`, `Makefile`

---

## 🧹 临时文件管理

### temp/ 目录规范

**用途**: 存放临时脚本、测试脚本、一次性脚本

**清理策略**:
- 🔴 **每月清理**: 删除超过 30 天的文件
- 🟡 **每周检查**: 检查是否有可归档的脚本
- 🟢 **即时清理**: 任务完成后立即删除临时脚本

**命名规范**:
```
temp/
├── temp_YYYYMMDD_description.bat      # 临时脚本（带日期）
├── test_feature_name.ps1               # 测试脚本
└── experiment_YYYYMMDD.sh              # 实验脚本
```

**强制规则**:
- ✅ 必须包含 `temp_`, `test_`, `experiment_` 前缀
- ✅ 必须包含日期或明确用途
- ✅ 必须在 temp/ 目录，不得在其他位置

---

## 📋 整理执行计划

### Phase 1: 创建目录结构

```bash
# 创建 scripts 子目录
mkdir -p scripts/{build,check,deploy,dev,ci,temp,archived}

# 创建 scripts 子目录 README
touch scripts/README.md
touch scripts/build/README.md
touch scripts/check/README.md
touch scripts/deploy/README.md
```

### Phase 2: 移动脚本文件

#### 编译脚本 → scripts/build/
```bash
mv build_mt3_v120_complete.bat scripts/build/
mv Build-MT3-v120.ps1 scripts/build/
mv clean_build.bat scripts/build/
mv copy_runtime_dlls.bat scripts/build/
```

#### 检查脚本 → scripts/check/
```bash
mv check_build_tools.bat scripts/check/
mv check_env.bat scripts/check/
mv verify_android_sdk.bat scripts/check/
```

#### 部署脚本 → scripts/deploy/
```bash
mv CopyVersion.bat scripts/deploy/
```

#### 临时脚本 → scripts/temp/ (或删除)
```bash
# temp_script.ps1 - 临时脚本，删除
rm temp_script.ps1
```

### Phase 3: 移动文档文件

#### 文档 → docs/
```bash
# README-BUILD-SCRIPTS.md → docs/
mv README-BUILD-SCRIPTS.md docs/

# ANALYSIS_DOCUMENTS_MANIFEST.txt → docs/
mv ANALYSIS_DOCUMENTS_MANIFEST.txt docs/

# test.txt → 删除（临时文件）
rm test.txt

# 出正式包流程1.0.txt → docs/workflows/
mv 出正式包流程1.0.txt docs/workflows/正式包发布流程-Release-Package-Workflow.txt
```

### Phase 4: 创建 README 文档

为每个 scripts 子目录创建 README.md 说明文档。

---

## 📝 scripts/README.md 模板

```markdown
# MT3 项目脚本目录

**目录**: scripts/
**用途**: 统一管理项目所有脚本
**维护**: MT3 开发团队

---

## 📂 目录结构

| 目录 | 用途 | 说明 |
|------|------|------|
| `build/` | 编译脚本 | 项目编译、构建相关脚本 |
| `check/` | 检查脚本 | 环境检查、依赖验证脚本 |
| `deploy/` | 部署脚本 | 部署、发布、版本管理脚本 |
| `dev/` | 开发辅助 | 开发工具、代码生成脚本 |
| `ci/` | CI/CD | 持续集成/部署脚本 |
| `temp/` | 临时脚本 | 临时、测试脚本（定期清理） |
| `archived/` | 归档脚本 | 旧版本、已废弃脚本 |

---

## 🚀 常用脚本

### 编译相关
- `build/build_mt3_v120_complete.bat` - 完整编译（VS2013）
- `build/Build-MT3-v120.ps1` - PowerShell 编译脚本
- `build/clean_build.bat` - 清理编译产物

### 检查相关
- `check/check_build_tools.bat` - 检查编译工具
- `check/check_env.bat` - 检查环境变量
- `check/verify_android_sdk.bat` - 验证 Android SDK

### 部署相关
- `deploy/CopyVersion.bat` - 复制版本信息

---

## 📋 使用规范

### 脚本命名规范
- 功能描述清晰
- 使用小写字母和下划线
- 包含平台标识（如需要）

### 脚本分类规则
1. **build/**: 所有编译、构建相关
2. **check/**: 所有检查、验证相关
3. **deploy/**: 所有部署、发布相关
4. **dev/**: 开发辅助工具
5. **ci/**: CI/CD 专用脚本
6. **temp/**: 临时脚本（30天自动清理）

### 临时脚本规范
- 必须放在 `temp/` 目录
- 命名包含日期: `temp_20260105_xxx.bat`
- 完成后及时删除

---

## 🔄 维护策略

- **每周**: 检查 temp/ 目录，清理已完成任务的脚本
- **每月**: 清理超过 30 天的 temp/ 脚本
- **每季度**: 审查脚本有效性，归档废弃脚本

---

**最后更新**: 2026-01-05
**维护者**: MT3 开发团队
```

---

## 🔍 检查清单

### 根目录检查

```bash
# 检查根目录是否只有允许的文档
ls | grep -E "\.md$" | grep -v "README.md" | grep -v "AGENTS.md" | grep -v "codex.md"
# 期望结果: 无输出

# 检查根目录是否有脚本文件
ls | grep -E "\.(ps1|bat|sh|cmd)$"
# 期望结果: 无输出

# 检查根目录是否有临时文件
ls | grep -E "(temp|test|tmp)"
# 期望结果: 无输出
```

### scripts/ 目录检查

```bash
# 检查 scripts/ 子目录结构
ls -d scripts/*/
# 期望结果: build, check, deploy, dev, ci, temp, archived

# 检查每个子目录是否有 README.md
find scripts/ -mindepth 1 -maxdepth 1 -type d -exec test ! -f {}/README.md \; -print
# 期望结果: 无输出（所有子目录都有 README.md）
```

### docs/ 目录检查

```bash
# 检查 docs/ 是否包含所有文档
find docs/ -name "*.md" | wc -l
# 期望结果: 应该包含所有文档

# 检查根目录是否只有允许的文档
find . -maxdepth 1 -name "*.md" | wc -l
# 期望结果: 3 (README.md, AGENTS.md, codex.md)
```

---

## 🎯 执行步骤

### 步骤 1: 创建目录结构
```bash
mkdir -p scripts/{build,check,deploy,dev,ci,temp,archived}
```

### 步骤 2: 移动脚本文件
```bash
# 编译脚本
mv build_mt3_v120_complete.bat scripts/build/
mv Build-MT3-v120.ps1 scripts/build/
mv clean_build.bat scripts/build/
mv copy_runtime_dlls.bat scripts/build/

# 检查脚本
mv check_build_tools.bat scripts/check/
mv check_env.bat scripts/check/
mv verify_android_sdk.bat scripts/check/

# 部署脚本
mv CopyVersion.bat scripts/deploy/

# 临时脚本（删除）
rm temp_script.ps1
```

### 步骤 3: 移动文档文件
```bash
# 移动到 docs/
mv README-BUILD-SCRIPTS.md docs/
mv ANALYSIS_DOCUMENTS_MANIFEST.txt docs/

# 移动到 docs/workflows/
mv 出正式包流程1.0.txt docs/workflows/正式包发布流程-Release-Package-Workflow.txt

# 删除临时文件
rm test.txt
```

### 步骤 4: 创建 README 文档
```bash
# 为每个 scripts 子目录创建 README.md
touch scripts/README.md
touch scripts/build/README.md
touch scripts/check/README.md
touch scripts/deploy/README.md
touch scripts/dev/README.md
touch scripts/ci/README.md
touch scripts/temp/.gitignore
touch scripts/archived/README.md
```

### 步骤 5: 更新 .gitignore
```bash
# 在 scripts/temp/.gitignore 中添加
echo "*" > scripts/temp/.gitignore
echo "!.gitignore" >> scripts/temp/.gitignore
echo "!README.md" >> scripts/temp/.gitignore
```

---

## 📊 预期结果

### 根目录文件（整理后）

```
MT3/
├── README.md                    # ✅ 保留
├── AGENTS.md                    # ✅ 保留
├── codex.md                     # ✅ 保留
├── scripts/                     # ✅ 新建（脚本管理）
├── docs/                        # ✅ 已存在（文档管理）
├── client/
├── server/
├── tools/
└── ...
```

**根目录 .md 文件**: 3 个（仅 README.md, AGENTS.md, codex.md）
**根目录脚本文件**: 0 个（全部移至 scripts/）
**根目录临时文件**: 0 个（已清理）

---

## ✅ 验证命令

```bash
# 验证根目录只有允许的文档
echo "根目录 .md 文件:"
find . -maxdepth 1 -name "*.md" | wc -l
# 期望: 3

# 验证根目录没有脚本
echo "根目录脚本文件:"
find . -maxdepth 1 \( -name "*.ps1" -o -name "*.bat" -o -name "*.sh" -o -name "*.cmd" \) | wc -l
# 期望: 0

# 验证 scripts/ 目录结构
echo "scripts/ 子目录:"
ls -d scripts/*/
# 期望: build, check, deploy, dev, ci, temp, archived

# 验证 scripts/ 中的文件数量
echo "scripts/ 中的脚本数量:"
find scripts/ -type f \( -name "*.ps1" -o -name "*.bat" -o -name "*.sh" -o -name "*.cmd" \) | wc -l
# 期望: 8 (原有脚本数量)
```

---

**规范版本**: 1.0
**最后更新**: 2026-01-05
**维护者**: MT3 开发团队
**状态**: ✅ 待执行
