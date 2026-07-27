/***********************************************************************
filename:   CEGUICompnentTip.cpp
purpose:    Implementation of CompnentTip (MT3: MessageTip compatibility)
*************************************************************************/
#include "elements/CEGUICompnentTip.h"
#include "CEGUIFont.h"
#include "CEGUIWindowManager.h"
#include "CEGUIImagesetManager.h"
#include "CEGUIImageset.h"
#include "CEGUIImage.h"

// Start of CEGUI namespace section
namespace CEGUI
{
	const String CompnentTip::WidgetTypeName("CEGUI/MessageTip");
	const String CompnentTip::EventNamespace("MessageTip");
	const String CompnentTip::EventStartFade("StartFade");

	CompnentTip::CompnentTip(const String& type, const String& name) :
		Window(type, name),
		d_targetCompnent(NULL),
		d_elapsed(0.0f),
		d_displayTime(5.0f),
		d_fadeTime(0.2f),
		d_InChatOutWin(false),
		d_destYPos(0.5f),
		d_decHeight(0.0f),
		d_startFade(false),
		d_startYPos(0.5f),
		d_fHeightScale(0.0f),
		d_tipType(eMsgTip)
	{
	}

	CompnentTip::CompnentTip(const String& type) :
		Window(type),
		d_targetCompnent(NULL),
		d_elapsed(0.0f),
		d_displayTime(5.0f),
		d_fadeTime(0.2f),
		d_InChatOutWin(false),
		d_destYPos(0.5f),
		d_decHeight(0.0f),
		d_startFade(false),
		d_startYPos(0.5f),
		d_fHeightScale(0.0f),
		d_tipType(eMsgTip)
	{
	}

	const CompnentTip& CompnentTip::operator=(const CompnentTip& t)
	{
		Window::operator=(t);
		d_targetCompnent = t.d_targetCompnent;
		d_elapsed = t.d_elapsed;
		d_displayTime = t.d_displayTime;
		d_fadeTime = t.d_fadeTime;
		d_InChatOutWin = t.d_InChatOutWin;
		d_destYPos = t.d_destYPos;
		d_decHeight = t.d_decHeight;
		d_startFade = t.d_startFade;
		d_startYPos = t.d_startYPos;
		d_fHeightScale = t.d_fHeightScale;
		d_tipType = t.d_tipType;
		return *this;
	}

	Window* CompnentTip::clone(Window* wnd)
	{
		CompnentTip* retWnd = (CompnentTip*)wnd;
		if (retWnd == NULL)
			retWnd = new CompnentTip(d_type);
		*retWnd = *this;
		return retWnd;
	}

	CompnentTip::~CompnentTip(void)
	{
	}

	void CompnentTip::SetTipsText(const String& tip)
	{
		setText(tip);
	}

	Size CompnentTip::getTextSize() const
	{
		return getTextSize_impl();
	}

	Size CompnentTip::getTextSize_impl() const
	{
		Size sz(0.0f, 0.0f);
		if (getFont())
		{
			float extent = getFont()->getTextExtent(getText());
			sz.d_width = extent;
			sz.d_height = getFont()->getLineSpacing();
		}
		return sz;
	}

	void CompnentTip::SetTargetCompnent(const RichEditboxComponent* pCompnent, bool bInChatOutWin)
	{
		d_targetCompnent = pCompnent;
		d_InChatOutWin = bInChatOutWin;
	}

	void CompnentTip::positionSelf(void)
	{
		// Default positioning
	}

	void CompnentTip::sizeSelf(void)
	{
		Size textSize(getTextSize());
		setSize(UVector2(cegui_absdim(textSize.d_width), cegui_absdim(textSize.d_height)));
	}

	void CompnentTip::updateSelf(float elapsed)
	{
		Window::updateSelf(elapsed);

		if (!isVisible())
			return;

		d_elapsed += elapsed;
	}

	void CompnentTip::InitSysMsgParamter()
	{
		d_destYPos = 0.5f;
		d_decHeight = 0.0f;
		d_elapsed = 0.0f;
		d_displayTime = 2.0f;
		d_fadeTime = 0.2f;
		d_startFade = false;
		setText("");
		setFont(CEGUI::String("simhei-20"));
	}

	bool CompnentTip::GetTextureIsLoading()
	{
		return g_bIsTextLoading;
	}

} // End of CEGUI namespace section