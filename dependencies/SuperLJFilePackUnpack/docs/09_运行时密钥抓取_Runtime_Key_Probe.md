# 09 运行时密钥抓取

> 基准日期: 2026-04-21
> 关联实现: `DecryptMode::ApkClientObf`、`DeSMS4Ex_ClientObf`

## 1. 文档定位

这份文档服务于两个判断：

1. 当前资源数据到底走的是哪条解密链
2. 默认密钥或调用时实际生效的 key 是否和工具配置一致

它不是通用 Frida 教程，也不是日常解包必读文档，而是“运行时 key / 模式判定”的补充排障材料。

对应脚本资产位于：

- [tools/runtime/check_adb_frida_env.ps1](../tools/runtime/check_adb_frida_env.ps1)
- [tools/runtime/lj_runtime_key_probe.js](../tools/runtime/lj_runtime_key_probe.js)

## 2. 与当前代码的关系

主库里可选的解密模式只有三种：

- `Auto`
- `LJFilePackSMS4`
- `ApkClientObf`

运行时抓密钥的价值在于：

- 帮我们验证目标资源是否真的应走 `ApkClientObf`
- 在默认密钥失效时提取真实参数，回填到 `decryptKey`

## 3. 推荐抓取目标

优先关注：

- `LJDeSMS4Func`
- `xxxx_decrypt_128`

重点参数：

- 传入的 `std::string` 或 key 参数对象
- 调用 `xxxx_decrypt_128` 前真正生效的 key 指针
- `xxxx_decrypt_128` 入参 `arg0`

## 4. 建议验证顺序

1. 先抓 `LJDeSMS4Func` 的表面 key 参数
2. 再抓 `xxxx_decrypt_128` 的真实 key 指针
3. 对比两者是否一致
4. 用抓到的结果验证：
   - `DecryptMode::LJFilePackSMS4`
   - `DecryptMode::ApkClientObf`

如果只有 `ApkClientObf` 能稳定还原且 CRC32 正确，就应在工具里明确指定这个模式，而不是长期依赖 `Auto`。

## 5. 工具侧联动建议

抓到密钥后，优先采用以下方式验证：

```cpp
options.decryptMode = SLJFP::DecryptMode::ApkClientObf;
options.decryptKey = "runtime-key";
```

如果验证通过，再决定是否更新 GUI 默认值或记录到专用配置。

## 6. 结论

运行时密钥抓取在当前模块中的定位很明确：

- 它不是库的常规使用步骤
- 它是“解密模式与密钥异常”时的证据型排障手段

因此本次文档同步后，相关说明统一只服务于“模式判定”和“参数回填”，不再把它写成日常使用流程。
