# jsconvert - JavaScript 配置转换器

## 1. 工具概述

### 1.1 用途说明

jsconvert 是 MT3 游戏服务器的核心数据转换工具，负责将策划配置的 XML 数据批量转换为游戏运行时所需的配置文件，并绑定 JavaScript 脚本引擎。该工具实现以下核心功能：

- **XML 数据转换**：批量解析 `gamedata/xml/auto` 目录下的游戏配置 XML
- **脚本引擎绑定**：初始化 JavaScript 引擎，绑定表达式和函数
- **模块化加载**：通过 ModuleMgr 加载各业务模块（技能、Buff、战斗、NPC 等）
- **配置安装**：转换后的数据安装至 `server/game_server/gs` 目录供服务器使用
- **数据校验**：提供辅助工具检查配置正确性

### 1.2 典型使用场景

- **策划数据发布**：将策划导出的 XML 配置转换为服务器可读格式
- **版本构建**：在游戏服务器编译流程中自动转换配置数据
- **数据热更新**：生成增量配置，支持运行时动态加载
- **配置验证**：转换前检查数据一致性和脚本语法

### 1.3 关键特性

- **批量转换**：支持一次性转换数十个 XML 配置表
- **脚本支持**：内嵌 JavaScript 引擎，支持表达式计算和函数绑定
- **增量处理**：仅转换变更的配置文件（可选）
- **模块化设计**：各业务模块独立解析和验证
- **自动安装**：转换完成后自动部署到目标目录

---

## 2. 项目角色与架构定位

### 2.1 在系统中的角色

jsconvert 位于 MT3 游戏服务器的**数据处理层**，连接策划配置和服务器运行时：

```
┌─────────────────────────────────────────┐
│        策划工具 (Excel/XML 编辑器)      │
└──────────────┬──────────────────────────┘
               │ 导出 XML
               ↓
┌─────────────────────────────────────────┐
│       gamedata/xml/auto/*.xml           │
│      (游戏配置 XML 数据源)              │
└──────────────┬──────────────────────────┘
               │ 读取
               ↓
┌─────────────────────────────────────────┐
│           jsconvert 转换器              │
│  - XML 解析 (XStream)                   │
│  - JavaScript 引擎初始化                │
│  - 模块化加载与验证                     │
│  - 数据序列化                           │
└──────────────┬──────────────────────────┘
               │ 安装
               ↓
┌─────────────────────────────────────────┐
│   server/game_server/gs/config/         │
│      (服务器运行时配置)                 │
└─────────────────────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│        游戏服务器 (fire.main.*)         │
│      (启动时加载配置)                   │
└─────────────────────────────────────────┘
```

### 2.2 与其他模块的交互

- **上游依赖**：
  - gamedata/xml/auto/*.xml (策划配置数据)
  - properties/*.properties (属性配置文件)
  - XStream 库 (XML 序列化/反序列化)
  - Rhino/Nashorn (JavaScript 引擎)
- **下游消费者**：
  - 游戏服务器 (fire.main.GameServer)
  - GM 工具 (读取配置进行管理操作)
- **数据流**：
  - 输入：XML 文件
  - 输出：Java 序列化对象、JavaScript 脚本绑定

### 2.3 关键代码位置

| 功能模块 | 文件路径 | 关键行号 |
|---------|---------|---------|
| 主入口 | [src/fire/pb/main/Main.java](src/fire/pb/main/Main.java#L84-L97) | 84-97 |
| 路径初始化 | [src/fire/pb/main/Main.java](src/fire/pb/main/Main.java#L49-L57) | 49-57 |
| XML 数据定义 | [src/fire/pb/main/Main.java](src/fire/pb/main/Main.java#L59-L74) | 59-74 |
| 模块初始化 | [src/fire/pb/main/Main.java](src/fire/pb/main/Main.java#L41-L47) | 41-47 |
| 脚本引擎 | [src/fire/script/JavaScript.java](src/fire/script/JavaScript.java) | 全文 |
| 脚本线程管理 | [src/fire/script/ScriptEngineBindThreadMgr.java](src/fire/script/ScriptEngineBindThreadMgr.java) | 全文 |
| 配置管理 | [src/fire/pb/main/ConfigMgr.java](src/fire/pb/main/ConfigMgr.java) | 全文 |
| 模块管理 | [src/fire/pb/main/ModuleMgr.java](src/fire/pb/main/ModuleMgr.java) | 全文 |

---

## 3. 依赖与构建

### 3.1 运行时依赖

- **Java 运行时**：JDK 1.6 及以上（推荐 JDK 8）
- **核心库**：
  - XStream (XML 序列化)
  - Rhino/Nashorn (JavaScript 引擎)
  - 游戏核心库 (fire.pb.*)
- **数据文件**：
  - gamedata/xml/auto/*.xml (配置数据)
  - properties/*.properties (属性文件)

### 3.2 构建时依赖

- **Apache Ant**：1.8.0 及以上版本
- **JDK**：编译需要 JDK（包含 javac）

### 3.3 构建步骤

#### 使用 Ant 构建

```bash
# 在 jsconvert 目录下执行
ant

# 输出文件：jsconvert.jar
# 自动安装到：../../game_server/gs/ (如果目录存在)
```

#### 构建流程说明

构建脚本执行以下步骤：

1. **清理阶段**（clean）：删除旧的 bin/ 目录和 jar 文件
2. **初始化阶段**（init）：创建 bin/ 编译输出目录
3. **编译阶段**（compile）：
   - 编译 `src/**/*.java` → `bin/`
   - 使用 UTF-8 编码
   - 包含游戏核心库依赖
4. **打包阶段**（jar）：
   - 生成 `jsconvert.jar`
   - 设置 Main-Class: `fire.pb.main.Main`
5. **安装阶段**（可选）：
   - 复制到 `../../game_server/gs/` 目录

---

## 4. 配置与使用

### 4.1 基本命令格式

```bash
# 在 jsconvert 目录下执行
java -jar jsconvert.jar

