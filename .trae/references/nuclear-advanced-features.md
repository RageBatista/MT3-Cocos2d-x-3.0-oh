# Nuclear 高级特性文档

> MT3 项目 Nuclear 引擎高级特性文档

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、粒子系统高级特性

### 1.1 粒子系统概述

Nuclear 引擎的粒子系统支持以下高级特性：

- 粒子发射器
- 粒子物理
- 粒子碰撞
- 粒子颜色渐变
- 粒子大小渐变
- 粒子旋转
- 粒子纹理动画
- 粒子拖尾

### 1.2 粒子发射器

#### 点发射器

```cpp
// 创建点发射器
Nuclear::PointEmitter* emitter = Nuclear::PointEmitter::create();
emitter->setPosition(0, 0, 0);
emitter->setEmissionRate(100);
emitter->setParticleLifetime(2.0f);
```

#### 线发射器

```cpp
// 创建线发射器
Nuclear::LineEmitter* emitter = Nuclear::LineEmitter::create();
emitter->setStartPoint(-100, 0, 0);
emitter->setEndPoint(100, 0, 0);
emitter->setEmissionRate(100);
emitter->setParticleLifetime(2.0f);
```

#### 面发射器

```cpp
// 创建面发射器
Nuclear::PlaneEmitter* emitter = Nuclear::PlaneEmitter::create();
emitter->setPlaneSize(200, 200);
emitter->setEmissionRate(100);
emitter->setParticleLifetime(2.0f);
```

#### 体积发射器

```cpp
// 创建体积发射器
Nuclear::VolumeEmitter* emitter = Nuclear::VolumeEmitter::create();
emitter->setVolumeSize(100, 100, 100);
emitter->setEmissionRate(100);
emitter->setParticleLifetime(2.0f);
```

### 1.3 粒子物理

#### 重力

```cpp
// 设置粒子重力
particleSystem->setGravity(0, -9.8f, 0);
```

#### 风力

```cpp
// 设置粒子风力
particleSystem->setWind(10, 0, 0);
```

#### 阻力

```cpp
// 设置粒子阻力
particleSystem->setDrag(0.1f);
```

#### 湍流

```cpp
// 设置粒子湍流
particleSystem->setTurbulence(0.5f);
```

### 1.4 粒子碰撞

#### 平面碰撞

```cpp
// 添加平面碰撞体
Nuclear::PlaneCollider* collider = Nuclear::PlaneCollider::create();
collider->setPlane(0, 1, 0, 0);
collider->setRestitution(0.5f);
particleSystem->addCollider(collider);
```

#### 球体碰撞

```cpp
// 添加球体碰撞体
Nuclear::SphereCollider* collider = Nuclear::SphereCollider::create();
collider->setSphere(0, 0, 0, 50);
collider->setRestitution(0.5f);
particleSystem->addCollider(collider);
```

#### 盒体碰撞

```cpp
// 添加盒体碰撞体
Nuclear::BoxCollider* collider = Nuclear::BoxCollider::create();
collider->setBox(0, 0, 0, 100, 100, 100);
collider->setRestitution(0.5f);
particleSystem->addCollider(collider);
```

### 1.5 粒子颜色渐变

```cpp
// 设置粒子颜色渐变
Nuclear::ColorGradient gradient;
gradient.addKey(0.0f, Nuclear::Color(1, 1, 1, 1));
gradient.addKey(0.5f, Nuclear::Color(1, 0.5f, 0, 1));
gradient.addKey(1.0f, Nuclear::Color(1, 0, 0, 0));

particleSystem->setColorGradient(gradient);
```

### 1.6 粒子大小渐变

```cpp
// 设置粒子大小渐变
Nuclear::SizeGradient gradient;
gradient.addKey(0.0f, 10);
gradient.addKey(0.5f, 20);
gradient.addKey(1.0f, 5);

particleSystem->setSizeGradient(gradient);
```

### 1.7 粒子旋转

```cpp
// 设置粒子旋转
particleSystem->setStartRotation(0);
particleSystem->setEndRotation(360);
particleSystem->setRotationSpeed(180);
```

### 1.8 粒子纹理动画

```cpp
// 设置粒子纹理动画
particleSystem->setTextureAnimation(true);
particleSystem->setTextureFrameCount(8);
particleSystem->setTextureFrameRate(10);
```

### 1.9 粒子拖尾

```cpp
// 启用粒子拖尾
particleSystem->setTrailEnabled(true);
particleSystem->setTrailLength(10);
particleSystem->setTrailFade(0.1f);
```

---

## 二、光照系统高级特性

### 2.1 光照系统概述

Nuclear 引擎的光照系统支持以下高级特性：

- 点光源
- 聚光源
- 平行光
- 环境光
- 阴影
- 光照贴图
- 全局光照

### 2.2 点光源

```cpp
// 创建点光源
Nuclear::PointLight* light = Nuclear::PointLight::create();
light->setPosition(0, 100, 0);
light->setColor(1, 1, 1);
light->setIntensity(1.0f);
light->setRange(100);
light->setAttenuation(1.0f, 0.1f, 0.01f);

scene->addLight(light);
```

### 2.3 聚光源

```cpp
// 创建聚光源
Nuclear::SpotLight* light = Nuclear::SpotLight::create();
light->setPosition(0, 100, 0);
light->setDirection(0, -1, 0);
light->setColor(1, 1, 1);
light->setIntensity(1.0f);
light->setRange(100);
light->setInnerAngle(30);
light->setOuterAngle(45);

scene->addLight(light);
```

### 2.4 平行光

