#pragma once

#include <d3d9types.h>
#include "../engine/ISprite.h"

class CSpriteEditorDoc;

struct TrajectoryScreenPoints
{
    Nuclear::FPOINT start;
    Nuclear::FPOINT control;
    Nuclear::FPOINT end;
    Nuclear::CPOINT effectWorld;
};

namespace SpriteEditorViewRenderUtils
{
    bool HasExactDisplayMode(Nuclear::Renderer* renderer, const Nuclear::XDisplayMode& mode);
    bool BuildTrajectoryScreenPoints(
        CSpriteEditorDoc* pDoc,
        float centerX,
        float centerY,
        float fscale,
        bool isRiding,
        int horseHeight,
        TrajectoryScreenPoints& outPoints);
    Nuclear::FPOINT EvalQuadraticBezier(
        const Nuclear::FPOINT& p0,
        const Nuclear::FPOINT& p1,
        const Nuclear::FPOINT& p2,
        float t);
}
