# 命令速查卡片 (Quick Command Reference)

> **版本**: 1.1 | **更新**: 2026-01-08

---

## 🆕 快速构建脚本 (推荐)

```bash
# 环境设置 (首次使用)
setup-env.bat

# 客户端编译
build-client-debug.bat     # Debug 版本
build-client-release.bat   # Release 版本

# 服务器编译
build-server.bat           # 编译服务器
```

**优势**: 自动验证环境、多核编译、错误提示

---

## 🚀 构建命令

### Windows 客户端编译

```bash
# 使用快捷脚本 (推荐)
build-client-debug.bat
build-client-release.bat

# 使用 Claude 命令
/build-win Debug
/build-win Release

# 完整命令 (MSBuild直接调用)
msbuild client/MT3Win32App/mt3.win32.vcxproj /p:Configuration=Debug /p:Platform=Win32 /p:PlatformToolset=v120 /m
```

**常用参数**:
- `/p:Configuration=Debug|Release` - 构建配置
- `/p:Platform=Win32` - 目标平台
- `/p:PlatformToolset=v120` - 工具集版本 (必须)
- `/v:minimal|normal|detailed` - 日志详细度
- `/m` - 多核并行编译

---

### CEGUI 编译

```bash
# 推荐：直接调用 MSBuild 构建 CEGUIBase
"C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" "E:\MT3\tools\CEGUI-0.7.9-r5\projects\premake\BaseSystem\CEGUIBase.vcxproj" /t:Build /p:Configuration=Debug /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo
"C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" "E:\MT3\tools\CEGUI-0.7.9-r5\projects\premake\BaseSystem\CEGUIBase.vcxproj" /t:Build /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo
```

**关键点**:
- 必须使用 v120 工具集
- 先编译 Debug 再编译 Release
- 验证生成的 lib 文件大小 (~2.7 MB)

---

### Android 客户端编译

```bash
# 使用快捷命令
/build-android

# 手动编译流程
cd client/android/LocojoyProject
ndk-build clean
ndk-build
ant clean release

# 签名APK
jarsigner -verbose -keystore mt3.keystore -signedjar signed.apk unsigned.apk mt3
```

**环境要求**:
- NDK r16 clang (16.1.4479499，必须)
- Ant 1.9+
- JDK 1.8

---

### 服务器编译

```bash
# 编译单个服务
/build-server game_server

# 编译所有服务
cd server
./build-all.sh

# 编译特定模块
cd server/tools/jgs
ant clean jar
```

**常用模块**:
- `game_server` - 游戏逻辑服务
- `gate_server` - 网关服务
- `zone_server` - 区域场景服务
- `jgs` - 公共工具库

---

## 🔧 代码生成命令

### xbean 生成

```bash
# 使用快捷命令
/codegen xbean

# 手动生成
cd server/tools/jgs
ant xbean

# 验证生成结果
ls -la gnet/xbean/  # 检查生成的 .java 文件
```

**生成路径**: `server/**/xbean/*.java`

---

### gnet 协议生成

```bash
# 使用快捷命令
/codegen gnet

# 手动生成
cd server/tools/jgs
ant gnet

# 验证生成结果
ls -la gnet/protocol/  # 检查生成的 RPC 文件
```

**生成路径**: `server/**/rpc/*.java`

---

### tolua++ 绑定生成

```bash
# 生成 C++/Lua 绑定
cd client/tolua++-pkgs
./generate.sh  # Linux/Mac
generate.bat   # Windows

# 验证生成结果
ls -la client/FireClient/*_tolua.cpp
```

**生成路径**: `client/**/*_tolua.cpp`

---

## 🧹 清理命令

### 清理编译产物

```bash
# 使用快捷命令
/clean

# 手动清理 Windows
msbuild client/MT3Win32App/mt3.win32.vcxproj /t:Clean /p:Configuration=Debug
msbuild client/MT3Win32App/mt3.win32.vcxproj /t:Clean /p:Configuration=Release

# 手动清理 Android
cd client/android/LocojoyProject
ndk-build clean
ant clean

# 手动清理服务器
cd server
./clean-all.sh
```

