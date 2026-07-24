# MT3 项目技术知识库

> **版本**: 1.0 | **更新**: 2026-01-05 | **AI 专用**

---

## 核心技术架构速查

### 客户端五层架构

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 5: Lua 脚本层 (client/resource/script/)              │
│  - 游戏业务逻辑 (~30k 行)                                    │
│  - 界面控制、事件处理                                        │
│  - 关键文件: main.lua, GameApp.lua                          │
└─────────────────────────────────────────────────────────────┘
                    ↓ tolua++ 绑定 (client/tolua++-pkgs/)
┌─────────────────────────────────────────────────────────────┐
│  Layer 4: FireClient 业务层 (client/FireClient/)            │
│  - FireClient.lib (预编译, v120, 不可修改)                   │
│  - 网络通信、协议处理、数据管理                              │
│  - 关键接口: IFireClient, INetworkHandler                   │
└─────────────────────────────────────────────────────────────┘
                    ↓ IApp 接口
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: Nuclear 引擎层 (engine/)                          │
│  - engine.lib (~17k 行)                                     │
│  - 场景/精灵/动画/特效管理                                   │
│  - 关键头文件: nuiengine.h, nuisprite.h, nuiworld.h         │
│  - 命名空间: Nuclear::                                       │
└─────────────────────────────────────────────────────────────┘
                    ↓ CCLayer 桥接
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: Cocos2d-x 2.2.6 层 (cocos2d-x-2.2.6/)             │
│  - libcocos2d, libCocosDenshion, libExtensions              │
│  - 渲染、输入、音频基础设施                                  │
│  - 关键类: CCSprite, CCNode, CCLayer, CCScene               │
└─────────────────────────────────────────────────────────────┘
                    ↓ 平台 API
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: 平台层 (common/platform/)                         │
│  - Win32 API / Android NDK / iOS                            │
│  - OpenGL ES 渲染                                            │
└─────────────────────────────────────────────────────────────┘
```

### 服务器分布式架构

```
┌─────────────────────────────────────────────────────────────┐
│                      客户端 (Client)                         │
└───────────────────────────┬─────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  gate_server (网关) - 连接管理、协议转发                     │
│  端口: 通常 8080                                             │
└───────────────────────────┬─────────────────────────────────┘
                            ↓
┌─────────────────┬─────────────────┬─────────────────────────┐
│  game_server    │  zone_server    │  spirit_server          │
│  (游戏逻辑)     │  (区域场景)     │  (灵兽系统)             │
└────────┬────────┴────────┬────────┴────────┬────────────────┘
         │                 │                 │
         ↓                 ↓                 ↓
┌─────────────────────────────────────────────────────────────┐
│  支撑服务层                                                  │
│  name_server | proxy_server | trans_server | sdk_server     │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│  XDB 文件数据库 (server/tools/monkeyking/)                  │
│  - xbean 数据持久化                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 关键技术约束 (AI 必须遵守)

### 编译工具链 (绝对约束)

| 平台 | 必须使用 | 禁止使用 | 后果 |
|------|----------|----------|------|
| Windows | VS2013 v120 | v140/141/142/143 | ABI 不兼容崩溃 |
| Android | NDK r16 clang + Ant + JDK8 | r10e/GCC、NDK r21+、Gradle | JNI/ABI 链接失败 |
| Server | JDK 1.7/1.8 + Ant | JDK 9+, Maven/Gradle | 模块化冲突 |

### 预编译库 (不可修改)

```yaml
客户端预编译库:
  - client/FireClient/FireClient.lib    # v120, 核心业务
  - common/platform/*.lib               # v120, 平台层
  - cocos2d-x-2.2.6/**/*.lib           # v120, 当前 Cocos2d-x 引擎
  - dependencies/cegui/**/*.lib         # v120, UI

修改后果:
  - LNK2001/LNK2019 链接错误
  - 运行时 Access Violation
  - CRT 堆冲突
```

### 生成代码 (禁止手动修改)

| 类型 | 路径模式 | 生成命令 | 源配置 |
|------|----------|----------|--------|
| xbean | `server/**/xbean/*.java` | `ant xbean` | xbean.xml |
| gnet RPC | `server/**/rpc/*.java` | `ant gnet` | protocol.xml |
| tolua++ | `client/**/*_tolua.cpp` | tolua++ 脚本 | *.pkg |

---

## 关键代码模式

### 客户端 - Nuclear 精灵系统

```cpp
// 创建精灵的标准模式
Nuclear::NuclearSprite* sprite = Nuclear::NuclearSprite::create();
sprite->SetLocation(Nuclear::NuclearPoint(100.0f, 100.0f));
sprite->SetScale(1.0f);
sprite->SetRotation(0.0f);

// 内存管理 - 引用计数
sprite->retain();   // 增加引用
sprite->release();  // 减少引用 (避免 delete)

// 对象池模式 (性能关键)
ObjectPool<Effect> g_effectPool(100);
Effect* effect = g_effectPool.Allocate();
g_effectPool.Free(effect);

// 脏标记优化
if (m_bTransformDirty) {
    RecalculateMatrix();
    m_bTransformDirty = false;
}
```

### 客户端 - Lua 脚本模式

```lua
-- 缓存全局函数 (性能关键)
local GetEngine = Nuclear.GetEngine
local engine = GetEngine()

-- 复用对象避免 GC
local point = Nuclear.NuclearPoint(0, 0)
function UpdatePos(x, y)
    point.x = x
    point.y = y
    engine:SetEngineSpriteLoc(handle, point)
end

-- 类定义模式
local GamePlayer = class("GamePlayer")
function GamePlayer:ctor(name)
    self.name = name
    self.level = 1
end
```

