# xclear - mkdb 数据库清理工具

## 1. 工具概述

### 1.1 用途说明
xclear 是一个 mkdb 数据库清理工具,用于清理、重置或初始化 mkdb 数据库目录结构。

**核心功能**:
- **数据库清理**: 清理 mkdb 数据库文件和日志
- **结构重置**: 重置数据库目录结构
- **配置验证**: 验证 gsx.mkdb.xml 配置文件
- **批处理执行**: 通过 run.bat 自动执行清理流程

**解决的问题**:
- 开发测试环境需要清理数据库
- 数据库损坏需要重建
- 版本升级前清理旧数据
- 初始化新环境的数据库结构

**典型使用场景**:
- 开发环境数据库重置
- 测试环境初始化
- 数据库迁移前清理
- 解决数据库损坏问题

### 1.2 关键特性
- **安全清理**: 按照 mkdb 规范清理数据
- **配置驱动**: 基于 gsx.mkdb.xml 配置
- **批处理自动化**: 通过 run.bat 一键执行
- **版本兼容**: 与当前数据库版本对应

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色
xclear 位于 MT3 **数据库维护工具层**:

```
┌─────────────────────────────────────────────────────────────┐
│         游戏服务器（Game Server Layer）                      │
│  使用 mkdb 数据库存储游戏数据                                │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────────┐
│              mkdb 数据库目录                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   数据库文件结构                                     │   │
│  │   - table/ (表数据)                                 │   │
│  │   - log/ (事务日志)                                 │   │
│  │   - metadata.xml (元数据)                          │   │
│  │   - mkdb.inuse (锁文件)                            │   │
│  └─────────────────────────────────────────────────────┘   │
└────────────────┬────────────────────────────────────────────┘
                 │ 清理维护
                 ↓
┌─────────────────────────────────────────────────────────────┐
│              xclear 清理工具                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │   清理流程                                           │   │
│  │   1. 读取 gsx.mkdb.xml 配置                        │   │
│  │   2. 验证数据库版本对应                             │   │
│  │   3. 执行 run.bat 清理脚本                         │   │
│  │   4. 删除数据文件和日志                             │   │
│  │   5. 重建目录结构                                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 与其他模块的交互
- **操作对象**:
  - mkdb 数据库目录 - 清理目标
  - gsx.mkdb.xml - 配置文件
  - run.bat - 执行脚本

- **依赖模块**:
  - Windows 批处理环境
  - mkdb 数据库规范

- **数据流**:
  - 配置验证: gsx.mkdb.xml → 版本检查
  - 执行清理: run.bat → 删除文件 → 重建结构

### 2.3 关键代码位置

| 功能模块 | 文件路径 | 说明 |
|---------|---------|------|
| 使用说明 | [使用文档.txt](使用文档.txt) | 操作步骤说明 |
| 配置文件 | `gsx.mkdb.xml` | 数据库配置 |
| 执行脚本 | `run.bat` | 清理批处理脚本 |
| 目标目录 | `mkdb/` | 数据库目录 |

---

## 3. 依赖与构建

### 3.1 运行时依赖
- **操作系统**: Windows (批处理脚本)
- **必需文件**:
  - `gsx.mkdb.xml` - 数据库配置文件
  - `run.bat` - 清理执行脚本
  - `mkdb/` - 数据库目录

### 3.2 使用前提
- 确保数据库服务器已停止
- 备份重要数据(清理操作不可逆)
- 配置文件与当前数据库版本对应

---

## 4. 配置与使用

### 4.1 使用步骤

根据 [使用文档.txt](使用文档.txt) 的说明:

#### 步骤 1: 准备数据库目录
```batch
REM 将数据库目录放到 mkdb 目录下
xcopy /E /I /Y path\to\database mkdb\
```

#### 步骤 2: 验证配置文件
```batch
REM 确保 gsx.mkdb.xml 与当前数据库版本对应
notepad gsx.mkdb.xml
```

**配置文件示例**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xdb dbhome="mkdb"
     trace="info"
     version="1.0">
  <!-- 数据库表定义 -->
  <table name="users" key="long" value="UserInfo"/>
  <table name="items" key="int" value="ItemData"/>
  <!-- 更多表定义... -->
</xdb>
```

#### 步骤 3: 执行清理脚本
```batch
REM 双击运行或命令行执行
run.bat
```

**run.bat 典型内容**:
```batch
@echo off
echo ========================================
echo  mkdb Database Cleanup Tool
echo ========================================
echo.

REM 检查数据库目录
if not exist "mkdb\" (
    echo ERROR: mkdb directory not found!
    pause
    exit /b 1
)

REM 检查配置文件
if not exist "gsx.mkdb.xml" (
    echo ERROR: gsx.mkdb.xml not found!
    pause
    exit /b 1
)

REM 确认操作
echo WARNING: This will delete all data in mkdb directory!
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b 0
)

echo.
echo Cleaning database...

REM 删除锁文件
if exist "mkdb\mkdb.inuse" del /f /q "mkdb\mkdb.inuse"

REM 清理日志
if exist "mkdb\log\" rd /s /q "mkdb\log"

REM 清理表数据
if exist "mkdb\table\" rd /s /q "mkdb\table"

REM 删除元数据
if exist "mkdb\metadata.xml" del /f /q "mkdb\metadata.xml"

REM 重建目录结构
mkdir "mkdb\log" 2>nul
mkdir "mkdb\table" 2>nul

echo.
echo Database cleanup completed successfully!
echo.
pause
```

