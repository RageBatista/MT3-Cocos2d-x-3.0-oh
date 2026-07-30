#ifndef MT3_SPINE_DIAGNOSTIC_H
#define MT3_SPINE_DIAGNOSTIC_H

// Shared diagnostic trace helper for MT3 Spine rendering.
// Writes formatted output to spine_draw_debug.log (append mode).
// Used by CCSkeleton.cpp and CCSkeletonAnimation.cpp to avoid
// duplicating the file open/write/close logic.
void MT3SpineTrace(const char* fmt, ...);

#endif // MT3_SPINE_DIAGNOSTIC_H
