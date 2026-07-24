---
name: audio
description: MT3 项目 FMOD 音频系统 AI 辅助开发技能
---

# 音频系统开发技能

> MT3 项目 FMOD 音频系统 AI 辅助开发技能

## 何时使用

在以下场景使用本技能：

- 需要播放背景音乐时
- 需要播放音效时
- 需要控制音频播放时
- 需要处理音频事件时
- 需要优化音频性能时

## 何时不使用

在以下场景不使用本技能：

- 需要处理网络通信时 → 使用 [Network 技能](../network/SKILL.md)
- 需要创建 UI 界面时 → 使用 [CEGUI 技能](../cegui/SKILL.md)

## 输入要求

使用本技能前需要满足以下条件：

- 已阅读 [公共约束](../references/common-constraints.md)
- 已配置 FMOD 音频引擎
- 已准备音频资源文件

## 关键约束

使用本技能时需要注意以下约束：

- **音频格式**: 支持 MP3, WAV, OGG 格式
- **内存限制**: 音频资源占用内存较大，需要合理管理
- **线程安全**: FMOD 是线程安全的，可以在任意线程调用
- **性能考虑**: 音频解码有一定开销，需要异步加载

## 工作流程

### 1. 初始化 FMOD

```cpp
#include "fmod.hpp"

// 初始化 FMOD
FMOD::System* system;
FMOD::System_Create(&system);
system->init(32, FMOD_INIT_NORMAL, 0);
```

### 2. 加载音频资源

```cpp
// 加载音频
FMOD::Sound* sound;
system->createSound("music.mp3", FMOD_DEFAULT, 0, &sound);
```

### 3. 播放音频

```cpp
// 播放音频
FMOD::Channel* channel;
system->playSound(sound, 0, false, &channel);
```

### 4. 控制播放

```cpp
// 控制音量
channel->setVolume(0.5f);

// 控制播放/暂停
channel->setPaused(true);
channel->setPaused(false);

// 停止播放
channel->stop();
```

### 5. 更新系统

```cpp
// 在主循环中更新系统
void Update(float dt)
{
    system->update();
}
```

### 6. 释放资源

```cpp
// 释放资源
sound->release();
system->close();
system->release();
```

## 代码示例

### 示例 1: 播放背景音乐

```cpp
// 播放背景音乐
void PlayBackgroundMusic(const char* filename)
{
    FMOD::Sound* music;
    system->createStream(filename, FMOD_LOOP_NORMAL, 0, &music);
    
    FMOD::Channel* channel;
    system->playSound(music, 0, false, &channel);
    channel->setVolume(0.5f);
}
```

### 示例 2: 播放音效

```cpp
// 播放音效
void PlaySoundEffect(const char* filename)
{
    FMOD::Sound* sound;
    system->createSound(filename, FMOD_DEFAULT, 0, &sound);
    
    FMOD::Channel* channel;
    system->playSound(sound, 0, false, &channel);
}
```

### 示例 3: 控制音频播放

```cpp
// 控制音频播放
void ControlAudio(FMOD::Channel* channel)
{
    // 设置音量
    channel->setVolume(0.8f);
    
    // 设置音调
    channel->setPitch(1.0f);
    
    // 设置声像
    channel->setPan(0.0f);
}
```

## 常见错误与解决方案

### 错误 1: 音频播放失败

**错误信息**:
```
FMOD error: FMOD_ERR_FILE_NOTFOUND
```

**原因**:
- 音频文件不存在
- 文件路径不正确

**解决方案**:
```cpp
// 检查文件是否存在
if (!FileExists(filename)) {
    // 处理文件缺失
}

// 使用正确的文件路径
system->createSound("resource/audio/music.mp3", FMOD_DEFAULT, 0, &sound);
```

---

### 错误 2: 音频卡顿

**错误信息**:
```
Audio stuttering
```

**原因**:
- 音频解码开销过大
- 内存不足

**解决方案**:
```cpp
// 使用流式加载
system->createStream("music.mp3", FMOD_DEFAULT, 0, &sound);

// 异步加载
system->createSoundAsync("music.mp3", callback);
```

---

### 错误 3: 音频泄漏

**错误信息**:
```
Memory leak detected
```

**原因**:
- 音频资源未释放

**解决方案**:
```cpp
// 及时释放音频资源
sound->release();
sound = nullptr;
```

## 调试技巧

### 技巧 1: 启用 FMOD 调试输出

```cpp
// 启用调试输出
system->setOutput(FMOD_OUTPUTTYPE_WAVWRITER);
system->setSoftwareFormat(44100, FMOD_SOUND_FORMAT_PCM16, 0, 0);
```

### 技巧 2: 检查音频状态

```cpp
// 检查音频是否正在播放
bool isPlaying = false;
channel->isPlaying(&isPlaying);
```

### 技巧 3: 使用音频分析工具

```cpp
// 获取音频频谱
system->getSpectrum(spectrum, 256, 0, FMOD_DSP_FFT_WINDOW_RECT);
```

## 性能优化

### 优化 1: 使用流式加载

```cpp
// 对于长音频使用流式加载
system->createStream("music.mp3", FMOD_DEFAULT, 0, &sound);
```

### 优化 2: 使用音频池

```cpp
// 使用音频池复用音频资源
AudioPool* pool = AudioPool::Create(10);
FMOD::Sound* sound = pool->obtain("sound.wav");
```

### 优化 3: 异步加载

```cpp
// 异步加载音频资源
system->createSoundAsync("sound.wav", callback);
```

## 注意事项

1. **内存管理**: 音频资源占用内存较大，需要合理管理
2. **性能考虑**: 音频解码有一定开销，需要异步加载
3. **线程安全**: FMOD 是线程安全的，可以在任意线程调用
4. **错误处理**: 检查所有 API 调用的返回值，处理错误情况
5. **资源释放**: 及时释放不再使用的音频资源

## 相关技能

- [公共约束](../references/common-constraints.md) - 编码规范与代码风格
- [性能优化指南](../references/performance-guide.md) - 性能优化策略

## 参考资料

- [FMOD 官方文档](https://www.fmod.com/docs/)