# 或在 game_server/gs 目录下执行
cd ../../game_server/gs
java -jar jsconvert.jar
```

### 4.2 目录结构要求

工具会根据当前工作目录自动判断路径：

```
情况 1：在 jsconvert 目录下运行
当前目录：server/tools/jsconvert/
配置路径：
  - curPath = "" (当前目录)
  - XML 源：gamedata/xml/auto/
  - 属性源：properties/

情况 2：在 game_server/gs 目录下运行
当前目录：server/game_server/gs/
配置路径：
  - curPath = "当前路径/gs/"
  - XML 源：gs/gamedata/xml/auto/
  - 属性源：gs/properties/
```

路径判断逻辑参见：`Main.initCurPath()`（Main.java:49-57）

### 4.3 支持的 XML 数据表

工具默认转换以下 XML 配置（定义在 `Main.initXmlData()`）：

| XML 文件 | 说明 | 模块 |
|---------|------|------|
| fire.pb.battle.SBattleInfo.xml | 战斗信息配置 | battle |
| fire.pb.battle.SCondition.xml | 条件配置 | battle |
| fire.pb.battle.STargetFilter.xml | 目标过滤器 | battle |
| fire.pb.buff.SIBuffConfig.xml | Buff 接口配置 | buff |
| fire.pb.buff.SCBuffConfig.xml | Buff 具体配置 | buff |
| fire.pb.effect.SAttrEffectID2Name.xml | 属性效果映射 | effect |
| fire.pb.game.SActivityAward.xml | 活动奖励 | game |
| fire.pb.main.ModuleInfo.xml | 模块信息 | main |
| fire.pb.skill.SSceneSkillConfig.xml | 场景技能配置 | skill |
| fire.pb.skill.SSkillConfig.xml | 技能配置 | skill |
| fire.pb.skill.SSubSkillConfig.xml | 子技能配置 | skill |
| fire.pb.game.SPointCardActivityAward.xml | 点卡活动奖励 | game |
| fire.pb.npc.SRefreshTimerNpc.xml | 定时刷新 NPC | npc |
| fire.pb.npc.SRefreshTimerNpcDianKa.xml | 点卡定时刷新 NPC | npc |

### 4.4 执行流程

工具执行时按以下顺序处理：

1. **初始化主线程 ID**（用于线程安全检查）
2. **初始化路径**：设置 curPath 和 curAbsolutePath
3. **初始化 XML 数据列表**：加载需要转换的表
4. **初始化 ConfigMgr**：加载 XML 和 properties
5. **初始化 ModuleMgr**：加载各业务模块
6. **初始化脚本引擎**：绑定 JavaScript 表达式和函数
7. **清理资源**：调用 `ModuleMgr.exit()`
8. **输出结果**：
   - 成功：`CREATED FINISHED`
   - 失败：`CREATED FAILED` + 异常堆栈

### 4.5 配置示例

#### 示例 1：在开发环境运行

```bash
# 假设目录结构如下：
# server/
#   ├── tools/jsconvert/
#   │   ├── jsconvert.jar
#   │   ├── gamedata/xml/auto/*.xml
#   │   └── properties/*.properties
#   └── game_server/gs/

cd server/tools/jsconvert
java -jar jsconvert.jar

# 输出：
# CREATED FINISHED
# It takes 3.5s to finished
```

#### 示例 2：在生产环境运行

```bash
# 假设已部署到服务器目录
cd /opt/gameserver/gs
java -jar jsconvert.jar

# 输出：
# CREATED FINISHED
# It takes 2.8s to finished
```

#### 示例 3：集成到构建脚本

```bash
#!/bin/bash
# build_and_convert.sh

# 1. 编译 jsconvert
cd server/tools/jsconvert
ant clean jar

# 2. 运行转换
java -jar jsconvert.jar

# 3. 检查结果
if [ $? -eq 0 ]; then
  echo "Config conversion successful"
  # 复制到服务器目录
  cp -r gamedata ../../game_server/gs/
  cp -r properties ../../game_server/gs/
else
  echo "Config conversion failed!"
  exit 1
