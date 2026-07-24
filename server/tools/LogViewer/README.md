# LogViewer - SWT 日志查看器

## 1. 工具概述

### 1.1 用途说明

LogViewer 是一个基于 SWT (Standard Widget Toolkit) 的桌面图形界面日志查看工具，专为 MT3 游戏服务器日志分析设计。该工具提供以下核心功能：

- **图形化查看**：友好的 GUI 界面，支持表格化显示日志
- **快速过滤**：基于正则表达式的实时搜索和过滤
- **多编码支持**：支持 UTF-8 和 GBK 编码切换
- **标记功能**：高亮重要日志，支持黄色标记
- **批量处理**：支持打开目录，批量加载多个日志文件
- **导出功能**：将过滤结果导出为新的日志文件

### 1.2 典型使用场景

- **日志分析**：快速浏览服务器运行日志，定位错误
- **问题排查**：通过关键词搜索，定位异常堆栈
- **数据提取**：过滤特定类型日志并导出
- **性能分析**：查看系统日志、错误日志的时间分布
- **运维监控**：实时浏览最新日志，监控服务器状态

### 1.3 关键特性

- **SWT 图形界面**：跨平台桌面应用，比 Swing 性能更好
- **双视图模式**：当前视图和搜索视图，快速切换
- **实时过滤**：输入搜索条件即时刷新结果
- **智能解析**：自动解析日志级别、时间戳、来源、消息
- **右键菜单**：支持标记/取消标记操作
- **CLI 工具**：包含 LogFilter 命令行过滤工具

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色

LogViewer 位于 MT3 运维工具集的**日志分析层**：

```
┌─────────────────────────────────────────┐
│      游戏服务器运行日志                 │
│  - syslog.YYYY-MM-DD.log                │
│  - error.log, debug.log                 │
└──────────────┬──────────────────────────┘
               │ 读取
               ↓
┌─────────────────────────────────────────┐
│           LogViewer GUI                 │
│  - 文件/目录选择                        │
│  - 日志解析与表格显示                   │
│  - 搜索过滤与标记                       │
│  - 编码切换 (UTF-8/GBK)                 │
│  - 结果导出                             │
└──────────────┬──────────────────────────┘
               │ 输出
               ↓
┌─────────────────────────────────────────┐
│       过滤后的日志文件 (导出)           │
│      - filtered.log                     │
└─────────────────────────────────────────┘
```

### 2.2 与其他模块的交互

- **上游依赖**：
  - 服务器日志文件 (*.log, *.txt)
  - SWT 库 (org.eclipse.swt, org.eclipse.jface)
  - icon.gif (应用图标)
- **下游消费者**：运维人员、开发人员
- **数据流**：
  - 输入：文本日志文件
  - 输出：过滤后的日志文件

### 2.3 关键代码位置

