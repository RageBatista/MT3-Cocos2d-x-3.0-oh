#include "gesture/CEGUILongPressGestureRecognizer.h"

namespace CEGUI
{
namespace Gesture
{
CEGUILongPressGestureRecognizer::CEGUILongPressGestureRecognizer() :
    m_dlTimeInterval(2.0f),
    m_fAllowableMovement(10.0f),
    d_touchBegan(-1.0f),
    d_accumulatedMovement(0.0f)
{
}

bool CEGUILongPressGestureRecognizer::onMouseButtonDown(
    const MouseEventArgs& e)
{
    if (e.button != LeftButton)
        return false;

    updateMouseEvent(e);
    d_touchBegan = 0.0f;
    d_accumulatedMovement = 0.0f;
    d_inMove = false;
    d_state = GestureRecognizerStatePossible;
    return false;
}

bool CEGUILongPressGestureRecognizer::onMouseMove(const MouseEventArgs& e)
{
    if (d_touchBegan < 0.0f &&
        d_state != GestureRecognizerStateBegan &&
        d_state != GestureRecognizerStateChanged)
        return false;

    updateMouseEvent(e);
    d_accumulatedMovement +=
        (e.moveDelta.d_x < 0.0f ? -e.moveDelta.d_x : e.moveDelta.d_x) +
        (e.moveDelta.d_y < 0.0f ? -e.moveDelta.d_y : e.moveDelta.d_y);

    if (d_state == GestureRecognizerStateBegan ||
        d_state == GestureRecognizerStateChanged)
    {
        d_state = GestureRecognizerStateChanged;
        d_inMove = true;
        fireGestureEvent();
        return true;
    }

    if (d_accumulatedMovement > m_fAllowableMovement)
    {
        d_touchBegan = -1.0f;
        d_state = GestureRecognizerStateFailed;
    }
    return false;
}

bool CEGUILongPressGestureRecognizer::onMouseButtonUp(
    const MouseEventArgs& e)
{
    d_touchBegan = -1.0f;
    updateMouseEvent(e);

    if (d_state != GestureRecognizerStateBegan &&
        d_state != GestureRecognizerStateChanged)
    {
        d_state = GestureRecognizerStatePossible;
        return false;
    }

    d_state = GestureRecognizerStateEnded;
    d_inMove = false;
    fireGestureEvent();
    d_state = GestureRecognizerStatePossible;
    return true;
}

bool CEGUILongPressGestureRecognizer::onMouseLeaves(const MouseEventArgs& e)
{
    return onMouseButtonUp(e);
}

bool CEGUILongPressGestureRecognizer::update(const UpdateEventArgs& e)
{
    if (d_touchBegan < 0.0f || d_state != GestureRecognizerStatePossible)
        return false;

    d_touchBegan += e.d_timeSinceLastFrame;
    if (d_touchBegan < m_dlTimeInterval)
        return false;

    d_touchBegan = -1.0f;
    d_state = GestureRecognizerStateBegan;
    fireGestureEvent();
    return true;
}

} // End of Gesture namespace section
} // End of CEGUI namespace section
