#ifndef _CEGUIGestureRecognizer_h_
#define _CEGUIGestureRecognizer_h_

#include "CEGUIEventSet.h"
#include "CEGUIInputEvent.h"

namespace CEGUI
{
class Window;

namespace Gesture
{
enum GestureRecognizerState
{
    GestureRecognizerStatePossible,
    GestureRecognizerStateBegan,
    GestureRecognizerStateChanged,
    GestureRecognizerStateEnded,
    GestureRecognizerStateCancelled,
    GestureRecognizerStateFailed,
    GestureRecognizerStateRecognized = GestureRecognizerStateEnded
};

class CEGUIGestureRecognizer : public EventSet
{
public:
    static const String EventNameSpace;
    static const String EventGesture;

    CEGUIGestureRecognizer();
    virtual ~CEGUIGestureRecognizer();

    virtual void addTarget(Window* target);
    virtual bool onMouseButtonDown(const MouseEventArgs&) { return false; }
    virtual bool onMouseButtonUp(const MouseEventArgs&) { return false; }
    virtual bool onMouseMove(const MouseEventArgs&) { return false; }
    virtual bool onMouseLeaves(const MouseEventArgs&) { return false; }
    virtual bool update(const UpdateEventArgs&) { return false; }

    GestureRecognizerState GetState() const { return d_state; }
    bool inMove() const { return d_inMove; }
    const EventArgs* GetEvent() const { return d_mouseEvent; }
    MouseEventArgs* getMouseEvent() const { return d_mouseEvent; }
    int numberOfTouches() const { return 1; }

protected:
    void updateMouseEvent(const MouseEventArgs& eventArgs);
    void fireGestureEvent();

    Window* d_target;
    bool d_inMove;
    GestureRecognizerState d_state;
    MouseEventArgs* d_mouseEvent;
};

} // End of Gesture namespace section
} // End of CEGUI namespace section

#endif