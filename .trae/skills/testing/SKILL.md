---
name: testing
description: MT3 项目测试技能
---

# 测试技能

> MT3 项目测试技能

## 何时使用

在以下场景使用本技能：

- 需要编写单元测试时
- 需要编写集成测试时
- 需要编写性能测试时
- 需要编写自动化测试时

## 何时不使用

在以下场景不使用本技能：

- 需要开发新功能时 → 使用相应的技能文档
- 需要修复 Bug 时 → 使用相应的技能文档

## 输入要求

使用本技能前需要满足以下条件：

- 已阅读 [公共约束](../references/common-constraints.md)
- 已配置测试框架
- 已熟悉 C++ 和 Lua 语言

## 关键约束

使用本技能时需要注意以下约束：

- **测试框架**: 必须使用 Google Test 框架
- **测试覆盖率**: 关键模块测试覆盖率必须达到 80% 以上
- **性能测试**: 性能测试必须包含 FPS、内存、加载速度
- **兼容性测试**: 必须支持 Windows/Android/iOS 平台

## 单元测试

### 1.1 测试框架

MT3 项目使用 Google Test 框架进行单元测试。

```cpp
#include <gtest/gtest.h>

TEST(TestCaseName, TestName) {
    EXPECT_EQ(1, 1);
}
```

### 1.2 测试示例

#### Manager 测试

```cpp
TEST(GameUIManagerTest, ShowUI) {
    GameUIManager* manager = GameUIManager::sharedManager();
    manager->init();

    manager->showUI("TestDialog");
    EXPECT_TRUE(manager->isUIVisible("TestDialog"));

    manager->cleanup();
}

TEST(GameUIManagerTest, HideUI) {
    GameUIManager* manager = GameUIManager::sharedManager();
    manager->init();

    manager->showUI("TestDialog");
    manager->hideUI("TestDialog");
    EXPECT_FALSE(manager->isUIVisible("TestDialog"));

    manager->cleanup();
}
```

#### Nuclear 引擎测试

```cpp
TEST(NuclearEngineTest, CreateScene) {
    Nuclear::Engine* engine = Nuclear::GetEngine();
    ASSERT_NE(engine, nullptr);

    Nuclear::Scene* scene = engine->CreateScene();
    ASSERT_NE(scene, nullptr);

    engine->DestroyScene(scene);
}
```

#### CEGUI 测试

```cpp
TEST(CEGUITest, CreateWindow) {
    CEGUI::Window* window = CEGUI::WindowManager::getSingleton().createWindow("DefaultWindow", "TestWindow");
    ASSERT_NE(window, nullptr);

    CEGUI::WindowManager::getSingleton().destroyWindow(window);
}
```

### 1.3 测试断言

```cpp
// 相等断言
EXPECT_EQ(expected, actual);
ASSERT_EQ(expected, actual);

// 不等断言
EXPECT_NE(expected, actual);
ASSERT_NE(expected, actual);

// 大于断言
EXPECT_GT(val1, val2);
ASSERT_GT(val1, val2);

// 小于断言
EXPECT_LT(val1, val2);
ASSERT_LT(val1, val2);

// 真值断言
EXPECT_TRUE(condition);
ASSERT_TRUE(condition);

// 假值断言
EXPECT_FALSE(condition);
ASSERT_FALSE(condition);

// 浮点数断言
EXPECT_FLOAT_EQ(expected, actual);
ASSERT_FLOAT_EQ(expected, actual);
```

## 集成测试

### 2.1 测试场景

#### 登录流程测试

```cpp
TEST(IntegrationTest, LoginFlow) {
    LoginManager::sharedManager()->init();
    GameUIManager::sharedManager()->init();

    LoginManager::sharedManager()->login("test", "test", [](bool success, const std::string& error) {
        EXPECT_TRUE(success);
        EXPECT_TRUE(GameUIManager::sharedManager()->isUIVisible("MainDialog"));
    });

    LoginManager::sharedManager()->cleanup();
    GameUIManager::sharedManager()->cleanup();
}
```