```cpp
// 创建平行光
Nuclear::DirectionalLight* light = Nuclear::DirectionalLight::create();
light->setDirection(0, -1, 0);
light->setColor(1, 1, 1);
light->setIntensity(1.0f);

scene->addLight(light);
```

### 2.5 环境光

```cpp
// 创建环境光
Nuclear::AmbientLight* light = Nuclear::AmbientLight::create();
light->setColor(0.2f, 0.2f, 0.2f);
light->setIntensity(1.0f);

scene->addLight(light);
```

### 2.6 阴影

```cpp
// 启用阴影
light->setShadowEnabled(true);
light->setShadowMapSize(1024);
light->setShadowNearPlane(1.0f);
light->setShadowFarPlane(100.0f);
light->setShadowBias(0.005f);
```

### 2.7 光照贴图

```cpp
// 加载光照贴图
Nuclear::Lightmap* lightmap = Nuclear::Lightmap::create();
lightmap->loadFromFile("lightmap.png");

scene->setLightmap(lightmap);
```

---

## 三、后处理效果

### 3.1 后处理效果概述

Nuclear 引擎的后处理系统支持以下高级特性：

- 泛光
- 景深
- 运动模糊
- 色差
- 色调映射
- 边缘检测
- 灰度
- 复古效果

### 3.2 泛光

```cpp
// 创建泛光效果
Nuclear::BloomEffect* bloom = Nuclear::BloomEffect::create();
bloom->setThreshold(0.8f);
bloom->setIntensity(1.0f);
bloom->setBlurSize(5);

renderer->addPostEffect(bloom);
```

### 3.3 景深

```cpp
// 创建景深效果
Nuclear::DepthOfFieldEffect* dof = Nuclear::DepthOfFieldEffect::create();
dof->setFocusDistance(10.0f);
dof->setFocusRange(5.0f);
dof->setBlurSize(5);

renderer->addPostEffect(dof);
```

### 3.4 运动模糊

```cpp
// 创建运动模糊效果
Nuclear::MotionBlurEffect* motionBlur = Nuclear::MotionBlurEffect::create();
motionBlur->setIntensity(0.5f);
motionBlur->setSampleCount(8);

renderer->addPostEffect(motionBlur);
```

### 3.5 色差

```cpp
// 创建色差效果
Nuclear::ChromaticAberrationEffect* chromatic = Nuclear::ChromaticAberrationEffect::create();
chromatic->setIntensity(0.01f);

renderer->addPostEffect(chromatic);
```

### 3.6 色调映射

```cpp
// 创建色调映射效果
Nuclear::ToneMappingEffect* toneMapping = Nuclear::ToneMappingEffect::create();
toneMapping->setExposure(1.0f);
toneMapping->setGamma(2.2f);

renderer->addPostEffect(toneMapping);
```

---

## 四、自定义着色器

### 4.1 自定义着色器概述

Nuclear 引擎支持自定义着色器，包括：

- 顶点着色器
- 片段着色器
- 几何着色器
- 计算着色器

### 4.2 顶点着色器

```glsl
// 顶点着色器示例
#version 120

attribute vec3 a_position;
attribute vec3 a_normal;
attribute vec2 a_texcoord;

uniform mat4 u_modelViewProjectionMatrix;
uniform mat3 u_normalMatrix;

varying vec3 v_normal;
varying vec2 v_texcoord;

void main() {
    gl_Position = u_modelViewProjectionMatrix * vec4(a_position, 1.0);
    v_normal = u_normalMatrix * a_normal;
    v_texcoord = a_texcoord;
}
```

### 4.3 片段着色器

```glsl
// 片段着色器示例
#version 120

uniform sampler2D u_texture;
uniform vec3 u_lightColor;
uniform float u_lightIntensity;

varying vec3 v_normal;
varying vec2 v_texcoord;

void main() {
    vec4 texColor = texture2D(u_texture, v_texcoord);
    vec3 normal = normalize(v_normal);
    vec3 lightDir = normalize(vec3(0, 1, 0));
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * u_lightColor * u_lightIntensity;
    gl_FragColor = texColor * vec4(diffuse, 1.0);
}
```

### 4.4 加载自定义着色器

```cpp
// 创建自定义着色器
Nuclear::Shader* shader = Nuclear::Shader::create();
shader->loadFromFile("vertex.glsl", "fragment.glsl");

// 创建材质
Nuclear::Material* material = Nuclear::Material::create();
material->setShader(shader);

// 应用材质
sprite->setMaterial(material);
```

---

## 五、性能优化

### 5.1 粒子系统优化

- 减少粒子数量
- 使用粒子池
- 优化粒子生命周期
- 使用 LOD (Level of Detail)

### 5.2 光照系统优化

- 减少光源数量
- 使用光照贴图
- 优化阴影贴图
- 使用光照探针

### 5.3 后处理优化

- 减少后处理效果数量
- 优化后处理效果参数
- 使用低分辨率渲染
- 使用延迟渲染

---

## 六、最佳实践

### 6.1 粒子系统最佳实践

- 使用粒子池复用粒子
- 优化粒子发射器参数
- 使用粒子碰撞体优化性能
- 使用粒子 LOD

### 6.2 光照系统最佳实践

- 使用光照贴图减少实时计算
- 优化光源数量和参数
- 使用阴影优化技术
- 使用光照探针

### 6.3 后处理最佳实践

- 减少后处理效果数量
- 优化后处理效果参数
- 使用低分辨率渲染
- 使用延迟渲染

---

## 七、参考资料

- [Nuclear 引擎技能](../skills/nuclear/SKILL.md)
- [Nuclear 集成指南](../references/nuclear-integration.md)
- [Nuclear 工具使用指南](../references/nuclear-tools.md)
- [性能优化指南](../references/performance-guide.md)
