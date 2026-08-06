#ifndef _CEGUILongPressGestureRecognizer_h_
#define _CEGUILongPressGestureRecognizer_h_

#include "gesture/CEGUIGestureRecognizer.h"

namespace CEGUI
{
namespace Gesture
{
class CEGUILongPressGestureRecognizer : public CEGUIGestureRecognizer
{
public:
    CEGUILongPressGestureRecognizer();

    virtual bool onMouseButtonDown(const MouseEventArgs& e);
    virtual bool onMouseButtonUp(const MouseEventArgs& e);
    virtual bool onMouseMove(const MouseEventArgs& e);
    virtual bool onMouseLeaves(const MouseEventArgs& e);
    virtual bool update(const UpdateEventArgs& e);

    float m_dlTimeInterval;
    float m_fAllowableMovement;

private:
    float d_touchBegan;
    float d_accumulatedMovement;
};

} // End of Gesture namespace section
} // End of CEGUI namespace section

#endif