fi
```

---

## 5. 输入输出规范

### 5.1 标准输入格式

工具不接受标准输入（stdin），所有配置通过文件系统读取。

### 5.2 标准输出格式

#### 成功场景

```
CREATED FINISHED
It takes X.XXXs to finished
```

#### 失败场景

```
CREATED FAILED
<异常堆栈追踪>
```

### 5.3 输出文件

转换后的数据会被加载到内存，由各模块管理器负责持久化。具体输出格式由各模块定义。

---

## 6. 注意事项

### 6.1 已知限制

#### 功能限制

- **单线程执行**：所有转换操作在主线程完成，大数据量时可能较慢
- **全量转换**：每次执行都会重新加载所有配置，不支持增量更新
- **路径硬编码**：目录结构必须符合预期，否则需修改代码

#### 数据限制

- **XML 格式要求**：必须符合 XStream 解析规范
- **JavaScript 语法**：脚本表达式必须是合法的 JavaScript
- **内存占用**：大量配置加载时会占用较多内存

### 6.2 性能考虑

#### 转换耗时

- 典型数据量（~50 个表，~10000 条记录）：2-5 秒
- 大数据量（~100 个表，>50000 条记录）：10-30 秒

#### 内存占用

- 建议堆内存：-Xmx512m 以上
- 大数据量：-Xmx1g 或更多

### 6.3 故障排查指南

#### 问题 1：找不到配置文件

**症状**：

```
FileNotFoundException: gamedata/xml/auto/fire.pb.battle.SBattleInfo.xml
```

**解决方案**：

```bash
# 1. 检查当前工作目录
pwd

# 2. 确认配置文件存在
ls gamedata/xml/auto/

# 3. 检查路径设置
# 在正确的目录下运行，或修改 Main.initCurPath()
```

#### 问题 2：JavaScript 脚本错误

**症状**：

```
JS脚本with(Math){ return HP*0.1;}有错：
ScriptException: ...
```

**解决方案**：

- 检查 XML 中的脚本表达式语法
- 确认变量名拼写正确
- 使用在线 JavaScript 验证器测试表达式

#### 问题 3：模块初始化失败

**症状**：

```
CREATED FAILED
NullPointerException at ModuleMgr.init()
```

**解决方案**：

```bash
# 1. 检查 properties 文件是否齐全
ls properties/

# 2. 验证 XML 数据完整性
# 确保所有 initXmlData() 中定义的文件都存在

# 3. 查看详细堆栈，定位具体失败模块
```

#### 问题 4：内存溢出

**症状**：

```
OutOfMemoryError: Java heap space
```

**解决方案**：

```bash
# 增加堆内存
java -Xmx1g -jar jsconvert.jar

# 或在构建脚本中设置
export JAVA_OPTS="-Xmx1g -Xms512m"
java $JAVA_OPTS -jar jsconvert.jar
```

---

## 7. 扩展与改进

### 7.1 当前架构优势

- **模块化设计**：业务模块独立，易于扩展新配置类型
- **脚本引擎集成**：支持动态表达式计算
- **配置驱动**：通过修改 `initXmlData()` 轻松添加新表

### 7.2 推荐改进方向

#### 短期优化（1-2 周）

1. **增量转换**：仅转换变更的 XML 文件
2. **并行处理**：利用多线程加速解析
3. **详细日志**：记录每个表的转换耗时和状态

#### 中期优化（1-2 个月）

4. **配置验证**：转换前检查数据合法性
5. **热重载支持**：生成增量补丁，支持运行时加载
6. **错误恢复**：部分表失败时继续处理其他表

#### 长期优化（3-6 个月）

7. **可视化工具**：提供 Web UI，查看转换进度和结果
8. **版本管理**：记录配置变更历史，支持回滚
9. **云端集成**：支持从 Git/OSS 自动拉取配置

---

## 8. 快速参考

### 8.1 常用命令速查表

```bash
# 编译工具
cd server/tools/jsconvert
ant clean jar

# 运行转换
java -jar jsconvert.jar

# 带日志运行
java -jar jsconvert.jar > convert.log 2>&1

# 增加内存运行
java -Xmx1g -jar jsconvert.jar

# 集成到脚本
ant && java -jar jsconvert.jar && echo "Success"
```

### 8.2 目录结构速查

| 目录 | 说明 |
|-----|------|
| gamedata/xml/auto/ | XML 配置数据源 |
| properties/ | 属性配置文件 |
| src/fire/pb/main/ | 主程序代码 |
| src/fire/script/ | 脚本引擎代码 |
| src/fire/pb/battle/ | 战斗模块 |
| src/fire/pb/buff/ | Buff 模块 |
| src/fire/pb/skill/ | 技能模块 |

---

## 9. 维护信息

| 项目 | 信息 |
|-----|------|
| **工具名称** | jsconvert (JavaScript Config Converter) |
| **版本** | 见最新 Jar 文件时间戳 |
| **主要维护者** | 见项目 Git 提交历史 |
| **代码位置** | `server/tools/jsconvert/` |
| **最后更新** | 2025-11-27 |
| **许可证** | 项目内部工具 |
| **技术栈** | Java 1.6+, XStream, Rhino/Nashorn |

---

## 10. 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue 到项目仓库
- 联系游戏服务器开发团队
- 查看项目 Wiki 获取更多文档
