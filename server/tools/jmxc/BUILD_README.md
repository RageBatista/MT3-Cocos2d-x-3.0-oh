# jmxc 重新编译打包指南

**版本**: v1.0.0
**创建日期**: 2025-11-24
**适用范围**: jmxc 工具重新编译和打包

---

## 📋 目录

1. [快速开始](#快速开始)
2. [方法一：Windows 批处理脚本](#方法一windows-批处理脚本)
3. [方法二：Linux/Mac Shell 脚本](#方法二linuxmac-shell-脚本)
4. [方法三：Ant 构建](#方法三ant-构建)
5. [方法四：手动命令行](#方法四手动命令行)
6. [方法五：IDE 打包](#方法五ide-打包)
7. [验证和测试](#验证和测试)
8. [常见问题](#常见问题)

---

## 🚀 快速开始

### 前置要求

```bash
# 检查 Java 版本（需要 JDK 8 或更高）
java -version
javac -version

# 检查 jar 命令
jar --help
```

**最简单的方法（Windows）**：
```cmd
cd e:\MT3\server\tools\jmxc
build.bat
```

---

## 方法一：Windows 批处理脚本

### 使用步骤

```cmd
# 1. 进入项目目录
cd e:\MT3\server\tools\jmxc

# 2. 运行构建脚本
build.bat

# 3. 完成！新的 jar 文件生成为 jmxc-new.jar
```

### 输出示例

```
[1/4] 清理旧的编译文件...
[2/4] 编译 Java 源代码...
[3/4] 创建 MANIFEST.MF...
[4/4] 打包 JAR 文件...

============================================
构建成功！
新的 jar 文件: jmxc-new.jar
文件大小: 13,148 字节
============================================
```

---

## 方法二：Linux/Mac Shell 脚本

### 使用步骤

```bash
# 1. 进入项目目录
cd /path/to/MT3/server/tools/jmxc

# 2. 添加执行权限
chmod +x build.sh

# 3. 运行构建脚本
./build.sh

# 4. 完成！新的 jar 文件生成为 jmxc-new.jar
```

---

## 方法三：Ant 构建

### 前置要求

```bash
# 检查 Ant 是否安装
ant -version

# 如果未安装，Windows 可以使用 Chocolatey 安装
choco install ant

# Linux/Mac 使用包管理器
# Ubuntu/Debian: sudo apt-get install ant
# CentOS/RHEL: sudo yum install ant
# macOS: brew install ant
```

### 使用步骤

```bash
# 1. 进入项目目录
cd e:\MT3\server\tools\jmxc

# 2. 查看可用任务
ant -p

# 3. 执行构建（默认任务）
ant

# 或者指定任务
ant build    # 完整构建
ant clean    # 只清理
ant compile  # 只编译
ant jar      # 只打包
ant test     # 测试 jar 包内容
```

### Ant 任务说明

| 任务 | 说明 |
|-----|------|
| `ant clean` | 清理 bin 目录和旧的 jar 文件 |
| `ant init` | 初始化构建环境（创建目录） |
| `ant compile` | 编译 Java 源代码 |
| `ant jar` | 打包 JAR 文件 |
| `ant build` | 完整构建流程（默认） |
| `ant test` | 查看 jar 包内容 |

---

## 方法四：手动命令行

### 完整流程

```bash
# 1. 清理旧文件
cd e:\MT3\server\tools\jmxc
rmdir /s /q bin
del jmxc-new.jar
mkdir bin

# 2. 编译 Java 源代码
javac -d bin -encoding UTF-8 ^
  src\jmxc.java ^
  src\ConnectTask.java ^
  src\com\jmxservice\mt3interfaces\GameOnlineNumBean.java ^
  src\com\jmxservice\mt3interfaces\LogInfo.java

# 3. 创建 MANIFEST.MF
echo Manifest-Version: 1.0 > manifest.txt
echo Class-Path: . >> manifest.txt
echo Main-Class: jmxc >> manifest.txt
echo. >> manifest.txt

# 4. 打包 JAR
jar -cvfm jmxc-new.jar manifest.txt -C bin .

# 5. 清理临时文件
del manifest.txt
```

### 快捷方式（使用已有的 class 文件）

```bash
# 如果 bin 目录已经有编译好的 .class 文件
cd e:\MT3\server\tools\jmxc
jar -cvfm jmxc-new.jar META-INF\MANIFEST.MF -C bin .
```

---

## 方法五：IDE 打包

### Eclipse

1. **导入项目**
   - File → Import → Existing Projects into Workspace
   - 选择 `e:\MT3\server\tools\jmxc` 目录

2. **清理和构建**
   - Project → Clean
   - Project → Build Project

3. **导出 JAR**
   - 右键项目 → Export → Java → JAR file
   - 选择导出位置
   - 勾选 "Export generated class files and resources"
   - Next → Next
   - Main class: 选择 `jmxc`
   - Finish

### IntelliJ IDEA

1. **打开项目**
   - File → Open → 选择 `e:\MT3\server\tools\jmxc` 目录

2. **构建配置**
   - File → Project Structure → Artifacts
   - 点击 "+" → JAR → From modules with dependencies
   - Main Class: 选择 `jmxc`
   - OK

3. **构建 JAR**
   - Build → Build Artifacts → jmxc → Build
   - JAR 文件生成在 `out/artifacts/` 目录

### VS Code (with Java Extension Pack)

1. **打开项目**
   ```bash
   code e:\MT3\server\tools\jmxc
   ```

2. **安装扩展**
   - Java Extension Pack
   - Maven for Java（可选）

3. **运行构建任务**
   - Terminal → Run Task → 选择 Java 编译任务
   - 或使用命令面板：Java: Export Jar

---

## 验证和测试

### 1. 检查 JAR 包内容

```bash
# 列出 jar 包中的所有文件
jar -tf jmxc-new.jar

# 预期输出：
# META-INF/MANIFEST.MF
# ConnectTask.class
# jmxc$1.class
# jmxc$2.class
# jmxc$DaemonThreadFactory.class
# jmxc.class
# com/jmxservice/mt3interfaces/LogInfo.class
# com/jmxservice/mt3interfaces/GameOnlineNumBean.class
```

### 2. 查看 MANIFEST.MF

```bash
jar -xf jmxc-new.jar META-INF/MANIFEST.MF
type META-INF\MANIFEST.MF

# 预期输出：
# Manifest-Version: 1.0
# Class-Path: .
# Main-Class: jmxc
```

### 3. 测试运行

```bash
# 测试 1: 显示帮助信息（参数不足时）
java -jar jmxc-new.jar

# 预期输出：
# Usage:  java jmxc username password ip port function...

# 测试 2: 实际测试（需要有运行的服务器）
java -jar jmxc-new.jar "" "" "192.168.32.44" "1098" "GetMaxOnlineNum"
```

### 4. 对比新旧 JAR

```bash
# 对比文件大小
dir jmxc.jar jmxc-new.jar

# 对比文件内容
jar -tf jmxc.jar > old.txt
jar -tf jmxc-new.jar > new.txt
fc old.txt new.txt
```

---

## 🔧 修改和定制

### 修改源代码后重新打包

```bash
# 1. 修改源代码
# 编辑 src/jmxc.java 或其他 .java 文件

# 2. 重新编译打包
build.bat  # Windows
# 或
./build.sh # Linux/Mac
# 或
ant build  # Ant

# 3. 测试新功能
java -jar jmxc-new.jar [参数...]
```

### 添加新功能示例

假设你想添加一个新的 GM 命令：

```java
// 1. 编辑 src/jmxc.java
public String myNewCommand() throws Exception {
    Object result = invokeWithTimeout(
        this.connector,
        "gs.counter:type=MyNewBean",
        "execute",
        new Object[0],
        new String[0]
    );
    return (String)result;
}

// 2. 在 main 方法中添加命令处理
if (str5.equals("myNewCommand")) {
    try {
        String result = localjmxc.myNewCommand();
        System.out.println(result);
    } catch (Exception e) {
        System.out.println("0");
    }
}

// 3. 重新编译打包
build.bat
```

---

## ❓ 常见问题

### Q1: 编译时报错 "javac 不是内部或外部命令"

**解决方案**：
```bash
# 检查 JDK 是否安装
java -version

# 设置 JAVA_HOME 环境变量
# Windows: 控制面板 → 系统 → 高级系统设置 → 环境变量
# 添加: JAVA_HOME = C:\Program Files\Java\jdk1.8.0_144
# 添加到 Path: %JAVA_HOME%\bin
```

### Q2: 打包后的 jar 文件无法运行

**解决方案**：
```bash
# 检查 MANIFEST.MF 中的 Main-Class
jar -xf jmxc-new.jar META-INF/MANIFEST.MF
type META-INF\MANIFEST.MF

# 确保包含:
# Main-Class: jmxc

# 如果缺失，手动创建并重新打包
```

### Q3: 编译时出现编码错误

**解决方案**：
```bash
# 使用 UTF-8 编码编译
javac -encoding UTF-8 -d bin src/*.java

# 或修改 build.bat，确保包含 -encoding UTF-8
```

### Q4: jar 包大小不一致

**原因**：
- 不同的 JDK 版本可能生成略有不同的 class 文件
- MANIFEST.MF 格式差异
- 文件顺序不同

**验证**：
```bash
# 对比内容而非大小
jar -tf jmxc.jar | sort > old.txt
jar -tf jmxc-new.jar | sort > new.txt
fc old.txt new.txt
```

### Q5: 使用 Ant 时报错 "找不到 build.xml"

**解决方案**：
```bash
# 确保在正确的目录
cd e:\MT3\server\tools\jmxc

# 确保 build.xml 存在
dir build.xml

# 指定构建文件
ant -f build.xml
```

---

## 📚 参考资源

### 官方文档
- [Java JAR 文件规范](https://docs.oracle.com/javase/8/docs/technotes/guides/jar/jar.html)
- [Apache Ant 手册](https://ant.apache.org/manual/)

### 相关工具
- **JDK**: Java Development Kit
- **Ant**: Apache Ant 构建工具
- **Maven**: 项目管理工具（可选）
- **Gradle**: 现代构建工具（可选）

---

## 🎯 最佳实践

### 1. 版本管理

```bash
# 使用版本号命名
jmxc-v1.0.0.jar
jmxc-v1.1.0.jar

# 或使用日期
jmxc-20251124.jar
```

### 2. 备份原始文件

```bash
# 重新打包前先备份
copy jmxc.jar jmxc.jar.bak
# 或
cp jmxc.jar jmxc.jar.bak
```

### 3. 测试环境验证

```bash
# 先在测试环境验证新的 jar 包
java -jar jmxc-new.jar "" "" "test-server" "1098" "keepAlive"

# 确认无误后再部署到生产环境
```

### 4. 文档化修改

```bash
# 在 CHANGELOG.md 中记录修改
# v1.1.0 (2025-11-24)
# - 添加新的 GM 命令 XXX
# - 修复超时问题
# - 优化连接逻辑
```

---

**维护者**: 技术委员会
**创建日期**: 2025-11-24
**下次更新**: 根据需要
