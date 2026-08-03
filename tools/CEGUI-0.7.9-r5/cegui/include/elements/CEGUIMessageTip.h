#ifndef _CEGUIMessageTip_h_
#define _CEGUIMessageTip_h_

#include "../CEGUIBase.h"
#include "../CEGUIWindow.h"
#include "CEGUIRichEditbox.h"

namespace CEGUI
{
enum TipType
{
    eMsgTip = 1,
    eSystemTip = 2
};

class CEGUIEXPORT MessageTip : public Window
{
public:
    static const String WidgetTypeName;
    static const String EventNamespace;
    static const String RichEditboxNameSuffix;
    static const String EventStartFade;

    MessageTip(const String& type, const String& name);
    MessageTip(const String& type);
    virtual ~MessageTip(void);

    virtual void initialiseComponents(void) { initialiseComponents(false); }
    void initialiseComponents(bool clone);
    RichEditbox* getRichEditbox() const;
    Size getTextSize() const;
    void SetDestYPos(float value) { d_destYPos = value; }
    float GetDestYPos() { return d_destYPos; }
    bool GetTextureIsLoading();
    void SetTipsType(TipType type);
    TipType GetTipType() { return d_tipType; }
    void InitSysMsgParamter();
    void SetStartYPos(float value) { d_startYPos = value; }
    float GetStartYPos() { return d_startYPos; }
    void SetDisplayTime(float value) { d_displayTime = value; }
    float GetHeightScale() { return d_heightScale; }
    void SetHeightScale(float value) { d_heightScale = value; }

    const MessageTip& operator=(const MessageTip& tip);
    virtual Window* clone(Window* wnd);
    virtual bool onRenameTemplatePrefix(const String& prefix)
    {
        return Window::onRenameTemplatePrefix(prefix);
    }

protected:
    virtual void onMouseClicked(MouseEventArgs& args);
    virtual void onTextChanged(WindowEventArgs& args);
    virtual void updateSelf(float elapsed);
    void onStartFade(WindowEventArgs& args);
    bool editboxMouseDownHandler(const EventArgs& args);
    void sizeSelf(void);
    virtual bool testClassName_impl(const String& className) const
    {
        return className == "MessageTip" || Window::testClassName_impl(className);
    }

    float d_destYPos;
    float d_decHeight;
    float d_elapsed;
    float d_displayTime;
    float d_fadeTime;
    TipType d_tipType;
    bool d_startFade;
    float d_startYPos;
    float d_heightScale;

    static const float d_ConstWidth;
    static const float d_ConstHeight;
    static const float d_SysTipHeight;
};
}

#endif
