# 编译工具链规则

> **优先级**: 🔴 强制性 (不可违背)
> **适用范围**: 所有代码修改和编译操作

---

## Windows 客户端

### 强制配置

```xml
<!-- ✅ 正确配置 -->
<PlatformToolset>v120</PlatformToolset>
<CharacterSet>Unicode</CharacterSet>
<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>  <!-- Release: /MD -->
<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>  <!-- Debug: /MDd -->
```

### 禁止配置

```yaml
❌ 绝对禁止:
  - v140 (VS2015)
  - v141 (VS2017)
  - v142 (VS2019)
  - v143 (VS2022)

原因:
  - FireClient.lib 为 v120 预编译库
  - v140+ 与 v120 存在 ABI 不兼容
  - 使用其他工具集会导致链接错误或运行时崩溃
```

### 验证方法

```batch
:: 检查项目工具集
findstr /i "PlatformToolset" *.vcxproj

:: 检查库文件
dumpbin /HEADERS FireClient.lib | findstr "linker version"
```

---

## Android 客户端

### 强制配置

```bash
# ✅ 正确配置
NDK_VERSION=r16 (16.1.4479499)
ANDROID_API_LEVEL=22
ABI=arm64-v8a
TOOLCHAIN=Clang
BUILD_SYSTEM="NDK Build + Apache Ant"
```

### 禁止配置

```yaml
❌ 绝对禁止:
  - NDK r10e/GCC 或 r21+ 等未验证版本 (ABI 不兼容)
  - Gradle 构建系统 (历史架构不支持)
  - 回退到 armeabi 或仅靠历史 v7a/GCC 产物打包
```

### 验证方法

```bash
# 检查 NDK 版本
ndk-build --version

# 检查构建配置
cat jni/Application.mk | grep APP_ABI
```

---

## 服务器端

### 强制配置

```bash
# ✅ 正确配置
JDK_VERSION=1.7+  # 推荐 1.8
ANT_VERSION=1.9+
BUILD_SYSTEM="Apache Ant"
```

### 禁止配置

```yaml
❌ 绝对禁止:
  - JDK 9+ (模块系统不兼容)
  - Maven (项目使用 Ant)
  - Gradle (项目使用 Ant)
```

### 验证方法

```bash
# 检查 JDK 版本
java -version

# 检查 Ant 版本
ant -version
```

---

## 错误码速查

| 错误码 | 含义 | 可能原因 |
|--------|------|----------|
| LNK2001 | 无法解析外部符号 | 工具集版本不匹配 |
| LNK2019 | 无法解析外部符号 | 缺少库文件或版本错误 |
| LNK2038 | RuntimeLibrary 不匹配 | /MD 与 /MT 混用 |
| C1083 | 无法打开包含文件 | 头文件路径配置错误 |

---

**相关文档**:
- [编译完整指南](../../docs/03-开发指南/02-Windows完整构建指南.md)
- [Android 编译指南](../../docs/05-平台专项/android/00-README.md)
- [构建故障排查](../skills/common/build-troubleshooting.md)
