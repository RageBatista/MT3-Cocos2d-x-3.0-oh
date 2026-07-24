# generated 目录说明

> **状态**：机器产物
> **最后更新**：2026-07-15
> **当前入口**：[MT3 文档中心](../README.md) · [文档索引](../07-参考文档/02-文档索引.md) · [文档维护指南](../10-管理文档/01-文档维护指南.md)

## 1. 目录定位

本目录保存扫描和分析流程生成的结构化证据，不承载当前规范或人工教程。当前实物为 **11 个文件**：1 个说明 Markdown、2 个 JSON、8 个 CSV。

| 子目录 | 当前内容 | 用途 |
| --- | ---: | --- |
| `client-platform/` | 1 个 JSON | 三端客户端批次基线 |
| `mt3win32app/` | 8 个 CSV、1 个 JSON | Win32 工程、依赖、文件和模块关系扫描 |

## 2. Git LFS 状态

当前结构化文件以 Git LFS 管理。工作树只出现以下三行时，表示签出的是 pointer，而不是业务数据：

```text
version https://git-lfs.github.com/spec/v1
oid sha256:...
size ...
```

分析内容前先执行 `git lfs pull`，并核对文件大小、生成批次和来源脚本。

## 3. 使用规则

1. 引用产物时记录相对路径、生成日期或批次、来源脚本和上游提交。
2. 产物与源码、构建输出或现行基线冲突时，以工程实物为准并重新生成。
3. 不手工编辑 CSV/JSON 来制造“已更新”结果；修正生成器或扫描入口后重跑。
4. 新批次优先保持稳定目录和可追踪命名，避免把机器产物混入现行指南。
5. 删除或迁移前检查脚本默认输出路径、Git LFS 跟踪规则和历史审计引用。

## 4. 维护检查

```powershell
Get-ChildItem docs/generated -Recurse -File | Sort-Object FullName
git lfs status
rg -a -n 'version https://git-lfs.github.com/spec/v1' docs/generated
```

`rg` 有输出表示对应文件仍是 pointer；这不是内容验证通过的证据。
