#ifndef _CEGUIPanGestureRecognizer_h_
#define _CEGUIPanGestureRecognizer_h_

#include "gesture/CEGUIGestureRecognizer.h"

namespace CEGUI
{
namespace Gesture
{
enum UIPanGestureRecognizerDirection
{
    UIPanGestureRecognizerDirectionNone = 0,
    UIPanGestureRecognizerDirectionRight = 1 << 0,
    UIPanGestureRecognizerDirectionLeft = 1 << 1,
    UIPanGestureRecognizerDirectionUp = 1 << 2,
    UIPanGestureRecognizerDirectionDown = 1 << 3
};

class CEGUIPanGestureRecognizer : public CEGUIGestureRecognizer
{
public:
    CEGUIPanGestureRecognizer();

    virtual bool onMouseButtonDown(const MouseEventArgs& e);
    virtual bool onMouseButtonUp(const MouseEventArgs& e);
    virtual bool onMouseMove(const MouseEventArgs& e);
    virtual bool onMouseLeaves(const MouseEventArgs& e);
    virtual bool update(const UpdateEventArgs& e);

    const Vector2& velocityInView(Window* = 0) const { return d_velocity; }
    const Vector2& getAcceleration() const { return d_acceleration; }
    const String& getPushWndName() const { return d_pushWindowName; }
    UIPanGestureRecognizerDirection GetPanDirection(int index = 0) const;

    int m_iMinimumNumberOfTouches;
    int m_iMaximumNumberOfTouches;

private:
    bool checkBegan() const;
    void refreshVelocity(const Point& point);

    bool d_tracking;
    double d_clock;
    double d_lastSampleTime;
    Point d_lastPoint;
    Vector2 d_velocity;
    Vector2 d_acceleration;
    float d_dragBeforeBegan;
    float d_dragMinMove;
    String d_pushWindowName;
};

} // End of Gesture namespace section
} // End of CEGUI namespace section

#endif
