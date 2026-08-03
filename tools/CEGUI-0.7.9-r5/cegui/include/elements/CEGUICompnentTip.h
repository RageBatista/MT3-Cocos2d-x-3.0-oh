#ifndef _CEGUICompnentTip_h_
#define _CEGUICompnentTip_h_

#include "../CEGUIBase.h"
#include "../CEGUIWindow.h"
#include "CEGUIRichEditboxComponent.h"

namespace CEGUI
{
class CEGUIEXPORT CompnentTipWindowRenderer : public WindowRenderer
{
public:
    CompnentTipWindowRenderer(const String& name);
    virtual Size getTextSize() const = 0;
};

class CEGUIEXPORT CompnentTip : public Window
{
public:
    static const String WidgetTypeName;
    static const String EventNamespace;

    CompnentTip(const String& type, const String& name);
    CompnentTip(const String& type);
    virtual ~CompnentTip(void);

    void SetTipsText(const String& tip);
    Size getTextSize() const;
    virtual Size getTextSize_impl() const;
    void SetTargetCompnent(const RichEditboxComponent* component,
                           bool inChatOutWindow = false);
    void positionSelf(void);
    void sizeSelf(void);

    const CompnentTip& operator=(const CompnentTip& tip);
    virtual Window* clone(Window* wnd);
    virtual bool onRenameTemplatePrefix(const String& prefix)
    {
        return Window::onRenameTemplatePrefix(prefix);
    }

protected:
    virtual void updateSelf(float elapsed);
    virtual bool testClassName_impl(const String& className) const
    {
        return className == "CompnentTip" || Window::testClassName_impl(className);
    }

    const RichEditboxComponent* d_targetCompnent;
    float d_elapsed;
    float d_displayTime;
    float d_fadeTime;
    bool d_InChatOutWin;
};
}

#endif
