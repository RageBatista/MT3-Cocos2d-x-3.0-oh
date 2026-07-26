#ifndef _CEGUICocos2DViewportTarget_h_
#define _CEGUICocos2DViewportTarget_h_

#include "CEGUICocos2DRenderTarget.h"

#if defined(_MSC_VER)
#   pragma warning(push)
#   pragma warning(disable : 4251)
#endif

namespace CEGUI
{
class COCOS2D_GUIRENDERER_API Cocos2DViewportTarget : public Cocos2DRenderTarget
{
public:
    Cocos2DViewportTarget(Cocos2DRenderer& owner);
    Cocos2DViewportTarget(Cocos2DRenderer& owner, const Rect& area);

    virtual bool isImageryCache() const;
};

} // End of  CEGUI namespace section

#if defined(_MSC_VER)
#   pragma warning(pop)
#endif

#endif  // end of guard _CEGUICocos2DViewportTarget_h_