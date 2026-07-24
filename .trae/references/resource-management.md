# 资源管理策略

> 本文件定义了 MT3 项目中的资源管理策略，包括加载、释放、热更新等。

## 目录

- [资源分类](#资源分类)
- [资源加载](#资源加载)
- [资源释放](#资源释放)
- [资源生命周期管理](#资源生命周期管理)
- [资源热更新](#资源热更新)
- [资源缓存策略](#资源缓存策略)
- [资源打包](#资源打包)
- [常见问题](#常见问题)
- [参考文档](#参考文档)

---

## 资源分类

### CEGUI 资源

| 类型 | 扩展名 | 位置 | 说明 |
|------|--------|------|------|
| 布局文件 | `.layout` | `client/resource/ui/` | UI 布局定义 |
| 方案文件 | `.scheme` | `client/resource/ui/` | 控件样式方案 |
| 外观文件 | `.looknfeel` | `client/resource/ui/` | 控件外观定义 |
| 图片集 | `.imageset` | `client/resource/ui/` | UI 图片集合 |
| 字体文件 | `.font` | `client/resource/ui/` | 字体定义 |

### Cocos2d-x 资源

| 类型 | 扩展名 | 位置 | 说明 |
|------|--------|------|------|
| 纹理图片 | `.png` | `client/resource/` | 纹理图片 |
| 精灵帧 | `.plist` | `client/resource/` | 精灵帧定义 |
| 动画文件 | `.xml` | `client/resource/` | 动画定义 |
| 音频文件 | `.mp3`, `.wav` | `client/resource/` | 音频资源 |

### Nuclear 资源

| 类型 | 扩展名 | 位置 | 说明 |
|------|--------|------|------|
| 特效文件 | `.fx`, `.xml` | `client/resource/effect/` | 特效定义 |
| 着色器 | `.glsl`, `.vs`, `.fs` | `client/resource/shader/` | 着色器代码 |

## 资源加载

### CEGUI 资源加载

```cpp
// 加载方案文件（必须先加载）
void loadCEGUIResources() {
    // 1. 加载方案文件（包含控件类型定义）
    CEGUI::SchemeManager::getSingleton().loadScheme("TaharezLook.scheme");
    CEGUI::SchemeManager::getSingleton().loadScheme("VanillaSkin.scheme");

    // 2. 加载图片集
    CEGUI::ImagesetManager::getSingleton().createImageset("common.imageset");

    // 3. 加载字体
    CEGUI::FontManager::getSingleton().createFont("simhei.font");

    // 4. 设置默认字体
    CEGUI::System::getSingleton().setDefaultFont("simhei");
}

// 加载布局文件
CEGUI::Window* loadLayout(const std::string& layoutFile) {
    try {
        return CEGUI::WindowManager::getSingleton().loadWindowLayout(layoutFile);
    } catch (const CEGUI::Exception& e) {
        LOG_ERROR("Failed to load layout %s: %s", layoutFile.c_str(), e.what());
        return nullptr;
    }
}
```

### Cocos2d-x 资源加载

```cpp
// 加载精灵帧缓存
void loadSpriteFrames(const std::string& plistFile, const std::string& textureFile) {
    CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile(
        plistFile.c_str(),
        textureFile.c_str()
    );
}

// 加载纹理
void loadTexture(const std::string& textureFile) {
    CCTextureCache::sharedTextureCache()->addImage(textureFile.c_str());
}

// 异步加载资源
void loadResourcesAsync() {
    CCTextureCache::sharedTextureCache()->addImageAsync(
        "background.png",
        this,
        callfuncO_selector(MyLayer::onTextureLoaded)
    );
}

void onTextureLoaded(CCTexture2D* texture) {
    // 纹理加载完成回调
    LOG_INFO("Texture loaded: %s", texture->getName());
}
```

### Nuclear 资源加载

```cpp
// 加载特效
Nuclear::IEffect* loadEffect(const std::string& effectName) {
    Nuclear::Engine* engine = static_cast<Nuclear::Engine*>(Nuclear::GetEngine());
    if (!engine) {
        return nullptr;
    }

    Nuclear::EffectManager* effectMan = engine->GetEffectManager();
    return effectMan->CreateEffect(effectName.c_str());
}
```

## 资源释放

### CEGUI 资源释放

```cpp
// 释放单个窗口
void releaseWindow(CEGUI::Window* window) {
    if (window) {
        // 1. 移除事件订阅
        window->removeAllEvents();

        // 2. 从父窗口移除
        if (window->getParent()) {
            window->getParent()->removeChild(window);
        }

        // 3. 销毁窗口
        CEGUI::WindowManager::getSingleton().destroyWindow(window);
    }
}

// 释放所有 CEGUI 资源
void releaseAllCEGUIResources() {
    // 1. 释放所有窗口
    CEGUI::WindowManager::getSingleton().destroyAllWindows();

    // 2. 释放所有图片集
    CEGUI::ImagesetManager::getSingleton().destroyAll();

    // 3. 释放所有字体
    CEGUI::FontManager::getSingleton().freeAllFont();

    // 4. 释放所有方案
    CEGUI::SchemeManager::getSingleton().unloadAllSchemes();
}
```

### Cocos2d-x 资源释放

```cpp
// 释放纹理
void releaseTexture(const std::string& textureFile) {
    CCTextureCache::sharedTextureCache()->removeTexture(textureFile.c_str());
}

// 释放未使用的纹理
void releaseUnusedTextures() {
    CCTextureCache::sharedTextureCache()->removeUnusedTextures();
}

// 释放精灵帧
void releaseSpriteFrames(const std::string& plistFile) {
    CCSpriteFrameCache::sharedSpriteFrameCache()->removeSpriteFramesFromFile(plistFile.c_str());
}

// 释放未使用的精灵帧
void releaseUnusedSpriteFrames() {
    CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFrames();
}

// 清空所有缓存
void clearAllCaches() {
    CCTextureCache::sharedTextureCache()->removeAllTextures();
    CCSpriteFrameCache::sharedSpriteFrameCache()->removeSpriteFrames();
}
```

### Nuclear 资源释放

```cpp
// 释放特效
void releaseEffect(Nuclear::IEffect* effect) {
    if (effect) {
        // 1. 从映射表中移除
        m_mapUIEffect.erase(effect);

        // 2. 销毁特效
        Nuclear::Engine* engine = static_cast<Nuclear::Engine*>(Nuclear::GetEngine());
        if (engine) {
            Nuclear::EffectManager* effectMan = engine->GetEffectManager();
            effectMan->DestroyEffect(effect);
        }
        effect = nullptr;
    }
}

// 释放所有特效
void releaseAllEffects() {
    Nuclear::Engine* engine = static_cast<Nuclear::Engine*>(Nuclear::GetEngine());
    if (!engine) {
        return;
    }

    Nuclear::EffectManager* effectMan = engine->GetEffectManager();

    // 清空映射表
    m_mapUIEffect.clear();

    // 销毁所有特效
    // 注意：需要根据实际 API 调整
}
```

## 资源生命周期管理

### 资源加载顺序

```cpp
// 推荐的资源加载顺序
void loadGameResources() {
    // 1. 加载公共资源（字体、基础 UI）
    loadCommonResources();

    // 2. 加载场景资源
    loadSceneResources();

    // 3. 加载角色资源
    loadCharacterResources();

    // 4. 加载特效资源
    loadEffectResources();
}

void loadCommonResources() {
    // 加载 CEGUI 方案
    CEGUI::SchemeManager::getSingleton().loadScheme("TaharezLook.scheme");

    // 加载公共字体
    CEGUI::FontManager::getSingleton().createFont("simhei.font");

    // 加载公共精灵帧
    CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile("common.plist", "common.png");
}
```

### 资源释放顺序

```cpp
// 推荐的资源释放顺序（与加载相反）
void releaseGameResources() {
    // 1. 释放特效资源
    releaseEffectResources();

    // 2. 释放角色资源
    releaseCharacterResources();

    // 3. 释放场景资源
    releaseSceneResources();

    // 4. 释放公共资源
    releaseCommonResources();
}
```

### 场景切换时的资源管理

```cpp
// 场景切换前释放旧场景资源
void onSceneExit() {
    // 1. 停止所有动画
    stopAllAnimations();

    // 2. 释放未使用的资源
    releaseUnusedResources();

    // 3. 清理特效
    cleanupEffects();
}

// 场景切换后加载新场景资源
void onSceneEnter() {
    // 1. 预加载新场景资源
    preloadSceneResources();

    // 2. 异步加载剩余资源
    asyncLoadRemainingResources();
}
```

## 资源热更新

### 资源版本管理

```cpp
// 资源版本信息
struct ResourceVersion {
    std::string name;
    std::string version;
    std::string md5;
    size_t size;
};

// 加载资源版本列表
std::vector<ResourceVersion> loadResourceVersions(const std::string& versionFile) {
    std::vector<ResourceVersion> versions;

    // 从服务器或本地文件加载版本信息
    // ...

    return versions;
}

// 检查资源是否需要更新
bool needUpdate(const ResourceVersion& local, const ResourceVersion& remote) {
    return local.version != remote.version || local.md5 != remote.md5;
}
```

### 资源下载

```cpp
// 下载资源
void downloadResource(const std::string& url, const std::string& localPath) {
    // 使用 libcurl 下载资源
    CURL* curl = curl_easy_init();
    if (curl) {
        FILE* fp = fopen(localPath.c_str(), "wb");
        if (fp) {
            curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);

            CURLcode res = curl_easy_perform(curl);
            if (res != CURLE_OK) {
                LOG_ERROR("Failed to download resource: %s", curl_easy_strerror(res));
            }

            fclose(fp);
        }
        curl_easy_cleanup(curl);
    }
}

// 写入数据回调
size_t write_data(void* ptr, size_t size, size_t nmemb, FILE* stream) {
    return fwrite(ptr, size, nmemb, stream);
}
```

### 资源验证

```cpp
// 计算文件 MD5
std::string calculateMD5(const std::string& filePath) {
    // 使用 OpenSSL 计算 MD5
    // ...

    return md5;
}

// 验证资源完整性
bool verifyResource(const std::string& filePath, const std::string& expectedMD5) {
    std::string actualMD5 = calculateMD5(filePath);
    return actualMD5 == expectedMD5;
}
```

## 资源缓存策略

### 内存缓存

```cpp
// 资源缓存管理器
class ResourceCache {
public:
    static ResourceCache& getInstance() {
        static ResourceCache instance;
        return instance;
    }

    template<typename T>
    T* get(const std::string& key) {
        auto it = m_cache.find(key);
        if (it != m_cache.end()) {
            return static_cast<T*>(it->second);
        }
        return nullptr;
    }

    template<typename T>
    void put(const std::string& key, T* resource) {
        m_cache[key] = resource;
    }

    void remove(const std::string& key) {
        m_cache.erase(key);
    }

    void clear() {
        m_cache.clear();
    }

private:
    std::map<std::string, void*> m_cache;
};
```

### 磁盘缓存

```cpp
// 磁盘缓存路径
const std::string DISK_CACHE_PATH = "cache/";

// 保存资源到磁盘缓存
void saveToDiskCache(const std::string& key, const std::string& data) {
    std::string filePath = DISK_CACHE_PATH + key;

    // 确保目录存在
    createDirectory(DISK_CACHE_PATH);

    // 写入文件
    FILE* fp = fopen(filePath.c_str(), "wb");
    if (fp) {
        fwrite(data.c_str(), 1, data.size(), fp);
        fclose(fp);
    }
}

// 从磁盘缓存加载资源
std::string loadFromDiskCache(const std::string& key) {
    std::string filePath = DISK_CACHE_PATH + key;

    FILE* fp = fopen(filePath.c_str(), "rb");
    if (fp) {
        fseek(fp, 0, SEEK_END);
        long size = ftell(fp);
        fseek(fp, 0, SEEK_SET);

        std::string data(size, '\0');
        fread(&data[0], 1, size, fp);
        fclose(fp);

        return data;
    }

    return "";
}
```

## 资源打包

### 使用 LJFilePackUnpacker

```bash
# 打包资源
tools/LJFilePackUnpacker/LJFPU.exe pack input_dir output.pack

# 解包资源
tools/LJFilePackUnpacker/LJFPU.exe unpack input.pack output_dir
```

## 常见问题

### 问题：资源加载失败

**可能原因**：
- 文件路径错误
- 文件不存在
- 文件损坏

**解决方案**：
- 检查文件路径是否正确
- 验证文件是否存在
- 检查文件完整性

### 问题：内存泄漏

**可能原因**：
- 资源未释放
- 循环引用
- 对象未正确销毁

**解决方案**：
- 确保资源在使用后释放
- 检查对象引用关系
- 使用内存泄漏检测工具

### 问题：资源加载慢

**可能原因**：
- 资源文件过大
- 同步加载阻塞
- 磁盘 I/O 瓶颈

**解决方案**：
- 压缩资源文件
- 使用异步加载
- 使用资源分包

## 参考文档

- [公共约束](common-constraints.md)
- [性能优化](performance-guide.md)
- [Nuclear 集成](nuclear-integration.md)
