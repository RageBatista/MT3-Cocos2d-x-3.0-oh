/*
Copyright (c) 2008, Luke Benstead.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#ifdef _WIN32
#include <windows.h>
#endif

#include "kazmath/GL/matrix.h"
#include "kazmath/GL/mat4stack.h"

km_mat4_stack modelview_matrix_stack;
km_mat4_stack projection_matrix_stack;
km_mat4_stack texture_matrix_stack;

km_mat4_stack* current_stack = NULL;

static unsigned char initialized = 0;

// MT3 debug: track push/pop balance and kmGLFreeAll calls
static int sModelViewPushCount = 0;
static int sModelViewPopCount = 0;
static int sFreeAllCount = 0;
static int sLastFreeAllMVBalance = 0;

void lazyInitialize()
{

    if (!initialized) {
        kmMat4 identity; //Temporary identity matrix

        //Initialize all 3 stacks
        //modelview_matrix_stack = (km_mat4_stack*) malloc(sizeof(km_mat4_stack));
        km_mat4_stack_initialize(&modelview_matrix_stack);

        //projection_matrix_stack = (km_mat4_stack*) malloc(sizeof(km_mat4_stack));
        km_mat4_stack_initialize(&projection_matrix_stack);

        //texture_matrix_stack = (km_mat4_stack*) malloc(sizeof(km_mat4_stack));
        km_mat4_stack_initialize(&texture_matrix_stack);

        current_stack = &modelview_matrix_stack;
        initialized = 1;

        kmMat4Identity(&identity);

        //Make sure that each stack has the identity matrix
        km_mat4_stack_push(&modelview_matrix_stack, &identity);
        km_mat4_stack_push(&projection_matrix_stack, &identity);
        km_mat4_stack_push(&texture_matrix_stack, &identity);
    }
}

void kmGLMatrixMode(kmGLEnum mode)
{
    lazyInitialize();

    switch(mode)
    {
        case KM_GL_MODELVIEW:
            current_stack = &modelview_matrix_stack;
        break;
        case KM_GL_PROJECTION:
            current_stack = &projection_matrix_stack;
        break;
        case KM_GL_TEXTURE:
            current_stack = &texture_matrix_stack;
        break;
        default:
            assert(0 && "Invalid matrix mode specified"); //TODO: Proper error handling
        break;
    }
}

void kmGLPushMatrix(void)
{
    kmMat4 top;

    lazyInitialize(); //Initialize the stacks if they haven't been already

    //Duplicate the top of the stack (i.e the current matrix)
    kmMat4Assign(&top, current_stack->top);
    km_mat4_stack_push(current_stack, &top);

    // MT3 debug: track MODELVIEW push count
    if (current_stack == &modelview_matrix_stack)
        ++sModelViewPushCount;
}

void kmGLPopMatrix(void)
{
    // Do not let a diagnostic path abort or block the render thread. A stale
    // state cache or an unmatched legacy pop must be reported and skipped.
    if (!initialized || !current_stack || current_stack->item_count == 0)
    {
#if defined(_MSC_VER)
        const char* stackName = (current_stack == &modelview_matrix_stack) ? "MODELVIEW" :
                                (current_stack == &projection_matrix_stack) ? "PROJECTION" :
                                (current_stack == &texture_matrix_stack) ? "TEXTURE" : "UNKNOWN";
        const int itemCount = current_stack ? current_stack->item_count : 0;
        const int capacity = current_stack ? current_stack->capacity : 0;
        char msg[512];
        _snprintf_s(msg, sizeof(msg), _TRUNCATE,
            "[MT3_MATRIX_DEBUG] kmGLPopMatrix on EMPTY %s stack! "
            "item_count=%d, capacity=%d. "
            "Skipping pop to avoid assertion.",
            stackName, itemCount, capacity);
        OutputDebugStringA(msg);
        OutputDebugStringA("\n");

        // Get the caller address from the stack frame (EBP+4 = return address)
        void* callerAddr = NULL;
        void* callersCallerAddr = NULL;
        __asm {
            mov eax, [ebp + 4]
            mov callerAddr, eax
            mov eax, [ebp]
            mov eax, [eax + 4]
            mov callersCallerAddr, eax
        }

        char frameMsg[512];
        _snprintf_s(frameMsg, sizeof(frameMsg), _TRUNCATE,
            "[MT3_MATRIX_DEBUG] kmGLPopMatrix EMPTY %s stack! caller=%p, caller's_caller=%p",
            stackName, callerAddr, callersCallerAddr);
        OutputDebugStringA(frameMsg);
        OutputDebugStringA("\n");

        // Keep the warning non-modal so startup and the render loop continue.
        static int sEmptyPopWarnings[3] = {0, 0, 0};
        int stackIdx = (current_stack == &modelview_matrix_stack) ? 0 :
                       (current_stack == &projection_matrix_stack) ? 1 : 2;
        if (sEmptyPopWarnings[stackIdx] < 3)
        {
            ++sEmptyPopWarnings[stackIdx];
            char warnMsg[512];
            _snprintf_s(warnMsg, sizeof(warnMsg), _TRUNCATE,
                "[MT3_MATRIX_DEBUG] Empty %s pop warning #%d (max 3), skipped; "
                "MV push=%d pop=%d balance=%d, kmGLFreeAll=%d, initialized=%d.\n",
                stackName, sEmptyPopWarnings[stackIdx],
                sModelViewPushCount, sModelViewPopCount,
                sModelViewPushCount - sModelViewPopCount,
                sFreeAllCount, (int)initialized);
            OutputDebugStringA(warnMsg);
        }
#endif

        return; // SAFETY: Do NOT pop from an empty stack
    }
    km_mat4_stack_pop(current_stack, NULL);

    // MT3 debug: track MODELVIEW pop count
    if (current_stack == &modelview_matrix_stack)
        ++sModelViewPopCount;
}

void kmGLLoadIdentity()
{
    lazyInitialize();

    kmMat4Identity(current_stack->top); //Replace the top matrix with the identity matrix
}

void kmGLFreeAll()
{
    // MT3 debug: track kmGLFreeAll calls
    ++sFreeAllCount;
    sLastFreeAllMVBalance = sModelViewPushCount - sModelViewPopCount;
#if defined(_MSC_VER)
    char dbgMsg[256];
    _snprintf_s(dbgMsg, sizeof(dbgMsg), _TRUNCATE,
        "[MT3_MATRIX_DEBUG] kmGLFreeAll called #%d, MV push=%d pop=%d balance=%d\n",
        sFreeAllCount, sModelViewPushCount, sModelViewPopCount,
        sLastFreeAllMVBalance);
    OutputDebugStringA(dbgMsg);
#endif

    //Clear the matrix stacks
    km_mat4_stack_release(&modelview_matrix_stack);
    km_mat4_stack_release(&projection_matrix_stack);
    km_mat4_stack_release(&texture_matrix_stack);

    //Delete the matrices
    initialized = 0; //Set to uninitialized

    current_stack = NULL; //Set the current stack to point nowhere
}

void kmGLMultMatrix(const kmMat4* pIn)
{
    lazyInitialize();
    kmMat4Multiply(current_stack->top, current_stack->top, pIn);
}

void kmGLLoadMatrix(const kmMat4* pIn)
{
    lazyInitialize();
    kmMat4Assign(current_stack->top, pIn);
}

void kmGLGetMatrix(kmGLEnum mode, kmMat4* pOut)
{
    lazyInitialize();

    switch(mode)
    {
        case KM_GL_MODELVIEW:
            kmMat4Assign(pOut, modelview_matrix_stack.top);
        break;
        case KM_GL_PROJECTION:
            kmMat4Assign(pOut, projection_matrix_stack.top);
        break;
        case KM_GL_TEXTURE:
            kmMat4Assign(pOut, texture_matrix_stack.top);
        break;
        default:
            assert(1 && "Invalid matrix mode specified"); //TODO: Proper error handling
        break;
    }
}

kmGLEnum kmGLGetCurrentMatrixMode(void)
{
    lazyInitialize();
    if (current_stack == &modelview_matrix_stack)
        return KM_GL_MODELVIEW;
    if (current_stack == &projection_matrix_stack)
        return KM_GL_PROJECTION;
    if (current_stack == &texture_matrix_stack)
        return KM_GL_TEXTURE;
    return KM_GL_MODELVIEW; // fallback
}

void kmGLTranslatef(float x, float y, float z)
{
    kmMat4 translation;

    //Create a rotation matrix using the axis and the angle
    kmMat4Translation(&translation,x,y,z);

    //Multiply the rotation matrix by the current matrix
    kmMat4Multiply(current_stack->top, current_stack->top, &translation);
}

void kmGLRotatef(float angle, float x, float y, float z)
{
    kmVec3 axis;
    kmMat4 rotation;

    //Create an axis vector
    kmVec3Fill(&axis, x, y, z);

    //Create a rotation matrix using the axis and the angle
    kmMat4RotationAxisAngle(&rotation, &axis, kmDegreesToRadians(angle));

    //Multiply the rotation matrix by the current matrix
    kmMat4Multiply(current_stack->top, current_stack->top, &rotation);
}

void kmGLScalef(float x, float y, float z)
{
    kmMat4 scaling;
    kmMat4Scaling(&scaling, x, y, z);
    kmMat4Multiply(current_stack->top, current_stack->top, &scaling);
}
