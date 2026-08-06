#include "gesture/CEGUIGestureRecognizer.h"

namespace CEGUI
{
namespace Gesture
{
const String CEGUIGestureRecognizer::EventGesture("GestureRecognized");
const String CEGUIGestureRecognizer::EventNameSpace("Gesture");

CEGUIGestureRecognizer::CEGUIGestureRecognizer() :
    d_target(0),
    d_inMove(false),
    d_state(GestureRecognizerStatePossible),
    d_mouseEvent(0)
{
}

CEGUIGestureRecognizer::~CEGUIGestureRecognizer()
{
    delete d_mouseEvent;
}

void CEGUIGestureRecognizer::addTarget(Window* target)
{
    d_target = target;
}

void CEGUIGestureRecognizer::updateMouseEvent(const MouseEventArgs& eventArgs)
{
    if (!d_mouseEvent)
        d_mouseEvent = new MouseEventArgs(eventArgs.window);

    *d_mouseEvent = eventArgs;
}

void CEGUIGestureRecognizer::fireGestureEvent()
{
    GestureEventArgs args(this);
    fireEvent(EventGesture, args, EventNameSpace);
}

} // End of Gesture namespace section
} // End of CEGUI namespace section
