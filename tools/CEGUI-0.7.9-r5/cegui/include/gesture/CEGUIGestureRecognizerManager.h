#ifndef _CEGUIGestureRecognizerManager_h_
#define _CEGUIGestureRecognizerManager_h_

#include "gesture/CEGUIGestureRecognizer.h"
#include <map>

namespace CEGUI
{
namespace Gesture
{
enum GestureRecognizerType
{
    LongPress,
    Pan
};

class CEGUIGestureRecognizerManager
{
public:
    CEGUIGestureRecognizerManager();
    ~CEGUIGestureRecognizerManager();

    bool AddRecoginzer(Window& window, GestureRecognizerType type,
                       Event::Subscriber subscriber);
    void RemoveRecognizer(GestureRecognizerType type);
    bool HasRecognizers() const { return !d_recognizers.empty(); }

    bool onMouseButtonDown(const MouseEventArgs& e);
    bool onMouseButtonUp(const MouseEventArgs& e);
    bool onMouseMove(const MouseEventArgs& e);
    bool onMouseLeaves(const MouseEventArgs& e);
    bool update(const UpdateEventArgs& e);
    bool CanReleaseCapture() const;

private:
    typedef std::map<GestureRecognizerType, CEGUIGestureRecognizer*>
        RecognizerMap;
    RecognizerMap d_recognizers;
};

} // End of Gesture namespace section
} // End of CEGUI namespace section

#endif
