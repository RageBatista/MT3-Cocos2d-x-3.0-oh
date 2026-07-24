# tools 目录说明

> 基准日期: 2026-04-30

`tools/` 目录当前承担“开发辅助资产”角色，不属于主库、GUI 或示例 CLI 的日常使用入口。

当前内容分为三类：

## 1. 诊断 CLI

- [UnpackDiag.cpp](UnpackDiag.cpp)
  - 构建目标：`ljfp-unpack-diag`
  - 用于索引统计、失败样本诊断、key 来源排查

## 2. 映射补种脚本

- [manifest_seed_pipeline.py](manifest_seed_pipeline.py)
  - 根据清单、参考目录和已有映射构建高置信 seed / merged mapping
  - GUI 在“生成/合并路径映射”流程中会尝试调用它
- [source_template_seed_pipeline.py](source_template_seed_pipeline.py)
  - 根据客户端源码、配置/文本语料和 `map.cmapconfig.bin` 提取路径模板变量
  - 再按 CRC 规则直接命中 numeric 文件，生成高置信 seed / merged mapping
  - 适合落实“打包器源码给 CRC 规则 + 客户端源码给路径模板 + 配置/文本语料补变量 + CRC 精确命中”这条最佳实践
- [extension_mismatch_classifier.py](extension_mismatch_classifier.py)
  - 根据 `unpack_path_manifest.tsv` 对扩展名差异做分级审计
  - 将 XML 域扩展、`.pngpart`、无扩展地图贴图、私有二进制无魔数、参考树同路径同内容别名、`review/unresolved` 残留与真实类型风险拆开统计
  - 支持 `--reference-root` 指向已知资源树，用于把同路径同内容的历史源树差异降级为已验证别名
  - 输出 `extension_mismatch_summary.*`、全量明细、高风险明细、review 明细和 `extension_mismatch_action_plan.tsv`，适合继续收敛最终资源树命名/类型一致性

## 3. 开发辅助子目录

- `runtime/`
  - Android / Frida 运行时 key 探测辅助
- `tests/`
  - `manifest_seed_pipeline.py`、`source_template_seed_pipeline.py` 与 `extension_mismatch_classifier.py` 的脚本测试

## 当前边界

- `tools/` 不再保留独立 `PathMappingGenerator.exe` 源码或独立 CMake
- `tools/` 默认不作为安装包正式交付内容
- `tools/` 下的脚本和测试更适合作为开发/排障资产，而不是面向最终用户的入口
