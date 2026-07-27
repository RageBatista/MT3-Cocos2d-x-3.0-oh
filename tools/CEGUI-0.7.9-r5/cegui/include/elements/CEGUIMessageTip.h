/***********************************************************************
filename: 	CEGUIMessageTip.h
purpose:	MT3 compatibility header for MessageTip (renamed to CompnentTip in 0.7.9-r5)
		Include this header instead of the old CEGUIMessageTip.h for backward compatibility.
*************************************************************************/

#ifndef _CEGUIMessageTip_h_
#define _CEGUIMessageTip_h_

#include "CEGUICompnentTip.h"

// Start of CEGUI namespace section
namespace CEGUI
{
	// MT3: MessageTip was renamed to CompnentTip in CEGUI 0.7.9-r5.
	// This typedef provides backward compatibility for FireClient code.
	// TipType enum is defined in CEGUICompnentTip.h
	typedef CompnentTip MessageTip;

} // End of CEGUI namespace section

#endif	// end of guard _CEGUIMessageTip_h_