# SuperLJFilePackUnpack 依赖库说明

## 📦 依赖库来源

本目录包含了 SuperLJFilePackUnpack 项目所需的所有第三方依赖库，全部来源于 `../LJFilePack/` 项目。

## 📚 依赖库清单

### ljfp/ - LJFilePack 核心库

| 文件名 | 大小 | 功能说明 | 来源 |
|--------|------|----------|------|
| `LJFP_SMS4.h` | 269 行 | SMS4 国密加密算法实现 | LJFilePack/LJFP_SMS4.h |
| `LJFP_CRC32.h` | 69 行 | CRC32 循环冗余校验算法 | LJFilePack/LJFP_CRC32.h |
| `LJFP_MiniZ.h` | 4779 行 | MiniZ 压缩库 (zlib 兼容) | LJFilePack/LJFP_MiniZ.h |
| `LJFP_Compress.h` | 73 行 | 压缩功能封装 | LJFilePack/LJFP_Compress.h |
| `LJFP_FileUtil.h` | 229 行 | 文件操作工具集 | LJFilePack/LJFP_FileUtil.h |
| `LJFP_StringUtil.h` | 104 行 | 字符串处理工具 | LJFilePack/LJFP_StringUtil.h |
| `LJFP_Var.h` | 18 行 | 全局变量和类型定义 | LJFilePack/LJFP_Var.h |

**总计**: 7 个文件，5541 行代码

## 🔧 库功能详解

### 1. SMS4 加密库 (LJFP_SMS4.h)

**功能**：实现 SM4 (原 SMS4) 国密对称加密算法

**核心函数**：
- `SMS4Ex()` - 加密函数
- `DeSMS4Ex()` - 解密函数

**用途**：用于 .ljzip 文件的加密/解密处理

**默认密钥**：`"locojoy123456789"`

---

### 2. CRC32 校验库 (LJFP_CRC32.h)

**功能**：实现 CRC32 循环冗余校验算法

**核心函数**：
- `LJCRC32()` - 计算数据块的 CRC32 值

**用途**：
- 文件完整性校验
- 数据传输验证
- 防篡改检测

---

### 3. MiniZ 压缩库 (LJFP_MiniZ.h)

**功能**：轻量级 zlib 兼容压缩库

**核心函数**：
- `mz_compress()` / `LJZipFunc()` - 压缩数据
- `mz_uncompress()` / `LJUnZipFunc()` - 解压数据
- `mz_crc32()` - CRC32 校验

**特性**：
- 完全兼容 zlib RFC 1950/1951
- Header-only 实现，无需编译链接
- 支持多种压缩级别 (0-10)

**版本**：miniz.c v1.14

---

### 4. 压缩封装库 (LJFP_Compress.h)

**功能**：对 MiniZ 库的高级封装

**提供接口**：
- 统一的压缩/解压接口
- 错误处理和异常捕获
- 内存管理优化

---

### 5. 文件工具库 (LJFP_FileUtil.h)

**功能**：文件系统操作封装

**核心功能**：
- 文件读写
- 目录遍历
- 路径处理
- 文件属性查询

---

### 6. 字符串工具库 (LJFP_StringUtil.h)

**功能**：字符串处理工具集

**核心功能**：
- 字符串分割、拼接
- 编码转换
- 路径规范化
- 大小写转换

---

### 7. 变量定义库 (LJFP_Var.h)

**功能**：全局常量和类型定义

**定义内容**：
- 魔数常量 (`LJZIP_MAGIC_KEY = 9999`)
- 类型别名
- 编译开关

---

## 🛠️ 使用方式

### 基本引用

```cpp
#include "libs/ljfp/LJFP_SMS4.h"      // SMS4 加密
#include "libs/ljfp/LJFP_CRC32.h"     // CRC32 校验
#include "libs/ljfp/LJFP_MiniZ.h"     // MiniZ 压缩
#include "libs/ljfp/LJFP_Compress.h"  // 压缩封装
#include "libs/ljfp/LJFP_FileUtil.h"  // 文件工具
```

### 函数指针类型定义

本项目使用函数指针来注入依赖库函数：

```cpp
// 定义在 include/SLJFP_Unpack.h
typedef unsigned int(*CRC32_Func)(unsigned int crc, const unsigned char* ptr, size_t buf_len);
typedef int(*Zip_Func)(unsigned char *pDest, unsigned int *pDest_len, const unsigned char *pSource, unsigned int source_len, int level);
typedef int(*UnZip_Func)(unsigned char *pDest, unsigned int *pDest_len, const unsigned char *pSource, unsigned int source_len);
typedef void(*SMS4_Func)(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword);
typedef void(*DeSMS4_Func)(unsigned char* inBuff, unsigned char* ouBuff, unsigned int uiSize, std::string strPassword);
```

### 实例化示例

```cpp
// 创建 Unpacker 对象，注入依赖库函数
SLJFP::Unpacker unpacker(
    LJCRC32Func,    // CRC32 函数
    LJZipFunc,      // 压缩函数
    LJUnZipFunc,    // 解压函数
    LJSMS4Func,     // 加密函数
    LJDeSMS4Func    // 解密函数
);
```

---

## ⚠️ 重要说明

### 1. Header-Only 库

所有依赖库均为 **Header-Only** 实现：
- ✅ 无需编译成静态/动态库
- ✅ 只需包含头文件即可使用
- ✅ 避免 ABI 兼容性问题

### 2. 依赖关系

```
LJFP_Compress.h
    └── LJFP_MiniZ.h        (压缩/解压)
    └── LJFP_Var.h          (常量定义)

LJFP_FileUtil.h
    └── LJFP_StringUtil.h   (字符串处理)

LJFP_SMS4.h                 (独立)
LJFP_CRC32.h                (独立)
```

### 3. 许可证

- **MiniZ** (`LJFP_MiniZ.h`): Public Domain (Unlicense)
- **其他库**: 继承 LJFilePack 项目许可证

---

## 🔄 更新维护

### 同步更新

如果 `../LJFilePack/` 项目更新了依赖库，可以使用以下命令同步：

```bash
# 从项目根目录执行
cp dependencies/LJFilePack/LJFP_*.h dependencies/SuperLJFilePackUnpack/libs/ljfp/
```

### 版本追踪

| 依赖库 | 当前版本 | 最后更新 | 备注 |
|--------|----------|----------|------|
| LJFP_MiniZ.h | v1.14 | 2016-03-22 | miniz.c v1.14 |
| LJFP_SMS4.h | - | 2016-03-14 | SMS4 标准实现 |
| LJFP_CRC32.h | - | 2016-03-14 | CRC32 标准实现 |
| LJFP_Compress.h | - | 2016-03-14 | LJFilePack 封装 |
| LJFP_FileUtil.h | - | 2016-03-14 | LJFilePack 工具 |
| LJFP_StringUtil.h | - | 2016-06-08 | LJFilePack 工具 |
| LJFP_Var.h | - | 2016-03-14 | LJFilePack 定义 |

---

## 📞 技术支持

如有依赖库相关问题，请参考：
- LJFilePack 项目文档: `../LJFilePack/docs/`
- MiniZ 官方仓库: https://github.com/richgel999/miniz

---

**最后更新**: 2025-01-03
**维护**: SuperLJFilePackUnpack 项目组