| 功能模块 | 文件路径 | 关键行号 |
|---------|---------|---------|
| 主窗口 | [src/com/mammoth/logger/gui/LogShell.java](src/com/mammoth/logger/gui/LogShell.java#L29-L443) | 29-443 |
| 文件打开 | [src/com/mammoth/logger/gui/LogShell.java](src/com/mammoth/logger/gui/LogShell.java#L103-L135) | 103-135 |
| 搜索功能 | [src/com/mammoth/logger/gui/LogShell.java](src/com/mammoth/logger/gui/LogShell.java#L358-L386) | 358-386 |
| 导出功能 | [src/com/mammoth/logger/gui/LogShell.java](src/com/mammoth/logger/gui/LogShell.java#L403-L429) | 403-429 |
| 编码切换 | [src/com/mammoth/logger/gui/LogShell.java](src/com/mammoth/logger/gui/LogShell.java#L228-L237) | 228-237 |
| TreeViewer | [src/com/mammoth/logger/gui/LogShell.java](src/com/mammoth/logger/gui/LogShell.java#L260-L300) | 260-300 |
| TableViewer | [src/com/mammoth/logger/gui/LogShell.java](src/com/mammoth/logger/gui/LogShell.java#L303-L356) | 303-356 |
| 标记操作 | [src/com/mammoth/logger/gui/MarkAction.java](src/com/mammoth/logger/gui/MarkAction.java) | 全文 |
| CLI 过滤器 | [src/LogFilter.java](src/LogFilter.java) | 全文 |

---

## 3. 依赖与构建

### 3.1 运行时依赖

- **Java 运行时**：JDK 1.6 及以上（推荐 JDK 8）
- **SWT 库**：
  - org.eclipse.swt (平台相关)
  - org.eclipse.jface
- **图标文件**：icon.gif（应用程序图标）
- **操作系统**：
  - Windows (swt-win32.jar)
  - Linux (swt-gtk.jar)
  - macOS (swt-cocoa.jar)

### 3.2 构建时依赖

- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac）
- **SWT 库**：需放置在 lib/ 目录

### 3.3 构建步骤

#### 使用 Ant 构建

```bash
# 在 LogViewer 目录下执行
ant clean jar

# 输出文件：LogViewer.jar
```

#### 手动构建（如果没有 build.xml）

```bash
# 编译
javac -d bin -cp "lib/*" src/**/*.java

# 打包
jar cvfm LogViewer.jar MANIFEST.MF -C bin .

# MANIFEST.MF 内容：
# Main-Class: com.mammoth.logger.gui.LogShell
```

---

## 4. 配置与使用

### 4.1 启动应用

#### Windows

```bash
# 方式 1：双击 Jar 文件（如果已配置文件关联）
LogViewer.jar

# 方式 2：命令行启动
java -jar LogViewer.jar

# 方式 3：指定 SWT 库路径
java -cp "LogViewer.jar;lib/swt-win32.jar" com.mammoth.logger.gui.LogShell
```

#### Linux

```bash
java -jar LogViewer.jar

# 如果提示缺少 SWT 库
java -cp "LogViewer.jar:lib/swt-gtk.jar" com.mammoth.logger.gui.LogShell
```

### 4.2 功能使用

#### 4.2.1 打开日志文件

**菜单操作**：

1. 点击菜单 `文件(F)` → `打开文件`
2. 选择 .log 或 .txt 文件
3. 双击左侧树形列表中的 `LineEntity` 节点加载日志

**目录批量加载**：

1. 点击菜单 `文件(F)` → `打开目录`
2. 选择包含日志文件的目录
3. 所有 .log 和 .txt 文件会显示在左侧树中

#### 4.2.2 搜索和过滤

**打开搜索对话框**：

- 点击菜单 `搜索`
- 或使用快捷键（如有配置）

**搜索条件设置**：

- **关键词**：输入要搜索的文本（支持正则表达式）
- **日志级别**：选择 INFO、WARN、ERROR 等
- **时间范围**：指定起止时间
- **来源过滤**：按日志来源筛选

**查看结果**：

- 搜索结果显示在 `搜索` 标签页
- 匹配行会以黄色背景高亮显示
- 双击日志行可查看完整内容

#### 4.2.3 标记操作

**标记重要日志**：

1. 在表格中选中一行或多行
2. 右键点击 → 选择 `标记`
3. 标记的行会显示为特定颜色

**取消标记**：

1. 选中已标记的行
2. 右键点击 → 选择 `取消标记`

#### 4.2.4 编码切换

**切换编码**：

- 菜单 `设置` → 选择 `UTF-8` 或 `GBK`
- 切换后自动重新加载所有日志

**适用场景**：

- UTF-8：现代服务器日志、Linux 环境
- GBK：Windows 中文环境、旧版日志

#### 4.2.5 导出结果

**导出过滤后的日志**：

1. 点击菜单 `导出`
2. 选择保存位置和文件名
3. 仅导出当前搜索结果中的日志

**导出格式**：

- 纯文本格式
- 保留原始日志格式
- 编码：UTF-8

### 4.3 CLI 工具：LogFilter

**命令格式**：

```bash
java -cp LogViewer.jar LogFilter <input> <output> [regex]
```

**参数说明**：

- `<input>`：输入日志文件路径
- `<output>`：输出文件路径
- `[regex]`：正则表达式（可选，默认 "系统日志"）

**使用示例**：

```bash
# 示例 1：提取包含"系统日志"的行
java -cp LogViewer.jar LogFilter syslog.2016-02-18.log out.log

# 示例 2：提取包含"ERROR"的行
java -cp LogViewer.jar LogFilter syslog.2016-02-18.log errors.log "ERROR"

# 示例 3：提取特定用户的日志
java -cp LogViewer.jar LogFilter game.log user_123.log "userId=123"

# 示例 4：批量处理多个文件
for file in logs/*.log; do
  java -cp LogViewer.jar LogFilter "$file" "filtered/$file" "WARN|ERROR"
done
```

---

## 5. 界面说明

### 5.1 主窗口布局

```
┌─────────────────────────────────────────────────────────────┐
│  LogViewer                                          [_][□][X] │
├─────────────────────────────────────────────────────────────┤
│  文件(F)  设置  搜索  导出  帮助                             │
├─────────────┬───────────────────────────────────────────────┤
│  目录树     │  [当前] [搜索]                                │
│             │                                               │
│  ├─ file1   │  序号 | 类型 | 时间 | 级别 | 来源 | 消息      │
│  │  └─行1   │  ─────┼──────┼──────┼──────┼──────┼────────  │
│  │  └─行2   │  001  | INFO | 10:00| DEBUG| Main | ...      │
│  └─ file2   │  002  | WARN | 10:01| WARN | DB   | ...      │
│             │  003  | ERROR| 10:02| ERROR| Net  | ...      │
│             │                                               │
│             │  (右键菜单: 标记 / 取消标记)                   │
└─────────────┴───────────────────────────────────────────────┘
```

### 5.2 菜单说明

| 菜单 | 子项 | 功能 |
|-----|------|------|
| 文件(F) | 打开目录 | 批量加载目录中的日志文件 |
| 文件(F) | 打开文件 | 加载单个日志文件 |
| 文件(F) | 退出 | 关闭应用程序 |
| 设置 | UTF-8 | 切换到 UTF-8 编码 |
| 设置 | GBK | 切换到 GBK 编码 |
| 搜索 | - | 打开搜索对话框 |
| 导出 | - | 导出当前搜索结果 |
| 帮助 | 说明 | 显示使用说明 |
| 帮助 | 版本 | 显示构建时间戳 |

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制

- **大文件性能**：单个文件 >100MB 时加载较慢
- **内存占用**：所有日志加载到内存，超大文件可能 OOM
- **搜索性能**：复杂正则表达式可能导致界面卡顿

#### 平台限制

- **SWT 依赖**：不同操作系统需要对应的 SWT 库
- **图标文件**：必须有 icon.gif，否则无法显示图标

### 6.2 性能考虑

#### 大文件处理

- 建议：单文件 < 100MB
- 大文件：使用 LogFilter CLI 工具预过滤

#### 内存配置

```bash
# 处理大日志时增加堆内存
java -Xmx2g -jar LogViewer.jar
```

### 6.3 故障排查指南

#### 问题 1：无法启动 - UnsatisfiedLinkError

**症状**：

```
java.lang.UnsatisfiedLinkError: no swt-win32 in java.library.path
```

**解决方案**：

```bash
# 下载对应平台的 SWT 库
# Windows: swt-win32-x64.jar
# Linux: swt-gtk-x64.jar
# macOS: swt-cocoa-x64.jar

# 启动时指定 classpath
java -cp "LogViewer.jar;lib/swt-win32-x64.jar" com.mammoth.logger.gui.LogShell
```

#### 问题 2：乱码显示

**症状**：中文日志显示为乱码

**解决方案**：

- 菜单 `设置` → 选择正确的编码（UTF-8 或 GBK）
- 或在 LogFilter 中手动设置编码

#### 问题 3：内存溢出

**症状**：

```
OutOfMemoryError: Java heap space
```

**解决方案**：

```bash
# 增加堆内存
java -Xmx2g -jar LogViewer.jar

# 或使用 CLI 工具预过滤
java -cp LogViewer.jar LogFilter large.log filtered.log "ERROR"
```

---

## 7. 扩展与改进

### 7.1 当前架构优势

- **SWT 框架**：原生性能，比 Swing 更快
- **MVC 设计**：数据模型、视图、控制器分离
- **双视图**：当前/搜索标签页，提高效率

### 7.2 推荐改进方向

#### 短期优化（1-2 周）

1. **流式加载**：支持大文件分块加载
2. **快捷键**：添加常用操作快捷键
3. **搜索历史**：保存最近搜索条件

#### 中期优化（1-2 个月）

4. **高级过滤**：支持复合条件（AND/OR/NOT）
5. **实时监控**：Tail -f 模式，监控最新日志
6. **统计图表**：按时间/级别统计日志分布

#### 长期优化（3-6 个月）

7. **多线程加载**：并行解析多个文件
8. **数据库存储**：索引大量日志，支持全文检索
9. **Web 版本**：基于 WebSocket 的实时日志查看器

---

## 8. 快速参考

### 8.1 常用操作速查

| 操作 | 方法 |
|-----|------|
| 打开文件 | 菜单 → 文件 → 打开文件 |
| 打开目录 | 菜单 → 文件 → 打开目录 |
| 搜索日志 | 菜单 → 搜索 |
| 标记日志 | 右键 → 标记 |
| 导出结果 | 菜单 → 导出 |
| 切换编码 | 菜单 → 设置 → UTF-8/GBK |
| 查看完整日志 | 双击日志行 |

### 8.2 CLI 工具速查

```bash
# 基本用法
java -cp LogViewer.jar LogFilter <input> <output> [regex]

# 提取错误日志
java -cp LogViewer.jar LogFilter game.log errors.log "ERROR|FATAL"

# 提取特定时间范围
java -cp LogViewer.jar LogFilter game.log today.log "2025-11-27"
```

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | LogViewer (SWT Log Viewer) |
| **版本** | 见 TimeStamp.getTimeStampInformation() |
| **主要维护者** | 见项目 Git 提交历史 |
| **代码位置** | `server/tools/LogViewer/` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, SWT, JFace |

---

## 10. 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue 到项目仓库
- 联系游戏服务器运维团队
- 查看项目 Wiki 获取更多文档
