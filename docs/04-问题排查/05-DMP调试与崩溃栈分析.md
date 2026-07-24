# 05-DMP 调试与崩溃栈分析

> **适用范围**：使用 VS2013 分析 MT3 Win32 `.dmp`，重点确认匹配符号、提取调用栈并区分空指针、越界、释放后使用和 ABI 混编。构建入口与完整依赖链见 [Windows 完整构建指南](../03-开发指南/02-Windows完整构建指南.md)。

## 1. 收集前提

分析前保存同一次构建/崩溃的完整证据：

| 证据 | 要求 |
| --- | --- |
| DMP | 崩溃进程生成的原始 `.dmp` |
| EXE/DLL | DMP 中实际加载的 `MT3.exe` 与相关 DLL |
| PDB | 与上述二进制同一次构建生成的 PDB |
| 日志 | 崩溃时间附近的 MT3、CEGUI、Lua 与启动日志 |
| 构建信息 | Git commit、配置、Win32、v120、构建命令和时间戳 |
| 复现信息 | 操作步骤、账号/场景占位信息、是否 fresh process、发生频率 |

Win32 入口在 `client/MT3Win32App/main.cpp` 中以日期/时间生成 DMP 文件名，并把文件写到进程当前工作目录。若从 `client/resource/bin/Release` 启动，优先在该目录查找：

```powershell
Get-ChildItem .\client\resource\bin\Release -Filter '*.dmp' | Sort-Object LastWriteTime -Descending
Get-ChildItem .\client\resource\bin\Release\* -Include '*.exe','*.dll','*.pdb' -File | Sort-Object Name
```

不要使用后来重编产生的同名 PDB 覆盖崩溃时的符号包。

## 2. VS2013 打开 DMP

1. 启动 Visual Studio 2013；
2. 选择“文件 -> 打开 -> 文件”，打开目标 `.dmp`；
3. 在 dump 摘要页选择“使用仅本机进行调试”；
4. 记录异常代码、异常地址、崩溃线程和初始模块名。

常见异常代码：

| 异常 | 含义 |
| --- | --- |
| `0xC0000005` | 访问冲突，需区分读/写/执行与目标地址 |
| `0xC0000374` | Windows heap corruption，崩溃点可能晚于破坏点 |
| `0xC0000409` | 栈缓冲区/快速失败类异常 |

## 3. 配置符号

在“工具 -> 选项 -> 调试 -> 符号”中添加：

1. 本次构建的 EXE/DLL/PDB 归档目录；
2. 本地缓存目录，例如 `C:\Symbols`；
3. 需要系统符号时添加 `SRV*C:\Symbols*https://msdl.microsoft.com/download/symbols`。

本地项目符号应优先于公共符号服务器。不要把多个不同构建的 PDB 目录同时加入搜索路径。

## 4. 验证 PDB 是否匹配

打开“调试 -> 窗口 -> 模块”，对 `MT3.exe` 和崩溃相关 DLL 逐个检查：

- 模块路径是否为崩溃时实际加载路径；
- 时间戳、映像大小是否与保存的二进制一致；
- 符号状态是否为“已加载符号”；
- “符号加载信息”中是否明确使用本次归档 PDB。

若显示“不匹配符号”，结论只能是当前 PDB 不能解释该模块，不要强制加载后继续定因。回到构建归档查找同一次构建的 PDB/二进制组合。

可用 PowerShell 先核对文件元数据与哈希：

```powershell
Get-Item DUMP, MT3_EXE, MODULE_DLL, MODULE_PDB | Select-Object FullName, Length, LastWriteTimeUtc
Get-FileHash MT3_EXE, MODULE_DLL, MODULE_PDB -Algorithm SHA256
```

## 5. 提取调用栈

