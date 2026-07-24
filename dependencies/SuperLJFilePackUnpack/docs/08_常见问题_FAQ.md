# 08 常见问题

> 基准日期: 2026-04-21

## 1. 为什么解包后文件名还是数字？

因为索引里只保存 `PathFileNameCRC32`，不保存原始路径字符串。

解决方式：

- 加载外部映射
- 用 GUI 生成/合并映射
- 用 `ljfp-unpack --scan=<resDir>` 生成映射

## 2. 当前还有命令行入口吗？

有，而且现在有两个：

- `ljfp-unpack`
- `ljfp-unpack-diag`

废弃的是历史上的 `BUILD_CLI` 通用主程序，不是当前示例 CLI。

## 3. 现在还有独立 `PathMappingGenerator.exe` 吗？

没有。

路径映射生成现在统一走：

- GUI
- `ljfp-unpack --scan`
- `SLJFP::PathMappingGenerator` API

## 4. 流式模式为什么会回退普通模式？

当前常见触发条件：

- `decryptMode=Auto`
- 解密块不满足 16 字节对齐
- inflate 初始化失败
- inflate 中途异常或停滞
- 输出尺寸与 `originalSize` 不一致

这是保护机制，不是开关失效。

## 5. GUI 能配置所有高级恢复开关吗？

不能。

GUI 主要暴露：

- CRC 校验
- 覆盖
- 按类型分类
- 流式模式
- 流式块大小
- 线程数
- 解密模式
- Android `libgame.so` 路径
- 解密 key

像 `strictRestoreValidation`、`writeReviewAliases`、`relocateRootNumericResiduals` 这类高级恢复策略，当前主要还是 CLI / 默认值层面的能力。

## 6. GUI 的“暂停”现在真的生效吗？

会协作式生效。

当前 `MainFrame` 会调用：

- `m_unpacker->SetPaused(true/false)`

底层 `Unpacker` 也有：

- `Pause()`
- `Resume()`
- `SetPaused()`

它不是强中断式暂停，但已经不是旧文档里的“只改按钮状态”。

## 7. `Auto` 一定最准吗？

不一定。

它的优势是：

- 不确定资源实际走哪条解密链时更稳

它的代价是：

- 候选更多
- 更慢
- 更容易让流式模式 fallback

如果你已经知道资源来源，显式指定模式通常更稳更快。

## 8. 为什么命中率不低，但还原结果仍不完整？

因为“命中率可用”不等于“目录完全恢复”。

还原效果还受这些因素影响：

- 参考目录是否是同版本/同渠道
- 是否启用了两阶段恢复
- 是否还有纯二进制、纯图片或无上下文残留

`90%` 更像“流程可继续”的门槛，不是“已完整恢复”的证明。

## 9. `organizeByType` 是什么？

它是“无映射或路径不可用时”的保底分类手段。

如果路径映射可用，最终仍会优先按路径输出，而不是按类型目录伪造结构。

## 10. `110` 是什么错误？

`110 = LJFP_ERR_PARTIAL_FAILURE`

含义是：

- 主流程跑完了
- 但存在部分文件失败

这不是“整体不可用”，而是应该进入结果审阅页继续看失败组。

## 11. 默认 key 是什么？能改吗？

默认 key：

```text
locojoy123456789
```

覆盖方式：

- `UnpackOptions.decryptKey`
- `Unpacker::SetDecryptKey()`
- CLI `--decrypt-key=...`

另外还可以通过 `--android-libgame=...` 或 GUI 的 Android 路径框自动提取。

## 12. 为什么仓库里不再有 `build/` 目录？

因为它现在被视为本地生成物，不再作为源码目录内容保留。

需要构建时，直接在本地重新生成即可：

```powershell
New-Item -ItemType Directory -Force build
cmake .. -G "Visual Studio 12 2013"
cmake --build . --config Release
```
