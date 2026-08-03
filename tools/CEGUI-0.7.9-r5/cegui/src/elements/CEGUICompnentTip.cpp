#include "elements/CEGUICompnentTip.h"
#include "CEGUIMouseCursor.h"
#include "CEGUIRenderedString.h"

namespace CEGUI
{
const String CompnentTip::WidgetTypeName("CEGUI/CompnentTip");
const String CompnentTip::EventNamespace("CompnentTip");

CompnentTipWindowRenderer::CompnentTipWindowRenderer(const String& name) :
    WindowRenderer(name, CompnentTip::EventNamespace)
{
}

CompnentTip::CompnentTip(const String& type, const String& name) :
    Window(type, name),
    d_targetCompnent(0),
    d_elapsed(0.0f),
    d_displayTime(10.0f),
    d_fadeTime(0.2f),
    d_InChatOutWin(false)
{
    setMousePassThroughEnabled(true);
}

CompnentTip::CompnentTip(const String& type) :
    Window(type),
    d_targetCompnent(0),
    d_elapsed(0.0f),
    d_displayTime(10.0f),
    d_fadeTime(0.2f),
    d_InChatOutWin(false)
{
    setMousePassThroughEnabled(true);
}

CompnentTip::~CompnentTip(void)
{
}

const CompnentTip& CompnentTip::operator=(const CompnentTip& tip)
{
    Window::operator=(tip);
    d_targetCompnent = 0;
    d_elapsed = tip.d_elapsed;
    d_displayTime = tip.d_displayTime;
    d_fadeTime = tip.d_fadeTime;
    d_InChatOutWin = tip.d_InChatOutWin;
    return *this;
}

Window* CompnentTip::clone(Window* wnd)
{
    CompnentTip* result = static_cast<CompnentTip*>(wnd);
    if (!result)
        result = new CompnentTip(d_type);
    *result = *this;
    return result;
}

void CompnentTip::SetTipsText(const String& tip)
{
    setText(tip);
}

void CompnentTip::SetTargetCompnent(const RichEditboxComponent* component,
                                    bool inChatOutWindow)
{
    d_InChatOutWin = inChatOutWindow;
    if (!component)
    {
        d_targetCompnent = 0;
        setAlpha(0.0f);
        d_elapsed = 0.0f;
        if (d_parent)
            d_parent->removeChildWindow(this);
        setText("");
        hide();
        return;
    }

    if (d_targetCompnent != component)
    {
        Window* root = inChatOutWindow ?
            System::getSingleton().GetChatOutRootWnd() :
            System::getSingleton().getGUISheet();
        if (root)
        {
            SetInChatOutWnd(inChatOutWindow);
            root->addChildWindow(this);
        }
        show();
        moveToFront();
        d_targetCompnent = component;
    }

    sizeSelf();
    positionSelf();
    d_elapsed = 0.0f;
}

void CompnentTip::sizeSelf(void)
{
    const Size textSize(getTextSize());
    setSize(UVector2(cegui_absdim(textSize.d_width),
                     cegui_absdim(textSize.d_height)));
}

void CompnentTip::updateSelf(float elapsed)
{
    Window::updateSelf(elapsed);
    if (d_displayTime > 0.0f && (d_elapsed += elapsed) < d_displayTime)
    {
        setAlpha(ceguimin((1.0f / d_fadeTime) * d_elapsed, 1.0f));
        return;
    }

    setAlpha(0.0f);
    d_elapsed = 0.0f;
    d_targetCompnent = 0;
    setText("");
    if (d_parent)
        d_parent->removeChildWindow(this);
    hide();
}

void CompnentTip::positionSelf(void)
{
    Rect screen(Vector2(0, 0),
                System::getSingleton().getRenderer()->getDisplaySize());
    if (d_InChatOutWin)
    {
        Window* chatRoot = System::getSingleton().GetChatOutRootWnd();
        if (chatRoot)
            screen.setSize(chatRoot->getPixelSize());
    }

    const Vector2 mousePos(MouseCursor::getSingleton().getPosition());
    const Size selfSize(getPixelSize());
    Vector2 position(mousePos.d_x, mousePos.d_y - selfSize.d_height);
    if (!d_InChatOutWin)
        position.d_y = mousePos.d_y + 32.0f;

    if (position.d_x + selfSize.d_width > screen.d_right)
        position.d_x = screen.d_right - selfSize.d_width;
    if (position.d_y < 0.0f)
        position.d_y = mousePos.d_y + 32.0f;
    position.d_x = ceguimax(position.d_x, 0.0f);

    setPosition(UVector2(cegui_absdim(position.d_x),
                         cegui_absdim(position.d_y)));
}

Size CompnentTip::getTextSize() const
{
    if (d_windowRenderer)
        return static_cast<CompnentTipWindowRenderer*>(d_windowRenderer)->getTextSize();
    return getTextSize_impl();
}

Size CompnentTip::getTextSize_impl() const
{
    const RenderedString& renderedString(getRenderedString());
    Size result(0.0f, 0.0f);
    for (size_t line = 0; line < renderedString.getLineCount(); ++line)
    {
        const Size lineSize(renderedString.getPixelSize(line));
        result.d_height += lineSize.d_height;
        result.d_width = ceguimax(result.d_width, lineSize.d_width);
    }
    return result;
}
}
