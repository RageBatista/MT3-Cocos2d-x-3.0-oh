# 技能治理规范

## 渐进式披露

- 主技能文件只保留三类信息：何时使用、如何分流、何时继续读深度资料
- 实际架构、模块依赖、API 锚点、命令细节放到 `references/`
- 不把整份 `.claude` 长文直接复制到 `.agents`

## `openai.yaml` 结构

所有技能统一使用：

```yaml
interface:
  display_name: "..."
  short_description: "..."
  default_prompt: "Use $skill-name ..."
```

约束：

- 所有字符串都使用引号
- `default_prompt` 必须显式提到 `$skill-name`
- `short_description` 只写能力和触发场景，保持简洁

## 事实来源优先级

1. 根 `AGENTS.md`
2. `.claude/RULES.md`
3. `.claude/BUILD_GUIDE.md`
4. 已校准的 `docs/`
5. 技能自己的 `references/`

## 技能矩阵建议

- 总入口：`mt3-project-guidelines`
- 配置治理：`claude-config-governance`
- 工具链：`windows-v120-build` `android-r10e-build` `server-ant-build`
- 守卫：`encoding-bom-guard` `generated-code-guard`
- 业务五域：`application-core-flow` `resource-packaging-pipeline` `sprite-pack-algorithm` `rendering-pipeline` `platform-bridge`

## 快速验证

对改动过的技能逐个执行：

```powershell
python C:\Users\www\.codex\skills\.system\skill-creator\scripts\quick_validate.py E:\MT3\.agents\skills\<skill-name>
```
