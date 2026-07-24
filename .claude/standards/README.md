# C++ 编码标准 (C++ Coding Standards)

> **范围**: MT3 项目 C++ 代码规范
> **版本**: 1.0 | **更新**: 2026-01-07

---

## 📚 文档导航

### 核心标准文档

| 文档 | 用途 | 适用范围 |
|-----|------|----------|
| [cpp-naming.md](cpp-naming.md) | 命名约定 | 类/函数/变量/常量/宏 |
| [cpp-patterns.md](cpp-patterns.md) | 设计模式 | 对象池/脏标记/引用计数 |

---

## 🎯 标准分层

### Layer 1: 引擎层 (engine/)

```yaml
适用范围: engine/**/*.h, engine/**/*.cpp
命名风格: Nuclear 自定义风格
关键模式:
  - 引用计数内存管理
  - 脏标记优化
  - 对象池复用
```

### Layer 2: Cocos2d-x 层

```yaml
适用范围: cocos2d-2.0-rc2-x-2.0.1/**/*
命名风格: Cocos2d-x 2.0 风格 (不可修改)
关键模式:
  - CCObject 引用计数
  - autorelease 自动释放池
  - retain/release 手动管理
```

### Layer 3: 工具层 (common/)

```yaml
适用范围: common/**/*.h, common/**/*.cpp
命名风格: 标准 C++ 风格
关键模式:
  - RAII 资源管理
  - 智能指针 (慎用)
  - 异常安全
```

### Layer 4: 业务层 (client/FireClient/)

```yaml
适用范围: client/FireClient/**/*
命名风格: FireClient 业务风格 (预编译库,不可修改)
关键模式:
  - IFireClient 接口
  - 协议处理
  - 数据管理
```

### Layer 5: 脚本层 (Lua)

```yaml
适用范围: client/resource/script/**/*.lua
命名风格: Lua 风格 (见 lua-naming.md)
关键模式:
  - 局部化全局变量
  - 对象复用避免 GC
  - 表预分配
```

---

## 🚦 标准选择流程图

```
新建 C++ 文件
    ↓
┌────────────────┐
│ 确定所属层级    │
└────┬───────────┘
     ├─→ engine/ → [Nuclear 命名风格] → [引用计数模式]
     ├─→ cocos2d/ → [Cocos2d-x 风格] → [CCObject 模式] (不可修改)
     ├─→ common/ → [标准 C++ 风格] → [RAII 模式]
     ├─→ client/FireClient/ → [FireClient 风格] (不可修改)
     └─→ 脚本绑定 → [tolua++ 风格] → [绑定模式]
```

---

## 📖 快速参考

### 命名速查表

| 类型 | engine/ | common/ | 示例 |
|-----|---------|---------|------|
| 类名 | NuclearXxx | XxxManager | `NuclearSprite`, `TextureManager` |
| 成员变量 | m_xxxYyy | m_xxxYyy | `m_nHealth`, `m_fScale` |
| 成员函数 | XxxYyy | xxxYyy | `SetLocation`, `getTexture` |
| 常量 | MAX_XXX | kMaxXxx | `MAX_SPRITES`, `kMaxPlayers` |
| 宏 | NUCLEAR_XXX | XXX_HELPER | `NUCLEAR_SAFE_DELETE`, `SAFE_RELEASE` |

### 设计模式速查

| 模式 | 用途 | 适用层 |
|-----|------|--------|
| 引用计数 | 内存管理 | engine, cocos2d |
| 对象池 | 性能优化 | engine, common |
| 脏标记 | 延迟计算 | engine, renderer |
| 单例 | 全局访问 | engine, common |
| 工厂 | 对象创建 | engine, common |

---

## ⚠️ 禁止模式

### 禁止使用 (ABI 兼容性)

```cpp
// ❌ 禁止: std::shared_ptr (v120 vs v140+ ABI 不兼容)
std::shared_ptr<Texture> texture;

// ❌ 禁止: std::function (跨 DLL 边界不安全)
std::function<void()> callback;

// ❌ 禁止: C++11 lambda (v120 支持有限)
auto lambda = [=]() { /* ... */ };
```

### 推荐替代方案

```cpp
// ✅ 推荐: 手动引用计数
class Texture : public CCObject {
    // retain/release/autorelease
};

// ✅ 推荐: 函数指针或接口
class ICallback {
    virtual void onEvent() = 0;
};

// ✅ 推荐: 命名函数
static void handleEvent() { /* ... */ }
```

---

## 🔍 代码审查检查清单

### 命名检查

```yaml
- [ ] 类名符合层级风格 (Nuclear/Xxx/Manager)
- [ ] 成员变量有 m_ 前缀
- [ ] 常量全大写或 kCamelCase
- [ ] 宏全大写带命名空间前缀
- [ ] 函数名动词开头 (Set/Get/Update/Draw)
```

### 内存管理检查

```yaml
- [ ] new 配对 delete (或使用 retain/release)
- [ ] retain 配对 release
- [ ] 构造函数中 retain 的对象在析构函数中 release
- [ ] 无裸指针传递 (使用引用或智能管理)
- [ ] 数组 new[] 配对 delete[]
```

### 性能检查

```yaml
- [ ] 频繁创建的对象使用对象池
- [ ] 大对象使用引用传递 (const Xxx&)
- [ ] 脏标记避免重复计算
- [ ] 缓存计算结果
- [ ] 避免在循环中分配内存
```

### 异常安全检查

```yaml
- [ ] RAII 管理资源
- [ ] 析构函数不抛异常
- [ ] 构造失败有清理逻辑
- [ ] 异常安全保证 (基本/强/无异常)
```

---

## 📚 参考文档

### 内部文档

- [KNOWLEDGE_BASE.md](../KNOWLEDGE_BASE.md) - 技术知识库
- [RULES.md](../RULES.md) - 项目强制规则
- [skills/client/cpp-development.md](../skills/client/cpp-development.md) - C++ 开发技能

### 外部参考

- C++ Core Guidelines (部分适用 - 考虑 v120 限制)
- Effective C++ (Scott Meyers)
- Google C++ Style Guide (部分适用 - 项目有自定义风格)

---

## 🔄 标准演化

### 版本历史

| 版本 | 日期 | 变更 |
|-----|------|------|
| 1.0 | 2026-01-07 | 初始版本,基于 MT3 项目实践 |

### 未来计划

- [ ] 添加 Lua 命名约定
- [ ] 添加协议设计模式
- [ ] 添加性能优化模式
- [ ] 添加多线程安全模式

---

**文档版本**: 1.0
**最后更新**: 2026-01-07
**维护**: MT3 开发团队
