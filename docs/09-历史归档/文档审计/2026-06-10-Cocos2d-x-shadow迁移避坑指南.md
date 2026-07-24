# Cocos2d-x 2.2.6 shadow 迁移避坑指南

> 日期：2026-06-10
> 适用范围：Cocos2d-x 2.0 -> 2.2.6 shadow 迁移、CEGUI 0.7.1 shadow 工程重建、CRT/编码治理、vendor 快照入库、Release 或主工程接入前检查。
> 权威顺序：工程文件与日志 > 根/就近 `AGENTS.md` > `.claude/RULES.md` > `.claude/BUILD_GUIDE.md` > `.codex` sidecar > 本指南。

## 1. 迁移任务首检模板

任何迁移任务开始前先执行：

```powershell
git rev-parse --show-toplevel
git branch --show-current
git status --short --branch
git config --get core.autocrlf
```

如果任务涉及 sparse worktree，再执行：

```powershell
git config --get core.sparseCheckout
git config --get core.sparseCheckoutCone
git sparse-checkout list
```

输出中必须写明当前是：

- `E:\MT3` 主线工作树；还是
- `E:\MT3-c226-shadow` / 其他 shadow worktree。

## 2. 架构心智模型

MT3 当前运行时按四层理解：

```text
平台层 Win32/Android/iOS
  -> Cocos2d-x 2.0 基础层
  -> Nuclear 引擎层
  -> FireClient 业务层
```

迁移时不要把这四层混成一个“引擎升级”问题：

| 层级 | 主要路径 | 迁移关注点 |
| --- | --- | --- |
| 平台层 | `client/MT3Win32App`, `client/android`, iOS 工程 | 入口、生命周期、JNI/ObjC++/Win32 桥接、SDK |
| Cocos2d-x | `cocos2d-2.0-rc2-x-2.0.1`, `cocos2d-x-2.2.6-mt3` | 渲染基础、资源访问、平台适配、ABI |
| Nuclear | `engine` | 场景、精灵、动画、特效、渲染组织 |
| FireClient | `client/FireClient`, Lua/UI 资源 | 登录、入世界、UI、网络、业务流程 |

CEGUI 0.7.1 横跨工具链和运行时：

- `tools/CEGUI-0.7.1`：vendor 源码、工程、绑定工具和重建依赖；
- `client/resource/res/ui`：运行时布局、scheme、imageset、looknfeel、font；
- Cocos/Nuclear/FireClient：资源提供器、渲染器、UI 管理和事件链。

## 3. CEGUI vendor 快照入库门禁

### 3.1 必须放行的范围

```text
tools/CEGUI-0.7.1/cegui/**
tools/CEGUI-0.7.1/dependencies/include/**
tools/CEGUI-0.7.1/dependencies/bin/**
tools/CEGUI-0.7.1/dependencies/lib/**
tools/CEGUI-0.7.1/projects/**
tools/CEGUI-0.7.1/configure.ac
tools/CEGUI-0.7.1/Makefile.am
```

### 3.2 必须继续忽略的范围

```text
tools/CEGUI-0.7.1/shadow-build/
tools/CEGUI-0.7.1/lib/
tools/CEGUI-0.7.1/**/obj/
tools/CEGUI-0.7.1/**/Debug*/
tools/CEGUI-0.7.1/**/Release*/
tools/CEGUI-0.7.1/**/*.pdb
tools/CEGUI-0.7.1/**/*.idb
tools/CEGUI-0.7.1/**/*.ilk
tools/CEGUI-0.7.1/**/*.tlog
tools/CEGUI-0.7.1/**/*.lastbuildstate
tools/CEGUI-0.7.1/**/._*
tools/CEGUI-0.7.1/**/.DS_Store
```

### 3.3 推荐验证命令

