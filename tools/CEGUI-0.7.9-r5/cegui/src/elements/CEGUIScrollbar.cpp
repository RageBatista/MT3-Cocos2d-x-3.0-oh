/***********************************************************************
    filename:   CEGUIScrollbar.cpp
    created:    13/4/2004
    author:     Paul D Turner
*************************************************************************/
/***************************************************************************
 *   Copyright (C) 2004 - 2010 Paul D Turner & The CEGUI Development Team
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
#include "elements/CEGUIScrollbar.h"
#include "elements/CEGUIThumb.h"
#include "CEGUIWindowManager.h"
#include "CEGUIExceptions.h"
#include "elements/CEGUIScrollablePane.h"
#include "gesture/CEGUIPanGestureRecognizer.h"
#include <math.h>

// Start of CEGUI namespace section
namespace CEGUI
{
//----------------------------------------------------------------------------//
const String Scrollbar::EventNamespace("Scrollbar");
const String Scrollbar::WidgetTypeName("CEGUI/Scrollbar");
float Scrollbar::d_DefultAcceleration(100.0f);

//----------------------------------------------------------------------------//
ScrollbarProperties::DocumentSize   Scrollbar::d_documentSizeProperty;
ScrollbarProperties::PageSize       Scrollbar::d_pageSizeProperty;
ScrollbarProperties::StepSize       Scrollbar::d_stepSizeProperty;
ScrollbarProperties::OverlapSize    Scrollbar::d_overlapSizeProperty;
ScrollbarProperties::ScrollPosition Scrollbar::d_scrollPositionProperty;
ScrollbarProperties::EndLockEnabled Scrollbar::d_endLockEnabledProperty;

//----------------------------------------------------------------------------//
const String Scrollbar::EventScrollPositionChanged("ScrollPosChanged");
const String Scrollbar::EventThumbTrackStarted("ThumbTrackStarted");
const String Scrollbar::EventThumbTrackEnded("ThumbTrackEnded");
const String Scrollbar::EventScrollConfigChanged("ScrollConfigChanged");
const String Scrollbar::EventScrollbarEnd("ScrollbarEnd");
const String Scrollbar::EventSlideStopped("SlideStopped");

//----------------------------------------------------------------------------//
const String Scrollbar::ThumbNameSuffix("__auto_thumb__");
const String Scrollbar::IncreaseButtonNameSuffix("__auto_incbtn__");
const String Scrollbar::DecreaseButtonNameSuffix("__auto_decbtn__");

//----------------------------------------------------------------------------//
ScrollbarWindowRenderer::ScrollbarWindowRenderer(const String& name) :
        WindowRenderer(name, Scrollbar::EventNamespace)
{
}

//----------------------------------------------------------------------------//
Scrollbar::Scrollbar(const String& type, const String& name) :
    Window(type, name),
    d_documentSize(1.0f),
    d_pageSize(0.0f),
    d_stepSize(1.0f),
    d_overlapSize(0.0f),
    d_position(0.0f),
    d_endLockPosition(false),
    d_velocity(0.0f),
    d_acceleration(0.0f),
    d_Lock(false),
    d_TotalSlideTime(0.0f),
    d_ClickEnable(true),
    d_parentScrollPane(NULL),
    m_SlideState(StopState),
    m_BackElapseTime(0.0f),
    m_SlideElapseTime(0.0f),
    m_SlideStartPos(0.0f),
    m_SlideDstPos(0.0f),
    d_PanGuestureEnable(true),
    d_PanForVert(true),
    m_Offset(0.0f),
    d_StopStep(false),
    m_ticktime(0.0f)
{
    addScrollbarProperties();
    EnbaleSlide(true);
    EnableDrag(true);
}

//----------------------------------------------------------------------------//
Scrollbar::~Scrollbar(void)
{
}

//----------------------------------------------------------------------------//
void Scrollbar::initialiseComponents(void)
{
    // Set up thumb
    Thumb* const t = getThumb();
    t->subscribeEvent(Thumb::EventThumbPositionChanged,
                      Event::Subscriber(&CEGUI::Scrollbar::handleThumbMoved,
                      this));

    t->subscribeEvent(Thumb::EventThumbTrackStarted,
                      Event::Subscriber(&CEGUI::Scrollbar::handleThumbTrackStarted,
                      this));

    t->subscribeEvent(Thumb::EventThumbTrackEnded,
                      Event::Subscriber(&CEGUI::Scrollbar::handleThumbTrackEnded,
                      this));

    // set up Increase button
    getIncreaseButton()->
        subscribeEvent(PushButton::EventMouseButtonDown,
                       Event::Subscriber(&CEGUI::Scrollbar::handleIncreaseClicked,
                       this));

    // set up Decrease button
    getDecreaseButton()->
        subscribeEvent(PushButton::EventMouseButtonDown,
                       Event::Subscriber(&CEGUI::Scrollbar::handleDecreaseClicked,
                       this));

    // do initial layout
    performChildWindowLayout();
}

//----------------------------------------------------------------------------//
void Scrollbar::setDocumentSize(float document_size)
{
    if (d_documentSize != document_size)
    {
        const bool reset_max_position = d_endLockPosition && isAtEnd();

        d_documentSize = document_size;

        if (reset_max_position)
            setScrollPosition(getMaxScrollPosition());
        else
            updateThumb();

        WindowEventArgs args(this);
        onScrollConfigChanged(args);
    }
}

//----------------------------------------------------------------------------//
void Scrollbar::setPageSize(float page_size)
{
    if (d_pageSize != page_size)
    {
        const bool reset_max_position = d_endLockPosition && isAtEnd();

        d_pageSize = page_size;

        if (reset_max_position)
            setScrollPosition(getMaxScrollPosition());
        else
            updateThumb();

        WindowEventArgs args(this);
        onScrollConfigChanged(args);
    }
}

//----------------------------------------------------------------------------//
void Scrollbar::setStepSize(float step_size)
{
    if (d_stepSize != step_size)
    {
        d_stepSize = step_size;

        WindowEventArgs args(this);
        onScrollConfigChanged(args);
    }
}

//----------------------------------------------------------------------------//
void Scrollbar::setOverlapSize(float overlap_size)
{
    if (d_overlapSize != overlap_size)
    {
        d_overlapSize = overlap_size;

        WindowEventArgs args(this);
        onScrollConfigChanged(args);
    }
}

//----------------------------------------------------------------------------//
void Scrollbar::setScrollPosition(float position)
{
    const bool modified = setScrollPosition_impl(position);
    updateThumb();

    // notification if required
    if (modified)
    {
        WindowEventArgs args(this);
        onScrollPositionChanged(args);
    }
}

//----------------------------------------------------------------------------//
// MT3: Overloaded setScrollPosition with checkPos parameter
void Scrollbar::setScrollPosition(float position, bool checkPos)
{
    float old_pos = d_position;

    // max position is (docSize - pageSize), but must be at least 0 (in case doc size is very small)
    float max_pos = ceguimax((d_documentSize - d_pageSize), 0.0f);

    // limit position to valid range:  0 <= position <= max_pos
    if (checkPos)
    {
        d_position = (position >= 0) ? ((position <= max_pos) ? position : max_pos) : 0.0f;
    }
    else
    {
        d_position = position;
    }

    updateThumb();

    // notification if required
    if (d_position != old_pos)
    {
        WindowEventArgs args(this);
        onScrollPositionChanged(args);
    }
}

//----------------------------------------------------------------------------//
void Scrollbar::onScrollPositionChanged(WindowEventArgs& e)
{
    fireEvent(EventScrollPositionChanged, e, EventNamespace);
}

//----------------------------------------------------------------------------//
void Scrollbar::onThumbTrackStarted(WindowEventArgs& e)
{
    fireEvent(EventThumbTrackStarted, e, EventNamespace);
}

//----------------------------------------------------------------------------//
void Scrollbar::onThumbTrackEnded(WindowEventArgs& e)
{
    fireEvent(EventThumbTrackEnded, e, EventNamespace);
}

//----------------------------------------------------------------------------//
void Scrollbar::onScrollConfigChanged(WindowEventArgs& e)
{
    performChildWindowLayout();
    fireEvent(EventScrollConfigChanged, e, EventNamespace);
}

//----------------------------------------------------------------------------//
void Scrollbar::onScrollbarEnd(WindowEventArgs& e)
{
    fireEvent(EventScrollbarEnd, e, EventNamespace);
}

//----------------------------------------------------------------------------//
void Scrollbar::onMouseButtonDown(MouseEventArgs& e)
{
    if (!d_ClickEnable)
        return;

    // base class processing
    Window::onMouseButtonDown(e);

    if (e.button == LeftButton)
    {
        const float adj = getAdjustDirectionFromPoint(e.position);

        // adjust scroll bar position in whichever direction as required.
        if (adj != 0)
            setScrollPosition(
                d_position + ((d_pageSize - d_overlapSize) * adj));

        ++e.handled;
    }

    d_StopStep = false;
}

//----------------------------------------------------------------------------//
void Scrollbar::onMouseWheel(MouseEventArgs& e)
{
    // base class processing
    Window::onMouseWheel(e);

    // scroll by e.wheelChange * stepSize
    setScrollPosition(d_position + d_stepSize * -e.wheelChange);

    // ensure the message does not go to our parent.
    ++e.handled;
}

//----------------------------------------------------------------------------//
bool Scrollbar::handleThumbMoved(const EventArgs&)
{
    // adjust scroll bar position as required.
    setScrollPosition(getValueFromThumb());

    return true;
}

//----------------------------------------------------------------------------//
bool Scrollbar::handleIncreaseClicked(const EventArgs& e)
{
    if (((const MouseEventArgs&)e).button == LeftButton)
    {
        // adjust scroll bar position as required.
        setScrollPosition(d_position + d_stepSize);

        return true;
    }

    return false;
}

//----------------------------------------------------------------------------//
bool Scrollbar::handleDecreaseClicked(const EventArgs& e)
{
    if (((const MouseEventArgs&)e).button == LeftButton)
    {
        // adjust scroll bar position as required.
        setScrollPosition(d_position - d_stepSize);

        return true;
    }

    return false;
}

//----------------------------------------------------------------------------//
bool Scrollbar::handleThumbTrackStarted(const EventArgs&)
{
    // simply trigger our own version of this event
    WindowEventArgs args(this);
    onThumbTrackStarted(args);

    return true;
}

//----------------------------------------------------------------------------//
bool Scrollbar::handleThumbTrackEnded(const EventArgs&)
{
    // simply trigger our own version of this event
    WindowEventArgs args(this);
    onThumbTrackEnded(args);

    return true;
}

//----------------------------------------------------------------------------//
void Scrollbar::addScrollbarProperties(void)
{
    addProperty(&d_documentSizeProperty);
    addProperty(&d_pageSizeProperty);
    addProperty(&d_stepSizeProperty);
    addProperty(&d_overlapSizeProperty);
    addProperty(&d_scrollPositionProperty);
    addProperty(&d_endLockEnabledProperty);

    // we ban all these properties from xml for auto windows
    if (isAutoWindow())
    {
        banPropertyFromXML(&d_documentSizeProperty);
        banPropertyFromXML(&d_pageSizeProperty);
        banPropertyFromXML(&d_stepSizeProperty);
        banPropertyFromXML(&d_overlapSizeProperty);
        banPropertyFromXML(&d_scrollPositionProperty);

        // scrollbars tend to have their visibility toggled alot, so we ban
        // that as well
        banPropertyFromXML(&d_visibleProperty);
    }
}

//----------------------------------------------------------------------------//
PushButton* Scrollbar::getIncreaseButton() const
{
    return static_cast<PushButton*>(WindowManager::getSingleton().getWindow(
                                        getName() + IncreaseButtonNameSuffix));
}

//----------------------------------------------------------------------------//
PushButton* Scrollbar::getDecreaseButton() const
{
    return static_cast<PushButton*>(WindowManager::getSingleton().getWindow(
                                        getName() + DecreaseButtonNameSuffix));
}

//----------------------------------------------------------------------------//
Thumb* Scrollbar::getThumb() const
{
    return static_cast<Thumb*>(WindowManager::getSingleton().getWindow(
                                   getName() + ThumbNameSuffix));
}

//----------------------------------------------------------------------------//
void Scrollbar::updateThumb(void)
{
    if (!d_windowRenderer)
        CEGUI_THROW(InvalidRequestException("Scrollbar::updateThumb: This "
            "function must be implemented by the window renderer object (no "
            "window renderer is assigned.)"));

    static_cast<ScrollbarWindowRenderer*>(d_windowRenderer)->updateThumb();
}

//----------------------------------------------------------------------------//
float Scrollbar::getValueFromThumb(void) const
{
    if (!d_windowRenderer)
        CEGUI_THROW(InvalidRequestException("Scrollbar::getValueFromThumb: This "
            "function must be implemented by the window renderer object (no "
            "window renderer is assigned.)"));

    return static_cast<ScrollbarWindowRenderer*>(
        d_windowRenderer)->getValueFromThumb();
}

//----------------------------------------------------------------------------//
float Scrollbar::getAdjustDirectionFromPoint(const Point& pt) const
{
    if (!d_windowRenderer)
        CEGUI_THROW(InvalidRequestException(
            "Scrollbar::getAdjustDirectionFromPoint: "
            "This function must be implemented by the window renderer object "
            "(no window renderer is assigned.)"));

    return static_cast<ScrollbarWindowRenderer*>(
        d_windowRenderer)->getAdjustDirectionFromPoint(pt);
}

//----------------------------------------------------------------------------//
// MT3: Check if thumb is at the end position
//----------------------------------------------------------------------------//
bool Scrollbar::isThumbOnEnd()
{
    if (d_windowRenderer != 0)
    {
        ScrollbarWindowRenderer* wr = (ScrollbarWindowRenderer*)d_windowRenderer;
        return wr->isThumbOnEnd();
    }
    return false;
}

//----------------------------------------------------------------------------//
// MT3: Mouse slide event handler
//----------------------------------------------------------------------------//
void Scrollbar::onMouseSlide(MouseEventArgs& e)
{
    WindowEventArgs args(this);
    fireEvent(EventSlide, args, EventNamespace);
    ++e.handled;
}

//----------------------------------------------------------------------------//
bool Scrollbar::onMouseDrag(Gesture::CEGUIGestureRecognizer* recognizer)
{
    Window::onMouseDrag(recognizer);

    if (!d_PanGuestureEnable || !recognizer)
        return true;

    if (m_SlideState == SlideState || m_SlideState == BackState)
        Stop();

    if (recognizer->GetState() != Gesture::GestureRecognizerStateEnded)
    {
        const MouseEventArgs* args = recognizer->getMouseEvent();
        if (!args)
            return false;

        float position = getScrollPosition();
        const float delta = d_PanForVert ? args->moveDelta.d_y : args->moveDelta.d_x;
        position -= delta / getWeakenRatio(position);

        const float lastOffset = m_Offset;
        m_Offset = position - getScrollPosition();
        if (m_Offset * lastOffset < 0.0f)
        {
            m_ticktime = 0.0f;
            d_StopStep = true;
            m_Offset = 0.0f;
        }

        setScrollPosition(position, false);
        return true;
    }

    Gesture::CEGUIPanGestureRecognizer* pan =
        dynamic_cast<Gesture::CEGUIPanGestureRecognizer*>(recognizer);
    if (!pan)
    {
        Back();
        return false;
    }

    d_velocity = d_PanForVert ?
        -pan->velocityInView().d_y : -pan->velocityInView().d_x;
    d_velocity /= getWeakenRatio(getScrollPosition());
    Slide();
    return true;
}

//----------------------------------------------------------------------------//
bool Scrollbar::setScrollPosition_impl(const float position)
{
    const float old_pos = d_position;
    const float max_pos = getMaxScrollPosition();

    // limit position to valid range:  0 <= position <= max_pos
    d_position = (position >= 0) ?
                    ((position <= max_pos) ?
                        position :
                        max_pos) :
                    0.0f;

    return d_position != old_pos;
}

//----------------------------------------------------------------------------//
void Scrollbar::setConfig(const float* const document_size,
                          const float* const page_size,
                          const float* const step_size,
                          const float* const overlap_size,
                          const float* const position)
{
    const bool reset_max_position = d_endLockPosition && isAtEnd();
    bool config_changed = false;
    bool position_changed = false;

    if (document_size && (d_documentSize != *document_size))
    {
        d_documentSize = *document_size;
        config_changed = true;
    }

    if (page_size && (d_pageSize != *page_size))
    {
        d_pageSize = *page_size;
        config_changed = true;
    }

    if (step_size && (d_stepSize != *step_size))
    {
        d_stepSize = *step_size;
        config_changed = true;
    }
    
    if (overlap_size && (d_overlapSize != *overlap_size))
    {
        d_overlapSize = *overlap_size;
        config_changed = true;
    }

    if (position)
        position_changed = setScrollPosition_impl(*position);
    else if (reset_max_position)
        position_changed = setScrollPosition_impl(getMaxScrollPosition());

    // _always_ update the thumb to keep things in sync.  (though this
    // can cause a double-trigger of EventScrollPositionChanged, which
    // also happens with setScrollPosition anyway).
    updateThumb();

    //
    // Fire appropriate events based on actions we took.
    //
    if (config_changed)
    {
        WindowEventArgs args(this);
        onScrollConfigChanged(args);
    }

    if (position_changed)
    {
        WindowEventArgs args(this);
        onScrollPositionChanged(args);
    }
}

//----------------------------------------------------------------------------//
float Scrollbar::getMaxScrollPosition() const
{
    // max position is (docSize - pageSize)
    // but must be at least 0 (in case doc size is very small)
    return ceguimax((d_documentSize - d_pageSize), 0.0f);
}

//----------------------------------------------------------------------------//
bool Scrollbar::isAtEnd() const
{
    return d_position >= getMaxScrollPosition(); 
}

//----------------------------------------------------------------------------//
void Scrollbar::setEndLockEnabled(const bool enabled)
{
    d_endLockPosition = enabled;
}

//----------------------------------------------------------------------------//
bool Scrollbar::isEndLockEnabled() const
{
    return d_endLockPosition;
}

//----------------------------------------------------------------------------//

void Scrollbar::Stop()
{
    m_SlideState = StopState;
    m_BackElapseTime = 0.0f;
    d_velocity = 0.0f;
    d_acceleration = 0.0f;
    m_SlideElapseTime = 0.0f;
    d_TotalSlideTime = 0.0f;
    m_Offset = 0.0f;
    setScrollPosition(getScrollPosition(), true);

    WindowEventArgs args(this);
    fireEvent(EventSlideStopped, args, EventNamespace);
}

//----------------------------------------------------------------------------//
void Scrollbar::Back()
{
    const float position = getScrollPosition();
    const float maxPosition = getMaxScrollPosition();
    if (position >= 0.0f && position <= maxPosition)
    {
        Stop();
        return;
    }

    m_SlideState = BackState;
    m_BackElapseTime = 0.0f;
    m_SlideElapseTime = 0.0f;
    d_TotalSlideTime = 0.0f;
    m_SlideStartPos = position;
    m_Offset = 0.0f;
}

//----------------------------------------------------------------------------//
void Scrollbar::Slide()
{
    m_SlideStartPos = getScrollPosition();
    const float maxPosition = getMaxScrollPosition();
    if (m_SlideStartPos <= 0.0f || m_SlideStartPos >= maxPosition)
    {
        Back();
        return;
    }

    m_SlideDstPos = m_SlideStartPos;
    d_TotalSlideTime = 3.0f;
    m_SlideElapseTime = 0.0f;

    const float velocityThreshold = 20.0f;
    const float minimumVelocity = 100.0f;
    const float maximumVelocity = 1500.0f;
    if (d_velocity > velocityThreshold)
    {
        if (d_velocity < minimumVelocity)
        {
            d_velocity = minimumVelocity;
            d_TotalSlideTime = 1.5f;
        }
        else if (d_velocity > maximumVelocity)
            d_velocity = maximumVelocity;
    }
    else if (d_velocity < -velocityThreshold)
    {
        if (d_velocity > -minimumVelocity)
        {
            d_velocity = -minimumVelocity;
            d_TotalSlideTime = 1.5f;
        }
        else if (d_velocity < -maximumVelocity)
            d_velocity = -maximumVelocity;
    }
    else
    {
        d_TotalSlideTime = 0.75f;
        if (d_parentScrollPane)
        {
            ScrollablePane* pane = dynamic_cast<ScrollablePane*>(d_parentScrollPane);
            if (pane)
                pane->amendSlideDesPos(m_SlideStartPos, m_SlideDstPos,
                                       d_TotalSlideTime, d_velocity);
        }

        if (fabsf(m_SlideDstPos - m_SlideStartPos) < 0.01f)
            Back();
        else
            m_SlideState = SlideState;
        return;
    }

    if (fabsf(d_velocity) < 500.0f)
        d_TotalSlideTime *= 0.5f;
    else if (fabsf(d_velocity) < 1000.0f)
        d_TotalSlideTime *= 0.6f;
    else if (fabsf(d_velocity) < 1500.0f)
        d_TotalSlideTime *= 0.7f;

    const float offset = d_velocity * 0.5f;
    m_SlideDstPos = d_StopStep ? m_SlideStartPos : m_SlideStartPos + offset;
    if (m_SlideDstPos < 0.0f)
        m_SlideDstPos = 0.0f;
    else if (m_SlideDstPos > maxPosition)
        m_SlideDstPos = maxPosition;

    if (d_parentScrollPane)
    {
        ScrollablePane* pane = dynamic_cast<ScrollablePane*>(d_parentScrollPane);
        if (pane)
            pane->amendSlideDesPos(m_SlideStartPos, m_SlideDstPos,
                                   d_TotalSlideTime, d_velocity);
    }

    m_SlideState = SlideState;
}

//----------------------------------------------------------------------------//
void Scrollbar::updateSelf(float elapsed)
{
    Window::updateSelf(elapsed);
    const float maxPosition = getMaxScrollPosition();

    if (m_SlideState == SlideState)
    {
        m_SlideElapseTime += elapsed;
        const float duration = ceguimax(d_TotalSlideTime, 0.001f);
        float t = ceguimin(m_SlideElapseTime / duration, 1.0f) - 1.0f;
        const float position =
            (m_SlideDstPos - m_SlideStartPos) * (t * t * t + 1.0f) +
            m_SlideStartPos;
        setScrollPosition(position, false);

        if (m_SlideElapseTime >= duration)
        {
            setScrollPosition(m_SlideDstPos, false);
            Back();
        }
    }
    else if (m_SlideState == BackState)
    {
        m_BackElapseTime += elapsed;
        const float target = m_SlideStartPos < 0.0f ? 0.0f : maxPosition;
        const float ratio = ceguimin(m_BackElapseTime / 0.3f, 1.0f);
        const float t = ratio - 1.0f;
        const float position =
            (target - m_SlideStartPos) * (t * t * t + 1.0f) +
            m_SlideStartPos;
        setScrollPosition(position, false);

        if (ratio >= 1.0f)
        {
            setScrollPosition(target, true);
            Stop();
            WindowEventArgs args(this);
            onScrollbarEnd(args);
        }
    }

    m_ticktime += elapsed;
    if (m_ticktime > 1.5f && d_StopStep)
    {
        m_ticktime = 0.0f;
        d_StopStep = false;
    }
}

//----------------------------------------------------------------------------//
void Scrollbar::Lock()
{
    Stop();
    d_Lock = true;
    m_SlideState = LockState;
}

//----------------------------------------------------------------------------//
void Scrollbar::Free()
{
    d_Lock = false;
    if (m_SlideState == LockState)
        m_SlideState = StopState;
}

//----------------------------------------------------------------------------//
float Scrollbar::getWeakenRatio(float position) const
{
    const float pageSize = ceguimin(d_pageSize, d_documentSize);
    if (pageSize <= 0.0f)
        return 1.0f;

    const float maxPosition = getMaxScrollPosition();
    float ratio = 1.0f;
    if (position < 0.0f)
        ratio = ((-position) * 3.0f + pageSize) / pageSize;
    else if (position > maxPosition)
        ratio = ((position - maxPosition) * 3.0f + pageSize) / pageSize;

    return ratio > 1.0f ? ratio * ratio * ratio : 1.0f;
}

} // End of  CEGUI namespace section
