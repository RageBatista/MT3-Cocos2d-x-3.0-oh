# 06 客户端资源读取逻辑分析

> 基准日期: 2026-03-13
> 目的: 解释为什么 `SuperLJFilePackUnpack` 需要外部路径映射与类型探测

## 1. 结论

客户端资源读取链路给解包器带来的核心约束只有一个：

`LJFilePack` 索引并不保存原始路径字符串，而是只保存路径 CRC32。

因此解包器在代码层必须接受这件事：

- 不能仅靠 `.ljpi` / `.ljzip` 恢复原始路径
- 想还原目录结构，必须有外部路径映射
- 如果映射缺失，只能退化为 CRC32 文件名

## 2. 当前模块如何应对这个约束

### 2.1 第一层：路径映射

`Unpacker::GetFilePath()` 和 `BuildOutputPath()` 会优先使用：

```text
m_pathMapping[PathFileNameCRC32]
```

来源可以是：

- 手工加载文本映射
- 手工加载 `.ljpm`
- GUI 自动加载同目录映射
- GUI 从参考资源目录自动生成 `auto_path_mapping.ljpm`

### 2.2 第二层：类型检测

路径映射缺失时，当前实现还会：

- 使用 `PathFileNameCRC32` 作为基础文件名
- 调用 `FileTypeDetector` 根据文件头补扩展名

这不能恢复目录树，但能让结果具备可读性和可筛选性。

## 3. 代码证据

### 3.1 索引中只有 CRC32

`FileInfo` 的路径相关字段只有：

```cpp
unsigned int m_PathFileNameCRC32;
```

在 `LoadLjpiIndex()` / `ParseLjpiData()` 中，最终读入的也是这一项，没有任何路径字符串段。

### 3.2 解包器的恢复策略

`GetFilePath(index)` 当前逻辑：

1. 查映射
2. 命中则返回原始路径
3. 否则返回 CRC32 十进制字符串

`BuildOutputPath()` 当前逻辑：

1. 优先映射路径
2. 否则拿 CRC32 作为文件名
3. 有文件头则补扩展名
4. 可选再按类型分目录

## 4. GUI 为什么强调映射命中率

GUI 并不是“只要找到一个映射文件就直接用”，而是还会看：

- `GetPathMappingCount()`
- `GetPathMappingHitRate()`

原因很实际：

- 找到映射文件不代表规范化规则一致
- 大小写、斜杠、路径前缀不同，都会导致大面积 miss

当前 GUI 会把命中率过低视为“映射不可信”，继而尝试：

- 清空旧映射
- 从参考资源目录重新扫描
- 重新生成二进制映射

## 5. 为什么路径规范化很重要

`PathMappingGenerator` 当前默认会：

- `lowercasePaths=true`
- `normalizeSlashes=true`

如果打包时参与 CRC32 的路径也遵循这一规范，命中率会高；反之，映射看似存在，实际上仍会大量 miss。

## 6. 对文档和使用的直接影响

基于这套事实，当前文档必须避免两种误导：

1. 不能写成“解包工具能从索引完整还原原始路径”
2. 不能把文件类型检测描述成“路径恢复手段”

正确说法应该是：

- 路径恢复依赖映射
- 类型检测只负责补扩展名和粗粒度分类

## 7. 审计结论

这份分析直接支撑了当前模块的三个实现决定：

1. `LoadPathMapping()` / `LoadPathMappingBinary()` 是一等公民，不是可有可无的附加功能
2. `PathMappingGenerator` 被同时做成库能力、GUI 功能和 CLI 工具
3. `FileTypeDetector` 的职责被严格限定在“无映射时改善输出可读性”，而不是试图替代路径映射
