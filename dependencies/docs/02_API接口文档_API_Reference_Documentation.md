# 02_API接口文档_API_Reference_Documentation

> **项目名称**: MT3 Dependencies API Reference
> **文档版本**: 1.0
> **更新日期**: 2026-04-22
> **文档类型**: API接口文档

---

## 目录

1. [LJFilePack API](#1-ljfilepack-api)
2. [SuperLJFilePackUnpack API](#2-superljfilepackunpack-api)
3. [BinLayoutConvert API](#3-binlayoutconvert-api)
4. [CEGUI API](#4-cegui-api)
5. [算法库API](#5-算法库api)

---

## 1. LJFilePack API

### 1.1 核心类

#### LJFP_File

文件处理类，负责单个文件的加载、压缩、加密。

**头文件**: `LJFP_Pack.h`

**构造函数**:
```cpp
LJFP_File();
```

**公共成员变量**:
```cpp
unsigned int m_Pack;              // 包索引
unsigned int m_Pos;               // 包内位置
unsigned int m_Size;              // 当前大小
unsigned int m_CRC32;             // 当前CRC32
unsigned int m_CompressType;      // 压缩类型
unsigned int m_CodeType;          // 加密类型
unsigned int m_SizeOriginal;      // 原始大小
unsigned int m_CRC32Original;     // 原始CRC32
unsigned int m_PathFileNameCRC32;  // 路径文件名CRC32
std::wstring m_RootPathName;      // 根路径
std::wstring m_PathName;          // 路径名
std::wstring m_Name;             // 文件名
```

**公共方法**:

```cpp
// 加载文件数据
int LoadData();

// 压缩数据
int CompressData(bool bCompress);

// 加密数据
int CodeData(bool bCode);

// 释放数据
void ReleaseData();

// 清空数据
void Clear();
```

**返回值**:
- `0`: 成功
- `-1`: 失败

#### LJFP_FileList

文件列表管理类。

**头文件**: `LJFP_Pack.h`

**公共方法**:

```cpp
// 添加文件
void AddFile(LJFP_File* pFile);

// 获取文件数量
unsigned int GetFileCount();

// 获取文件
LJFP_File* GetFile(unsigned int index);

// 清空列表
void Clear();
```

#### LJFP_Version

版本管理类，支持三段式版本号。

**头文件**: `LJFP_Version.h`

**公共方法**:

```cpp
// 版本号转版本字符串
static std::wstring Version2VersionCaption(unsigned int Version, int ResultType = 0);

// 版本字符串转版本号
static unsigned int VersionCaption2Version(std::wstring VersionCaption);

// 获取版本号
unsigned int GetVersion();

// 获取基础版本号
unsigned int GetVersionBase();

// 获取最小版本号
unsigned int GetVersionMinimum();

// 设置版本号
void SetVersionCaption(std::wstring VersionCaption);

// 获取版本字符串
std::wstring GetVersionCaption();

// 设置基础版本号
void SetVersionCaptionBase(std::wstring VersionCaptionBase);

// 获取基础版本字符串
std::wstring GetVersionCaptionBase();

// 设置最小版本号
void SetVersionCaptionMinimum(std::wstring VersionCaptionMinimum);

// 获取最小版本字符串
std::wstring GetVersionCaptionMinimum();
```

**版本号格式**:
- 主版本号: 8位 (0-255)
- 次版本号: 12位 (0-4095)
- 补丁版本号: 12位 (0-4095)
- 总共32位: `Major << 24 | Minor << 12 | Patch`

**示例**:
```cpp
unsigned int version = 0x01000100;  // 1.1.256
std::wstring caption = LJFP_Version::Version2VersionCaption(version);  // "1.1.256"
unsigned int num = LJFP_Version::VersionCaption2Version(L"1.1.256");  // 0x01000100

// 使用实例方法
LJFP_Version V;
V.SetVersionCaption(L"1.2.3");
std::wstring ver = V.GetVersionCaption();  // "1.2.3"
```

### 1.2 工具类

#### LJFP_ZipFile

加密压缩文件处理类。

**头文件**: `LJFP_ZipFile.h`

**构造函数**:
```cpp
LJFP_ZipFile(unsigned int uiKey,
             CRC32_Func crc32Func,
             Zip_Func zipFunc,
             UnZip_Func unzipFunc,
             SMS4_Func sms4Func,
             DeSMS4_Func desms4Func,
             std::string strPassword);
```

**参数说明**:
- `uiKey`: 魔数 (通常为 9999)
- `crc32Func`: CRC32 计算函数
- `zipFunc`: 压缩函数 (通常为 mz_compress2)
- `unzipFunc`: 解压函数 (通常为 mz_uncompress)
- `sms4Func`: SMS4 加密函数 (通常为 SMS4Ex)
- `desms4Func`: SMS4 解密函数 (通常为 DeSMS4Ex)
- `strPassword`: 加密密码 (通常为 "locojoy123456789")

**公共方法**:

```cpp
// 压缩文件
int ZipFile(std::wstring strSrcPath, std::wstring strDstPath);

// 解压文件
int UnZipFile(std::wstring strSrcPath, std::wstring strDstPath);

// 解压文件（带大小和CRC32输出）
int UnZipFile(std::wstring strSrcPath, std::wstring strDstPath, 
             unsigned int& SizeDst, unsigned int& CRC32Dst);
```

**返回值**:
- `0`: 成功
- `非0`: 失败

#### LJFP_File

文件信息类。

**头文件**: `LJFP_Pack.h`

**成员变量**:
```cpp
unsigned int m_Pack;                    // 包索引
unsigned int m_Pos;                      // 包内位置偏移
unsigned int m_Size;                     // 当前大小
unsigned int m_CRC32;                    // 当前CRC32
unsigned int m_CompressType;             // 压缩类型 (0=未压缩)
unsigned int m_CodeType;                 // 加密类型 (0=未加密)
unsigned int m_SizeOriginal;             // 原始大小
unsigned int m_CRC32Original;            // 原始CRC32
unsigned int m_SizeCompress;             // 压缩后大小
unsigned int m_CRC32Compress;            // 压缩后CRC32
unsigned int m_SizeCode;                 // 加密后大小
unsigned int m_CRC32Code;                // 加密后CRC32
unsigned int m_PathFileNameCRC32;         // 路径文件名CRC32
std::wstring m_RootPathName;            // 根路径名
std::wstring m_PathName;                // 路径名
std::wstring m_Name;                    // 文件名
```

**公共方法**:
```cpp
// 加载文件数据
int LoadData();

// 压缩数据
int CompressData(bool bCompress);

// 加密数据
int CodeData(bool bCode);

// 保存数据
int SaveData(std::wstring strRootPathName);

// 释放数据
int ReleaseData();

// 清空信息
int Clear();
```

#### LJFP_Pack

打包管理类。

**头文件**: `LJFP_Pack.h`

**成员变量**:
```cpp
unsigned int m_PackMaxSize;                           // 包最大大小
std::vector<LJFP_File*> m_FileArr;                  // 文件数组
std::map<unsigned int, std::vector<LJFP_File*>> m_FileMap;  // 文件映射
std::map<unsigned int, std::vector<LJFP_File*>> m_SameFileMap; // 相同文件映射
```

**公共方法**:
```cpp
// 添加文件
int AddFile(LJFP_File* pFile);

// 打包文件
int PackFiles(std::wstring strOutputPath);

// 获取包索引
unsigned int GetPackIndex(unsigned int uiSize);
```

#### LJFP_FileList

文件列表管理类。

**头文件**: `LJFP_Pack.h`

**公共方法**:
```cpp
// 获取文件列表实例
LJFP_FileList* GetFileList();

// 添加文件
int AddFile(LJFP_File* pFile);

// 获取文件
LJFP_File* GetFile(unsigned int uiIndex);

// 获取文件数量
unsigned int GetFileCount();
```

#### LJFP_FileUtil

文件工具类。

**头文件**: `LJFP_FileUtil.h`

**公共方法**:

```cpp
// 创建目录
bool CreateDir(std::wstring strDir);

// 递归创建目录
bool CreateDirEx(std::wstring strDir);

// 删除目录
bool RemoveDir(std::wstring strDir);

// 递归删除目录
bool RemoveDirEx(std::wstring strDir);

// 文件是否存在
bool FileExists(std::wstring strPath);

// 目录是否存在
bool DirExists(std::wstring strPath);

// 获取文件大小
unsigned int GetFileSize(std::wstring strPath);
```

#### LJFP_StringUtil

字符串工具类。

**头文件**: `LJFP_StringUtil.h`

**公共方法**:

```cpp
// 宽字符串转窄字符串
std::string WS2S(std::wstring ws);

// 窄字符串转宽字符串
std::wstring S2WS(std::string s);

// 宽字符串转整数
int WS2I(std::wstring ws);

// 宽字符串转无符号整数
unsigned int WS2UI(std::wstring ws);

// 整数转宽字符串
std::wstring I2WS(int i);

// 无符号整数转宽字符串
std::wstring UI2WS(unsigned int ui);
```

### 1.3 算法函数

#### CRC32

CRC32校验算法。

**头文件**: `LJFP_CRC32.h`

**函数原型**:
```cpp
unsigned int crc32(unsigned int crc, const unsigned char* ptr, unsigned int buf_len);
```

**参数**:
- `crc`: 初始CRC值（通常为0）
- `ptr`: 数据指针
- `buf_len`: 数据长度

**返回值**: CRC32校验值

**示例**:
```cpp
unsigned int crc = crc32(0, data, dataSize);
```

#### SMS4

SMS4加密算法（国密SM4）。

**头文件**: `LJFP_SMS4.h`

**函数原型**:
```cpp
// 加密
void SMS4Ex(unsigned char* inBuff, unsigned char* outBuff, unsigned int uiSize, std::string strPassword);

// 解密
void DeSMS4Ex(unsigned char* inBuff, unsigned char* outBuff, unsigned int uiSize, std::string strPassword);
```

**参数**:
- `inBuff`: 输入缓冲区
- `outBuff`: 输出缓冲区
- `uiSize`: 数据大小
- `strPassword`: 密钥字符串

**注意**:
- 密钥长度必须为16字节
- 数据块大小必须为16字节的倍数

**示例**:
```cpp
std::string key = "locojoy123456789";
SMS4Ex(inData, outData, dataSize, key);
```

#### MiniZ

MiniZ压缩库（zlib兼容）。

**头文件**: `LJFP_MiniZ.h`

**函数原型**:
```cpp
// 压缩
unsigned int mz_compress2(unsigned char *pDest, unsigned int *pDest_len,
                         const unsigned char *pSource, unsigned int source_len, int level);

// 解压
unsigned int mz_uncompress(unsigned char *pDest, unsigned int *pDest_len,
                         const unsigned char *pSource, unsigned int source_len);
```

**参数**:
- `pDest`: 目标缓冲区
- `pDest_len`: 目标缓冲区大小（输入）/ 实际大小（输出）
- `pSource`: 源缓冲区
- `source_len`: 源数据大小
- `level`: 压缩级别（0-9，9为最高）

**返回值**:
- `0`: 成功
- `非0`: 失败

**示例**:
```cpp
unsigned int compressedSize = sourceSize + 256;
unsigned char* compressed = new unsigned char[compressedSize];
mz_compress2(compressed, &compressedSize, source, sourceSize, 9);
```

### 1.4 命令行接口

**可执行文件**: `LJFilePack.exe`

**命令**:

```bash
# 获取版本号
LJFilePack.exe getversionnum

# 获取版本字符串
LJFilePack.exe getversioncaption

# 获取字符串CRC32
LJFilePack.exe getstrcrc32

# 版本文件转换
LJFilePack.exe verljvi2xml:version.ljvi
LJFilePack.exe verxml2ljvi:version.xml

# 索引文件转换
LJFilePack.exe ljpi2xml:pack.ljpi
LJFilePack.exe ljzip2xml:pack.ljzip
```

---

## 2. SuperLJFilePackUnpack API

### 2.1 核心类

#### SLJFP::Unpacker

解包核心类。

**头文件**: `include/SLJFP_Unpack.h`

**命名空间**: `SLJFP`

**构造函数**:
```cpp
Unpacker(
    CRC32_Func crc32Func,      // CRC32函数指针
    Zip_Func zipFunc,          // 压缩函数指针
    UnZip_Func unzipFunc,      // 解压函数指针
    SMS4_Func sms4Func,        // 加密函数指针
    DeSMS4_Func desms4Func     // 解密函数指针
);
```

**公共方法**:

```cpp
// 加载索引文件
int LoadIndex(const std::string& indexFilePath);

// 批量解包
int UnpackAll(const std::string& inputDir,
              const std::string& outputDir,
              const UnpackOptions& options);
int UnpackSelected(const std::vector<size_t>& fileIndices,
                   const std::string& inputDir,
                   const std::string& outputDir,
                   const UnpackOptions& options);

// 会话与单文件
void ConfigureSession(const std::string& inputDir,
                      const std::string& outputDir,
                      const UnpackOptions& options);
int UnpackSingle(size_t index, const std::string& outputPath = "");

// 运行控制
void Stop();
void Pause();
void Resume();
void SetPaused(bool paused);

// 清空数据
void Clear();

// 设置进度回调
void SetProgressCallback(ProgressCallback callback);

// 获取统计信息
uint32_t GetTotalFiles() const;
uint32_t GetProcessedFiles() const;
uint32_t GetFailedFiles() const;
uint64_t GetTotalBytes() const;
uint64_t GetProcessedBytes() const;

// 映射与审计
int LoadPathMapping(const std::string& mapPath);
int LoadPathMappingBinary(const std::string& ljpmPath);
std::vector<FailedFileRecord> GetLastFailedFiles() const;
bool GetFirstFailedDecryptDiagnostic(DecryptFailureDiagnostic& outDiagnostic) const;
std::vector<OutputPathManifestRecord> GetLastOutputPathManifestRecords() const;
```

**返回值**:
- `LJFP_SUCCESS` (0): 成功
- `LJFP_ERR_FILE_NOT_FOUND` (100): 文件不存在
- `LJFP_ERR_INDEX_INVALID_FORMAT` (201): 索引格式无效
- `LJFP_ERR_DECOMPRESS_FAILED` (405): 解压失败
- `LJFP_ERR_CRC32_MISMATCH` (500): CRC32校验失败
- 更多错误码见 `SLJFP_ErrorCodes.h`

### 2.2 数据结构

#### FileInfo

文件信息结构。

**定义**:
```cpp
struct FileInfo {
    unsigned int m_PackIndex;        // 包索引 (0=散文件, >0=包内文件)
    unsigned int m_Pos;              // 包内位置偏移
    unsigned int m_Size;             // 当前大小
    unsigned int m_CRC32;            // 当前CRC32
    unsigned int m_CompressType;     // 压缩类型
    unsigned int m_CodeType;         // 加密类型
    unsigned int m_SizeOriginal;     // 原始大小
    unsigned int m_CRC32Original;    // 原始CRC32
    unsigned int m_PathFileNameCRC32; // 路径文件名CRC32
};
```

#### UnpackOptions

解包选项配置。

**定义**:
```cpp
struct UnpackOptions {
    bool verifyCRC32;
    bool overwriteExisting;
    bool createDirectories;
    int threadCount;
    std::string decryptKey;
    bool useStreamMode;
    uint32_t streamChunkSize;
    bool detectFileType;
    bool preferPathMapping;
    bool organizeByType;
    bool forceCrcOutputFirst;
    bool restorePathStructureAfterUnpack;
    bool strictRestoreValidation;
    bool relocateRootNumericResiduals;
    bool writeReviewAliases;
    bool writePathManifest;
    DecryptMode decryptMode;
};
```

说明：

- CLI `ljfp-unpack` 固定启用 `forceCrcOutputFirst + restorePathStructureAfterUnpack`
- GUI 只暴露常用控件，高级恢复项保持默认值

### 2.3 回调函数

#### ProgressCallback

进度回调函数类型。

**定义**:
```cpp
typedef std::function<void(float progress, uint32_t current, uint32_t total)> ProgressCallback;
```

**参数**:
- `progress`: 进度 (0.0-1.0)
- `current`: 当前文件索引
- `total`: 总文件数

**示例**:
```cpp
unpacker.SetProgressCallback([](float progress, uint32_t current, uint32_t total) {
    std::cout << "Progress: " << (int)(progress * 100) << "% "
              << "(" << current << "/" << total << ")" << std::endl;
});
```

### 2.4 使用示例

**基本用法**:
```cpp
#include "SLJFP_Unpack.h"
#include "SLJFP_Logger_Impl.h"
#include "SLJFP_LibsWrapper.h"

// 初始化日志
InitLogger(L"unpack.log", LOG_LEVEL_INFO);

// 创建解包器
SLJFP::Unpacker unpacker(
    SLJFP_crc32,
    SLJFP_mz_compress2,
    SLJFP_mz_uncompress,
    SLJFP_SMS4Ex,
    SLJFP_DeSMS4Ex
);

// 加载索引文件
int result = unpacker.LoadIndex("path/to/fl.ljpi");
if (result != LJFP_SUCCESS) {
    LJFP_LOG_ERROR(L"Failed to load index");
    return -1;
}

// 配置解包选项
SLJFP::UnpackOptions options;
options.verifyCRC32 = true;
options.overwriteExisting = false;
options.decryptMode = SLJFP::DecryptMode::Auto;
options.writePathManifest = true;

// 设置进度回调
unpacker.SetProgressCallback([](float progress, uint32_t current, uint32_t total) {
    std::cout << "Progress: " << (int)(progress * 100) << "%" << std::endl;
});

// 执行解包
result = unpacker.UnpackAll(
    "path/to/packed/",      // 输入目录
    "path/to/restored/",    // 输出目录
    options
);

if (result == LJFP_SUCCESS) {
    LJFP_LOG_INFO(L"Unpacking completed successfully!");
}

// 关闭日志
CloseLogger();
```

---

## 3. BinLayoutConvert API

### 3.1 CLI工具

**可执行文件**: `BinLayoutConvert.exe`

**命令行参数**:
```bash
# 单文件转换
BinLayoutConvert.exe <file_path>

# 目录批量转换
BinLayoutConvert.exe <directory_path>

# 创建备份
BinLayoutConvert.exe --backup <file_path>

# 多线程模式
BinLayoutConvert.exe --parallel --threads=4 <directory_path>

# 传统模式（不安全）
BinLayoutConvert.exe --legacy <file_path>
```

**选项**:
- `--backup`: 创建.bak备份文件
- `--parallel`: 启用多线程模式
- `--threads=N`: 指定线程数（默认4）
- `--legacy`: 使用传统转换模式（不安全）

### 3.2 GUI工具

**可执行文件**: `BinLayoutStudio.exe`

**CLI模式**:
```bash
# Bin -> XML
BinLayoutStudio.exe --bin2xml <input.bin> <output.xml>

# XML -> Bin
BinLayoutStudio.exe --xml2bin <input.xml> <output.bin>
```

**GUI操作**:
- 打开文件（自动识别BIN/XML）
- 菜单 `转换` → `导出 XML` (Ctrl+E)
- 菜单 `转换` → `导出 BIN` (Ctrl+B)
- 拖拽文件到窗口打开
- 最近文件列表

### 3.3 CEGUI BinLayout API

#### CEGUI::BinLayout::XMLToBin

XML到BinLayout转换器。

**头文件**: `cegui/CEGUI/src/BinLayout/CEGUIXMLToBin.h`

**公共方法**:
```cpp
// 执行转换
bool convert(const std::string& srcPath, const std::string& dstPath);
```

**参数**:
- `srcPath`: 源文件路径（XML）
- `dstPath`: 目标文件路径（BinLayout）

**返回值**:
- `true`: 成功
- `false`: 失败

**示例**:
```cpp
#include "BinLayout/CEGUIXMLToBin.h"

CEGUI::BinLayout::g_RegSerializers_v1();
CEGUI::BinLayout::XMLToBin converter;
converter.convert("layout.xml", "layout.bin");
```

---

## 4. CEGUI API

### 4.1 布局加载

**头文件**: `cegui/CEGUI/include/CEGUI/WindowManager.h`

**函数**:
```cpp
// 从文件加载窗口
Window* loadWindowLayoutFromFile(const String& filename,
                               const String& resourceGroup = "");

// 从内存加载窗口
Window* loadWindowLayoutFromString(const String& source);
```

**参数**:
- `filename`: 布局文件路径（.layout或.bin）
- `resourceGroup`: 资源组名称
- `source`: 布局内容字符串

**返回值**: 窗口指针

**示例**:
```cpp
using namespace CEGUI;

// 自动识别XML或BinLayout格式
Window* root = WindowManager::getSingleton().loadWindowLayoutFromFile("vip.layout");
```

---

## 5. 算法库API

### 5.1 libogg

**头文件**: `libogg/include/ogg/ogg.h`

**主要结构**:
```cpp
// Ogg流状态
typedef struct ogg_stream_state {
    unsigned char   *body_data;    // 数据
    long            body_storage;   // 存储空间
    long            body_fill;     // 填充量
    int             *body_returned; // 返回标记
    // ... 更多字段
} ogg_stream_state;

// Ogg页面
typedef struct ogg_page {
    unsigned char *header;
    long header_len;
    unsigned char *body;
    long body_len;
} ogg_page;

// Ogg包
typedef struct ogg_packet {
    unsigned char *packet;
    long  bytes;
    long  b_o_s;
    long  e_o_s;
    // ... 更多字段
} ogg_packet;
```

**主要函数**:
```cpp
// 初始化流
int ogg_stream_init(ogg_stream_state *os, int serialno);

// 清理流
int ogg_stream_clear(ogg_stream_state *os);

// 写入包
int ogg_stream_packetin(ogg_stream_state *os, ogg_packet *op);

// 读取页面
int ogg_stream_pageout(ogg_stream_state *os, ogg_page *og);

// 解码页面
int ogg_page_packetsin(ogg_page *og, ogg_packet *op);
```

### 5.2 libvorbis

**头文件**: `libvorbis/include/vorbis/codec.h`

**主要结构**:
```cpp
// Vorbis信息
typedef struct vorbis_info {
    int version;           // 编码器版本
    int channels;          // 声道数
    long rate;             // 采样率
    // ... 更多字段
} vorbis_info;

// VorbisDSP状态
typedef struct vorbis_dsp_state {
    int analysisp;
    // ... 更多字段
} vorbis_dsp_state;

// Vorbis块
typedef struct vorbis_block {
    float **pcm;          // PCM数据
    ogg_packet op;        // Ogg包
    // ... 更多字段
} vorbis_block;
```

**主要函数**:
```cpp
// 初始化编码器
int vorbis_encode_init(vorbis_info *vi, long channels, long rate,
                      long max_bitrate, long nominal_bitrate, long min_bitrate);

// 初始化解码器
int vorbis_synthesis_init(vorbis_dsp_state *v, vorbis_info *vi);

// 编码块
int vorbis_analysis(vorbis_block *vb, ogg_packet *op);

// 解码块
int vorbis_synthesis(vorbis_block *vb, ogg_packet *op);
```

### 5.3 libpng

**头文件**: `libpng/include/png.h`

**主要结构**:
```cpp
// PNG信息结构
typedef struct png_info_def png_info;
typedef struct png_struct_def png_struct;

// PNG颜色类型
#define PNG_COLOR_TYPE_GRAY 0
#define PNG_COLOR_TYPE_RGB  2
#define PNG_COLOR_TYPE_RGBA 4
```

**主要函数**:
```cpp
// 创建PNG结构
png_structp png_create_read_struct(png_const_charp user_png_ver,
                                  png_voidp error_ptr,
                                  png_error_ptr error_fn,
                                  png_error_ptr warn_fn);

// 创建信息结构
png_infop png_create_info_struct(png_structp png_ptr);

// 初始化IO
void png_init_io(png_structp png_ptr, FILE *fp);

// 读取PNG信息
void png_read_info(png_structp png_ptr, png_infop info_ptr);

// 读取图像数据
void png_read_image(png_structp png_ptr, png_bytepp image);

// 写入PNG信息
void png_write_info(png_structp png_ptr, png_infop info_ptr);

// 写入图像数据
void png_write_image(png_structp png_ptr, png_bytepp image);
```

**示例**:
```cpp
#include <png.h>

// 读取PNG
FILE *fp = fopen("image.png", "rb");
png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
png_infop info = png_create_info_struct(png);
png_init_io(png, fp);
png_read_info(png, info);

// 获取图像信息
png_uint_32 width, height;
int bit_depth, color_type;
png_get_IHDR(png, info, &width, &height, &bit_depth, &color_type, NULL, NULL, NULL);

// 读取数据
png_bytep *row_pointers = new png_bytep[height];
for (int y = 0; y < height; y++) {
    row_pointers[y] = new png_byte[png_get_rowbytes(png, info)];
}
png_read_image(png, row_pointers);

// 清理
png_destroy_read_struct(&png, &info, NULL);
fclose(fp);
```

---

## 6. 错误码

### 6.1 SuperLJFilePackUnpack错误码

| 错误码 | 常量 | 描述 |
|--------|------|------|
| 0 | `LJFP_SUCCESS` | 操作成功 |
| 100 | `LJFP_ERR_FILE_NOT_FOUND` | 文件不存在 |
| 101 | `LJFP_ERR_FILE_OPEN_FAILED` | 无法打开文件 |
| 102 | `LJFP_ERR_FILE_READ_FAILED` | 文件读取失败 |
| 103 | `LJFP_ERR_FILE_WRITE_FAILED` | 文件写入失败 |
| 105 | `LJFP_ERR_FILE_CREATE_FAILED` | 文件创建失败 |
| 110 | `LJFP_ERR_PARTIAL_FAILURE` | 主流程完成但存在失败文件 |
| 201 | `LJFP_ERR_INDEX_INVALID_FORMAT` | 索引文件格式无效 |
| 203 | `LJFP_ERR_INDEX_CORRUPTED` | 索引文件已损坏 |
| 205 | `LJFP_ERR_INDEX_DECOMPRESS_FAILED` | 索引文件解压失败 |
| 405 | `LJFP_ERR_DECOMPRESS_FAILED` | 数据解压失败 |
| 403 | `LJFP_ERR_DECOMPRESS_TOO_LARGE` | 解压后数据过大 |
| 500 | `LJFP_ERR_CRC32_MISMATCH` | CRC32校验失败 |
| 600 | `LJFP_ERR_PACK_NOT_FOUND` | 包文件不存在 |

---

## 7. 最佳实践

### 7.1 资源打包

1. **使用版本控制**: 始终使用三段式版本号
2. **合理压缩**: 根据文件类型选择压缩级别
3. **加密敏感数据**: 对敏感资源使用SMS4加密
4. **校验完整性**: 始终验证CRC32

### 7.2 资源解包

1. **验证索引**: 加载索引后检查文件数量
2. **进度反馈**: 使用进度回调提供用户反馈
3. **错误处理**: 检查所有返回值
4. **日志记录**: 记录解包过程和错误

### 7.3 布局转换

1. **备份原文件**: 使用`--backup`选项
2. **批量处理**: 使用多线程模式加速
3. **验证转换**: 转换后验证文件格式
4. **版本兼容**: 确保使用正确的版本格式

---

**文档版本**: 1.0
**最后更新**: 2026-01-27
**维护者**: MT3项目组