#### 战斗流程测试

```cpp
TEST(IntegrationTest, BattleFlow) {
    BattleManager::sharedManager()->init();
    GameUIManager::sharedManager()->init();

    BattleManager::sharedManager()->startBattle(1, [](bool success) {
        EXPECT_TRUE(success);
        EXPECT_EQ(BattleManager::sharedManager()->getBattleState(), BattleState::FIGHTING);
    });

    BattleManager::sharedManager()->cleanup();
    GameUIManager::sharedManager()->cleanup();
}
```

### 2.2 测试设置

```cpp
class IntegrationTest : public ::testing::Test {
protected:
    virtual void SetUp() override {
        InitializeManagers();
    }

    virtual void TearDown() override {
        CleanupManagers();
    }
};

TEST_F(IntegrationTest, TestScenario) {
    // 测试场景
}
```

## 性能测试

### 3.1 FPS 测试

```cpp
TEST(PerformanceTest, FPS) {
    int frameCount = 0;
    auto startTime = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < 1000; i++) {
        CCDirector::sharedDirector()->drawScene();
        frameCount++;
    }

    auto endTime = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(endTime - startTime).count();

    float fps = frameCount * 1000.0f / duration;
    EXPECT_GT(fps, 30.0f);
}
```

### 3.2 内存测试

```cpp
TEST(PerformanceTest, Memory) {
    size_t initialMemory = GetCurrentMemoryUsage();

    for (int i = 0; i < 1000; i++) {
        CCSprite* sprite = CCSprite::create("sprite.png");
        addChild(sprite);
    }

    size_t finalMemory = GetCurrentMemoryUsage();
    size_t memoryIncrease = finalMemory - initialMemory;

    EXPECT_LT(memoryIncrease, 100 * 1024 * 1024); // 小于 100MB
}
```

### 3.3 加载速度测试

```cpp
TEST(PerformanceTest, LoadTime) {
    auto startTime = std::chrono::high_resolution_clock::now();

    GameScene* scene = GameScene::create();
    scene->loadResources();

    auto endTime = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(endTime - startTime).count();

    EXPECT_LT(duration, 3000); // 小于 3 秒
}
```

## 自动化测试

### 4.1 测试脚本

```python
import subprocess
import sys

def run_test(test_name):
    result = subprocess.run(["./test.exe", "--gtest_filter=" + test_name], capture_output=True)
    if result.returncode != 0:
        print(f"Test {test_name} failed")
        print(result.stdout)
        print(result.stderr)
        return False
    return True

if __name__ == "__main__":
    tests = [
        "GameUIManagerTest.ShowUI",
        "GameUIManagerTest.HideUI",
        "NuclearEngineTest.CreateScene",
        "CEGUITest.CreateWindow"
    ]

    for test in tests:
        if not run_test(test):
            sys.exit(1)

    print("All tests passed")
```

### 4.2 持续集成

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build
        run: |
          mkdir build
          cd build
          cmake ..
          cmake --build . --config Release
      - name: Test
        run: |
          cd build
          ctest --config Release --output-on-failure
```

## 最佳实践

### 5.1 单元测试最佳实践

- 每个测试只测试一个功能
- 使用清晰的测试名称
- 使用 Given-When-Then 模式
- 避免测试间的依赖

### 5.2 集成测试最佳实践

- 测试真实的场景
- 使用测试数据
- 模拟外部依赖
- 验证端到端流程

### 5.3 性能测试最佳实践

- 使用性能基线
- 多次运行取平均值
- 监控性能指标
- 优化性能瓶颈

## 参考资料

- [公共约束](../references/common-constraints.md)
- [性能优化指南](../references/performance-guide.md)
- [Google Test 文档](https://google.github.io/googletest/)
