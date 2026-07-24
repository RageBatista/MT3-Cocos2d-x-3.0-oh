# MT3 Skill Script JSON Schema

本文件定义 MT3 repo-local Codex skill 脚本在 `-Json` 模式下的统一返回结构。

## 1. 顶层字段

所有可机读 skill 脚本都必须输出一个 JSON 对象，字段固定如下：

- `status`
- `skill`
- `summary`
- `next`
- `details`
- `data`

示例：

```json
{
  "status": "WARN",
  "skill": "windows-v120-build",
  "summary": "Windows build repo baseline is valid, but the local toolchain environment still needs attention.",
  "next": "Repair VS2013/MSBuild 12.0 visibility, then run the canonical build entry.",
  "details": [
    "repo_file=tools/scripts/Build-MT3-Exe-Canonical.ps1",
    "warning=MSBuild 12.0 not found"
  ],
  "data": {
    "repo_root": "E:\\MT3",
    "warnings": [
      "MSBuild 12.0 not found"
    ]
  }
}
```

## 2. 字段语义

### `status`

- 枚举值固定为 `PASS | WARN | FAIL`
- `FAIL` 表示当前脚本已发现应先修复的硬阻塞
- `WARN` 表示主链可继续，但仍有本地环境或人工确认项
- `PASS` 表示静态基线和当前前置检查均通过

### `skill`

- 固定填当前 skill 名称
- 必须与对应 skill 目录名一致

### `summary`

- 单行结果摘要
- 用一句话说明“当前结论是什么”

### `next`

- 下一步建议
- 应尽量可执行，不写空泛语句

### `details`

- 字符串数组
- 作为稳定、可 grep 的事实明细
- 推荐使用 `key=value`、`warning=...`、`failure=...` 这类轻量格式

### `data`

- 对象
- 作为领域特定的结构化补充载荷
- 优先放后续步骤可能复用的字段，而不是把 `details` 再重复一遍

## 3. `data` 字段约束

### 推荐字段

- `repo_root`
- `failures`
- `warnings`
- 任务域特有的锚点字段，例如：
  - `layout_path`
  - `resolved_lua_path`
  - `vcvarsall`
  - `ndk_build`
  - `toolset_drift`

### 命名规则

- 一律使用 `snake_case`
- 路径字段尽量稳定，不混用多种相对/绝对格式
- 布尔值字段使用真正的 `true/false`
- 列表字段始终输出数组，即使为空也保持数组

## 4. 设计原则

- 顶层结构固定，方便后续治理脚本和串联步骤稳定复用
- 领域变化放进 `data`，不要频繁改顶层字段
- `details` 负责人工扫描，`data` 负责机器复用
- 同一类事实不要同时在多个字段里发散命名

## 5. 后续脚本开发规则

- 新增 repo-local skill 脚本时，优先复用共享 helper：
  - `.agents/skills/mt3-project-guidelines/scripts/skill-script-helpers.ps1`
- 新脚本起步时优先复制：
  - `assets/skill-script-template.ps1.txt`
- 新脚本若新增 JSON 字段，优先加在 `data` 下，不先破坏顶层结构
