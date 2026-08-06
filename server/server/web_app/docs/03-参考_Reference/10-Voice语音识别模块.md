# Voice 语音模块说明（源码对齐版）

> 更新时间：2026-03-20  
> 控制器：`app/api/controller/Voice.php`  
> 模型：`app/model/Voice.php`（表：`user_voice`）

## 1. 模块现状

Voice 模块当前实现是“语音文件接收 + 文件校验 + 元数据入库 + 文件回读”。

注意：代码中腾讯云 SDK 仍保留，但实际识别结果当前固定为占位文本：

- `text = "未能识别语音"`

## 2. 接口定义

## 2.1 `receive`

- 路径：`POST /api/voice/receive`
- 请求体：JSON（从原始输入流读取）
- 必填参数：
  - `uuid`
  - `speech`（base64）
  - `channelId`

处理流程：

1. 校验必填参数
2. 校验 UUID 格式（标准 UUID）
3. 校验 base64 编码
4. base64 解码并检查大小（<= 5MB）
5. 校验 AMR 文件头（`#!AMR`）
6. 落盘至 `public/iat/{uuid}.amr`
7. 写入 `user_voice`
8. 返回 `uuid/channelid/text`

## 2.2 `iat`

- 路径：`GET /api/voice/iat`
- 参数：`uuid`
- 行为：
  1. 校验 UUID
  2. 查库 `user_voice`
  3. 校验文件存在、大小、AMR头
  4. 返回 base64 文件内容（附件下载头）

## 3. 安全与校验

当前实现包含：

1. UUID 正则白名单
2. base64 字符集与可逆校验
3. 文件大小上限（5MB）
4. AMR 文件头校验
5. 日志记录上传行为

## 4. 关键澄清

1. 虽定义 `ALLOWED_EXTENSIONS = ['amr','wav','mp3']`，但当前实际校验逻辑只接受 AMR 头数据
2. 落盘扩展名固定 `.amr`
3. 真实语音识别调用路径当前未启用，返回文本为占位值

## 5. 数据结构

写入表：`user_voice`

核心字段：

- `uuid`
- `text`
- `channelid`
- `time`

## 6. 运维建议

1. 定期清理 `public/iat/` 历史语音文件
2. 若启用真实 ASR，需同步更新：
   - 错误码说明
   - 文本回写流程
   - 计费与重试策略
