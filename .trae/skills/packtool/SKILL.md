---
name: packtool
description: MT3 项目 LJFilePackUnpacker 资源打包 AI 辅助开发技能
---

# 资源打包技能

> MT3 项目 LJFilePackUnpacker 资源打包 AI 辅助开发技能

## 何时使用

在以下场景使用本技能：

- 需要打包游戏资源时
- 需要解包游戏资源时
- 需要优化资源加载性能时
- 需要保护游戏资源时

## 何时不使用

在以下场景不使用本技能：

- 需要开发游戏逻辑时
- 需要创建 UI 界面时 → 使用 [CEGUI 技能](../cegui/SKILL.md)

## 输入要求

使用本技能前需要满足以下条件：

- 已阅读 [公共约束](../references/common-constraints.md)
- 已配置 LJFilePackUnpacker 工具
- 已准备好资源文件

## 关键约束

使用本技能时需要注意以下约束：

- **文件格式**: 支持打包任意格式的文件
- **压缩算法**: 使用 LZ77 压缩算法
- **加密方式**: 使用 XOR 加密
- **文件大小**: 单个包文件大小建议不超过 2GB

## 工作流程

### 1. 创建打包配置

```xml
<!-- packconfig.xml -->
<PackConfig>
    <InputDir>resource/</InputDir>
    <OutputFile>resource.pak</OutputFile>
    <Compress>true</Compress>
    <Encrypt>true</Encrypt>
    <EncryptKey>0x55</EncryptKey>
</PackConfig>
```

### 2. 执行打包命令

```bash
cd tools/packtool
LJFilePackUnpacker.exe -p packconfig.xml
```

### 3. 验证打包结果

```bash
LJFilePackUnpacker.exe -l resource.pak
```

### 4. 解包测试

```bash
LJFilePackUnpacker.exe -u resource.pak output/
```

## 代码示例

### 示例 1: 打包资源

```cpp
// 打包资源
void PackResources(const char* inputDir, const char* outputFile)
{
    LJFilePackUnpacker packer;
    packer.SetInputDir(inputDir);
    packer.SetOutputFile(outputFile);
    packer.SetCompress(true);
    packer.SetEncrypt(true);
    packer.SetEncryptKey(0x55);
    packer.Pack();
}
```

### 示例 2: 解包资源

```cpp
// 解包资源
void UnpackResources(const char* packFile, const char* outputDir)
{
    LJFilePackUnpacker unpacker;
    unpacker.SetPackFile(packFile);
    unpacker.SetOutputDir(outputDir);
    unpacker.Unpack();
}
```

### 示例 3: 读取打包文件

```cpp
// 读取打包文件
void ReadFromPack(const char* packFile, const char* filename)
{
    LJFilePackUnpacker reader;
    reader.SetPackFile(packFile);
    
    std::vector<char> data = reader.ReadFile(filename);
    // 处理数据
}
```

## 常见错误与解决方案

### 错误 1: 打包失败

**错误信息**:
```
Pack failed: file not found
```

**原因**:
- 输入目录不存在
- 文件路径不正确

**解决方案**:
```cpp
// 检查输入目录
if (!DirectoryExists(inputDir)) {
    // 处理目录不存在
}

// 使用正确的路径
packer.SetInputDir("resource/");
```

---

### 错误 2: 解包失败

**错误信息**:
```
Unpack failed: invalid pack file
```

**原因**:
- 打包文件损坏
- 加密密钥不匹配

**解决方案**:
```cpp
// 检查打包文件完整性
// 使用正确的加密密钥
packer.SetEncryptKey(0x55);
```

---

### 错误 3: 读取文件失败

**错误信息**:
```
Read failed: file not found in pack
```

**原因**:
- 文件未打包
- 文件名不正确

**解决方案**:
```cpp
// 检查文件是否在打包文件中
std::vector<std::string> files = reader.ListFiles();
// 检查文件名是否正确
```

## 调试技巧

### 技巧 1: 列出打包文件

```bash
# 列出打包文件中的所有文件
LJFilePackUnpacker.exe -l resource.pak
```

### 技巧 2: 验证打包文件

```bash
# 验证打包文件完整性
LJFilePackUnpacker.exe -v resource.pak
```

### 技巧 3: 解包到临时目录

```bash
# 解包到临时目录进行测试
LJFilePackUnpacker.exe -u resource.pak temp/
```

## 性能优化

### 优化 1: 分包打包

```xml
<!-- 按类型分包 -->
<PackConfig>
    <Pack name="images.pak">
        <Include>*.png</Include>
        <Include>*.jpg</Include>
    </Pack>
    <Pack name="audio.pak">
        <Include>*.mp3</Include>
        <Include>*.wav</Include>
    </Pack>
</PackConfig>
```

### 优化 2: 压缩级别

```xml
<!-- 调整压缩级别 -->
<PackConfig>
    <CompressLevel>9</CompressLevel> <!-- 0-9, 9 为最高压缩 -->
</PackConfig>
```

### 优化 3: 异步加载

```cpp
// 异步加载打包文件
std::thread thread(LoadPackAsync, "resource.pak");
```

## 注意事项

1. **文件大小**: 单个包文件大小建议不超过 2GB
2. **压缩算法**: 使用 LZ77 压缩算法，压缩率约 50%
3. **加密方式**: 使用 XOR 加密，仅用于防止直接访问
4. **性能考虑**: 打包和解包有一定开销，需要合理安排时机
5. **备份策略**: 打包前备份原始资源文件

## 相关技能

- [公共约束](../references/common-constraints.md) - 编码规范与代码风格
- [资源管理策略](../references/resource-management.md) - 资源管理方法

## 参考资料

- [LJFilePackUnpacker 源码](../../tools/packtool/)
- [资源管理策略](../references/resource-management.md)
