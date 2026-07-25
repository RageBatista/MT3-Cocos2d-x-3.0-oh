/***********************************************************************
filename: 	RenderEffectRegistry.h
purpose:	CEGUI 0.7.9 RenderEffect 注册模板
            将自定义 RenderEffect 注册到 RenderEffectManager，
            以便在 scheme 文件中通过 RenderEffect 属性自动关联

author:     MT3 技术团队
date:       2026-01-07
version:    1.0.0

usage:
    1. 在 GameUIManager::InitGameUI() 中调用 RegisterAllRenderEffects()
    2. 在 scheme 文件中使用 RenderEffect="EffectName" 属性
*************************************************************************/
#pragma once

#include "CEGUIRenderEffect.h"
#include "CEGUIRenderEffectManager.h"
#include "XPRenderEffect.h"
#include <cmath>


//=============================================================================
// GlowRenderEffect - 发光效果
// 用于窗口边缘发光效果
//=============================================================================
class GlowRenderEffect : public XPRenderEffect
{
public:
    GlowRenderEffect()
        : XPRenderEffect()
        , m_glowIntensity(1.0f)
        , m_glowR(1.0f), m_glowG(1.0f), m_glowB(1.0f), m_glowA(1.0f)
    {
        m_iType = 1; // effect type
    }

    virtual ~GlowRenderEffect() {}

    // 设置发光强度
    void setGlowIntensity(float intensity) { m_glowIntensity = intensity; }
    float getGlowIntensity() const { return m_glowIntensity; }

    // 设置发光颜色 (RGBA)
    void setGlowColour(float r, float g, float b, float a)
    {
        m_glowR = r; m_glowG = g; m_glowB = b; m_glowA = a;
    }

    // 重写渲染函数
    virtual void performPostRenderFunctions()
    {
        // 调用基类实现
        XPRenderEffect::performPostRenderFunctions();

        // TODO: 在此添加发光效果的 OpenGL 渲染代码
        // 可以使用 glBlendFunc, glColor4f 等设置发光效果
    }

protected:
    float m_glowIntensity;
    float m_glowR, m_glowG, m_glowB, m_glowA;
};


//=============================================================================
// PulseRenderEffect - 脉冲效果
// 用于元素脉冲动画效果
//=============================================================================
class PulseRenderEffect : public XPRenderEffect
{
public:
    PulseRenderEffect()
        : XPRenderEffect()
        , m_pulseSpeed(1.0f)
        , m_pulsePhase(0.0f)
        , m_minAlpha(0.5f)
        , m_maxAlpha(1.0f)
    {
        m_iType = 1; // effect type
    }

    virtual ~PulseRenderEffect() {}

    // 设置脉冲参数
    void setPulseSpeed(float speed) { m_pulseSpeed = speed; }
    void setPulseRange(float minAlpha, float maxAlpha)
    {
        m_minAlpha = minAlpha;
        m_maxAlpha = maxAlpha;
    }

    // 更新脉冲相位
    virtual bool update(const float elapsed, CEGUI::RenderingWindow& window)
    {
        m_pulsePhase += elapsed * m_pulseSpeed;
        if (m_pulsePhase > 6.28318f) // 2 * PI
            m_pulsePhase -= 6.28318f;

        return XPRenderEffect::update(elapsed, window);
    }

    // 重写渲染函数
    virtual void performPostRenderFunctions()
    {
        XPRenderEffect::performPostRenderFunctions();

        // 计算当前 alpha 值
        float alpha = m_minAlpha + (m_maxAlpha - m_minAlpha) *
                      (0.5f + 0.5f * sinf(m_pulsePhase));

        // TODO: 应用 alpha 调制到渲染
        (void)alpha; // 避免未使用警告
    }

protected:
    float m_pulseSpeed;
    float m_pulsePhase;
    float m_minAlpha;
    float m_maxAlpha;
};


//=============================================================================
// BlurRenderEffect - 模糊效果
// 用于背景模糊效果
//=============================================================================
class BlurRenderEffect : public XPRenderEffect
{
public:
    BlurRenderEffect()
        : XPRenderEffect()
        , m_blurRadius(2.0f)
    {
        m_iType = 1; // effect type
    }

    virtual ~BlurRenderEffect() {}

    void setBlurRadius(float radius) { m_blurRadius = radius; }
    float getBlurRadius() const { return m_blurRadius; }

    virtual void performPostRenderFunctions()
    {
        XPRenderEffect::performPostRenderFunctions();

        // TODO: 使用多次渲染或着色器实现模糊效果
    }

protected:
    float m_blurRadius;
};


//=============================================================================
// RegisterAllRenderEffects
// 注册所有自定义 RenderEffect 到 RenderEffectManager
//
// 调用位置：GameUIManager::InitGameUI() 或 CEGUI 初始化后
//
// 注册后，可在 scheme 文件中使用：
//   <FalagardMapping ... RenderEffect="GlowEffect" />
//   <FalagardMapping ... RenderEffect="PulseEffect" />
//   <FalagardMapping ... RenderEffect="BlurEffect" />
//=============================================================================
inline void RegisterAllRenderEffects()
{
    CEGUI::RenderEffectManager& rem = CEGUI::RenderEffectManager::getSingleton();

    // 注册发光效果
    rem.addEffect<GlowRenderEffect>("GlowEffect");

    // 注册脉冲效果
    rem.addEffect<PulseRenderEffect>("PulseEffect");

    // 注册模糊效果
    rem.addEffect<BlurRenderEffect>("BlurEffect");
}


/*=============================================================================
 * 使用示例
 *=============================================================================
 *
 * === 1. 在 C++ 中注册效果 ===
 *
 * // 在 GameUIManager.cpp 的 InitGameUI() 函数中添加：
 * #include "RenderEffectRegistry.h"
 *
 * void GameUIManager::InitGameUI()
 * {
 *     // ... 现有初始化代码 ...
 *
 *     // 注册自定义渲染效果
 *     RegisterAllRenderEffects();
 *
 *     // ... 继续初始化 ...
 * }
 *
 * === 2. 在 scheme 文件中使用 RenderEffect ===
 *
 * <FalagardMapping
 *     WindowType="TaharezLook/GlowButton"
 *     TargetType="CEGUI/PushButton"
 *     Renderer="Falagard/Button"
 *     LookNFeel="TaharezLook/AnimatedButton"
 *     RenderEffect="GlowEffect" />
 *
 * === 3. 在 Lua 中动态应用效果 ===
 *
 * local rem = CEGUI.RenderEffectManager:getSingleton()
 * local glowEffect = rem:create("GlowEffect")
 * myWindow:setRenderEffect(glowEffect)
 *
 * -- 稍后移除效果
 * myWindow:setRenderEffect(nil)
 * rem:destroy(glowEffect)
 *
 *=============================================================================*/
