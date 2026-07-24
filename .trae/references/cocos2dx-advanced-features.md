# Cocos2d-x 高级特性文档

> MT3 项目 Cocos2d-x 2.0 高级特性文档

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、自定义着色器

### 1.1 创建自定义着色器

```cpp
// 顶点着色器
const char* vertexShader = R"(
    attribute vec4 a_position;
    attribute vec2 a_texCoord;
    attribute vec4 a_color;

    uniform mat4 u_MVPMatrix;

    varying vec2 v_texCoord;
    varying vec4 v_color;

    void main() {
        gl_Position = u_MVPMatrix * a_position;
        v_texCoord = a_texCoord;
        v_color = a_color;
    }
)";

// 片段着色器
const char* fragmentShader = R"(
    varying vec2 v_texCoord;
    varying vec4 v_color;

    uniform sampler2D u_texture;

    void main() {
        gl_FragColor = v_color * texture2D(u_texture, v_texCoord);
    }
)";

// 创建着色器程序
CCGLProgram* shader = new CCGLProgram();
shader->initWithVertexShaderByteArray(vertexShader, fragmentShader);
shader->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
shader->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
shader->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
shader->link();
shader->updateUniforms();

// 应用着色器
sprite->setShaderProgram(shader);
```

### 1.2 着色器 Uniform 变量

```cpp
// 设置 Uniform 变量
shader->use();
GLint mvpLocation = shader->getUniformLocationForName("u_MVPMatrix");
CCDirector::sharedDirector()->getProjectionMatrix();
CCDirector::sharedDirector()->getModelViewMatrix();
kmMat4 mvpMatrix;
kmMat4Multiply(&mvpMatrix, &projectionMatrix, &modelViewMatrix);
shader->setUniformLocationWithMatrix4fv(mvpLocation, mvpMatrix.mat);
```

---

## 二、自定义渲染器

### 2.1 创建自定义渲染器

```cpp
// 自定义渲染器
class CustomRenderer : public CCNode {
public:
    static CustomRenderer* create() {
        CustomRenderer* renderer = new CustomRenderer();
        if (renderer->init()) {
            renderer->autorelease();
            return renderer;
        }
        CC_SAFE_DELETE(renderer);
        return nullptr;
    }

    virtual void draw() {
        CC_NODE_DRAW_SETUP();

        // 自定义渲染逻辑
        ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords);

        ccDrawColor4B(255, 255, 255, 255);

        // 绘制三角形
        ccVertex2F vertices[3] = {
            {0, 100},
            {-100, -100},
            {100, -100}
        };

        ccDrawPoly(vertices, 3, true);
    }
};
```

---

## 三、自定义动作

### 3.1 创建自定义动作

```cpp
// 自定义动作
class CustomAction : public CCActionInterval {
public:
    static CustomAction* create(float duration) {
        CustomAction* action = new CustomAction();
        action->initWithDuration(duration);
        action->autorelease();
        return action;
    }

    virtual void update(float time) {
        if (m_pTarget) {
            // 自定义动作逻辑
            float scale = 1.0f + sin(time * M_PI * 2) * 0.2f;
            m_pTarget->setScale(scale);
        }
    }
};

// 使用自定义动作
CCAction* action = CustomAction::create(2.0f);
sprite->runAction(action);
```

---

## 四、自定义精灵

### 4.1 创建自定义精灵

```cpp
// 自定义精灵
class CustomSprite : public CCSprite {
public:
    static CustomSprite* create(const char* filename) {
        CustomSprite* sprite = new CustomSprite();
        if (sprite->initWithFile(filename)) {
            sprite->autorelease();
            return sprite;
        }
        CC_SAFE_DELETE(sprite);
        return nullptr;
    }

    virtual void draw() {
        CCSprite::draw();

        // 自定义绘制
        ccDrawColor4B(255, 0, 0, 255);
        ccDrawRect(0, 0, getContentSize().width, getContentSize().height);
    }
};

// 使用自定义精灵
CustomSprite* sprite = CustomSprite::create("sprite.png");
addChild(sprite);
```

---

## 五、性能优化

### 5.1 精灵批处理

```cpp
// 使用 CCSpriteBatchNode 批处理精灵
CCSpriteBatchNode* batchNode = CCSpriteBatchNode::create("sprites.png");
addChild(batchNode);

for (int i = 0; i < 100; i++) {
    CCSprite* sprite = CCSprite::createWithTexture(batchNode->getTexture());
    sprite->setPosition(i * 10, 0);
    batchNode->addChild(sprite);
}
```

### 5.2 对象池

```cpp
// 对象池
class SpritePool {
public:
    static SpritePool* getInstance() {
        static SpritePool instance;
        return &instance;
    }

    CCSprite* obtain() {
        if (!m_pool.empty()) {
            CCSprite* sprite = m_pool.back();
            m_pool.pop_back();
            return sprite;
        }
        return CCSprite::create("sprite.png");
    }

    void recycle(CCSprite* sprite) {
        sprite->setVisible(false);
        m_pool.push_back(sprite);
    }

private:
    std::vector<CCSprite*> m_pool;
};

// 使用对象池
CCSprite* sprite = SpritePool::getInstance()->obtain();
addChild(sprite);

// 回收对象
SpritePool::getInstance()->recycle(sprite);
```

---

## 六、最佳实践

### 6.1 着色器最佳实践

- 使用 GLSL 1.20 版本
- 优化着色器性能
- 使用 Uniform 缓冲
- 避免复杂的计算

### 6.2 渲染器最佳实践

- 使用批处理减少 Draw Call
- 优化渲染顺序
- 使用视锥体裁剪
- 使用 LOD (Level of Detail)

### 6.3 动作最佳实践

- 使用动作池
- 优化动作参数
- 使用动作序列
- 避免频繁创建动作

---

## 七、参考资料

- [Cocos2d-x 技能](../skills/cocos2dx/SKILL.md)
- [Cocos2d-x 工具使用指南](../references/cocos2dx-tools.md)
- [性能优化指南](../references/performance-guide.md)
