---
name: generated-code-guard
description: "MT3 生成代码保护技能。处理 xbean、rpc、tolua++、ProtoDef 等生成路径时使用，或当任务可能误改自动生成文件时使用；它负责识别源定义与生成流程，不直接承担业务实现。"
---

默认把生成产物视为只读结果，不把它们当成首选修改点。

## 何时使用

- 改动命中 `xbean`、`rpc`、`tolua++`、`ProtoDef` 或协议 Lua 镜像边界
- 需要判断问题应改“源定义”还是“生成产物”
- 需要确认 `res/script/protodef/**` 是否属于运行时镜像而非第一方定义

## 不使用

- 普通业务源码、布局资源或平台壳层改动未命中生成边界时，不要主动加载本技能
- 仅做编码/BOM 保护时，优先用 `encoding-bom-guard`

## 输入校验

- 先确认命中文件是否真在生成路径内
- 先确认是否存在上游定义、生成入口、实物对照来源或运行时镜像
- 先确认本轮缺口属于“定义缺失”“生成未同步”还是“镜像层遗漏”
- 可先运行边界探测脚本：

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\generated-code-guard\scripts\find-generation-source.ps1 -Path "<file>"
```
- 需要供后续脚本或审计链直接消费时，可追加 `-Json`

## 命中路径

- `server/**/xbean/*.java`
- `server/**/rpc/*.java`
- `client/**/tolua++/*.cpp`
- `*_tolua.cpp`
- `client/FireClient/Application/ProtoDef/**`

## 边界辨别

- `client/FireClient/Application/ProtoDef/**` 仍按生成物处理，优先回源定义。
- `client/resource/res/script/protodef/**/*.lua` 和 `client/resource/res/script/protodef/protocols.lua` 是运行时 Lua 协议资源镜像，不能简单套用“禁止修改所有 ProtoDef”。
- 遇到 `res/script/protodef` 缺口时，先区分是：
  1. Lua 侧注册缺失
  2. 协议 Lua 文件缺失
  3. 协议内部继续 `require` 的 bean 文件缺失
- 对 `res/script/protodef` 的补齐，优先对照 `android/.../assets/unpacked/script/protodef/**` 做实物同步，不要凭空手写或重构协议定义。

## 正确动作

1. 定位源定义文件。
2. 修改源定义。
3. 运行生成流程。
4. 验证生成结果与受影响调用方。

若命中的是 `client/resource/res/script/protodef/**`：

1. 先确认缺口是否只在 Lua 运行时镜像层
2. 再对照 `unpacked` 查同名协议/bean/注册项
3. 按最小集合同步到 `res`
4. 回查调用方 dialog、manager 和 `protocols.lua` 是否闭环

## 失败处理

- 若源定义和生成入口都未定位到，不要直接修改生成产物顶过去
- 若 `res/script/protodef/**` 与 `android/.../assets/unpacked/**` 不一致，优先做实物对照，不手写猜协议

## 输出与验证

- 输出至少包含：命中边界、源定义位置、生成/同步动作、受影响调用方、验证结果
- 若最终判断允许改 `res/script/protodef/**`，必须说明为何它属于运行时镜像层而非生成产物本体
- 边界探测脚本固定输出 `STATUS/SUMMARY/DETAIL/NEXT`，可作为“禁止直改/允许镜像同步”的首轮证据
- 若需要机器可读结果，优先使用 `find-generation-source.ps1 -Json`

## 资源与上下文预算

- 默认只读命中路径、源定义候选和最小生成入口
- 不因单个协议问题一次性展开整个 `ProtoDef` 或服务端生成链

## 深度参考

- `.claude/RULES.md`
- `.claude/hooks/post-edit-generated-guard.ps1`
