#pragma once

#include <afxwin.h>
#include "../engine/ISprite.h"

namespace Nuclear
{
    class PSpriteMaze;
}

enum AdjRectFlag
{
    AdjRect_Top    = 1,
    AdjRect_Bottom = 2,
    AdjRect_Left   = 4,
    AdjRect_Right  = 8,
};

namespace SpriteEditorViewInteractionUtils
{
    int GetAniDir(int dirMode, int ndir);

    float CalPointsDistance(CPoint pt1, CPoint pt2);

    bool GetMazeRect(const Nuclear::PSpriteMaze* pSpriteMaze, RECT& rect);

    int CheckRectAdjPos(const CPoint& pt, const CRect& rect, float scale);

    HCURSOR GetAdjCursorForPosition(int adjPosition);
}
