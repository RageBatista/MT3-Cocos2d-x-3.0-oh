/***********************************************************************
	filename: 	CEGUIItemTable.h
*************************************************************************/

#ifndef _CEGUIItemCell_h_
#define _CEGUIItemCell_h_

#include "../CEGUIWindow.h"
#include "../CEGUIWindowFactory.h"
#include "CEGUIItemCellProperties.h"


#if defined(_MSC_VER)
#	pragma warning(push)
#	pragma warning(disable : 4251)
#endif


#define STANDARD_ITEMCELL_SIZE 94.0f

// Start of CEGUI namespace section
namespace CEGUI
{
    /*!
    \brief
        Generic drag & drop enabled window class
    */

	enum ItemCellTextType         //cellһ
	{
		ItemCellTextType_LeftTop,  //Ͻ
		ItemCellTextType_RightBottom,//½
		ItemCellTextType_Center,
		ItemCellTextType_NUM
		
	};

	enum ItemCellStyle	//by liugeng
	{
		ItemCellStyle_IconInside,
		ItemCellStyle_IconExtend	//used for pet, assist hero, etc. the ear or hair will beyond the bound of itemcell
	};

	struct ItemCellTextUnit 
	{
		String Text;
		ItemCellTextType type;
		colour color;
		int offect;

		ItemCellTextUnit():
		Text(""),
		type(ItemCellTextType_RightBottom),
		color(0xFFFFFFFF),
		offect(0)
		{
		}
	};

	const colour DefaultItemCellTextColor=colour(1.0f,1.0f,1.0f,1.0);
	
    
	class CEGUIEXPORT ItemCell : public Window
    {
    public:
       
        static const String WidgetTypeName;     //!< Type name for DragContainer.
        static const String EventNamespace;     //!< Namespace for global events
		static const String EventCellClick;    //!< click events
        static const String EventCellLongPressBegan;   //!< long press events;
        static const String EventCellLongPressMove;   //!< long press events;
        static const String EventCellLongPressEnded;   //!< long press events;
		static const String EventLockCellClick;    //!< click events
        static const String EventCellDoubleClick;
		static const String EventCellMaskClick;

        ItemCell(const String& type, const String& name);
        virtual ~ItemCell(void);

		bool testClassName_impl(const String& class_name) const
		{
			if (class_name==(const utf8*)"ItemCell")
				return true;

			return Window::testClassName_impl(class_name);
		}
		size_t GetIndex() { return d_index; }
		void SetIndex(size_t index)  {  d_index=index; }
		void SetImage( const Image* image);
		const Image* GetImage() const { return d_image; } 
		void SetImagePosOffsetScale(float scale) { d_iconPosOffsetScale = scale; }	//by liugeng.ҳ
		float GetImagePosOffsetScale() { return d_iconPosOffsetScale; }
		void SetImagePosOffset(int offset) { d_iconPosOffset = offset; }	//by liugeng.ͼ
		int GetImagePosOffset() { return d_iconPosOffset; }

		void SetImage(String ImagesetName, String ImageName);

		void SetMaskImage(int id,const Image* image);
		const Image* GetMaskImage(int id) const { if (id >= 0 && id < 5) return d_maskimage[id]; return NULL; }
		void SetMaskImage(int id,String Imageset, String ImageName);
		void ClearMaskImage(int id);
		void ClearAllMaskImage();

		bool isMouseOnThisCell() { return d_isMouseOnThisCell; }
		void setMouseOnThisCell(bool bMouseOn);// { d_isMouseOnThisCell = bMouseOn;}

		void SetTextUnit(CEGUI::String text, ItemCellTextType type = ItemCellTextType_RightBottom, CEGUI::colour color = DefaultItemCellTextColor, int yoffect = 0);
		void SetTextUnitText(CEGUI::String text, ItemCellTextType type = ItemCellTextType_RightBottom, int yoffect = 0);
		void SetTextUnitColor(CEGUI::colour color, ItemCellTextType type = ItemCellTextType_RightBottom, int yoffect = 0);
		ItemCellTextUnit* GetTextUnit(ItemCellTextType type=ItemCellTextType_RightBottom);
		CEGUI::Point GetTextUnitDrawPos(const Rect& rect,ItemCellTextType type=ItemCellTextType_RightBottom); //

		bool isBackGroundEnable()  { return d_BackGroundEnable; }
		void SetBackGroundEnable(bool bEnable);
		int GetCellTypeMask() { return d_CellTypeMask; }
		void SetCellTypeMask(int mask) { d_CellTypeMask=mask; }

		bool IsAshy()  { return d_ashy;}
		void SetAshy(bool bAshy);// { d_ashy = bAshy; invalidate();}

		bool IsLock()  { return d_lock;}
		void SetLockState(bool block);// { d_ashy = bAshy; invalidate();}

		bool isSelected() { return d_selected;}
		void SetSelected(bool bSelect);
		void SetMutiSelected(bool bSelect);
		void OnSelectedChanged();

		void SetHaveSelectedState(bool bHaveSelected) { d_haveSelectedState = bHaveSelected;}

