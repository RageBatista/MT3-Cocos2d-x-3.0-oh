---
name: encoding-bom-guard
description: "MT3 文本编码、BOM 和换行保护技能。处理中文文件、历史 C++ 源码、PowerShell 脚本、Markdown 文档或任何可能出现乱码和 BOM 漂移的编辑任务时使用；它是编辑守卫，不负责业务逻辑判定。"
---

先确认原文件编码，再修改；默认目标不是“统一转成某种编码”，而是“保持原编码、BOM 和换行稳定”。

## 何时使用

- 修改含中文内容的源码、脚本、文档或配置文件
- 处理 `.rc`、历史 `CP936/ANSI`、`UTF-16` 或混合编码目录中的文件
- 需要确认 PowerShell 文本读写不会破坏 BOM 与换行

## 不使用

- 仅做运行逻辑分析、调用链梳理或配置路由判断而没有文件写回时，不需要优先加载本技能
- 命中文件属于生成代码边界时，先用 `generated-code-guard` 判断是否允许改动

## 输入校验

- 先确认目标文件路径、原始编码、BOM、换行风格和是否含中文
- 先确认文件是否属于 `client/MT3Win32App/**`、`cocos2d-2.0-rc2-x-2.0.1/**`、`dependencies/**` 等混合编码目录
- 先确认本轮是“新增文件”还是“修改已有文件”

## 强制规则

- 修改已有文件时，优先保持原编码、原 BOM 和原换行符。
- `.rc` 文件必须先探测编码；Win32 客户端/工具主线 `.rc` 优先接受 `UTF-16 LE with BOM`，不要一律改成 `UTF-8 BOM`。
- `client/MT3Win32App/**`、`cocos2d-2.0-rc2-x-2.0.1/**`、`dependencies/**` 含历史混合编码文件，禁止按扩展名一刀切转码。
- `client/FireClient/Application/**`、`engine/**` 的 C/C++ 文件新增或收敛时可优先落到 `UTF-8 BOM`，但修改既有文件仍以保持原编码为先。
- **凡是交给 VS2013/cl.exe 编译、且包含中文或其他非 ASCII 字符的 C/C++ 源文件，必须保留 `UTF-8 with BOM`；不要误写成 `UTF-8 no BOM`。**
- VS2013 在读取无 BOM 的 UTF-8 中文源码时，可能按 `CP936/GBK` 解码，触发 `C2001: 常量中有换行符` 等伪字符串错误。
- `.lua/.java/.md/.xml/.json/.ps1/.yml/.yaml` 新建文件默认 `UTF-8 无 BOM`；修改既有文件时仍先看原编码。
- 修改前先看 BOM，修改后再回读字节。
- 保持原换行风格，不做无关整文件重写。

### VS2013 C2001 经验教训

若同时出现以下现象：

- C/C++ 文件包含中文字符串
- hex 检查字符串完整、没有物理换行
- VS2013 仍报 `error C2001: 常量中有换行符`

优先判断为 **BOM 丢失导致 cl.exe 误解码**，而不是直接判断为字符串内容断裂。

推荐恢复方式：

```powershell
$enc = New-Object System.Text.UTF8Encoding($true)
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($path, $text, $enc)
```

## 推荐检查

- `Format-Hex -Path <file> -Count 4`
- `Get-Content -Raw -Encoding UTF8 <file>`
- `Format-Hex -Path <file> -Count 16`
- `Get-Content -Encoding UTF8 -TotalCount 20 <file>`
- 快速探测脚本：

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\encoding-bom-guard\scripts\detect-file-encoding.ps1 -Path "<file>"
```
- 需要供后续脚本或审计链直接消费时，可追加 `-Json`
- 无法确认编码时，先停在探测阶段，不直接写回。

## 失败处理

- 若 `UTF8` 严格读取失败，不要猜测式写回；先回退到编码探测或请求进一步确认
- 若回读出现 `�`、`ï»¿`、`锟斤拷` 等异常字符，立即停止后续改动并恢复原文件

## 输出与验证

- 输出至少包含：原编码、原 BOM、回写方式、回读校验结果
- 对 `.rc`、历史 C++、PowerShell 脚本和中文文档，必须做字节级回读或 BOM 校验
- 快速探测脚本固定输出 `STATUS/SUMMARY/DETAIL/NEXT`，其中 `apply_patch_safe=false` 时不得直接 `apply_patch`
- 若需要机器可读结果，优先使用 `detect-file-encoding.ps1 -Json`

## 资源与上下文预算

- 默认只读目标文件本身和直接相关的编码规则文档
- 不为单文件编码判断批量展开整个仓库的长文规则

## 深度参考

- `AGENTS.md`
- `.claude/hooks/post-edit-encoding-reminder.ps1`
- `.claude/RULES.md`