### 4.2 使用示例

#### 示例 1: 开发环境重置
```batch
@echo off
REM 1. 停止服务器
taskkill /F /IM game_server.exe

REM 2. 执行清理
cd tools\xclear
run.bat

REM 3. 重新启动服务器
cd ..\..\server
start game_server.exe
```

#### 示例 2: 测试环境初始化
```batch
@echo off
echo Initializing test environment...

REM 1. 备份现有数据
xcopy /E /I /Y mkdb mkdb.backup.%date:~0,10%

REM 2. 执行清理
run.bat

REM 3. 导入测试数据
java -jar ..\tools\importdata.jar test_data.xml

echo Test environment ready.
pause
```

#### 示例 3: 版本升级前清理
```batch
@echo off
echo Database migration preparation...

REM 1. 检查版本
echo Current version: %DB_VERSION%
echo Target version: %NEW_VERSION%

REM 2. 导出数据
java -jar ..\tools\exportdata.jar mkdb export.dat

REM 3. 清理旧版本数据库
run.bat

REM 4. 更新配置文件
copy /Y gsx.mkdb.xml.new gsx.mkdb.xml

REM 5. 导入数据到新版本
java -jar ..\tools\importdata.jar export.dat

echo Migration completed.
pause
```

### 4.3 安全检查清单

**执行前必须确认**:
- [ ] 数据库服务器已停止
- [ ] 重要数据已备份
- [ ] gsx.mkdb.xml 版本正确
- [ ] 有足够的磁盘空间
- [ ] 确认清理范围(不误删其他数据)

---

## 5. 输入输出规范

### 5.1 输入文件

#### gsx.mkdb.xml 配置文件
- **编码**: UTF-8 或 GBK
- **格式**: mkdb XML Schema
- **必需元素**: `<xdb>`, `<table>`
- **版本**: 必须与数据库版本对应

#### mkdb 目录结构
```
mkdb/
├── table/              # 表数据目录
│   ├── users/
│   ├── items/
│   └── ...
├── log/                # 事务日志
├── metadata.xml        # 元数据
└── mkdb.inuse          # 锁文件
```

### 5.2 输出结果

#### 清理后的目录结构
```
mkdb/
├── log/                # 空目录(已重建)
└── table/              # 空目录(已重建)
```

#### 控制台输出示例
```
========================================
 mkdb Database Cleanup Tool
========================================

WARNING: This will delete all data in mkdb directory!
Continue? (Y/N): Y

Cleaning database...
Deleting lock file...
Cleaning logs...
Cleaning tables...
Removing metadata...
Rebuilding directory structure...

Database cleanup completed successfully!

Press any key to continue...
```

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制
- **Windows 专用**: 批处理脚本仅支持 Windows
- **不可恢复**: 清理操作删除所有数据,无法撤销
- **手动验证**: 需要手动确认配置文件版本
- **无增量清理**: 不支持选择性清理特定表

#### 安全限制
- **无自动备份**: 不会自动备份数据
- **无版本检查**: 不会自动验证配置文件版本
- **无锁检测**: 不检查数据库是否正在使用

### 6.2 性能考虑

#### 清理速度
- **小型数据库** (< 1GB): 几秒钟
- **中型数据库** (1-10GB): 10-30秒
- **大型数据库** (> 10GB): 1-5分钟

#### 影响因素
- 磁盘 I/O 速度
- 文件数量
- 目录深度
- 杀毒软件扫描

### 6.3 安全注意事项

#### 数据安全
```yaml
critical_warnings:
  - "清理操作不可逆,务必备份重要数据"
  - "确认清理范围,避免误删其他数据"
  - "验证配置文件版本,避免版本不匹配"

best_practices:
  - "清理前停止所有使用数据库的服务"
  - "清理前完整备份数据库目录"
  - "在测试环境验证清理脚本"
  - "保留最近3次备份"
```

#### 权限要求
- 对 mkdb 目录有完全控制权限
- 能够删除文件和目录
- 能够创建目录

### 6.4 故障排查指南

#### 问题 1: "mkdb directory not found"
**症状**: run.bat 报错找不到 mkdb 目录

**解决方案**:
```batch
REM 检查目录是否存在
dir mkdb

REM 如果不存在,创建目录
mkdir mkdb
```

#### 问题 2: "Access Denied" 权限错误
**症状**: 删除文件时提示权限不足

**解决方案**:
```batch
REM 以管理员身份运行
右键 run.bat → 以管理员身份运行

REM 或检查文件属性
attrib mkdb\* /s
attrib -r -s -h mkdb\* /s
```

