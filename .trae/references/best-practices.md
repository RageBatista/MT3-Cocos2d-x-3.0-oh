# 最佳实践文档

> MT3 项目最佳实践文档

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、代码规范

### 1.1 命名约定

| 类型 | 约定 | 示例 |
|------|------|------|
| 类名 | PascalCase | `GamePlayer`, `SceneManager` |
| 方法/变量 | camelCase | `updatePosition()`, `m_position` |
| 常量 | 全大写下划线 | `MAX_PLAYERS`, `DEFAULT_TIMEOUT` |
| 宏定义 | 全大写下划线 | `MAX_PLAYERS`, `DEFAULT_TIMEOUT` |
| 文件名 | 小写下划线 | `game_player.cpp`, `scene_manager.h` |

### 1.2 代码格式

```cpp
// 缩进：4 空格
// 花括号：行尾
class MyClass {
public:
    MyClass() {
        m_value = 0;
    }

    void setValue(int value) {
        m_value = value;
    }

private:
    int m_value;
};
```

### 1.3 注释规范

```cpp
// 单行注释
int value = 0;

// 多行注释
// 这是一个多行注释
// 用于解释复杂的逻辑
for (int i = 0; i < 10; i++) {
    // 代码
}

// 函数注释
/**
 * @brief 计算两个数的和
 * @param a 第一个数
 * @param b 第二个数
 * @return 两个数的和
 */
int add(int a, int b) {
    return a + b;
}
```

---

## 二、内存管理

### 2.1 引用计数

```cpp
// 使用引用计数管理对象生命周期
CCSprite* sprite = CCSprite::create("sprite.png");
sprite->retain();

// 使用完成后释放
sprite->release();

// 使用自动释放
CCSprite* sprite = CCSprite::create("sprite.png");
addChild(sprite); // 自动释放
```

### 2.2 智能指针

```cpp
// 使用智能指针管理对象
std::shared_ptr<MyClass> obj = std::make_shared<MyClass>();

// 使用弱指针避免循环引用
std::weak_ptr<MyClass> weakObj = obj;

// 获取对象
if (auto ptr = weakObj.lock()) {
    ptr->doSomething();
}
```

### 2.3 对象池

```cpp
// 使用对象池复用对象
class ObjectPool {
public:
    static ObjectPool& getInstance() {
        static ObjectPool instance;
        return instance;
    }

    MyClass* obtain() {
        if (!m_pool.empty()) {
            MyClass* obj = m_pool.back();
            m_pool.pop_back();
            return obj;
        }
        return new MyClass();
    }

    void recycle(MyClass* obj) {
        obj->reset();
        m_pool.push_back(obj);
    }

private:
    std::vector<MyClass*> m_pool;
};
```

---

## 三、错误处理

### 3.1 错误检查

```cpp
// 检查指针是否为空
if (ptr == nullptr) {
    return false;
}

// 检查返回值
if (!manager->init()) {
    printf("Manager init failed\n");
    return false;
}

// 检查文件是否存在
FILE* file = fopen("filename.txt", "rb");
if (file == nullptr) {
    printf("File not found\n");
    return false;
}
fclose(file);
```

### 3.2 异常处理

```cpp
try {
    // 可能抛出异常的代码
    doSomething();
} catch (const std::exception& e) {
    printf("Exception: %s\n", e.what());
    return false;
}
```

### 3.3 日志记录

```cpp
// 使用日志系统记录错误
Logger::log(Logger::Level::ERROR, "Error message");

// 使用日志系统记录警告
Logger::log(Logger::Level::WARNING, "Warning message");

// 使用日志系统记录信息
Logger::log(Logger::Level::INFO, "Info message");
```

---

## 四、性能优化

### 4.1 减少内存分配

```cpp
// 错误：频繁分配内存
void Update() {
    for (int i = 0; i < 100; i++) {
        int* array = new int[100];
        // 使用数组
        delete[] array;
    }
}

// 正确：复用内存
void Update() {
    int* array = new int[100];
    for (int i = 0; i < 100; i++) {
        // 使用数组
    }
    delete[] array;
}
```

### 4.2 减少函数调用