**清理范围**:
- ✅ .obj, .pch, .ilk, .pdb 中间文件
- ✅ bin/, obj/, build/ 输出目录
- ❌ 不删除依赖库 (dependencies/)

---

## 🔍 诊断命令

### 构建诊断

```bash
# 使用快捷命令
/diagnose-build

# 手动诊断流程
1. 读取最新编译日志
2. 提取错误码 (LNK****, C****, MSB****)
3. 参考 .claude/errors/ 文档
4. 提供修复建议
```

---

### 项目状态查看

```bash
# 使用快捷命令
/status

# 手动查看
git status
git branch
git log -5 --oneline
```

---

## 🛠️ Git 命令

### 常用 Git 操作

```bash
# 查看状态
git status

# 提交修改
git add .
git commit -m "feat: 添加xxx功能"

# 推送代码
git push origin feature/xxx

# 切换分支
git checkout -b feature/xxx

# 查看日志
git log --oneline --graph --all -10
```

**提交规范**:
- `feat:` - 新功能
- `fix:` - Bug 修复
- `refactor:` - 代码重构
- `docs:` - 文档更新
- `chore:` - 构建/工具变更

---

## 🔧 MSBuild 常用选项

### 编译选项

```bash
/t:Build              # 构建 (默认)
/t:Rebuild            # 重新构建
/t:Clean              # 清理
/t:Build;Test         # 多目标

/p:Configuration=Debug|Release
/p:Platform=Win32|x64
/p:PlatformToolset=v120|v140|v141

/v:quiet              # 最小输出
/v:minimal            # 最少输出
/v:normal             # 正常输出
/v:detailed           # 详细输出
/v:diagnostic         # 诊断输出

/m                    # 多核并行
/m:4                  # 使用4核

/fl                   # 输出到日志文件
/flp:LogFile=build.log;Verbosity=detailed
```

---

## 🐛 调试命令

### Visual Studio 调试

```bash
# 启动调试
F5                    # 开始调试
Ctrl+F5               # 不调试运行
F9                    # 设置断点
F10                   # 单步跳过
F11                   # 单步进入
Shift+F11             # 跳出

# 查看变量
鼠标悬停             # 快速查看
添加监视             # 持续监视
即时窗口             # 执行表达式
```

---

### GDB 调试 (Linux)

```bash
# 启动调试
gdb ./mt3_server

# 常用命令
(gdb) break main
(gdb) run
(gdb) next           # 单步跳过
(gdb) step           # 单步进入
(gdb) print var      # 打印变量
(gdb) backtrace      # 查看调用栈
(gdb) quit           # 退出
```

---

## 📊 性能分析

### 客户端性能分析

```bash
# Visual Studio Profiler
分析 → 性能探查器 → CPU 使用率

# 内存泄漏检测
_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
```

---

### 服务器性能分析

```bash
# JProfiler
jprofiler                      # 启动 JProfiler
连接到 Java 进程 → 分析

# jstack (线程分析)
jstack <pid> > threads.txt

# jmap (堆分析)
jmap -dump:format=b,file=heap.bin <pid>
```

---

## 🔑 快捷键速查

### Visual Studio

| 快捷键 | 功能 |
|-------|------|
| Ctrl+Shift+B | 生成解决方案 |
| F7 | 生成项目 |
| Ctrl+F5 | 运行 (不调试) |
| F5 | 调试运行 |
| Ctrl+K, Ctrl+C | 注释代码 |
| Ctrl+K, Ctrl+U | 取消注释 |
| Ctrl+. | 快速操作 |
| F12 | 转到定义 |
| Ctrl+F12 | 转到实现 |

---

### Eclipse/IntelliJ IDEA

| 快捷键 | 功能 |
|-------|------|
| Ctrl+B | 生成项目 |
| Shift+F10 | 运行 |
| Shift+F9 | 调试 |
| Ctrl+/ | 注释/取消注释 |
| Ctrl+Space | 代码补全 |
| Ctrl+Click | 转到定义 |
| Alt+F7 | 查找用法 |

---

**文档版本**: 1.0
**最后更新**: 2026-01-07
**维护**: MT3 开发团队