#### 问题 3: "数据库正在使用" 错误
**症状**: mkdb.inuse 文件存在且无法删除

**解决方案**:
```batch
REM 1. 检查进程
tasklist | findstr game_server
tasklist | findstr java

REM 2. 强制结束进程
taskkill /F /IM game_server.exe
taskkill /F /IM java.exe

REM 3. 等待几秒后重试
timeout /t 5
del /f /q mkdb\mkdb.inuse
```

#### 问题 4: 配置文件版本不匹配
**症状**: 清理后服务器启动失败,提示 "Compare metadata fail"

**解决方案**:
```batch
REM 1. 恢复备份
rd /s /q mkdb
xcopy /E /I /Y mkdb.backup mkdb

REM 2. 检查配置文件版本
notepad gsx.mkdb.xml

REM 3. 使用正确版本的配置文件
copy /Y gsx.mkdb.xml.v2.0 gsx.mkdb.xml

REM 4. 重新清理
run.bat
```

#### 问题 5: 清理后目录结构不完整
**症状**: 清理后缺少必要的子目录

**解决方案**:
```batch
REM 手动重建目录结构
mkdir mkdb\log
mkdir mkdb\table
mkdir mkdb\backup

REM 或重新执行清理脚本
run.bat
```

---

## 7. 扩展与改进

### 7.1 推荐改进方向

#### 短期优化 (1-2 周)
1. **自动备份**: 清理前自动创建备份
2. **版本检查**: 自动验证配置文件版本
3. **选择性清理**: 支持清理特定表或日志

#### 中期优化 (1-2 个月)
4. **跨平台支持**: 提供 Linux/macOS 版本的 shell 脚本
5. **GUI 界面**: 图形化操作界面
6. **日志记录**: 记录清理操作日志

### 7.2 增强脚本示例

#### 增强版 run.bat (带备份)
```batch
@echo off
setlocal enabledelayedexpansion

echo ========================================
echo  Enhanced mkdb Cleanup Tool
echo ========================================
echo.

REM 获取时间戳
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

REM 检查数据库目录
if not exist "mkdb\" (
    echo ERROR: mkdb directory not found!
    pause
    exit /b 1
)

REM 自动备份
echo Creating backup...
set BACKUP_DIR=mkdb.backup.%TIMESTAMP%
xcopy /E /I /Q "mkdb" "%BACKUP_DIR%"
if errorlevel 1 (
    echo ERROR: Backup failed!
    pause
    exit /b 1
)
echo Backup created: %BACKUP_DIR%
echo.

REM 版本检查
if exist "gsx.mkdb.xml" (
    findstr /C:"version" gsx.mkdb.xml
    echo.
)

REM 确认操作
set /p confirm="Proceed with cleanup? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    exit /b 0
)

REM 清理操作
echo.
echo Cleaning database...
if exist "mkdb\mkdb.inuse" del /f /q "mkdb\mkdb.inuse"
if exist "mkdb\log\" rd /s /q "mkdb\log"
if exist "mkdb\table\" rd /s /q "mkdb\table"
if exist "mkdb\metadata.xml" del /f /q "mkdb\metadata.xml"

REM 重建目录
mkdir "mkdb\log" 2>nul
mkdir "mkdb\table" 2>nul

REM 记录日志
echo %TIMESTAMP% - Database cleaned successfully >> cleanup.log

echo.
echo Cleanup completed successfully!
echo Backup saved to: %BACKUP_DIR%
echo.
pause
```

---

## 8. 快速参考

### 8.1 常用命令速查表

```batch
# 基本清理
run.bat

# 带备份的清理
xcopy /E /I /Y mkdb mkdb.backup && run.bat

# 强制清理(跳过确认)
echo Y | run.bat

# 检查数据库状态
dir mkdb /s

# 删除锁文件
del /f /q mkdb\mkdb.inuse

# 重建目录结构
mkdir mkdb\log && mkdir mkdb\table
```

### 8.2 文件清单速查

| 文件/目录 | 用途 | 必需 |
|----------|------|-----|
| `gsx.mkdb.xml` | 数据库配置 | ✅ |
| `run.bat` | 清理脚本 | ✅ |
| `mkdb/` | 数据库目录 | ✅ |
| `使用文档.txt` | 使用说明 | ⚠️ 参考 |

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | xclear (mkdb Database Cleanup Tool) |
| **主要功能** | mkdb 数据库清理与重置 |
| **平台** | Windows (批处理) |
| **代码位置** | `server/tools/xclear/` |
| **配置文件** | `gsx.mkdb.xml` |
| **执行脚本** | `run.bat` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |

---

## 10. 联系方式

如有问题或建议,请通过以下方式联系:
- 提交 Issue 到项目仓库
- 联系游戏服务器运维团队
- 查看 mkdb 数据库维护文档

---

**文档版本**: v1.0
**维护者**: MT3 开发团队
**最后更新**: 2025-11-27
