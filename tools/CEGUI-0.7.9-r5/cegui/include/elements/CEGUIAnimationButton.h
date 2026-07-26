/***********************************************************************
	filename: 	CEGUIIrregularFigure.h
	purpose:	ͼΰŤ
 ***************************************************************************/
#ifndef _CEGUIAnimationButton_h_
#define _CEGUIAnimationButton_h_

#include "../CEGUIBase.h"
#include "../CEGUIWindow.h"
#include "CEGUIAnimationButtonProperties.h"



#if defined(_MSC_VER)
#	pragma warning(push)
#	pragma warning(disable : 4251)
#endif


// Start of CEGUI namespace section
namespace CEGUI
{

/*!
\brief
	Base class for all the 'button' type widgets (push button, radio button, check-box, etc)
*/
class CEGUIEXPORT AnimationButton : public Window
{
public:
	
	static const String EventNamespace;				//!< Namespace for global events
	static const String WidgetTypeName;             //!< Window factory name

	static const String ClickEventName;
	
	/*************************************************************************
		Construction and Destruction
	*************************************************************************/
	/*!
	\brief
		Constructor for ButtonBase objects
	*/
	AnimationButton(const String& type, const String& name);


	/*!
	\brief
		Destructor for ButtonBase objects
	*/
	virtual ~AnimationButton(void);

	void SetImageSetName(const String& name);
	void SetImageName(const String& name);
	void SetTotalFrame(int totalFrame);
	int GetCurFrame();

private:
	/*************************************************************************
		Implementation Data
		(declared before inline methods that use them)
	*************************************************************************/

	static AnimationButtonProperties::ImageSetName	d_ImageSetNameProperty;
	static AnimationButtonProperties::ImageName	d_ImageNameProperty;
	static AnimationButtonProperties::TotalFrame	d_TotalFrameProperty;
	static AnimationButtonProperties::AnimationSpeed	d_AniSpeedProperty;

	const Image* d_NormalImage;
	String d_ImageSetName;
	String d_ImageName;
	bool   d_MouseOn;
	int    d_AnimationSpeed;
	int    d_TotalFrame;
	float  d_ElapseTime;

public:
	const String& GetImageSetName() const { return d_ImageSetName; }
	const String& GetImageName() const { return d_ImageName; }

	const Image* GetNormalImage() { return d_NormalImage; }
	void SetAnimationSpeed(int speed) { d_AnimationSpeed=speed; }
	int  GetAnimationSpeed() const  { return d_AnimationSpeed; }
	int  GetTotalFrame() const { return d_TotalFrame; }

	bool isMouseOn() { return d_MouseOn; }

	AnimationButton(const String& type);
	const AnimationButton& operator=(const AnimationButton& t);
	virtual Window* clone(Window* wnd);
	virtual bool onRenameTemplatePrefix(const String& sPrefix){ return Window::onRenameTemplatePrefix(sPrefix); }

protected:
	/*************************************************************************
		Overridden event handlers
	*************************************************************************/
	virtual void	onMouseButtonDown(MouseEventArgs& e);
	virtual void	onMouseButtonUp(MouseEventArgs& e);
	virtual void	onCaptureLost(WindowEventArgs& e);
	virtual void    onMouseEnters(MouseEventArgs& e);
	virtual void	onMouseLeaves(MouseEventArgs& e);
	virtual void    updateSelf(float elapsed);
	
	virtual bool	testClassName_impl(const String& class_name) const
	{
		if (class_name=="AnimationButton")	return true;
		return Window::testClassName_impl(class_name);
	}
};

} // End of  CEGUI namespace section

#if defined(_MSC_VER)
#	pragma warning(pop)
#endif

#endif	// end of guard _CEGUIButtonBase_h_