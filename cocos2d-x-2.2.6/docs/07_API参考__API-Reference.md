# API参考 __ API Reference

> **版本**: 1.0
> **创建日期**: 2026-01-27
> **目的**: 提供Cocos2d-x 2.0.1的全局函数、宏、数据结构和模块API参考

---

## 目录

1. [全局函数](#全局函数)
2. [宏定义](#宏定义)
3. [数据结构](#数据结构)
4. [模块API](#模块api)

---

## 全局函数

### 点操作函数

```cpp
// 创建点（宏定义）
#define CCPointMake(x, y) CCPoint((float)(x), (float)(y))

// 点相加
CCPoint ccpAdd(const CCPoint& v1, const CCPoint& v2);

// 点相减
CCPoint ccpSub(const CCPoint& v1, const CCPoint& v2);

// 点乘标量
CCPoint ccpMult(const CCPoint& v, float s);

// 点除标量
CCPoint ccpDiv(const CCPoint& v, float s);

// 点取负
CCPoint ccpNeg(const CCPoint& v);

// 点长度
float ccpLength(const CCPoint& v);

// 点归一化
CCPoint ccpNormalize(const CCPoint& v);

// 点距离
float ccpDistance(const CCPoint& v1, const CCPoint& v2);

// 点距离平方
float ccpDistanceSQ(const CCPoint& v1, const CCPoint& v2);
```

### 尺寸操作函数

```cpp
// 创建尺寸（宏定义）
#define CCSizeMake(width, height) CCSize((float)(width), (float)(height))

// 尺寸相加
CCSize CCSizeAdd(const CCSize& s1, const CCSize& s2);

// 尺寸相减
CCSize CCSizeSub(const CCSize& s1, const CCSize& s2);

// 尺寸相乘
CCSize CCSizeMult(const CCSize& s, float f);
```

### 矩形操作函数

```cpp
// 创建矩形（宏定义）
#define CCRectMake(x, y, width, height) CCRect((float)(x), (float)(y), (float)(width), (float)(height))

// 矩形包含点
bool CCRectContainsPoint(const CCRect& rect, const CCPoint& point);

// 矩形相交
bool CCRectIntersectsRect(const CCRect& rect1, const CCRect& rect2);

// 矩形合并
CCRect CCRectUnion(const CCRect& rect1, const CCRect& rect2);
```

---

## 宏定义

### 数学宏

```cpp
// 最小值
#define MIN(x, y) (((x) < (y)) ? (x) : (y))

// 最大值
#define MAX(x, y) (((x) > (y)) ? (x) : (y))

// 绝对值
#define ABS(x) (((x) < 0) ? -(x) : (x))

// 交换值
#define SWAP(x, y) do { typeof(x) temp = x; x = y; y = temp; } while(0)
```

### 调试宏

```cpp
// 断言
#define CCAssert(cond, msg)

// 条件断言
#define CCAssert(cond, msg)

// 日志输出
#define CCLog(format, ...)

// 警告输出
#define CCWarn(format, ...)
```

### 内存管理宏

```cpp
// 安全删除
#define CC_SAFE_DELETE(p) do { delete (p); (p) = NULL; } while(0)

// 安全删除数组
#define CC_SAFE_DELETE_ARRAY(p) do { delete[] (p); (p) = NULL; } while(0)

// 安全释放
#define CC_SAFE_RELEASE(p) do { if(p) { (p)->release(); (p) = NULL; } } while(0)
```

---

## 数据结构

### CCPoint

```cpp
struct CCPoint {
    float x;
    float y;
    
    CCPoint();
    CCPoint(float x, float y);
    CCPoint(const CCPoint& other);
    CCPoint& operator=(const CCPoint& other);
    void setPoint(float x, float y);
    bool equals(const CCPoint& target) const;
};
```

### CCSize

```cpp
struct CCSize {
    float width;
    float height;
    
    CCSize();
    CCSize(float width, float height);
    CCSize(const CCSize& other);
    CCSize& operator=(const CCSize& other);
    void setSize(float width, float height);
    bool equals(const CCSize& target) const;
};
```

### CCRect

```cpp
struct CCRect {
    float originX;
    float originY;
    float sizeWidth;
    float sizeHeight;
    
    CCRect();
    CCRect(float x, float y, float width, float height);
    CCRect(const CCRect& other);
    CCRect& operator=(const CCRect& other);
    void setRect(float x, float y, float width, float height);
    float getMinX() const;
    float getMidX() const;
    float getMaxX() const;
    float getMinY() const;
    float getMidY() const;
    float getMaxY() const;
    bool equals(const CCRect& rect) const;
    bool containsPoint(const CCPoint& point) const;
    bool intersectsRect(const CCRect& rect) const;
};
```

---

## 模块API

### CCDirector API

```cpp
// 获取单例
static CCDirector* sharedDirector(void);

// 运行场景
void runWithScene(CCScene* scene);

// 替换场景
void replaceScene(CCScene* scene);

// 推入场景
void pushScene(CCScene* scene);

// 弹出场景
void popScene(void);

// 弹出到根场景
void popToRootScene(void);

// 获取运行场景
CCScene* getRunningScene(void);

// 暂停
void pause(void);

// 恢复
void resume(void);

// 获取动画间隔
float getAnimationInterval(void);

// 设置动画间隔
void setAnimationInterval(double interval);
```

### CCTextureCache API

```cpp
// 获取单例
static CCTextureCache* sharedTextureCache(void);

// 添加图像纹理
CCTexture2D* addImage(const char* path);

// 添加纹理
void addTexture(CCTexture2D* texture, const char* key);

// 移除纹理
void removeTexture(CCTexture2D* texture);

// 移除未使用纹理
void removeUnusedTextures(void);

// 重置缓存
void removeAllTextures(void);
```

### CCSpriteFrameCache API

```cpp
// 获取单例
static CCSpriteFrameCache* sharedSpriteFrameCache(void);

// 添加精灵帧
void addSpriteFramesWithFile(const char* plist, const char* textureFileName);

// 添加精灵帧
void addSpriteFramesWithFileContent(const char* plistContent, const char* textureFileName);

// 获取精灵帧
CCSpriteFrame* spriteFrameByName(const char* name);

// 移除精灵帧
void removeSpriteFrames(void);

// 移除未使用精灵帧
void removeUnusedSpriteFrames(void);
```

---

## 相关文档

- [00_文档索引__Documentation-Index.md](00_文档索引__Documentation-Index.md)
- [01_项目概览__Project-Overview.md](01_项目概览__Project-Overview.md)
- [02_核心类架构__Core-Classes-Architecture.md](02_核心类架构__Core-Classes-Architecture.md)

---

**文档版本**: 1.0
**最后更新**: 2026-01-27