1. 切换到异常线程；
2. 打开“调试 -> 窗口 -> 调用堆栈”；
3. 关闭“仅显示我的代码”，保留系统/第三方帧；
4. 从异常帧向上寻找第一个有符号的 MT3/FireClient/engine/Cocos 帧；
5. 双击关键帧查看源代码或反汇编；
6. 打开寄存器、内存和局部变量窗口，记录访问地址与相关参数；
7. 复制完整栈文本，不只截图最上面三帧。

建议报告格式：

```text
异常代码: EXCEPTION_CODE
异常地址: ADDRESS
崩溃线程: THREAD_ID
崩溃模块: MODULE!FUNCTION+OFFSET
访问类型: read / write / execute
访问目标: TARGET_ADDRESS
第一项目帧: PROJECT_MODULE!PROJECT_FUNCTION+OFFSET
完整调用栈:
  FRAME_0
  FRAME_1
  ...
```

## 6. 常见诊断模式

### 空指针或近空地址

- 访问地址接近 `0x00000000`；
- 检查异常帧寄存器、`this`、返回对象和资源查找结果；
- 回看上游为什么允许空对象进入该路径，而不是只在崩溃点加判空。

### 越界或释放后使用

- 访问地址随机、已填充模式或对象字段明显损坏；
- 检查容器边界、迭代器、引用计数、线程并发和生命周期；
- heap corruption 的实际写坏点通常早于异常点，需要结合日志、数据断点或最小复现继续追踪。

### 符号缺失

- 先确保 EXE/DLL 本身与 dump 匹配；
- 再找同一次构建 PDB；
- 只有系统模块使用公共符号服务器；
- 不能根据无符号偏移直接下业务根因结论。

### 调用栈为空或断裂

- 确认 DMP 不是损坏/零字节文件；
- 确认选择了正确线程和本机调试；
- 检查栈内存是否被覆盖；
- 结合反汇编、寄存器和模块基址计算偏移；
- 下次复现时保留更完整的 dump、日志和同构建符号。

### ABI 混编

若 fresh process 初始化期在 STL 容器或 `this + offset` 访问处崩溃，并且调用方/被调方对同名类型的对象大小或成员偏移不同，优先按 ABI 混编处理：

- `engine` 公共 ABI 变化：`Rebuild engine -> Rebuild FireClient -> Build MT3`；
- `FireClient` 公共 ABI 变化：`Rebuild FireClient -> Build MT3`；
- 核对所有产物均为 VS2013/`v120`/Win32 和同一配置；
- 核对 `engine.lib`、`FireClient.lib`、`MT3.exe` 的时间戳与构建顺序。

## 7. 日志与时间线

从 DMP 的修改时间向前后扩展一个小窗口，检索首个异常：

```powershell
$dump = Get-Item DUMP
Get-ChildItem RUNTIME_DIR -File |
    Where-Object { $_.Extension -in '.log', '.txt', '.json' } |
    Sort-Object LastWriteTime

rg -n 'ERROR|FATAL|exception|assert|failed|LUA ERROR|CEGUI' RUNTIME_DIR
```

先记录崩溃前最后一个成功阶段和首个错误，再分析后续级联日志。

## 8. 样本说明

历史文档曾使用 `client/resource/bin/Release/28_11_39_45.dmp` 与 `libcocos2d.pdb` 说明 VS2013 操作。该路径只代表一次 2026-01 样本，不是固定输入；每次分析都应替换为本次 DMP 和匹配符号包。

## 9. 调试报告模板

```yaml
问题现象: null
复现步骤: null
Git提交: null
配置: Release|Win32
工具链: VS2013/v120/Windows SDK 8.1
构建入口: tools/scripts/Build-MT3-Exe-Canonical.ps1
DMP: null
EXE_DLL_PDB归档: null
异常代码: null
异常地址: null
符号状态: null
第一项目帧: null
完整调用栈: |
  STACK_TEXT
首个日志错误: null
根因判断: null
修复点: null
验证方式: null
```

修复后应保留新的构建产物、PDB 和验证结果；若问题属于构建/ABI，回链 [Windows 构建前检查清单](../03-开发指南/03-Windows构建前检查清单.md)。