```cpp
// 错误：频繁调用函数
void Update() {
    for (int i = 0; i < 100; i++) {
        float x = getPosition().x;
        float y = getPosition().y;
        float z = getPosition().z;
    }
}

// 正确：缓存函数结果
void Update() {
    CCPoint pos = getPosition();
    for (int i = 0; i < 100; i++) {
        float x = pos.x;
        float y = pos.y;
        float z = pos.z;
    }
}
```

### 4.3 使用批处理

```cpp
// 使用批处理减少 Draw Call
CCSpriteBatchNode* batchNode = CCSpriteBatchNode::create("sprites.png");
addChild(batchNode);

for (int i = 0; i < 100; i++) {
    CCSprite* sprite = CCSprite::createWithTexture(batchNode->getTexture());
    sprite->setPosition(i * 10, 0);
    batchNode->addChild(sprite);
}
```

---

## 五、线程安全

### 5.1 使用互斥锁

```cpp
// 使用互斥锁保护共享资源
class ThreadSafeCounter {
public:
    void increment() {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_count++;
    }

    int getCount() {
        std::lock_guard<std::mutex> lock(m_mutex);
        return m_count;
    }

private:
    std::mutex m_mutex;
    int m_count;
};
```

### 5.2 使用原子操作

```cpp
// 使用原子操作避免锁
class AtomicCounter {
public:
    void increment() {
        m_count.fetch_add(1, std::memory_order_relaxed);
    }

    int getCount() {
        return m_count.load(std::memory_order_relaxed);
    }

private:
    std::atomic<int> m_count;
};
```

---

## 六、资源管理

### 6.1 资源加载

```cpp
// 异步加载资源
void LoadResourcesAsync(std::function<void(bool)> callback) {
    std::thread thread([callback]() {
        bool success = LoadResources();
        callback(success);
    });
    thread.detach();
}
```

### 6.2 资源释放

```cpp
// 及时释放资源
void CleanupResources() {
    for (auto sprite : m_sprites) {
        sprite->removeFromParent();
    }
    m_sprites.clear();
}
```

### 6.3 资源缓存

```cpp
// 使用资源缓存
class ResourceCache {
public:
    static ResourceCache& getInstance() {
        static ResourceCache instance;
        return instance;
    }

    CCSprite* getSprite(const std::string& filename) {
        auto it = m_cache.find(filename);
        if (it != m_cache.end()) {
            return it->second;
        }

        CCSprite* sprite = CCSprite::create(filename.c_str());
        m_cache[filename] = sprite;
        return sprite;
    }

private:
    std::map<std::string, CCSprite*> m_cache;
};
```

---

## 七、调试技巧

### 7.1 使用断言

```cpp
// 使用断言检查前置条件
void SetValue(int value) {
    assert(value >= 0 && value <= 100);
    m_value = value;
}
```

### 7.2 使用日志

```cpp
// 使用日志记录关键信息
Logger::log(Logger::Level::INFO, "Function started");
Logger::log(Logger::Level::INFO, "Function completed");
```

### 7.3 使用调试器

- 设置断点
- 查看变量
- 单步执行
- 查看调用堆栈

---

## 八、文档编写

### 8.1 代码注释

```cpp
// 函数注释
/**
 * @brief 计算两个数的和
 * @param a 第一个数
 * @param b 第二个数
 * @return 两个数的和
 */
int add(int a, int b) {
    return a + b;
}
```

### 8.2 文档格式

```markdown
# 文档标题

## 章节

### 子章节

- 列表项
- 列表项

代码示例：
```cpp
int value = 0;
```
```

---

## 九、版本控制

### 9.1 提交信息

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 9.2 分支策略

- `master`: 主分支，用于发布
- `develop`: 开发分支，用于集成
- `feature/*`: 功能分支，用于开发新功能
- `bugfix/*`: 修复分支，用于修复 Bug
- `release/*`: 发布分支，用于准备发布

---

## 十、参考资料

- [公共约束](../references/common-constraints.md)
- [性能优化指南](../references/performance-guide.md)
- [跨平台最佳实践](../references/cross-platform-best-practices.md)