### 服务器 - gnet 协议模式

```java
// 协议定义 (protocol.xml)
// <protocol name="SLogin" maxsize="256">
//     <variable name="username" type="string"/>
//     <variable name="password" type="string"/>
// </protocol>

// 发送协议
SLogin login = new SLogin();
login.username = "player1";
login.password = "encrypted";
link.send(login);

// 协议处理器
public class SLoginHandler extends Protocol.Handler {
    @Override
    public void process(Mkio.Link link, Protocol protocol) {
        SLogin login = (SLogin) protocol;
        // 验证逻辑
    }
}
```

### 服务器 - xbean 数据模式

```java
// Bean 定义 (xbean.xml)
// <bean name="PlayerData">
//     <variable name="id" type="int"/>
//     <variable name="name" type="string"/>
//     <variable name="level" type="int"/>
// </bean>

// 读取配置
PlayerData player = PlayerDataTable.get(playerId);
if (player != null) {
    String name = player.getName();
    int level = player.getLevel();
}

// XDB 事务操作
xdb.Procedure.execute(() -> {
    PlayerData data = PlayerDataTable.get(id);
    data.setLevel(data.getLevel() + 1);
    PlayerDataTable.put(id, data);
});
```

---

## 性能关键路径

### 客户端性能热点

| 模块 | 热点 | 优化策略 |
|------|------|----------|
| 渲染 | Draw Call 过多 | CCSpriteBatchNode 批量渲染 |
| 纹理 | 内存占用 | TexturePacker 图集 + 压缩 |
| Lua | GC 暂停 | 对象复用 + 局部化变量 |
| 动画 | 帧更新开销 | 骨骼动画 + 缓存 |
| 网络 | 协议解析 | 预分配 buffer + 池化 |

### 服务器性能热点

| 模块 | 热点 | 优化策略 |
|------|------|----------|
| 网络 | 并发连接 | Netty + 线程池 |
| 数据库 | XDB 读写 | 缓存 + 批量操作 |
| 协议 | 序列化 | 预分配 + 复用 Marshal |
| 逻辑 | 锁竞争 | 分区设计 + 无锁队列 |

---

## 常见错误模式与修复

### 编译错误

| 错误 | 原因 | 修复 |
|------|------|------|
| LNK2001 外部符号 | 工具集不匹配 | 检查 PlatformToolset=v120 |
| LNK2019 未解析 | 库缺失/顺序错误 | 检查 AdditionalDependencies |
| C1010 预编译头 | 未包含 nupch.h | 添加 `#include "nupch.h"` |
| MSVCR120.dll 缺失 | 运行时未部署 | 运行 copy_runtime_dlls.bat |

### 运行时错误

| 错误 | 原因 | 修复 |
|------|------|------|
| Access Violation | ABI 不兼容 | 确保全部使用 v120 |
| Lua 脚本错误 | 语法/绑定问题 | luac -p 验证语法 |
| 协议解析失败 | 版本不匹配 | 重新生成 ant gnet |
| XDB 事务失败 | 锁竞争/超时 | 检查事务范围和超时 |

---

## 目录快速索引

### 客户端关键目录

```
client/
├── FireClient/           # 主项目 (VS2013)
├── MT3Win32App/          # Win32 启动器
├── android/              # Android 多渠道
│   └── LocojoyProject/   # 主要 Android 项目
├── resource/
│   ├── script/           # Lua 脚本 (~30k 行)
│   ├── res/              # 资源文件
│   └── bin/              # 输出目录
└── tolua++-pkgs/         # C++/Lua 绑定

engine/                   # Nuclear 引擎
├── common/               # 通用模块
├── sprite/               # 精灵系统
├── effect/               # 特效系统
├── map/                  # 地图系统
├── renderer/             # 渲染器
└── world/                # 世界管理
```

### 服务器关键目录

```
server/
├── core/                 # 核心模块
│   └── jio/              # 网络 IO 库
├── server/               # 服务进程
│   ├── game_server/      # 游戏逻辑
│   ├── gate_server/      # 网关
│   ├── zone_server/      # 区域
│   └── spirit_server/    # 灵兽
├── tools/
│   ├── jgs/              # 游戏服务工具
│   ├── gnet/             # 协议生成
│   ├── xbean/            # 数据生成
│   └── monkeyking/       # XDB 数据库
└── common/               # 公共模块
```

---

## AI 辅助开发检查清单

### 代码修改前

```yaml
检查项:
  - [ ] 是否涉及预编译库？ → 不可修改
  - [ ] 是否涉及生成代码？ → 修改源配置
  - [ ] 是否符合编码规范？ → 参考 RULES.md
  - [ ] 是否有内存泄漏风险？ → 检查 retain/release
```

### 编译问题诊断

```yaml
诊断流程:
  1. 检查工具集版本 (v120)
  2. 验证预编译库存在
  3. 匹配错误码模式
  4. 引用权威文档
```

### 性能优化建议

```yaml
客户端优先级:
  1. 减少 Draw Call (BatchNode)
  2. 优化 Lua GC (对象复用)
  3. 纹理压缩和图集

服务器优先级:
  1. 减少锁竞争 (分区)
  2. 批量数据库操作
  3. 协议压缩
```

---

**文档版本**: 1.0
**AI 专用知识库**
**最后更新**: 2026-01-05
