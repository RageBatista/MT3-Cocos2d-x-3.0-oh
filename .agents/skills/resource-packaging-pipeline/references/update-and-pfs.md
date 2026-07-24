# 资源打包与热更链路

## 主体目录

- `common/updateengine/**`
- `client/Launcher/Code/Update/**`
- `tools/engine/pfs/**`
- `client/android/*/FileDownloader.java`
- `common/updateengine/ios/FileDownloader.mm`

## 关键文件职责

| 文件/概念 | 作用 |
|---|---|
| `ver.ljvi` | 版本信息索引 |
| `fl.ljpi` | 文件列表与补丁索引 |
| `UpdateJson` | 更新描述与客户端下载决策输入 |
| `PackInfo` | 打包输出与发布过程的元信息 |

## 基本流向

1. 资源打包产生发布产物与索引
2. 版本差异生成更新描述和下载列表
3. Launcher 或平台下载器拉取更新包
4. 下载完成后做校验、解包、写入或挂载
5. 客户端启动后通过 PFS/资源提供器接管最终资源

## 高风险点

- 版本文件不匹配导致“有包但不更新”或“重复更新”
- 下载成功但校验失败，通常要同时检查索引、文件名和平台下载器实现
- PFS 挂载路径不一致会表现成资源缺失或 UI/渲染异常
- 不要把 SpriteEditor 合图算法问题直接归到热更新链路

## 与打包算法层的边界

- 本文件关注“资源如何被发布、下载、校验、挂载”
- `sprite-pack-algorithm` 关注“资源如何在 SpriteEditor 被布局和导出”
