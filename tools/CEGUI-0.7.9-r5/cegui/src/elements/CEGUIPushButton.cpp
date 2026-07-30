/***********************************************************************
	filename: 	CEGUIPushButton.cpp
	created:	13/4/2004
	author:		Paul D Turner

	purpose:	Implementation of PushButton widget base class
*************************************************************************/
/***************************************************************************
 *   Copyright (C) 2004 - 2006 Paul D Turner & The CEGUI Development Team
 *
 *   Permission is hereby granted, free of charge, to any person obtaining
 *   a copy of this software and associated documentation files (the
 *   "Software"), to deal in the Software without restriction, including
 *   without limitation the rights to use, copy, modify, merge, publish,
 *   distribute, sublicense, and/or sell copies of the Software, and to
 *   permit persons to whom the Software is furnished to do so, subject to
 *   the following conditions:
 *
 *   The above copyright notice and this permission notice shall be
 *   included in all copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 *   IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 *   OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 *   ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *   OTHER DEALINGS IN THE SOFTWARE.
 ***************************************************************************/
#include "elements/CEGUIPushButton.h"
#include "CEGUIImage.h"
#include "CEGUIPropertyHelper.h"

// Start of CEGUI namespace section
namespace CEGUI
{
namespace
{
const float MT3ButtonWidthSmall = 40.0f;
const float MT3ButtonWidthNormal = 80.0f;
const float MT3ButtonWidthBig = 120.0f;
const float MT3ButtonHeight = 22.0f;
}

PushButtonProperties::SizeType PushButton::d_sizeTypeProperty;
PushButtonProperties::EnableClickAni PushButton::d_enableClickAniProperty;

/*************************************************************************
	constants
*************************************************************************/
// event strings
const String PushButton::EventNamespace("PushButton");
const String PushButton::WidgetTypeName("CEGUI/PushButton");
const String PushButton::EventClicked( "Clicked" );


/*************************************************************************
	Constructor
*************************************************************************/
PushButton::PushButton(const String& type, const String& name) :
	ButtonBase(type, name),
    d_sizeType(ePushButtonSizeType_Auto)
{
    addPushButtonProperties();
}


/*************************************************************************
	Destructor
*************************************************************************/
PushButton::~PushButton(void)
{
}

//----------------------------------------------------------------------------//
void PushButton::SetSizeType(PushButtonSizeType type)
{
    if (type == d_sizeType)
        return;

    d_sizeType = type;
    UVector2 size(cegui_absdim(0), cegui_absdim(MT3ButtonHeight));

    switch (d_sizeType)
    {
    case ePushButtonSizeType_Small:
        size.d_x = cegui_absdim(MT3ButtonWidthSmall);
        setMinSize(size);
        setMaxSize(size);
        break;
    case ePushButtonSizeType_Normal:
        size.d_x = cegui_absdim(MT3ButtonWidthNormal);
        setMinSize(size);
        setMaxSize(size);
        break;
    case ePushButtonSizeType_Big:
        size.d_x = cegui_absdim(MT3ButtonWidthBig);
        setMinSize(size);
        setMaxSize(size);
        break;
    case ePushButtonSizeType_Image:
        if (isPropertyPresent("NormalImage"))
        {
            const Image* image = PropertyHelper::stringToImage(
                getProperty("NormalImage"));
            if (image)
            {
                size.d_x = cegui_absdim(image->getWidth());
                size.d_y = cegui_absdim(image->getHeight());
                setMinSize(size);
                setMaxSize(size);
                break;
            }
        }
        SetSizeType(ePushButtonSizeType_Auto);
        break;
    case ePushButtonSizeType_Auto:
        setMinSize(UVector2(cegui_absdim(0), cegui_absdim(0)));
        setMaxSize(UVector2(cegui_reldim(1), cegui_reldim(1)));
        break;
    default:
        SetSizeType(ePushButtonSizeType_Auto);
        break;
    }
}

//----------------------------------------------------------------------------//
void PushButton::addPushButtonProperties()
{
    addProperty(&d_sizeTypeProperty);
    addProperty(&d_enableClickAniProperty);
}

//----------------------------------------------------------------------------//
String PushButtonProperties::SizeType::get(
    const PropertyReceiver* receiver) const
{
    switch (static_cast<const PushButton*>(receiver)->GetSizeType())
    {
    case ePushButtonSizeType_Small: return "Small";
    case ePushButtonSizeType_Normal: return "Normal";
    case ePushButtonSizeType_Big: return "Big";
    case ePushButtonSizeType_Image: return "Image";
    case ePushButtonSizeType_Auto: return "Auto";
    default: return "Auto";
    }
}

//----------------------------------------------------------------------------//
void PushButtonProperties::SizeType::set(PropertyReceiver* receiver,
                                         const String& value)
{
    PushButtonSizeType type = ePushButtonSizeType_Auto;
    if (value == "Small")
        type = ePushButtonSizeType_Small;
    else if (value == "Normal")
        type = ePushButtonSizeType_Normal;
    else if (value == "Big")
        type = ePushButtonSizeType_Big;
    else if (value == "Image")
        type = ePushButtonSizeType_Image;

    static_cast<PushButton*>(receiver)->SetSizeType(type);
}

//----------------------------------------------------------------------------//
String PushButtonProperties::EnableClickAni::get(
    const PropertyReceiver* receiver) const
{
    return PropertyHelper::boolToString(
        static_cast<const PushButton*>(receiver)->isClickAniEnable());
}

//----------------------------------------------------------------------------//
void PushButtonProperties::EnableClickAni::set(PropertyReceiver* receiver,
                                               const String& value)
{
    static_cast<PushButton*>(receiver)->EnableClickAni(
        PropertyHelper::stringToBool(value));
}


/*************************************************************************
	handler invoked internally when the button is clicked.
*************************************************************************/
void PushButton::onClicked(WindowEventArgs& e)
{
	fireEvent(EventClicked, e, EventNamespace);
}


/*************************************************************************
	Handler for mouse button release events
*************************************************************************/
void PushButton::onMouseButtonUp(MouseEventArgs& e)
{
	if ((e.button == LeftButton) && isPushed())
	{
		Window* sheet = System::getSingleton().getGUISheet();

		if (sheet)
		{
			// if mouse was released over this widget
            // (use position from mouse, as e.position has been unprojected)
			if (this == sheet->getTargetChildAtPosition(
                                    MouseCursor::getSingleton().getPosition()))
			{
				// fire event
				WindowEventArgs args(this);
				onClicked(args);
			}

		}

		++e.handled;
	}

	// default handling
	ButtonBase::onMouseButtonUp(e);
}

} // End of  CEGUI namespace section
