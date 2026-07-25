#include "stdafx.h"
#include "SpriteEditorViewRenderUtils.h"
#include "SpriteEditorDoc.h"
#include "SpriteEditorConstants.h"
#include "../engine/renderer/renderer.h"
#include "../engine/engine/configmanager.h"

namespace SpriteEditorViewRenderUtils
{
    namespace
    {
        static Nuclear::FPOINT ToScreenPoint(const Nuclear::CPOINT& world, float centerX, float centerY, float fscale)
        {
            return Nuclear::FPOINT(centerX + world.x * fscale, centerY + world.y * fscale);
        }
    }

    bool HasExactDisplayMode(Nuclear::Renderer* renderer, const Nuclear::XDisplayMode& mode)
    {
        if (!renderer)
            return false;

        const std::vector<Nuclear::XDisplayMode> modes = renderer->EnumDisplayMode();
        return std::find(modes.begin(), modes.end(), mode) != modes.end();
    }

    bool BuildTrajectoryScreenPoints(
        CSpriteEditorDoc* pDoc,
        float centerX,
        float centerY,
        float fscale,
        bool isRiding,
        int horseHeight,
        TrajectoryScreenPoints& outPoints)
    {
        if (!pDoc || !pDoc->m_pSpriteMgr || pDoc->m_CurModelName.empty())
            return false;

        Nuclear::CPOINT endWorld = pDoc->GetEffectPosition();
        if (isRiding)
            endWorld.y = static_cast<LONG>(endWorld.y - 25 - horseHeight);

        const Nuclear::CPOINT ctrlOffset = pDoc->GetTrajectoryControlOffset();
        const Nuclear::CPOINT startWorld(0, 0);
        Nuclear::CPOINT controlWorld(
            (startWorld.x + endWorld.x) / 2 + ctrlOffset.x,
            (startWorld.y + endWorld.y) / 2 + ctrlOffset.y);

        outPoints.start = ToScreenPoint(startWorld, centerX, centerY, fscale);
        outPoints.control = ToScreenPoint(controlWorld, centerX, centerY, fscale);
        outPoints.end = ToScreenPoint(endWorld, centerX, centerY, fscale);
        outPoints.effectWorld = endWorld;
        return true;
    }

    Nuclear::FPOINT EvalQuadraticBezier(
        const Nuclear::FPOINT& p0,
        const Nuclear::FPOINT& p1,
        const Nuclear::FPOINT& p2,
        float t)
    {
        const float oneMinusT = 1.0f - t;
        const float a = oneMinusT * oneMinusT;
        const float b = 2.0f * oneMinusT * t;
        const float c = t * t;
        return Nuclear::FPOINT(
            a * p0.x + b * p1.x + c * p2.x,
            a * p0.y + b * p1.y + c * p2.y);
    }
}
