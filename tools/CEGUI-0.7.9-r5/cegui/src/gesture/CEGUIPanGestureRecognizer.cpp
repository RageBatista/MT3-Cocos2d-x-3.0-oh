#include "gesture/CEGUIPanGestureRecognizer.h"
#include "CEGUIWindow.h"

namespace CEGUI
{
namespace Gesture
{
CEGUIPanGestureRecognizer::CEGUIPanGestureRecognizer() :
    m_iMinimumNumberOfTouches(1),
    m_iMaximumNumberOfTouches(5),
    d_tracking(false),
    d_clock(0.0),
    d_lastSampleTime(0.0),
    d_lastPoint(0.0f, 0.0f),
    d_velocity(0.0f, 0.0f),
    d_acceleration(0.0f, 0.0f),
    d_dragBeforeBegan(0.0f),
    d_dragMinMove(30.0f)
{
}

bool CEGUIPanGestureRecognizer::onMouseButtonDown(const MouseEventArgs& e)
{
    if (e.button != LeftButton)
        return false;

    updateMouseEvent(e);
    d_tracking = true;
    d_inMove = false;
    d_state = GestureRecognizerStatePossible;
    d_lastPoint = e.position;
    d_lastSampleTime = d_clock;
    d_velocity = Vector2(0.0f, 0.0f);
    d_acceleration = Vector2(0.0f, 0.0f);
    d_dragBeforeBegan = 0.0f;
    d_pushWindowName = e.window ? e.window->getName() : String("");
    return false;
}

bool CEGUIPanGestureRecognizer::checkBegan() const
{
    return d_dragBeforeBegan >= d_dragMinMove ||
           d_velocity.d_x > 500.0f || d_velocity.d_x < -500.0f ||
           d_velocity.d_y > 500.0f || d_velocity.d_y < -500.0f;
}

void CEGUIPanGestureRecognizer::refreshVelocity(const Point& point)
{
    const double elapsed = d_clock - d_lastSampleTime;
    if (elapsed > 0.001)
    {
        const Vector2 newVelocity(
            static_cast<float>((point.d_x - d_lastPoint.d_x) / elapsed),
            static_cast<float>((point.d_y - d_lastPoint.d_y) / elapsed));
        d_acceleration = Vector2(
            static_cast<float>((newVelocity.d_x - d_velocity.d_x) / elapsed),
            static_cast<float>((newVelocity.d_y - d_velocity.d_y) / elapsed));
        d_velocity = newVelocity;
    }

    d_lastPoint = point;
    d_lastSampleTime = d_clock;
}

bool CEGUIPanGestureRecognizer::onMouseMove(const MouseEventArgs& e)
{
    if (!d_tracking)
        return false;

    const float dx = e.position.d_x - d_lastPoint.d_x;
    const float dy = e.position.d_y - d_lastPoint.d_y;
    d_dragBeforeBegan +=
        (dx < 0.0f ? -dx : dx) + (dy < 0.0f ? -dy : dy);
    refreshVelocity(e.position);

    if (d_state == GestureRecognizerStatePossible && !checkBegan())
        return false;

    d_state = d_inMove ? GestureRecognizerStateChanged :
                         GestureRecognizerStateBegan;
    d_inMove = true;
    updateMouseEvent(e);
    fireGestureEvent();
    return true;
}

bool CEGUIPanGestureRecognizer::onMouseButtonUp(const MouseEventArgs& e)
{
    if (!d_tracking)
        return false;

    d_tracking = false;
    d_pushWindowName.clear();
    updateMouseEvent(e);

    if (!d_inMove)
    {
        d_state = GestureRecognizerStatePossible;
        return false;
    }

    refreshVelocity(e.position);
    d_state = GestureRecognizerStateEnded;
    d_inMove = false;
    fireGestureEvent();
    d_state = GestureRecognizerStatePossible;
    return true;
}

bool CEGUIPanGestureRecognizer::onMouseLeaves(const MouseEventArgs& e)
{
    return onMouseButtonUp(e);
}

bool CEGUIPanGestureRecognizer::update(const UpdateEventArgs& e)
{
    d_clock += e.d_timeSinceLastFrame;
    return false;
}

UIPanGestureRecognizerDirection
CEGUIPanGestureRecognizer::GetPanDirection(int) const
{
    const float absX = d_velocity.d_x < 0.0f ? -d_velocity.d_x : d_velocity.d_x;
    const float absY = d_velocity.d_y < 0.0f ? -d_velocity.d_y : d_velocity.d_y;
    if (absX > absY)
        return d_velocity.d_x >= 0.0f ?
            UIPanGestureRecognizerDirectionRight :
            UIPanGestureRecognizerDirectionLeft;
    if (absY > 0.0f)
        return d_velocity.d_y >= 0.0f ?
            UIPanGestureRecognizerDirectionDown :
            UIPanGestureRecognizerDirectionUp;
    return UIPanGestureRecognizerDirectionNone;
}

} // End of Gesture namespace section
} // End of CEGUI namespace section