		void SetBackGroundImage(const Image* image);
		void SetBackGroundImage(String Imageset, String ImageName);
		bool IsHaveBackGroundImage() { return d_backimage != NULL;}
		const Image* GetBackIamge() const { return d_backimage; } 
		
		void SetEquipColorImage(const Image* image);
		void SetEquipColorImage(String Imageset, String ImageName);
		const Image* GetColorImage() const { return d_colorimage; } 

		void SetCornerImage(const Image* image);
		void SetCornerImage(String Imageset, String ImageName);
		const Image* GetCornerImage() const { return d_cornerimage; } 

		void SetCornerImageAtPos(const Image* image, int pos, float scale);
		void SetCornerImageAtPos(String Imageset, String ImageName, int pos, float scale, float xoffset=0.0f, float yoffset=0.0f); //ĸǵͼ꣬0ϣ1ϣ2£3
		const Image* GetCornerImageAtPos(int pos) { if (pos >= 0 && pos < 4) return d_cornerimages[pos]; return NULL; }
		float GetCornerImageScaleAtPos(int pos) { if (pos >= 0 && pos < 4) return d_cornerimageScales[pos]; return 1.0f; }
		CEGUI::Point GetConerImageOffsetAtPos(int pos) { if (pos >= 0 && pos < 4) return d_cornerimageOffset[pos]; return CEGUI::Point(0.0f, 0.0f); };
		void ClearCornerImage(int pos);
		void Clear();

		bool HasFloodLight(){ return d_HasFloodLight; } //Ƿй
		void SetFloodLight(bool bHasFloodLight) { d_HasFloodLight=bHasFloodLight; }

		bool isImageAutoScale() { return d_ImageAutoScale; }
		void SetImageAutoScale(bool bAutoScale);
        
        bool isBtnVisible() { return d_BtnVisible;}
        void SetBtnVisible(bool visible) { d_BtnVisible = visible; }

		bool isEnableMaskClick(){ return d_enableMaskClickEvent;  }
		void SetEnableMaskClick(bool enable){ d_enableMaskClickEvent = enable;  }

		void SetStyle(int style) { d_style = (ItemCellStyle)style; }
		int GetStyle()const { return d_style; }
		void SetBackUpImage(const Image* image){ d_backimage2 = image; };
		void SetBackUpImage(String Imageset, String ImageName);
		void ClearBackUpImage();
		const Image* GetBackUpImage(){ return d_backimage2; }
	public:
		ItemCell(const String& type);
		const ItemCell& operator=(const ItemCell& t);
		virtual Window* clone(Window* wnd);
		virtual bool onRenameTemplatePrefix(const String& sPrefix){ return Window::onRenameTemplatePrefix(sPrefix); }

	private:
        void addItemCellProperties(void);
		void deselectOtherCellInTable(void); //tableϵӵѡ״̬Ϊfalse
		size_t d_index;              //ӵλñ־ڼеڼо;index
		bool d_isMouseOnThisCell;    //mouseǷ
		bool d_BackGroundEnable;     //ӱǷʾ
		bool d_ashy;				 //Ƿɫ
		bool d_selected;				 //Ƿѡ״̬
		bool d_haveSelectedState;    //ǷԱѡ
		bool d_lock;				//Ƿ
		bool d_enableMaskClickEvent;//Ч¼
		const Image* d_image;		//ϵͼƬ
		const Image* d_backimage;		//ϵͼ
		const Image* d_colorimage;		//װɫͼ
		const Image* d_cornerimage;		//½ǵı־ͼ
		const Image* d_maskimage[5];    //ͼ 
		const Image* d_cornerimages[4]; //ĸǵͼ꣬0ϣ1ϣ2£3
		float		 d_cornerimageScales[4];//by liugeng.ĸǵͼű
		CEGUI::Point d_cornerimageOffset[4];//ǱƫƣΪֵ֮Ϊֵ
		float	d_iconPosOffsetScale;	//by liugeng.ҳ
		int		d_iconPosOffset;		//by liugeng.ͼԵľ
		bool m_bIsTreasure;

		const Image* d_backimage2;      //һڱ֮ͼƬ֮µͼ
		
		virtual void onMouseEnters(MouseEventArgs& e);
		virtual void onMouseLeaves(MouseEventArgs& e);
		virtual void onMouseButtonDown(MouseEventArgs& e);
        virtual bool onLongPress(Gesture::CEGUIGestureRecognizer* recognizer);
		virtual void onMouseClicked(MouseEventArgs& e);
        virtual void onMouseDoubleClicked(MouseEventArgs& e);
        
		ItemCellTextUnit m_TextUnits[ItemCellTextType_NUM];
		int d_CellTypeMask;    //͵ж
		bool d_HasFloodLight;  //ǷйЧ
		bool d_ImageAutoScale; //ͼƬǷԶ
        bool d_BtnVisible;
		//void onMouseButtonUp(MouseEventArgs& e);
		//void onMouseButtonDown(MouseEventArgs& e);

		ItemCellStyle d_style;

		static ItemCellProperties::ItemCellStyle d_ItemCellStyleProperty;
    };

} // End of  CEGUI namespace section


#if defined(_MSC_VER)
#	pragma warning(pop)
#endif

#endif
