---
name: network
description: MT3 项目 libcurl 网络通信 AI 辅助开发技能
---

# 网络通信开发技能

> MT3 项目 libcurl 网络通信 AI 辅助开发技能

## 何时使用

在以下场景使用本技能：

- 需要发送 HTTP 请求时
- 需要下载文件时
- 需要上传文件时
- 需要处理网络错误时
- 需要优化网络性能时

## 何时不使用

在以下场景不使用本技能：

- 需要播放音频时 → 使用 [Audio 技能](../audio/SKILL.md)
- 需要创建 UI 界面时 → 使用 [CEGUI 技能](../cegui/SKILL.md)

## 输入要求

使用本技能前需要满足以下条件：

- 已阅读 [公共约束](../references/common-constraints.md)
- 已配置 libcurl 库
- 已了解 HTTP 协议基础

## 关键约束

使用本技能时需要注意以下约束：

- **线程安全**: libcurl 是线程安全的，但同一句柄不能在多线程中使用
- **内存管理**: libcurl 使用自己的内存管理，需要正确释放资源
- **超时设置**: 必须设置合理的超时时间
- **错误处理**: 必须检查所有 API 调用的返回值

## 工作流程

### 1. 初始化 libcurl

```cpp
#include <curl/curl.h>

// 初始化 libcurl
curl_global_init(CURL_GLOBAL_DEFAULT);
```

### 2. 创建句柄

```cpp
// 创建句柄
CURL* curl = curl_easy_init();
```

### 3. 设置选项

```cpp
// 设置 URL
curl_easy_setopt(curl, CURLOPT_URL, "http://example.com");

// 设置超时
curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30);

// 设置写入回调
curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
```

### 4. 执行请求

```cpp
// 执行请求
CURLcode res = curl_easy_perform(curl);
if (res != CURLE_OK) {
    // 处理错误
}
```

### 5. 清理资源

```cpp
// 清理资源
curl_easy_cleanup(curl);
curl_global_cleanup();
```

## 代码示例

### 示例 1: 发送 GET 请求

```cpp
// 发送 GET 请求
std::string SendGetRequest(const char* url)
{
    CURL* curl = curl_easy_init();
    std::string response;
    
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    
    CURLcode res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        // 处理错误
    }
    
    curl_easy_cleanup(curl);
    return response;
}
```

### 示例 2: 发送 POST 请求

```cpp
// 发送 POST 请求
std::string SendPostRequest(const char* url, const char* data)
{
    CURL* curl = curl_easy_init();
    std::string response;
    
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    
    CURLcode res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        // 处理错误
    }
    
    curl_easy_cleanup(curl);
    return response;
}
```

### 示例 3: 下载文件

```cpp
// 下载文件
bool DownloadFile(const char* url, const char* filename)
{
    CURL* curl = curl_easy_init();
    FILE* fp = fopen(filename, "wb");
    
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteFileCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
    
    CURLcode res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        // 处理错误
    }
    
    fclose(fp);
    curl_easy_cleanup(curl);
    return res == CURLE_OK;
}
```

## 常见错误与解决方案

### 错误 1: 请求超时

**错误信息**:
```
Operation timed out
```

**原因**:
- 网络连接超时
- 服务器响应慢

**解决方案**:
```cpp
// 增加超时时间
curl_easy_setopt(curl, CURLOPT_TIMEOUT, 60);

// 设置连接超时
curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);
```

---

### 错误 2: DNS 解析失败

**错误信息**:
```
Could not resolve host
```

**原因**:
- 网络不可用
- DNS 服务器配置错误

**解决方案**:
```cpp
// 检查网络连接
// 检查 DNS 服务器配置

// 使用 IP 地址代替域名
curl_easy_setopt(curl, CURLOPT_URL, "http://127.0.0.1");
```

---

### 错误 3: SSL 证书错误

**错误信息**:
```
SSL certificate problem
```

**原因**:
- SSL 证书无效
- CA 证书缺失

**解决方案**:
```cpp
// 跳过 SSL 验证（仅用于测试）
curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
```

## 调试技巧

### 技巧 1: 启用详细日志

```cpp
// 启用详细日志
curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
```

### 技巧 2: 检查响应头

```cpp
// 获取响应头
curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, HeaderCallback);
curl_easy_setopt(curl, CURLOPT_HEADERDATA, &headers);
```

### 技巧 3: 使用网络抓包工具

```cpp
// 使用 Wireshark 抓包分析网络请求
```

## 性能优化

### 优化 1: 使用连接池

```cpp
// 使用连接池复用连接
CURL* curl = curl_easy_init();
// 复用连接
```

### 优化 2: 异步请求

```cpp
// 使用多线程异步请求
std::thread thread(SendRequestAsync, url);
```

### 优化 3: 压缩数据

```cpp
// 启用压缩
curl_easy_setopt(curl, CURLOPT_ACCEPT_ENCODING, "gzip");
```

## 注意事项

1. **线程安全**: libcurl 是线程安全的，但同一句柄不能在多线程中使用
2. **超时设置**: 必须设置合理的超时时间
3. **错误处理**: 检查所有 API 调用的返回值，处理错误情况
4. **内存管理**: libcurl 使用自己的内存管理，需要正确释放资源
5. **安全考虑**: 生产环境不要跳过 SSL 验证

## 相关技能

- [公共约束](../references/common-constraints.md) - 编码规范与代码风格
- [错误处理策略](../references/error-handling.md) - 错误处理方法

## 参考资料

- [libcurl 官方文档](https://curl.se/libcurl/c/)
