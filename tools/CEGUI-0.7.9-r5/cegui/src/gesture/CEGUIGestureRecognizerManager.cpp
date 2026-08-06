#include "gesture/CEGUIGestureRecognizerManager.h"
#include "gesture/CEGUILongPressGestureRecognizer.h"
#include "gesture/CEGUIPanGestureRecognizer.h"

namespace CEGUI
{
namespace Gesture
{
CEGUIGestureRecognizerManager::CEGUIGestureRecognizerManager()
{
}

CEGUIGestureRecognizerManager::~CEGUIGestureRecognizerManager()
{
    for (RecognizerMap::iterator i = d_recognizers.begin();
         i != d_recognizers.end(); ++i)
        delete i->second;
}

bool CEGUIGestureRecognizerManager::AddRecoginzer(
    Window& window, GestureRecognizerType type, Event::Subscriber subscriber)
{
    RemoveRecognizer(type);

    CEGUIGestureRecognizer* recognizer = 0;
    if (type == LongPress)
        recognizer = new CEGUILongPressGestureRecognizer;
    else if (type == Pan)
        recognizer = new CEGUIPanGestureRecognizer;

    if (!recognizer)
        return false;

    recognizer->addTarget(&window);
    recognizer->subscribeEvent(
        CEGUIGestureRecognizer::EventGesture, subscriber);
    d_recognizers[type] = recognizer;
    return true;
}

void CEGUIGestureRecognizerManager::RemoveRecognizer(
    GestureRecognizerType type)
{
    RecognizerMap::iterator i = d_recognizers.find(type);
    if (i == d_recognizers.end())
        return;

    delete i->second;
    d_recognizers.erase(i);
}

bool CEGUIGestureRecognizerManager::onMouseButtonDown(
    const MouseEventArgs& e)
{
    bool handled = false;
    for (RecognizerMap::iterator i = d_recognizers.begin();
         i != d_recognizers.end(); ++i)
        handled = i->second->onMouseButtonDown(e) || handled;
    return handled;
}

bool CEGUIGestureRecognizerManager::onMouseButtonUp(const MouseEventArgs& e)
{
    bool handled = false;
    for (RecognizerMap::iterator i = d_recognizers.begin();
         i != d_recognizers.end(); ++i)
        handled = i->second->onMouseButtonUp(e) || handled;
    return handled;
}

bool CEGUIGestureRecognizerManager::onMouseMove(const MouseEventArgs& e)
{
    bool handled = false;
    for (RecognizerMap::iterator i = d_recognizers.begin();
         i != d_recognizers.end(); ++i)
        handled = i->second->onMouseMove(e) || handled;
    return handled;
}

bool CEGUIGestureRecognizerManager::onMouseLeaves(const MouseEventArgs& e)
{
    bool handled = false;
    for (RecognizerMap::iterator i = d_recognizers.begin();
         i != d_recognizers.end(); ++i)
        handled = i->second->onMouseLeaves(e) || handled;
    return handled;
}

bool CEGUIGestureRecognizerManager::update(const UpdateEventArgs& e)
{
    bool handled = false;
    for (RecognizerMap::iterator i = d_recognizers.begin();
         i != d_recognizers.end(); ++i)
        handled = i->second->update(e) || handled;
    return handled;
}

bool CEGUIGestureRecognizerManager::CanReleaseCapture() const
{
    RecognizerMap::const_iterator i = d_recognizers.find(Pan);
    return i == d_recognizers.end() || !i->second->inMove();
}

} // End of Gesture namespace section
} // End of CEGUI namespace section
