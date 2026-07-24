#ifndef MT3_RUNTIME_VIEWPORT_CALCULATOR_H
#define MT3_RUNTIME_VIEWPORT_CALCULATOR_H

namespace mt3
{
struct RuntimeSafeInset
{
    RuntimeSafeInset()
        : left(0), top(0), right(0), bottom(0)
    {
    }

    RuntimeSafeInset(int insetLeft, int insetTop, int insetRight, int insetBottom)
        : left(insetLeft), top(insetTop), right(insetRight), bottom(insetBottom)
    {
    }

    int left;
    int top;
    int right;
    int bottom;
};

struct RuntimeViewportProfile
{
    RuntimeViewportProfile()
        : screenWidth(0), screenHeight(0),
          targetWidth(0), targetHeight(0),
          displayX(0), displayY(0), displayWidth(0), displayHeight(0),
          logicWidth(0), logicHeight(0),
          uiScale(1.0f)
    {
    }

    int screenWidth;
    int screenHeight;
    int targetWidth;
    int targetHeight;
    RuntimeSafeInset safeInset;
    int displayX;
    int displayY;
    int displayWidth;
    int displayHeight;
    int logicWidth;
    int logicHeight;
    float uiScale;
};

inline void ComputeRuntimeLogicSize(int screenW, int screenH, int targetW, int targetH, int& logicW, int& logicH)
{
    if (screenW <= 0 || screenH <= 0)
    {
        logicW = 0;
        logicH = 0;
        return;
    }

    if (targetW <= 0 || targetH <= 0)
    {
        logicW = screenW;
        logicH = screenH;
        return;
    }

    if (screenW != targetW || screenH != targetH)
    {
        const float scaleW = (float)targetW / (float)screenW;
        const float scaleH = (float)targetH / (float)screenH;
        const float scale = scaleW > scaleH ? scaleW : scaleH;
        logicW = (int)(scale * (float)screenW + 0.5f);
        logicH = (int)(scale * (float)screenH + 0.5f);
    }
    else
    {
        logicW = screenW;
        logicH = screenH;
    }
}

inline void ApplyRuntimeMaxUiScale(int screenW, int screenH, float maxScale, int& logicW, int& logicH)
{
    if (screenW <= 0 || screenH <= 0 || logicW <= 0 || logicH <= 0 || maxScale <= 0.0f)
    {
        return;
    }

    const int minLogicW = (int)((float)screenW / maxScale + 0.999f);
    const int minLogicH = (int)((float)screenH / maxScale + 0.999f);
    const float scaleUpW = (float)minLogicW / (float)logicW;
    const float scaleUpH = (float)minLogicH / (float)logicH;
    const float scaleUp = scaleUpW > scaleUpH ? scaleUpW : scaleUpH;

    if (scaleUp > 1.0f)
    {
        logicW = (int)((float)logicW * scaleUp + 0.5f);
        logicH = (int)((float)logicH * scaleUp + 0.5f);
    }
}

inline float ComputeRuntimeUiScale(int screenH, int logicH)
{
    if (screenH <= 0 || logicH <= 0)
    {
        return 1.0f;
    }

    return (float)screenH / (float)logicH;
}

inline int ClampRuntimeInset(int value, int limit)
{
    if (value < 0)
    {
        return 0;
    }

    return value > limit ? limit : value;
}

inline void ComputeRuntimeViewportProfile(int screenW, int screenH, int targetW, int targetH, const RuntimeSafeInset& safeInset, float maxUiScale, RuntimeViewportProfile& profile)
{
    profile.screenWidth = screenW;
    profile.screenHeight = screenH;
    profile.targetWidth = targetW;
    profile.targetHeight = targetH;
    profile.safeInset.left = ClampRuntimeInset(safeInset.left, screenW);
    profile.safeInset.top = ClampRuntimeInset(safeInset.top, screenH);
    profile.safeInset.right = ClampRuntimeInset(safeInset.right, screenW);
    profile.safeInset.bottom = ClampRuntimeInset(safeInset.bottom, screenH);

    if (screenW <= 0 || screenH <= 0)
    {
        profile.displayX = 0;
        profile.displayY = 0;
        profile.displayWidth = 0;
        profile.displayHeight = 0;
        profile.logicWidth = 0;
        profile.logicHeight = 0;
        profile.uiScale = 1.0f;
        return;
    }

    profile.displayX = profile.safeInset.left;
    profile.displayY = profile.safeInset.top;
    profile.displayWidth = screenW - profile.safeInset.left - profile.safeInset.right;
    profile.displayHeight = screenH - profile.safeInset.top - profile.safeInset.bottom;
    if (profile.displayWidth <= 0 || profile.displayHeight <= 0)
    {
        profile.displayX = 0;
        profile.displayY = 0;
        profile.displayWidth = screenW;
        profile.displayHeight = screenH;
    }

    ComputeRuntimeLogicSize(profile.displayWidth, profile.displayHeight, targetW, targetH, profile.logicWidth, profile.logicHeight);
    if (maxUiScale > 0.0f)
    {
        ApplyRuntimeMaxUiScale(profile.displayWidth, profile.displayHeight, maxUiScale, profile.logicWidth, profile.logicHeight);
    }
    profile.uiScale = ComputeRuntimeUiScale(profile.displayHeight, profile.logicHeight);
}
}

#endif
