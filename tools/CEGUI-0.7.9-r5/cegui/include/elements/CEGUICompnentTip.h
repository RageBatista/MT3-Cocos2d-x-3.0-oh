/***********************************************************************
filename: 	CEGUICompnentTip.h
purpose:	richeditbox component tips (MT3: MessageTip compatibility)
*************************************************************************/

#ifndef _CEGUICompnentTip_h_
#define _CEGUICompnentTip_h_

#include "../CEGUIBase.h"
#include "../CEGUIWindow.h"
#include "CEGUIRichEditboxComponent.h"
#include <vector>
//#include "CEGUIRichEditbox.h"

#if defined(_MSC_VER)
#	pragma warning(push)
#	pragma warning(disable : 4251)
#endif


// Start of CEGUI namespace section
namespace CEGUI
{
	// MT3: TipType enum for MessageTip compatibility
	enum TipType
	{
		eMsgTip = 1,
		eSystemTip = 2,
	};

	/*!
	\brief
	Base class for Tooltip window renderer objects.
	*/
	class CEGUIEXPORT CompnentTipWindowRenderer : public WindowRenderer
	{
	public:
		/*!
		\brief
		Constructor
		*/
		CompnentTipWindowRenderer(const String& name);

		/*!
		\brief
		Return the size of the area that will be occupied by the tooltip text, given
		any current formatting options.

		\return
		Size object describing the size of the rendered tooltip text in pixels.
		*/
		virtual Size getTextSize() const = 0;

	};

	/*!
	\brief
	Base class for all the MessageTip type widgets 
	*/
	class CEGUIEXPORT CompnentTip : public Window
	{
		
	public:		
		/*************************************************************************
		Constants
		*************************************************************************/
		static const String WidgetTypeName;                 //!< Window factory name
		static const String EventNamespace;                 //!< Namespace for global events
		static const String EventStartFade;                 //!< MT3: Event fired when tip starts fading
		/*************************************************************************
		Construction and Destruction
		*************************************************************************/
		/*!
		\brief
		Constructor for MessageTip objects
		*/
		CompnentTip(const String& type, const String& name);


		/*!
		\brief
		Destructor for MessageTip objects
		*/
		virtual ~CompnentTip(void);

		void      SetTipsText(const String& tip);
		
		Size	  getTextSize() const;

		virtual Size getTextSize_impl() const;
		
		void	  SetTargetCompnent(const RichEditboxComponent* pCompnent,bool bInChatOutWin = false);
		/*!
		\brief
		Causes the tooltip to position itself appropriately.

		\return
		Nothing.
		*/
		void positionSelf(void);

		/*!
		\brief
		Causes the tooltip to resize itself appropriately.

		\return
		Nothing.
		*/
		void sizeSelf(void);

		// MT3: Methods added for MessageTip backward compatibility
		void		InitSysMsgParamter();
		void		SetDestYPos(float height) { d_destYPos = height; }
		float		GetDestYPos() { return d_destYPos; }
		void		SetTipsType(TipType type) { d_tipType = type; }
		TipType		GetTipType() { return d_tipType; }
		bool		GetTextureIsLoading();
		void		SetStartYPos(float yPos) { d_startYPos = yPos; }
		float		GetStartYPos() { return d_startYPos; }
		void		SetDisplayTime(float fDisplayTime) { d_displayTime = fDisplayTime; }
		float		GetHeightScale() { return d_fHeightScale; }
		void		SetHeightScale(float fHeightScale) { d_fHeightScale = fHeightScale; }

	public:
		CompnentTip(const String& type);
		const CompnentTip& operator=(const CompnentTip& t);
		virtual Window* clone(Window* wnd);
		virtual bool onRenameTemplatePrefix(const String& sPrefix){ return Window::onRenameTemplatePrefix(sPrefix); }

	protected:
		/*************************************************************************
		  Overridden from Window.
		*************************************************************************/
		void updateSelf(float elapsed);
		/*!
		\brief
		Return whether this window was inherited from the given class name at some point in the inheritance hierarchy.

		\param class_name
		The class name that is to be checked.

		\return
		true if this window was inherited from \a class_name. false if not.
		*/
		virtual bool	testClassName_impl(const String& class_name) const
		{
			if (class_name=="CompnentTip")	return true;
			return Window::testClassName_impl(class_name);
		}
		
		const RichEditboxComponent* d_targetCompnent;     //!< Current target Window for this Tooltip.
		float       d_elapsed;      //!< Used to track state change timings
		float       d_displayTime;  //!< tool-tip display time (seconds that tip is showsn for).
		float       d_fadeTime;     //!< tool-tip fade time (seconds it takes for tip to fade in and/or out).
		bool	    d_InChatOutWin;
		// MT3: Member variables added for MessageTip backward compatibility
		float		d_destYPos;
		float		d_decHeight;
		bool		d_startFade;
		float		d_startYPos;
		float		d_fHeightScale;
		TipType		d_tipType;
	};

} // End of  CEGUI namespace section

#if defined(_MSC_VER)
#	pragma warning(pop)
#endif

#endif	// end of guard _CEGUIButtonBase_h_