```powershell
$versionable = @(git ls-files --others --exclude-standard -- 'tools/CEGUI-0.7.1')
$ignored = @(git ls-files --others -i --exclude-standard -- 'tools/CEGUI-0.7.1')
[pscustomobject]@{
  VersionableCount = $versionable.Count
  IgnoredCount = $ignored.Count
  AppleDoubleVersionable = @($versionable | Select-String -Pattern '/\._').Count
  AppleDoubleIgnored = @($ignored | Select-String -Pattern '/\._').Count
} | Format-List
```

```powershell
$dry = @(git add -n -- 'tools/CEGUI-0.7.1' 2>&1)
$bad = @($dry | Select-String -Pattern 'shadow-build|tools/CEGUI-0.7.1/lib/|/\._|\.DS_Store')
if ($bad.Count) { $bad | Select-Object -First 20 } else { 'NO_BAD_OUTPUTS_IN_DRY_RUN' }
```

真实 `git add` 前必须确认 `git add -n` 无 outside sparse warning、无 bad path。

## 4. sparse-checkout 处理

如果 dry-run 出现 sparse 拦截，先取证：

```powershell
git sparse-checkout list
git config --get core.sparseCheckout
git config --get core.sparseCheckoutCone
```

非 cone 模式下可按当前 worktree 策略加入：

```powershell
git sparse-checkout add 'tools/CEGUI-0.7.1/**'
```

注意：`git sparse-checkout add --no-cone` 在部分 Git 版本中不是有效选项，不要照搬未验证命令。

## 5. 行尾与编码门禁

本仓库 Windows 环境常见 `core.autocrlf=true`。入库前确认：

```powershell
git check-attr -a -- 'tools/CEGUI-0.7.1/cegui/include/CEGUI.h'
git check-attr -a -- 'tools/CEGUI-0.7.1/dependencies/lib/dynamic/lua.lib'
git check-attr -a -- 'docs/03-开发指南/Cocos2d-x-2.2.6-shadow迁移避坑指南-2026-06-10.md'
```

期望：

- CEGUI vendor 文本：`text: unset`，保留原始字节；
- `.dll/.exe/.lib/.exp`：`binary: set`；
- `.codex/**` 与 `docs/**/*.md`：`text eol=lf`。

文档写回后必须验证：

```powershell
Format-Hex -Path <file> -Count 8
Get-Content -Encoding UTF8 -TotalCount 20 <file>
```

## 6. 索引操作顺序

禁止并行执行以下命令：

```text
git reset
git add
git diff --cached
git status
```

推荐顺序：

```powershell
git add -- <paths>
git diff --cached --check -- <governance-docs>
git diff --cached --name-only -- <paths>
git status --short --branch -- <paths>
```

说明：不要对 vendor 源码运行全量 `git diff --cached --check` 后强行格式化；vendor 的历史尾随空白和 EOF 状态应保持原样。

## 7. CRT/编码治理进入 Release 或主工程前的要求

shadow gate 通过后，进入 Release 或主工程接入前必须单独治理：

1. `LNK4098` / CRT 冲突；
2. `C4819` / 源码编码告警；
3. VS2013 下含中文 C/C++ 源文件的 UTF-8 BOM；
4. Debug/Release 两套配置的一致性；
5. 产物链是否从 `libcocos2d -> platform/ljfm -> CEGUIBase -> 下游` 顺序刷新；
6. 是否存在旧 `lib/` 输出与 `shadow-build/` 输出混用。

## 8. 提交拆分建议

推荐拆分为独立提交：

1. `.gitignore/.gitattributes` 与 CEGUI vendor 入库策略；
2. `tools/CEGUI-0.7.1` vendor snapshot；
3. Cocos2d-x 2.2.6 shadow 源码/工程补丁；
4. CRT/编码治理；
5. Release 或主工程接入；
6. 文档与 Codex 治理更新。

不要把 CEGUI vendor、引擎代码、CRT 修复、Codex 配置和业务逻辑混在同一个提交里。

## 9. 最小交付模板

每次迁移批次交付说明至少包含：

```text
工作树：
分支：
任务域：
变更点：
不纳入范围：
关键证据：
验证命令与结果：
剩余风险：
回滚方式：
```
