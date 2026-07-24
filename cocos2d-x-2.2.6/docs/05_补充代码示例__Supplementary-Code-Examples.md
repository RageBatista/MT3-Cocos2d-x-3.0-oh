# 补充代码示例 __ Supplementary Code Examples

> **版本**: 1.0
> **创建日期**: 2026-01-27
> **目的**: 为Cocos2d-x 2.0.1提供额外的代码示例和实用技巧

---

## 目录

1. [着色器相关](#着色器相关)
2. [物理引擎相关](#物理引擎相关)
3. [音频系统相关](#音频系统相关)
4. [UI组件相关](#ui组件相关)
5. [网络请求相关](#网络请求相关)
6. [数据存储相关](#数据存储相关)
7. [动画相关](#动画相关)
8. [场景管理相关](#场景管理相关)

---

## 着色器相关

### 着色器Uniform绑定示例

```cpp
CCGLProgram* shader = CCGLProgram::create();
shader->initWithVertexShaderFilename("my_vertex.vsh", "my_fragment.fsh");
shader->link();

GLint mvpMatrixLocation = shader->getUniformLocationForName("u_MVPMatrix");
GLint textureLocation = shader->getUniformLocationForName("u_Texture");
GLint timeLocation = shader->getUniformLocationForName("u_Time");
GLint colorLocation = shader->getUniformLocationForName("u_Color");

shader->use();
shader->setUniformLocationWith1i(textureLocation, 0);
shader->setUniformLocationWith1f(timeLocation, CACurrentMediaTime());
shader->setUniformLocationWith4f(colorLocation, 1.0f, 1.0f, 1.0f, 1.0f);
```

### 着色器属性绑定示例

```cpp
CCGLProgram* shader = CCGLProgram::create();
shader->initWithVertexShaderFilename("position_color.vsh", "position_color.fsh");
shader->link();

GLint positionLocation = shader->getAttribLocation("a_Position");
GLint colorLocation = shader->getAttribLocation("a_Color");
GLint texCoordLocation = shader->getAttribLocation("a_TexCoord");

shader->use();
glEnableVertexAttribArray(positionLocation);
glEnableVertexAttribArray(colorLocation);
glEnableVertexAttribArray(texCoordLocation);

glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)offsetof(Vertex, position));
glVertexAttribPointer(colorLocation, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)offsetof(Vertex, color));
glVertexAttribPointer(texCoordLocation, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)offsetof(Vertex, texCoord));
```

---

## 物理引擎相关

### 物理引擎功能示例 (Box2D)

```cpp
b2Vec2 gravity(0.0f, -9.8f);
b2World* world = new b2World(gravity);

b2BodyDef groundDef;
groundDef.position.Set(0.0f, -10.0f);
b2Body* ground = world->CreateBody(&groundDef);

b2PolygonShape groundShape;
groundShape.SetAsBox(50.0f, 1.0f);

b2FixtureDef groundFixture;
groundFixture.shape = &groundShape;
groundFixture.density = 0.0f;
ground->CreateFixture(&groundFixture);
```

### 物理碰撞检测示例

```cpp
class ContactListener : public b2ContactListener {
public:
    void BeginContact(b2Contact* contact) {
        b2Body* bodyA = contact->GetFixtureA()->GetBody();
        b2Body* bodyB = contact->GetFixtureB()->GetBody();
        
        CCNode* nodeA = (CCNode*)bodyA->GetUserData();
        CCNode* nodeB = (CCNode*)bodyB->GetUserData();
        
        CCLog("Collision between %s and %s", 
               nodeA->getDescription().c_str(), 
               nodeB->getDescription().c_str());
    }
};

ContactListener* listener = new ContactListener();
world->SetContactListener(listener);
```

---

## 音频系统相关

### 音频引擎初始化示例

```cpp
SimpleAudioEngine* engine = SimpleAudioEngine::sharedEngine();

engine->preloadEffect("explosion.wav");
engine->preloadEffect("shoot.wav");
engine->preloadEffect("jump.wav");

engine->preloadBackgroundMusic("background.mp3");
engine->preloadBackgroundMusic("menu.mp3");
```

### 音频播放控制示例

```cpp
SimpleAudioEngine* engine = SimpleAudioEngine::sharedEngine();

unsigned int soundId = engine->playEffect("explosion.wav");

engine->stopEffect(soundId);

engine->stopAllEffects();

engine->unloadEffect("explosion.wav");
```

---

## UI组件相关

### 按钮创建示例

```cpp
CCMenuItemImage* button = CCMenuItemImage::create(
    "button_normal.png",
    "button_pressed.png",
    this,
    menu_selector(MyLayer::onButtonClicked)
);

button->setPosition(ccp(visibleSize.width / 2, visibleSize.height / 2));

CCMenu* menu = CCMenu::create(button, NULL);
menu->setPosition(CCPointZero);
this->addChild(menu);
```

### 标签创建示例

```cpp
CCLabelTTF* label = CCLabelTTF::create("Hello World", "Arial", 24);
label->setPosition(ccp(visibleSize.width / 2, visibleSize.height / 2));
label->setColor(ccc3(255, 255, 255));
this->addChild(label);
```

---

## 网络请求相关

### HTTP请求示例

```cpp
CCHttpRequest* request = new CCHttpRequest();
request->setUrl("http://example.com/api/data");
request->setRequestType(CCHttpRequest::kHttpGet);
request->setResponseCallback(this, httpresponse_selector(MyLayer::onHttpRequestCompleted));
request->setTag("GET test");
CCHttpClient::getInstance()->send(request);
request->release();

void MyLayer::onHttpRequestCompleted(CCHttpClient* client, CCHttpResponse* response) {
    if (!response->isSucceed()) {
        CCLog("Request failed");
        return;
    }
    
    std::vector<char>* buffer = response->getResponseData();
    std::string data(buffer->begin(), buffer->end());
    CCLog("Response: %s", data.c_str());
}
```

---

## 数据存储相关

### UserDefault使用示例

```cpp
CCUserDefault* userDefault = CCUserDefault::sharedUserDefault();

userDefault->setIntegerForKey("high_score", 1000);
userDefault->setFloatForKey("volume", 0.5f);
userDefault->setBoolForKey("sound_enabled", true);
userDefault->setStringForKey("player_name", "Player1");

int highScore = userDefault->getIntegerForKey("high_score", 0);
float volume = userDefault->getFloatForKey("volume", 1.0f);
bool soundEnabled = userDefault->getBoolForKey("sound_enabled", true);
std::string playerName = userDefault->getStringForKey("player_name", "Guest");

userDefault->flush();
```

---

## 动画相关

### 帧动画创建示例

```cpp
CCSpriteFrameCache* frameCache = CCSpriteFrameCache::sharedSpriteFrameCache();
frameCache->addSpriteFramesWithFile("player.plist", "player.png");

CCAnimation* animation = CCAnimation::create();
animation->setDelayPerUnit(0.1f);

for (int i = 1; i <= 4; i++) {
    char frameName[64];
    sprintf(frameName, "player_%d.png", i);
    CCSpriteFrame* frame = frameCache->spriteFrameByName(frameName);
    animation->addSpriteFrame(frame);
}

CCAnimate* animate = CCAnimate::create(animation);
CCRepeatForever* repeat = CCRepeatForever::create(animate);
sprite->runAction(repeat);
```

---

## 场景管理相关

### 场景切换示例

```cpp
CCScene* newScene = GameScene::scene();
CCScene* currentScene = CCDirector::sharedDirector()->getRunningScene();

if (currentScene) {
    CCTransitionFade* transition = CCTransitionFade::create(0.5f, newScene);
    CCDirector::sharedDirector()->replaceScene(transition);
} else {
    CCDirector::sharedDirector()->runWithScene(newScene);
}
```

---

## 相关文档

- [00_文档索引__Documentation-Index.md](00_文档索引__Documentation-Index.md)
- [04_关键实现细节与代码示例__Key-Implementation-Details.md](04_关键实现细节与代码示例__Key-Implementation-Details.md)

---

**文档版本**: 1.0
**最后更新**: 2026-01-27
