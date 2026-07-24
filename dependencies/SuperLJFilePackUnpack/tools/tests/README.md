# tools/tests 目录说明

> 基准日期: 2026-04-30

`tools/tests/` 当前只承担脚本级回归测试角色。

## 当前文件

- [test_manifest_seed_pipeline.py](test_manifest_seed_pipeline.py)
  - 验证 `manifest_seed_pipeline.py`
  - 覆盖路径规范化、低置信过滤、文本/二进制映射加载、seed/merged mapping 输出
- [test_source_template_seed_pipeline.py](test_source_template_seed_pipeline.py)
  - 验证 `source_template_seed_pipeline.py`
  - 覆盖源码/文本模板提取、`map.cmapconfig.bin` 结构化 `resdir` 解析、CRC 精确命中与 merged mapping 输出
- [test_extension_mismatch_classifier.py](test_extension_mismatch_classifier.py)
  - 验证 `extension_mismatch_classifier.py`
  - 覆盖 XML 域扩展、`.pngpart`、无扩展地图贴图、私有二进制无魔数、review 残留、高风险图片类型冲突和报告输出

## 运行方式

```powershell
Set-Location E:\MT3\dependencies\SuperLJFilePackUnpack\tools\tests
python -m unittest test_manifest_seed_pipeline.py test_source_template_seed_pipeline.py test_extension_mismatch_classifier.py
```

## 当前边界

- 这里只放脚本测试，不放主库 C++ 单元测试
- `__pycache__/` 现在已通过项目 `.gitignore` 忽略
- 如果后续增加更多脚本级工具，优先把对应回归也放到这里
