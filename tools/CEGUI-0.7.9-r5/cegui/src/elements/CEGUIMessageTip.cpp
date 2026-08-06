#include "elements/CEGUIMessageTip.h"
#include "CEGUIWindowManager.h"

namespace CEGUI
{
const String MessageTip::WidgetTypeName("CEGUI/MessageTip");
const String MessageTip::EventNamespace("MessageTip");
const String MessageTip::RichEditboxNameSuffix("__auto_richeditbox__");
const String MessageTip::EventStartFade("StartFade");
const float MessageTip::d_ConstWidth = 400.0f;
const float MessageTip::d_ConstHeight = 20.0f;
const float MessageTip::d_SysTipHeight = 40.0f;

MessageTip::MessageTip(const String& type, const String& name) :
    Window(type, name),
    d_destYPos(0.5f),
    d_decHeight(0.0f),
    d_elapsed(0.0f),
    d_displayTime(5.0f),
    d_fadeTime(0.2f),
    d_tipType(eMsgTip),
    d_startFade(false),
    d_startYPos(0.5f),
    d_heightScale(0.0f)
{
}

MessageTip::MessageTip(const String& type) :
    Window(type),
    d_destYPos(0.5f),
    d_decHeight(0.0f),
    d_elapsed(0.0f),
    d_displayTime(5.0f),
    d_fadeTime(0.2f),
    d_tipType(eMsgTip),
    d_startFade(false),
    d_startYPos(0.5f),
    d_heightScale(0.0f)
{
}

MessageTip::~MessageTip(void)
{
}

const MessageTip& MessageTip::operator=(const MessageTip& tip)
{
    Window::operator=(tip);
    d_destYPos = tip.d_destYPos;
    d_decHeight = tip.d_decHeight;
    d_elapsed = tip.d_elapsed;
    d_displayTime = tip.d_displayTime;
    d_fadeTime = tip.d_fadeTime;
    d_tipType = tip.d_tipType;
    d_startFade = tip.d_startFade;
    d_startYPos = tip.d_startYPos;
    d_heightScale = tip.d_heightScale;
    return *this;
}

Window* MessageTip::clone(Window* wnd)
{
    MessageTip* result = static_cast<MessageTip*>(wnd);
    if (!result)
        result = new MessageTip(d_type);
    *result = *this;
    return result;
}

void MessageTip::initialiseComponents(bool clone)
{
    RichEditbox* editbox = getRichEditbox();
    if (!editbox)
        return;

    if (!clone)
    {
        editbox->SetBackGroundEnable(false);
        editbox->setReadOnly(true);
        editbox->setShowVertScrollbar(false);
        editbox->SetForceHideVerscroll(true);
    }
    editbox->subscribeEvent(Window::EventMouseButtonDown,
        Event::Subscriber(&MessageTip::editboxMouseDownHandler, this));
    if (!clone)
        performChildWindowLayout();
}

RichEditbox* MessageTip::getRichEditbox() const
{
    WindowManager& manager = WindowManager::getSingleton();
    const String name(getName() + RichEditboxNameSuffix);
    return manager.isWindowPresent(name) ?
        static_cast<RichEditbox*>(manager.getWindow(name)) : 0;
}

void MessageTip::SetTipsType(TipType type)
{
    d_tipType = type;
    RichEditbox* editbox = getRichEditbox();
    if (!editbox)
        return;

    editbox->setFont("simhei-14");
    if (type == eMsgTip)
        setSize(UVector2(cegui_absdim(d_ConstWidth), cegui_absdim(d_ConstHeight)));
    else
    {
        d_displayTime = 4.0f;
        setEnabled(false);
        setSize(UVector2(cegui_absdim(getParentPixelWidth() - 200.0f),
                         cegui_absdim(d_SysTipHeight)));
    }
}

void MessageTip::sizeSelf(void)
{
    const Size textSize(getTextSize());
    setSize(UVector2(cegui_absdim(textSize.d_width),
                     cegui_absdim(textSize.d_height)));
}

bool MessageTip::GetTextureIsLoading()
{
    return g_bIsTextLoading;
}

void MessageTip::updateSelf(float elapsed)
{
    Window::updateSelf(elapsed);
    if (!isVisible())
        return;

    d_elapsed += elapsed;
    if (g_bIsTextLoading)
        sizeSelf();

    if (d_displayTime - d_elapsed <= d_fadeTime && !d_startFade)
    {
        WindowEventArgs args(this);
        onStartFade(args);
    }

    if (d_displayTime == 0.0f || d_elapsed >= d_displayTime)
        destroy();
    else if (d_startFade && d_fadeTime > 0.0f && getAlpha() > 0.0f)
        setAlpha(ceguimax((d_displayTime - d_elapsed) / d_fadeTime, 0.1f));

    if (getYPosition().d_scale < 0.0f && g_bIsTextLoading)
        invalidate();
}

void MessageTip::onMouseClicked(MouseEventArgs& args)
{
    if (d_tipType == eMsgTip)
        destroy();
    Window::onMouseClicked(args);
}

void MessageTip::onTextChanged(WindowEventArgs& args)
{
    RichEditbox* editbox = getRichEditbox();
    if (editbox && editbox->getText() != getText())
    {
        editbox->Clear();
        editbox->AppendParseText(getText());
        editbox->Refresh();
    }
    sizeSelf();
    Window::onTextChanged(args);
}

Size MessageTip::getTextSize() const
{
    RichEditbox* editbox = getRichEditbox();
    if (!editbox)
        return Size(0.0f, 0.0f);

    Size result(editbox->GetExtendSize());
    if (d_tipType == eMsgTip)
    {
        if (isDisabled())
        {
            result.d_width += 14.0f;
            result.d_height += 7.0f;
        }
        else
        {
            result.d_width = d_ConstWidth;
            result.d_height += 10.0f;
        }
    }
    else
    {
        result.d_width += 14.0f;
        result.d_height += 14.0f;
    }
    return result;
}

bool MessageTip::editboxMouseDownHandler(const EventArgs&)
{
    if (d_tipType == eMsgTip)
        destroy();
    return true;
}

void MessageTip::onStartFade(WindowEventArgs& args)
{
    d_startFade = true;
    fireEvent(EventStartFade, args, EventNamespace);
}

void MessageTip::InitSysMsgParamter()
{
    d_destYPos = 0.5f;
    d_decHeight = 0.0f;
    d_elapsed = 0.0f;
    d_displayTime = 2.0f;
    d_fadeTime = 0.2f;
    d_startFade = false;
    setText("");
    setFont("simhei-20");
}
}
