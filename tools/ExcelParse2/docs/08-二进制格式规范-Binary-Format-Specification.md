# 二进制格式规范 (Binary Format Specification)

> **版本**: 1.0.0
> **更新日期**: 2026-02-20
> **维护者**: 技术团队

---

## 文档概述

本文档详细说明 ExcelParse2 工具生成的二进制文件格式规范，包括文件头格式、数据记录格式、类型编码规则和版本兼容性说明。

---

## 目录

1. [文件头格式](#文件头格式)
2. [数据记录格式](#数据记录格式)
3. [类型编码规则](#类型编码规则)
4. [版本兼容性说明](#版本兼容性说明)
5. [列校验和检测结构变更](#列校验和检测结构变更)
6. [示例文件解析](#示例文件解析)

---

## 文件头格式

### 文件头结构

二进制文件以文件头开始，包含魔数、文件长度、版本号、成员数量和列校验和。

#### C++ 结构定义

```cpp
struct BinFileHeader {
    char magic[4];        // 'LDZY' (4 bytes)
    uint fileLength;       // 文件长度 (4 bytes)
    ushort version;        // 版本号 = 101 (2 bytes)
    ushort memberCount;    // 成员数量 (2 bytes)
    uint colCheckNumber;   // 列校验和 (4 bytes)
};
```

#### 字段说明

| 字段名 | 类型 | 大小 | 说明 |
|-------|------|------|------|
| magic | char[4] | 4 bytes | 魔数，固定为 'LDZY' |
| fileLength | uint | 4 bytes | 文件总长度（字节） |
| version | ushort | 2 bytes | 版本号，当前为 101 |
| memberCount | ushort | 2 bytes | 数据记录数量 |
| colCheckNumber | uint | 4 bytes | 列校验和，用于检测结构变更 |

#### 文件头总大小

```
4 + 4 + 2 + 2 + 4 = 16 bytes
```

---

### 魔数 (Magic Number)

魔数用于标识文件类型，固定为 `'LDZY'`。

#### 魔数验证

```csharp
// 写入魔数
bw.Write('L');
bw.Write('D');
bw.Write('Z');
bw.Write('Y');

// 读取并验证魔数
char magic[4];
fread(magic, 1, 4, fp);
if (strncmp(magic, "LDZY", 4) != 0) {
    printf("Invalid file format!\n");
    return false;
}
```

#### 代码实现

参见 [`MainWindow.xaml.cs`](../MainWindow.xaml.cs:603) 中的魔数写入代码：

```csharp
bw.Write('L');
bw.Write('D');
bw.Write('Z');
bw.Write('Y');
```

---

### 文件长度 (File Length)

文件长度字段记录文件的总长度（字节），用于验证文件完整性。

#### 写入时机

文件长度在写入所有数据后回填：

```csharp
uint fileLength = 0; // 先写入占位符
bw.Write(fileLength);

// ... 写入数据

// 回填文件长度
long currentPos = bw.BaseStream.Position;
bw.BaseStream.Seek(4, SeekOrigin.Begin);
bw.Write((uint)currentPos);
bw.BaseStream.Seek(currentPos, SeekOrigin.Begin);
```

---

### 版本号 (Version)

版本号用于标识二进制文件格式版本，当前版本为 101。

#### 版本号定义

```csharp
public static ushort mBinFileVersion = 101;
```

#### 版本号写入

```csharp
bw.Write(MainWindow.mBinFileVersion);
```

#### 版本兼容性

| 版本号 | 说明 | 兼容性 |
|-------|------|--------|
| 101 | 当前版本 | 完全兼容 |
| 100 | 旧版本 | 需要转换 |

---

### 成员数量 (Member Count)

成员数量字段记录数据记录的总数。

#### 写入时机

成员数量在写入所有数据后回填：

```csharp
ushort memberCount = 0; // 先写入占位符
bw.Write(memberCount);

// ... 写入数据，计数增加
memberCount++;

// 回填成员数量
long currentPos = bw.BaseStream.Position;
bw.BaseStream.Seek(12, SeekOrigin.Begin);
bw.Write(memberCount);
bw.BaseStream.Seek(currentPos, SeekOrigin.Begin);
```

---

### 列校验和 (Column Check Number)

列校验和用于检测 Bean 结构变更。

#### 校验和计算

参见 [`DefineManager.cs`](../DefineManager.cs:65) 中的 `GetColCheckNumber()` 方法：

```csharp
public uint GetColCheckNumber()
{
    uint colVersion = 0;
    uint allColCount = 0;
    for (int i = 0; i < cols.Count; i++)
    {
        for (int j = 0; j < cols[i].subCols.Count; j++)
        {
            string type = cols[i].type;
            if (cols[i].type == "vector")
                type = cols[i].value;

            if (type == "bool")
                colVersion += 1;
            else if (type == "int")
                colVersion += 2;
            else if (cols[i].type == "long")
                colVersion += 3;
            else if (type == "double")
                colVersion += 4;
            else if (type == "string" || type == "String")
                colVersion += 5;
            colVersion += allColCount;
            ++allColCount;
        }
    }
    colVersion += allColCount * 0x10000;
    return colVersion;
}
```

#### 校验和写入

```csharp
bw.Write(beanDef.GetColCheckNumber());
```

---

## 数据记录格式

### 记录结构

每个数据记录包含所有字段的值，按 Bean 定义的顺序写入。

#### 记录格式

```
[字段1][字段2][字段3]...[字段N]
```

#### 示例记录

```
[id: 4 bytes][name: 长度 + UTF-8 字节][level: 4 bytes][exp: 8 bytes]
```

---

### 字段写入顺序

字段按 Bean 定义的 `cols` 列表顺序写入。

#### 示例 Bean 定义

```xml
<bean name="Item" ...>
    <col name="id" type="int" .../>
    <col name="name" type="string" .../>
    <col name="level" type="int" .../>
    <col name="exp" type="long" .../>
</bean>
```

#### 写入顺序

1. `id` (int)
2. `name` (string)
3. `level` (int)
4. `exp` (long)

---

### 空值处理

空值（空字符串）写入默认值。

#### 默认值表

| 类型 | 默认值 | 说明 |
|------|--------|------|
| bool | false | 布尔值默认为 false |
| int | 0 | 整数默认为 0 |
| long | 0 | 长整数默认为 0 |
| double | 0.0 | 浮点数默认为 0.0 |
| string | "" | 空字符串长度为 0 |

#### 代码实现

参见 [`MainWindow.xaml.cs`](../MainWindow.xaml.cs:468) 中的 `WriteBinData()` 方法：

```csharp
private bool WriteBinData(BinaryWriter bw, string type, string data)
{
    try
    {
        if (type == "int")
        {
            if (data.Length > 0)
            {
                int nPointPos = data.IndexOf(".");
                if (nPointPos != -1)
                {
                    data = data.Substring(0, nPointPos);
                }
                int intData = Convert.ToInt32(data);
                bw.Write(intData);
            }
            else
                bw.Write((int)0); // 空值写入 0
        }
        // ... 其他类型
    }
    catch (FormatException e)
    {
        Error("写二进制数据" + type + "=" + data + "时，发现数据格式错！异常信息=" + e.Message);
        return false;
    }
    return true;
}
```

---

## 类型编码规则

### 基本类型编码

#### bool

- **大小**：1 byte
- **值范围**：0 (false) 或 1 (true)
- **字节序**：小端序

```csharp
// 写入
bw.Write(boolData);

// 读取
bool value = reader.ReadBoolean();
```

#### int

- **大小**：4 bytes
- **值范围**：-2147483648 ~ 2147483647
- **字节序**：小端序

```csharp
// 写入
bw.Write(intData);

// 读取
int value = reader.ReadInt32();
```

#### long

- **大小**：8 bytes
- **值范围**：-9223372036854775808 ~ 9223372036854775807
- **字节序**：小端序

```csharp
// 写入
bw.Write(longData);

// 读取
long value = reader.ReadInt64();
```

#### double

- **大小**：8 bytes
- **精度**：双精度浮点数
- **字节序**：小端序

```csharp
// 写入
bw.Write(doubleData);

// 读取
double value = reader.ReadDouble();
```

#### string

- **大小**：长度 (4 bytes) + UTF-8 字节
- **编码**：UTF-8
- **字节序**：小端序

```csharp
// 写入
byte[] str = System.Text.UnicodeEncoding.UTF8.GetBytes(data);
bw.Write((str).Length);
bw.Write(str);

// 读取
int strLen = reader.ReadInt32();
byte[] strBytes = reader.ReadBytes(strLen);
string value = System.Text.Encoding.UTF8.GetString(strBytes);
```

---

### 复合类型编码

#### vector<int>

- **大小**：长度 (4 bytes) + 元素数据 (N × 4 bytes)
- **字节序**：小端序

```csharp
// 写入
bw.Write(array.Count);
for (int i = 0; i < array.Count; i++)
{
    bw.Write(array[i]);
}

// 读取
int arrayLen = reader.ReadInt32();
int[] array = new int[arrayLen];
for (int i = 0; i < arrayLen; i++)
{
    array[i] = reader.ReadInt32();
}
```

#### vector<long>

- **大小**：长度 (4 bytes) + 元素数据 (N × 8 bytes)
- **字节序**：小端序

```csharp
// 写入
bw.Write(array.Count);
for (int i = 0; i < array.Count; i++)
{
    bw.Write(array[i]);
}

// 读取
int arrayLen = reader.ReadInt32();
long[] array = new long[arrayLen];
for (int i = 0; i < arrayLen; i++)
{
    array[i] = reader.ReadInt64();
}
```

#### vector<double>

- **大小**：长度 (4 bytes) + 元素数据 (N × 8 bytes)
- **字节序**：小端序

```csharp
// 写入
bw.Write(array.Count);
for (int i = 0; i < array.Count; i++)
{
    bw.Write(array[i]);
}

// 读取
int arrayLen = reader.ReadInt32();
double[] array = new double[arrayLen];
for (int i = 0; i < arrayLen; i++)
{
    array[i] = reader.ReadDouble();
}
```

#### vector<string>

- **大小**：长度 (4 bytes) + 元素数据 (N × (长度 + UTF-8 字节))
- **字节序**：小端序

```csharp
// 写入
bw.Write(array.Count);
for (int i = 0; i < array.Count; i++)
{
    byte[] str = System.Text.UnicodeEncoding.UTF8.GetBytes(array[i]);
    bw.Write(str.Length);
    bw.Write(str);
}

// 读取
int arrayLen = reader.ReadInt32();
string[] array = new string[arrayLen];
for (int i = 0; i < arrayLen; i++)
{
    int strLen = reader.ReadInt32();
    byte[] strBytes = reader.ReadBytes(strLen);
    array[i] = System.Text.Encoding.UTF8.GetString(strBytes);
}
```

---

### Bean 类型编码

Bean 类型按字段顺序递归编码。

#### 示例 Bean

```xml
<bean name="Position" ...>
    <col name="x" type="int" .../>
    <col name="y" type="int" .../>
</bean>

<bean name="Monster" ...>
    <col name="id" type="int" .../>
    <col name="position" type="Position" .../>
</bean>
```

#### 编码顺序

```
[id: 4 bytes][position.x: 4 bytes][position.y: 4 bytes]
```

---

### 字节序说明

所有数值类型使用小端序（Little-Endian）。

#### 小端序示例

```
int value = 0x12345678;

内存布局（小端序）：
地址 0: 0x78
地址 1: 0x56
地址 2: 0x34
地址 3: 0x12
```

---

## 版本兼容性说明

### 版本号规则

版本号采用主版本号格式（ushort）。

#### 版本号格式

```
主版本号 (高位 8 bits) . 次版本号 (低位 8 bits)
```

#### 示例版本号

| 版本号 | 主版本 | 次版本 | 说明 |
|-------|-------|-------|------|
| 101 | 1 | 1 | 当前版本 |
| 100 | 1 | 0 | 旧版本 |

---

### 版本兼容性矩阵

| 版本 | 101 | 100 | 99 |
|-----|-----|-----|-----|
| 101 | ✅ 完全兼容 | ⚠️ 需要转换 | ❌ 不兼容 |
| 100 | ⚠️ 需要转换 | ✅ 完全兼容 | ❌ 不兼容 |
| 99 | ❌ 不兼容 | ❌ 不兼容 | ✅ 完全兼容 |

---

### 版本升级策略

#### 主版本升级（不兼容）

- 修改文件头结构
- 修改类型编码规则
- 修改字节序

#### 次版本升级（兼容）

- 添加新字段（向后兼容）
- 优化编码方式
- 修复 bug

---

### 版本检测

#### 读取版本号

```csharp
ushort version = reader.ReadUInt16();
if (version != MainWindow.mBinFileVersion)
{
    Error("二进制文件版本不匹配！期望版本：" + MainWindow.mBinFileVersion + "，实际版本：" + version);
    return false;
}
```

---

## 列校验和检测结构变更

### 校验和计算规则

校验和根据 Bean 的列定义计算，用于检测结构变更。

#### 计算公式

```
colCheckNumber = Σ(类型权重 + 列索引) + 列总数 × 0x10000
```

#### 类型权重表

| 类型 | 权重 |
|------|------|
| bool | 1 |
| int | 2 |
| long | 3 |
| double | 4 |
| string | 5 |

#### 计算示例

**Bean 定义**：
```xml
<bean name="Item" ...>
    <col name="id" type="int" .../>
    <col name="name" type="string" .../>
    <col name="level" type="int" .../>
</bean>
```

**校验和计算**：
```
colVersion = 0
allColCount = 0

# id (int)
colVersion += 2 + 0 = 2
allColCount = 1

# name (string)
colVersion += 5 + 1 = 8
allColCount = 2

# level (int)
colVersion += 2 + 2 = 12
allColCount = 3

colCheckNumber = 12 + 3 × 0x10000 = 196612
```

---

### 结构变更检测

#### 检测流程

1. 读取二进制文件的列校验和
2. 计算当前 Bean 定义的列校验和
3. 比较两个校验和
4. 如果不匹配，说明结构已变更

#### 代码实现

```csharp
uint fileColCheckNumber = reader.ReadUInt32();
uint currentColCheckNumber = beanDef.GetColCheckNumber();

if (fileColCheckNumber != currentColCheckNumber)
{
    Error("二进制文件结构已变更！文件校验和：" + fileColCheckNumber + "，当前校验和：" + currentColCheckNumber);
    return false;
}
```

---

### 变更类型

#### 添加字段

**原定义**：
```xml
<col name="id" type="int" .../>
<col name="name" type="string" .../>
```

**新定义**：
```xml
<col name="id" type="int" .../>
<col name="name" type="string" .../>
<col name="level" type="int" .../>  <!-- 新增字段 -->
```

**影响**：校验和不匹配，需要重新生成二进制文件。

#### 删除字段

**原定义**：
```xml
<col name="id" type="int" .../>
<col name="name" type="string" .../>
<col name="level" type="int" .../>
```

**新定义**：
```xml
<col name="id" type="int" .../>
<col name="name" type="string" .../>
<!-- 删除 level 字段 -->
```

**影响**：校验和不匹配，需要重新生成二进制文件。

#### 修改字段类型

**原定义**：
```xml
<col name="level" type="int" .../>
```

**新定义**：
```xml
<col name="level" type="long" .../>  <!-- 类型从 int 改为 long -->
```

**影响**：校验和不匹配，需要重新生成二进制文件。

#### 调整字段顺序

**原定义**：
```xml
<col name="id" type="int" .../>
<col name="name" type="string" .../>
<col name="level" type="int" .../>
```

**新定义**：
```xml
<col name="id" type="int" .../>
<col name="level" type="int" .../>  <!-- 顺序调整 -->
<col name="name" type="string" .../>
```

**影响**：校验和不匹配，需要重新生成二进制文件。

---

## 示例文件解析

### 示例数据

#### Excel 数据

| ID | Name | Level | Exp |
|----|------|-------|-----|
| 1 | "战士" | 1 | 100 |
| 2 | "法师" | 1 | 100 |

#### Bean 定义

```xml
<bean name="Item" ...>
    <col name="id" type="int" .../>
    <col name="name" type="string" .../>
    <col name="level" type="int" .../>
    <col name="exp" type="long" .../>
</bean>
```

---

### 二进制文件内容

#### 文件头 (16 bytes)

```
偏移 0-3:   'LDZY' (魔数)
偏移 4-7:   文件长度 (uint)
偏移 8-9:   版本号 = 101 (ushort)
偏移 10-11: 成员数量 = 2 (ushort)
偏移 12-15: 列校验和 (uint)
```

#### 记录 1 (ID = 1)

```
偏移 16-19:  id = 1 (int)
偏移 20-23:  name 长度 = 6 (uint)
偏移 24-29:  name = "战士" (UTF-8 字节)
偏移 30-33:  level = 1 (int)
偏移 34-41:  exp = 100 (long)
```

#### 记录 2 (ID = 2)

```
偏移 42-45:  id = 2 (int)
偏移 46-49:  name 长度 = 6 (uint)
偏移 50-55:  name = "法师" (UTF-8 字节)
偏移 56-59:  level = 1 (int)
偏移 60-67:  exp = 100 (long)
```

---

### 完整文件布局

```
[文件头: 16 bytes]
  [魔数: 4 bytes] 'LDZY'
  [文件长度: 4 bytes] 68
  [版本号: 2 bytes] 101
  [成员数量: 2 bytes] 2
  [列校验和: 4 bytes] 196612

[记录 1: 26 bytes]
  [id: 4 bytes] 1
  [name 长度: 4 bytes] 6
  [name 数据: 6 bytes] "战士"
  [level: 4 bytes] 1
  [exp: 8 bytes] 100

[记录 2: 26 bytes]
  [id: 4 bytes] 2
  [name 长度: 4 bytes] 6
  [name 数据: 6 bytes] "法师"
  [level: 4 bytes] 1
  [exp: 8 bytes] 100

总文件大小: 16 + 26 + 26 = 68 bytes
```

---

### 读取示例代码

#### C++ 读取代码

```cpp
#include <cstdio>
#include <cstring>

struct BinFileHeader {
    char magic[4];
    uint fileLength;
    ushort version;
    ushort memberCount;
    uint colCheckNumber;
};

bool loadItemTable(const char* filename) {
    FILE* fp = fopen(filename, "rb");
    if (!fp) {
        printf("Failed to open file: %s\n", filename);
        return false;
    }
    
    // 读取文件头
    BinFileHeader header;
    fread(&header, sizeof(BinFileHeader), 1, fp);
    
    // 验证魔数
    if (strncmp(header.magic, "LDZY", 4) != 0) {
        printf("Invalid file format!\n");
        fclose(fp);
        return false;
    }
    
    // 验证版本号
    if (header.version != 101) {
        printf("Unsupported version: %d\n", header.version);
        fclose(fp);
        return false;
    }
    
    // 读取数据
    for (int i = 0; i < header.memberCount; i++) {
        int id;
        fread(&id, sizeof(int), 1, fp);
        
        uint nameLen;
        fread(&nameLen, sizeof(uint), 1, fp);
        
        char* name = new char[nameLen + 1];
        fread(name, 1, nameLen, fp);
        name[nameLen] = '\0';
        
        int level;
        fread(&level, sizeof(int), 1, fp);
        
        long exp;
        fread(&exp, sizeof(long), 1, fp);
        
        printf("ID: %d, Name: %s, Level: %d, Exp: %ld\n", id, name, level, exp);
        
        delete[] name;
    }
    
    fclose(fp);
    return true;
}
```

#### Lua 读取代码

```lua
function Item.load(filename)
    local file = io.open(filename, "rb")
    if not file then
        return false
    end
    
    -- 读取文件头
    local magic = file:read(4)
    if magic ~= "LDZY" then
        file:close()
        return false
    end
    
    local fileLength = string.unpack("<I", file:read(4))
    local version = string.unpack("<H", file:read(2))
    local memberCount = string.unpack("<H", file:read(2))
    local colCheckNumber = string.unpack("<I", file:read(4))
    
    -- 读取数据
    for i = 1, memberCount do
        local id = string.unpack("<i", file:read(4))
        
        local nameLen = string.unpack("<I", file:read(4))
        local name = file:read(nameLen)
        
        local level = string.unpack("<i", file:read(4))
        local exp = string.unpack("<l", file:read(8))
        
        print("ID: " .. id .. ", Name: " .. name .. ", Level: " .. level .. ", Exp: " .. exp)
    end
    
    file:close()
    return true
end
```

---

## 参考资料

- [00-文档索引-Documentation-Index.md](00-文档索引-Documentation-Index.md) - 文档导航
- [05-数据格式规范-Data-Format-Specification.md](05-数据格式规范-Data-Format-Specification.md) - 数据格式规范
- [06-Bean定义指南-Bean-Definition-Guide.md](06-Bean定义指南-Bean-Definition-Guide.md) - Bean 定义规范
- [07-代码生成指南-Code-Generation-Guide.md](07-代码生成指南-Code-Generation-Guide.md) - 代码生成规则
- [MainWindow.xaml.cs](../MainWindow.xaml.cs:603) - 二进制文件写入实现
- [DefineManager.cs](../DefineManager.cs:65) - 列校验和计算实现

---

**维护者**: 技术团队
**下次审查**: 2026-03-20
**许可证**: 内部使用
