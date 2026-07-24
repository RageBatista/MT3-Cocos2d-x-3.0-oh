# runtime 目录说明

> 基准日期: 2026-04-21

`tools/runtime/` 是运行时排障辅助目录，主要服务于 Android `libgame.so` 相关的解密 key 取证，不属于日常解包流程必需项。

## 文件清单

- [check_adb_frida_env.ps1](check_adb_frida_env.ps1)
  - 检查本机 `adb` / `frida` / `frida-ps`
  - 检查设备连接、ABI、frida-server 进程
  - 给出探针脚本的建议启动命令
- [lj_runtime_key_probe.js](lj_runtime_key_probe.js)
  - Frida 脚本
  - 关注 `LJDeSMS4Func`、`xxxx_decrypt_128` 等关键点
  - 用于捕获运行时真实 key、候选对象和调用关系

## 典型使用顺序

1. 先阅读 [docs/09_运行时密钥抓取_Runtime_Key_Probe.md](../../docs/09_运行时密钥抓取_Runtime_Key_Probe.md)
2. 运行 `check_adb_frida_env.ps1` 检查环境
3. 使用 `lj_runtime_key_probe.js` 挂到目标进程
4. 把抓到的 key 回填到：
   - `UnpackOptions.decryptKey`
   - CLI `--decrypt-key`
   - GUI 的解密 key 输入框

## 当前边界

- 这是“异常解密链路”的证据工具，不是常规使用入口
- 默认不纳入安装包交付
- 若不涉及 Android `libgame.so` 或运行时 key 取证，可以完全不使用本目录
