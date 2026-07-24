---
name: ant-build
version: 1.2.0
priority: high
category: server
description: |
  MT3服务器端Apache Ant构建技能。涵盖build.xml配置、依赖管理、增量编译和部署流程。
  触发词: Ant, 构建, build.xml, 服务器编译, JAR, 部署, 依赖, genrpc, genxdb, gengbeans, javac, jar
allowed-tools:
  - Bash
  - Read
  - Edit
---

# Ant 构建技能 (MT3 服务器端)

**版本**: v1.2.0
**最后更新**: 2026-04-11

---

## 🛠️ 环境配置

### 必需软件

| 软件 | 版本 | 用途 | 下载 |
|------|------|------|------|
| **JDK** | 1.8+ | Java 编译运行 | [Oracle](https://www.oracle.com/java/technologies/javase-downloads.html) |
| **Apache Ant** | 1.9+ | 构建工具 | [Apache](https://ant.apache.org/bindownload.cgi) |

### 安装 JDK

1. **下载并安装 JDK 8**
2. **配置环境变量**
   ```bash
   # Windows
   JAVA_HOME = C:\Program Files\Java\jdk1.8.0_144
   PATH += %JAVA_HOME%\bin

   # Linux/Mac
   export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
   export PATH=$JAVA_HOME/bin:$PATH
   ```

3. **验证安装**
   ```bash
   java -version
   # java version "1.8.0_xxx"

   javac -version
   # javac 1.8.0_xxx
   ```

### 安装 Ant

1. **下载 Apache Ant**
2. **解压到目标目录**
3. **配置环境变量**
   ```bash
   # Windows
   ANT_HOME = C:\apache-ant-1.9.x
   PATH += %ANT_HOME%\bin

   # Linux/Mac
   export ANT_HOME=/opt/apache-ant-1.9.x
   export PATH=$ANT_HOME/bin:$PATH
   ```

4. **验证安装**
   ```bash
   ant -version
   # Apache Ant(TM) version 1.9.x
   ```

---

## 🧠 自动进化高价值规则（2026-03 回灌）

来源：`.claude/evolution/evolved/skills/backfill-proposals.md`（2026-03-05）。

### 规则：MSB/构建前工具链预检（confidence=0.81）

执行 `ant` 前，先确认 Java 与 Ant 工具链可用：

```bash
java -version
javac -version
ant -version
```

若当前任务联动 Windows 客户端或原生构建（日志出现 `MSB*`）：

```powershell
cmd /c "call \"%VS120COMNTOOLS%..\\..\\VC\\vcvarsall.bat\" x86 && cl >nul"
cmd /c "\"%ProgramFiles(x86)%\\MSBuild\\12.0\\Bin\\MSBuild.exe\" /version"
where ndk-build
```

任一预检失败，先修复环境后再构建，避免误判为业务代码问题。

---

## 📚 Ant 基础概念

### 核心概念

```xml
<!-- build.xml 基本结构 -->
<project name="MyProject" default="build" basedir=".">

    <!-- 属性定义 -->
    <property name="src.dir" value="src"/>
    <property name="build.dir" value="build"/>

    <!-- 目标定义 -->
    <target name="clean">
        <delete dir="${build.dir}"/>
    </target>

    <target name="compile" depends="clean">
        <mkdir dir="${build.dir}"/>
        <javac srcdir="${src.dir}" destdir="${build.dir}"/>
    </target>

    <target name="build" depends="compile">
        <jar destfile="myapp.jar" basedir="${build.dir}"/>
    </target>

</project>
```

### 术语说明

| 术语 | 说明 | 示例 |
|------|------|------|
| **Project** | 项目，build.xml 的根元素 | `<project name="MT3">` |
| **Target** | 目标，一组任务的集合 | `<target name="compile">` |
| **Task** | 任务，具体的构建操作 | `<javac>`, `<copy>`, `<delete>` |
| **Property** | 属性，变量定义 | `<property name="src" value="src"/>` |
| **Path** | 路径，类路径等 | `<classpath refid="lib.path"/>` |
| **Depends** | 依赖，目标间的依赖关系 | `depends="clean,compile"` |

### 常用任务

| 任务 | 功能 | 示例 |
|------|------|------|
| `javac` | 编译 Java 代码 | `<javac srcdir="src" destdir="bin"/>` |
| `java` | 运行 Java 程序 | `<java classname="Main" fork="true"/>` |
| `jar` | 打包 JAR | `<jar destfile="app.jar" basedir="bin"/>` |
| `copy` | 复制文件 | `<copy file="a.txt" todir="dist"/>` |
| `delete` | 删除文件 | `<delete dir="build"/>` |
| `mkdir` | 创建目录 | `<mkdir dir="build"/>` |
| `echo` | 输出信息 | `<echo message="Building..."/>` |
| `exec` | 执行外部命令 | `<exec executable="cmd"/>` |

---

## 🏗️ MT3 服务器构建流程

### 服务器项目结构

```
server/server/
├── game_server/           # 游戏服务器
│   ├── src/               # 源代码
│   ├── lib/               # 依赖库
│   ├── build.xml          # 构建配置
│   └── xgenoutput/        # xbean 生成代码
├── gate_server/           # 网关服务器
├── zone_server/           # 区域服务器
├── spirit_server/         # 灵兽服务器
├── name_server/           # 名称服务器
├── proxy_server/          # 代理服务器
├── trans_server/          # 传输服务器
├── sdk_server/            # SDK 服务器
└── common/                # 公共代码
    ├── gnet/              # 网络框架
    └── xbean/             # 数据框架
```

### 构建流程图

```
┌─────────────────────────────────────────────────────┐
│                    完整构建流程                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. clean (清理)                                    │
│     └─ 删除 build 目录和生成文件                     │
│                     ↓                               │
│  2. rpcgen (协议生成)                               │
│     └─ 从 gnet.xml 生成协议类                       │
│                     ↓                               │
│  3. xbean (数据生成)                                │
│     └─ 从 state.xml 生成数据类                      │
│                     ↓                               │
│  4. compile (编译)                                  │
│     └─ 编译所有 Java 源代码                         │
│                     ↓                               │
│  5. jar (打包)                                      │
│     └─ 打包成 JAR 文件                              │
│                     ↓                               │
│  6. package (发布)                                  │
│     └─ 复制到发布目录                               │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🔧 常用 Ant 命令

### 基本命令

```bash
# 查看可用目标
ant -p

# 执行默认目标
ant

# 执行指定目标
ant compile

# 执行多个目标
ant clean compile

# 查看详细输出
ant -v compile

# 查看调试输出
ant -d compile

# 指定 build.xml
ant -f build.xml compile

# 设置属性
ant -Denv=production compile
```

### MT3 服务器常用命令

```bash
# 进入服务器目录
cd server/server/game_server

# 清理构建
ant clean

# 生成协议代码
ant rpcgen

# 生成数据代码
ant xbean

# 编译项目
ant compile

# 完整构建
ant build

# 打包
ant jar

# 发布
ant package

# 运行
ant run
```

### 批量构建所有服务器

```bash
#!/bin/bash
# build-all.sh

SERVERS="game_server gate_server zone_server spirit_server name_server proxy_server trans_server sdk_server"

for server in $SERVERS; do
    echo "Building $server..."
    cd server/server/$server
    ant clean build
    if [ $? -ne 0 ]; then
        echo "Build failed for $server"
        exit 1
    fi
    cd ../../..
done

echo "All servers built successfully!"
```

---

## 📝 build.xml 详解

### 典型的 build.xml 结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project name="game_server" default="build" basedir=".">

    <!-- ========== 属性定义 ========== -->
    <property name="src.dir" value="src"/>
    <property name="lib.dir" value="lib"/>
    <property name="build.dir" value="build"/>
    <property name="dist.dir" value="dist"/>
    <property name="xgen.dir" value="xgenoutput"/>

    <!-- 公共模块路径 -->
    <property name="common.dir" value="../common"/>
    <property name="gnet.dir" value="${common.dir}/gnet"/>

    <!-- ========== 类路径定义 ========== -->
    <path id="compile.classpath">
        <fileset dir="${lib.dir}">
            <include name="**/*.jar"/>
        </fileset>
        <fileset dir="${gnet.dir}/lib">
            <include name="**/*.jar"/>
        </fileset>
    </path>

    <!-- ========== 清理目标 ========== -->
    <target name="clean" description="清理构建目录">
        <delete dir="${build.dir}"/>
        <delete dir="${dist.dir}"/>
        <echo message="清理完成"/>
    </target>

    <!-- ========== rpcgen 目标 ========== -->
    <target name="rpcgen" description="生成协议代码">
        <echo message="生成协议代码..."/>
        <java classname="gnet.RpcGen" fork="true" failonerror="true">
            <classpath refid="compile.classpath"/>
            <arg value="${src.dir}/gnet.xml"/>
            <arg value="${src.dir}"/>
        </java>
        <echo message="协议生成完成"/>
    </target>

    <!-- ========== xbean 目标 ========== -->
    <target name="xbean" description="生成数据类">
        <echo message="生成数据类..."/>
        <java classname="xbean.XBeanGen" fork="true" failonerror="true">
            <classpath refid="compile.classpath"/>
            <arg value="${src.dir}/state.xml"/>
            <arg value="${xgen.dir}"/>
        </java>
        <echo message="数据类生成完成"/>
    </target>

    <!-- ========== 编译目标 ========== -->
    <target name="compile" depends="rpcgen,xbean" description="编译源代码">
        <mkdir dir="${build.dir}"/>

        <echo message="编译源代码..."/>
        <javac srcdir="${src.dir}"
               destdir="${build.dir}"
               includeantruntime="false"
               encoding="UTF-8"
               debug="true"
               debuglevel="lines,vars,source">
            <classpath refid="compile.classpath"/>
            <compilerarg value="-Xlint:unchecked"/>
        </javac>

        <!-- 编译生成的代码 -->
        <javac srcdir="${xgen.dir}"
               destdir="${build.dir}"
               includeantruntime="false"
               encoding="UTF-8"
               debug="true">
            <classpath refid="compile.classpath"/>
        </javac>

        <echo message="编译完成"/>
    </target>

    <!-- ========== 打包目标 ========== -->
    <target name="jar" depends="compile" description="打包 JAR">
        <mkdir dir="${dist.dir}"/>

        <jar destfile="${dist.dir}/game_server.jar" basedir="${build.dir}">
            <manifest>
                <attribute name="Main-Class" value="com.mt3.gameserver.Main"/>
                <attribute name="Class-Path" value=". lib/*"/>
            </manifest>
        </jar>

        <echo message="打包完成: ${dist.dir}/game_server.jar"/>
    </target>

    <!-- ========== 发布目标 ========== -->
    <target name="package" depends="jar" description="发布">
        <!-- 复制 JAR -->
        <copy file="${dist.dir}/game_server.jar" todir="${dist.dir}/release"/>

        <!-- 复制依赖 -->
        <copy todir="${dist.dir}/release/lib">
            <fileset dir="${lib.dir}">
                <include name="**/*.jar"/>
            </fileset>
        </copy>

        <!-- 复制配置 -->
        <copy todir="${dist.dir}/release/config">
            <fileset dir="config"/>
        </copy>

        <!-- 复制启动脚本 -->
        <copy file="start.sh" todir="${dist.dir}/release"/>
        <chmod file="${dist.dir}/release/start.sh" perm="755"/>

        <echo message="发布完成: ${dist.dir}/release"/>
    </target>

    <!-- ========== 构建目标（默认）========== -->
    <target name="build" depends="package" description="完整构建">
        <echo message="构建完成!"/>
    </target>

    <!-- ========== 运行目标 ========== -->
    <target name="run" depends="compile" description="运行服务器">
        <java classname="com.mt3.gameserver.Main" fork="true">
            <classpath>
                <pathelement location="${build.dir}"/>
                <path refid="compile.classpath"/>
            </classpath>
            <jvmarg value="-Xmx1024m"/>
            <jvmarg value="-Dconfig.dir=config"/>
        </java>
    </target>

</project>
```

---

## 🔄 rpcgen 协议生成

### gnet.xml 协议定义

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gnet>
    <!-- 协议命名空间 -->
    <namespace>com.mt3.gameserver.protocol</namespace>

    <!-- 登录协议 -->
    <protocol id="1001" name="LoginRequest">
        <field name="username" type="string"/>
        <field name="password" type="string"/>
        <field name="deviceId" type="string"/>
    </protocol>

    <protocol id="1002" name="LoginResponse">
        <field name="success" type="boolean"/>
        <field name="playerId" type="int"/>
        <field name="errorCode" type="int"/>
        <field name="errorMsg" type="string"/>
    </protocol>

    <!-- 聊天协议 -->
    <protocol id="2001" name="ChatRequest">
        <field name="channel" type="int"/>
        <field name="content" type="string"/>
        <field name="targetId" type="int"/>
    </protocol>

    <protocol id="2002" name="ChatResponse">
        <field name="senderId" type="int"/>
        <field name="senderName" type="string"/>
        <field name="channel" type="int"/>
        <field name="content" type="string"/>
        <field name="timestamp" type="long"/>
    </protocol>

</gnet>
```

### 支持的数据类型

| 类型 | Java 类型 | 说明 |
|------|-----------|------|
| `boolean` | `boolean` | 布尔值 |
| `byte` | `byte` | 字节 |
| `short` | `short` | 短整数 |
| `int` | `int` | 整数 |
| `long` | `long` | 长整数 |
| `float` | `float` | 单精度浮点 |
| `double` | `double` | 双精度浮点 |
| `string` | `String` | 字符串 |
| `bytes` | `byte[]` | 字节数组 |
| `list<T>` | `List<T>` | 列表 |
| `map<K,V>` | `Map<K,V>` | 映射 |

### 生成的代码结构

```java
// 生成的 LoginRequest.java
package com.mt3.gameserver.protocol;

public class LoginRequest implements Protocol {
    public static final int PROTOCOL_ID = 1001;

    private String username;
    private String password;
    private String deviceId;

    // getter/setter
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    // ...

    // 序列化
    @Override
    public void marshal(OutputStream out) throws IOException {
        // ...
    }

    // 反序列化
    @Override
    public void unmarshal(InputStream in) throws IOException {
        // ...
    }
}
```

---

## 📊 xbean 数据生成

### state.xml 数据定义

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xbean>
    <namespace>com.mt3.gameserver.xbean</namespace>

    <!-- 玩家状态 -->
    <bean name="PlayerState">
        <field name="playerId" type="int"/>
        <field name="name" type="string"/>
        <field name="level" type="int"/>
        <field name="exp" type="long"/>
        <field name="gold" type="long"/>
        <field name="diamond" type="int"/>
        <field name="vipLevel" type="int"/>
        <field name="createTime" type="long"/>
        <field name="lastLoginTime" type="long"/>
    </bean>

    <!-- 物品状态 -->
    <bean name="ItemState">
        <field name="itemId" type="int"/>
        <field name="templateId" type="int"/>
        <field name="count" type="int"/>
        <field name="bindType" type="int"/>
        <field name="expireTime" type="long"/>
    </bean>

    <!-- 背包状态 -->
    <bean name="InventoryState">
        <field name="playerId" type="int"/>
        <field name="capacity" type="int"/>
        <field name="items" type="list&lt;ItemState&gt;"/>
    </bean>

</xbean>
```

### 生成的代码

```java
// 生成的 PlayerState.java
package com.mt3.gameserver.xbean;

public class PlayerState implements XBean {
    private int playerId;
    private String name;
    private int level;
    private long exp;
    private long gold;
    private int diamond;
    private int vipLevel;
    private long createTime;
    private long lastLoginTime;

    // 构造函数
    public PlayerState() {}

    // getter/setter
    public int getPlayerId() { return playerId; }
    public void setPlayerId(int playerId) { this.playerId = playerId; }
    // ...

    // 序列化到字节数组
    public byte[] marshal() {
        // ...
    }

    // 从字节数组反序列化
    public static PlayerState unmarshal(byte[] data) {
        // ...
    }
}
```

---

## ❌ 常见构建错误

### 1. JAVA_HOME 未设置

```
错误: JAVA_HOME is not set
```

**解决方法**：
```bash
# Windows
set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_144

# Linux
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
```

### 2. 找不到类

```
错误: package com.xxx does not exist
```

**原因**：类路径配置不正确

**解决方法**：
```xml
<!-- 检查 classpath 配置 -->
<path id="compile.classpath">
    <fileset dir="${lib.dir}">
        <include name="**/*.jar"/>
    </fileset>
</path>

<javac srcdir="${src.dir}" destdir="${build.dir}">
    <classpath refid="compile.classpath"/>
</javac>
```

### 3. rpcgen 失败

```
错误: rpcgen failed: Invalid protocol definition
```

**原因**：gnet.xml 格式错误

**解决方法**：
```xml
<!-- 检查 XML 格式 -->
<!-- 1. 所有标签正确关闭 -->
<!-- 2. 属性值使用引号 -->
<!-- 3. 协议 ID 不重复 -->
<!-- 4. 数据类型正确 -->
```

### 4. 编译错误：编码问题

```
错误: unmappable character for encoding GBK
```

**解决方法**：
```xml
<javac srcdir="${src.dir}"
       destdir="${build.dir}"
       encoding="UTF-8">
    <!-- 指定 UTF-8 编码 -->
</javac>
```

### 5. 依赖库缺失

```
错误: cannot find symbol
```

**解决方法**：
```bash
# 1. 检查 lib 目录是否有所需的 JAR
ls lib/

# 2. 检查 classpath 配置
# 3. 下载缺失的依赖库
```

### 6. 内存不足

```
错误: java.lang.OutOfMemoryError: Java heap space
```

**解决方法**：
```xml
<!-- 增加内存 -->
<javac fork="true" memoryMaximumSize="1024m">
    <!-- ... -->
</javac>

<!-- 或者设置环境变量 -->
<!-- ANT_OPTS=-Xmx1024m -->
```

---

## ⚡ 构建优化

### 1. 增量编译

```xml
<!-- 只编译修改过的文件 -->
<javac srcdir="${src.dir}"
       destdir="${build.dir}"
       includeantruntime="false">
    <!-- Ant 默认支持增量编译 -->
</javac>
```

### 2. 并行编译

```bash
# 使用 fork 和多线程
ant -Dbuild.compiler.fork=true compile
```

### 3. 跳过不必要的步骤

```bash
# 只编译，不打包
ant compile

# 跳过测试
ant -DskipTests=true build
```

### 4. 使用 Ivy 管理依赖

```xml
<!-- ivy.xml -->
<ivy-module version="2.0">
    <dependencies>
        <dependency org="org.slf4j" name="slf4j-api" rev="1.7.25"/>
        <dependency org="com.google.guava" name="guava" rev="28.0-jre"/>
    </dependencies>
</ivy-module>
```

---

## 🎯 实践项目

### 初级项目：成功编译服务器
```
任务：编译所有服务器模块
步骤：
1. 配置环境
2. 运行 ant build
3. 解决编译错误
4. 验证输出
```

### 中级项目：添加新的构建任务
```
任务：添加代码质量检查任务
要求：
- 集成 Checkstyle
- 在编译前运行检查
- 生成报告
```

### 高级项目：优化构建流程
```
任务：减少构建时间 50%
要求：
- 分析当前构建瓶颈
- 实施增量编译
- 添加并行构建
- 记录优化效果
```

---

## 📚 推荐资源

### 官方文档
- [Apache Ant Manual](https://ant.apache.org/manual/)
- [Ant Task Reference](https://ant.apache.org/manual/tasksoverview.html)

### 项目文档
- [Java 开发](java-development.md)
- [gnet 框架](gnet-framework.md)

---

## ✅ 技能检查清单

### 初级检查点
- [ ] 成功安装 JDK 和 Ant
- [ ] 能够运行基本 Ant 命令
- [ ] 能够编译服务器项目
- [ ] 能够解决常见错误
- [ ] 理解构建流程

### 中级检查点
- [ ] 理解 build.xml 结构
- [ ] 能够修改构建配置
- [ ] 理解 rpcgen 流程
- [ ] 理解 xbean 流程
- [ ] 能够添加新任务

### 高级检查点
- [ ] 能够优化构建性能
- [ ] 能够创建自定义任务
- [ ] 能够维护构建系统
- [ ] 能够排查复杂问题
- [ ] 能够指导他人

---

## 变更日志

### v1.0.0 (2025-11-24)
- 初始版本
- 包含 Ant 基础、MT3 构建流程
- 添加 rpcgen 和 xbean 详解
- 添加常见错误解决方案

---

**相关技能**:
- [Java 开发](java-development.md)
- [gnet 框架](gnet-framework.md)
- [分布式架构](distributed-arch.md)

**下次更新**: 2026-02-24
