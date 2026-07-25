#include "stdafx.h"
#include "SpriteEditorViewInteractionUtils.h"
#include "SpriteEditorDoc.h"
#include "SpriteEditorConstants.h"
#include "../engine/sprite/pspritemaze.h"

namespace
{
    const int kMouseNear = 3;
}

namespace SpriteEditorViewInteractionUtils
{
    int GetAniDir(int dirMode, int ndir)
    {
        switch (dirMode)
        {
        case Nuclear::XPANIDM_8:
            break;
        case Nuclear::XPANIDM_8USE1:
        case Nuclear::XPANIDM_8FROM1:
        case Nuclear::XPANIDM_B2FROM1:
            ndir = 0;
            break;
        case Nuclear::XPANIDM_8FROM5:
            if (ndir == Nuclear::XPDIR_BOTTOMLEFT)
                ndir = 3;
            else if (ndir == Nuclear::XPDIR_LEFT)
                ndir = 2;
            else if (ndir == Nuclear::XPDIR_TOPLEFT)
                ndir = 1;
            break;
        case Nuclear::XPANIDM_4:
            if ((ndir == Nuclear::XPDIR_TOP) || (ndir == Nuclear::XPDIR_TOPRIGHT))
                ndir = 0;
            else if ((ndir == Nuclear::XPDIR_RIGHT) || (ndir == Nuclear::XPDIR_BOTTOMRIGHT))
                ndir = 1;
            else if ((ndir == Nuclear::XPDIR_BOTTOM) || (ndir == Nuclear::XPDIR_BOTTOMLEFT))
                ndir = 2;
            else
                ndir = 3;
            break;
        case Nuclear::XPANIDM_3:
            if (ndir == Nuclear::XPDIR_BOTTOMRIGHT)
                ndir = 0;
            else if (ndir == Nuclear::XPDIR_BOTTOM)
                ndir = 1;
            else if (ndir == Nuclear::XPDIR_BOTTOMLEFT)
                ndir = 2;
            else
                ndir = 0;
            break;
        case Nuclear::XPANIDM_2:
            if (ndir == Nuclear::XPDIR_BOTTOMRIGHT)
                ndir = 0;
            else if (ndir == Nuclear::XPDIR_TOPLEFT)
                ndir = 1;
            else
                ndir = 0;
            break;
        case Nuclear::XPANIDM_4FROM2:
            if (ndir == Nuclear::XPDIR_BOTTOMLEFT)
                ndir = 0;
            else if (ndir == Nuclear::XPDIR_TOPRIGHT)
                ndir = 1;
            break;
        }
        return ndir;
    }

    float CalPointsDistance(CPoint pt1, CPoint pt2)
    {
        float dis = powf((float)(pt1.x - pt2.x), 2.0f) + powf((float)(pt1.y - pt2.y), 2.0f);
        dis = sqrt(dis);
        return dis;
    }

    bool GetMazeRect(const Nuclear::PSpriteMaze* pSpriteMaze, RECT& rect)
    {
        if (pSpriteMaze == NULL)
            return false;
        int gridwidth = SpriteEditorConst::kMazeGridWidth;
        int gridheight = SpriteEditorConst::kMazeGridHeight;
        const Nuclear::CPOINT& ltpt = pSpriteMaze->GetLeftTopPos();
        rect.left = -ltpt.x;
        rect.right = rect.left + gridwidth * pSpriteMaze->GetWidth();
        rect.top = -ltpt.y;
        rect.bottom = rect.top + gridheight * pSpriteMaze->GetHeight();
        return true;
    }

    int CheckRectAdjPos(const CPoint& pt, const CRect& rect, float scale)
    {
        int result = 0;
        int mousenear = (int)(kMouseNear / scale);
        if (pt.y >= rect.top - mousenear && pt.y <= rect.bottom + mousenear)
        {
            if (abs(pt.x - rect.left) < mousenear)
            {
                result |= AdjRect_Left;
            }
            else if (abs(pt.x - rect.right) < mousenear)
            {
                result |= AdjRect_Right;
            }
        }
        if (pt.x >= rect.left - mousenear && pt.x <= rect.right + mousenear)
        {
            if (abs(pt.y - rect.top) < mousenear)
            {
                result |= AdjRect_Top;
            }
            else if (abs(pt.y - rect.bottom) < mousenear)
            {
                result |= AdjRect_Bottom;
            }
        }
        return result;
    }

    HCURSOR GetAdjCursorForPosition(int adjPosition)
    {
        switch (adjPosition)
        {
        case AdjRect_Top:
        case AdjRect_Bottom:
            return LoadCursor(NULL, IDC_SIZENS);
        case AdjRect_Left:
        case AdjRect_Right:
            return LoadCursor(NULL, IDC_SIZEWE);
        case AdjRect_Left | AdjRect_Top:
        case AdjRect_Right | AdjRect_Bottom:
            return LoadCursor(NULL, IDC_SIZENWSE);
        case AdjRect_Left | AdjRect_Bottom:
        case AdjRect_Right | AdjRect_Top:
            return LoadCursor(NULL, IDC_SIZENESW);
        default:
            return LoadCursor(NULL, IDC_ARROW);
        }
    }
}
