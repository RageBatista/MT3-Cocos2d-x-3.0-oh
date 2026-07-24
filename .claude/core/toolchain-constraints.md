# 工具链强制约束

> **版本**: 1.0 | **状态**: 🔴 强制执行

---

## ⚠️ 关键约束速查表

| 平台 | 工具链 | 版本 | 状态 |
|------|--------|------|------|
| **Windows 客户端** | Visual Studio | 2013 (v120) | ✅ 必须 |
| **Android 客户端** | NDK | r16 clang (16.1.4479499) | ✅ 必须 |
| **Android 构建** | Ant | 1.9+ | ✅ 必须 |
| **服务器 Java** | JDK | 1.8 | ✅ 必须 |
| **服务器构建** | Apache Ant | 1.9+ | ✅ 必须 |


## 🚫 禁止使用

### Windows 平台

```yaml
禁止工具集:
  - v140 (VS2015)
  - v141 (VS2017)
  - v142 (VS2019)
  - v143 (VS2022)

原因: FireClient.lib 为 v120 预编译，ABI 不兼容
后果: LNK2001/LNK2019 链接错误，运行时崩溃
```

### Android 平台

```yaml
禁止:
  - NDK r10e/GCC 或 r21+ 等未验证版本
  - Gradle 构建系统
  - CMake 构建

原因: 项目历史架构，迁移风险极高
```

### 服务器平台

```yaml
禁止:
  - JDK 9+ (模块系统不兼容)
  - Maven / Gradle

原因: gnet 框架与新版 JDK 不兼容
```

---

## 📦 预编译库清单

以下库**禁止重新编译或替换**：

```
client/
├── FireClient/FireClient.lib      # v120
├── libcocos2d/libcocos2d.lib      # v120
└── libCocosDenshion/              # v120

common/
└── platform/*.lib                 # v120

dependencies/
└── cegui/**/*.lib                 # v120
```

---

## ✅ 验证命令

```powershell
# 检查 VS 工具集版本
Select-String -Path "*.vcxproj" -Pattern "PlatformToolset"

# 预期输出
<PlatformToolset>v120</PlatformToolset>
```

---

**详细规则**: [../RULES.md](../RULES.md#编译工具链)
**错误诊断**: [../errors/README.md](../errors/README.md)
