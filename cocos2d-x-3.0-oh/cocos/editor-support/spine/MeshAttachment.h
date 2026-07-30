/******************************************************************************
 * Spine Runtime Software License - Version 1.1
 *
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms in whole or in part, with
 * or without modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. A Spine Essential, Professional, Enterprise, or Education License must
 *    be purchased from Esoteric Software and the license must remain valid:
 *    http://esotericsoftware.com/
 * 2. Redistributions of source code must retain this license, which is the
 *    above copyright notice, this declaration of conditions and the following
 *    disclaimer.
 * 3. Redistributions in binary form must reproduce this license, which is the
 *    above copyright notice, this declaration of conditions and the following
 *    disclaimer, in the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

#ifndef SPINE_MESHATTACHMENT_H_
#define SPINE_MESHATTACHMENT_H_

#include <spine/Attachment.h>
#include <spine/Atlas.h>
#include <spine/Slot.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct spMeshAttachment spMeshAttachment;
struct spMeshAttachment {
	spAttachment super;
	const char* path;

	int verticesCount;
	float* vertices;
	int hullLength;

	float* regionUVs;
	float* uvs;

	int trianglesCount;
	int* triangles;

	float r, g, b, a;

	void* rendererObject;
	int regionOffsetX, regionOffsetY;
	int regionWidth, regionHeight;
	int regionOriginalWidth, regionOriginalHeight;
	float regionU, regionV, regionU2, regionV2;
	int/*bool*/regionRotate;

	int edgesCount;
	int* edges;
	float width, height;
};

spMeshAttachment* spMeshAttachment_create (const char* name);
void spMeshAttachment_updateUVs (spMeshAttachment* self);
void spMeshAttachment_computeWorldVertices (spMeshAttachment* self, spSlot* slot, float* worldVertices);

typedef struct spSkinnedMeshAttachment spSkinnedMeshAttachment;
struct spSkinnedMeshAttachment {
	spAttachment super;
	const char* path;

	int bonesCount;
	int* bones;

	int weightsCount;
	float* weights;

	int trianglesCount;
	int* triangles;

	int uvsCount;
	float* regionUVs;
	float* uvs;
	int hullLength;

	float r, g, b, a;

	void* rendererObject;
	int regionOffsetX, regionOffsetY;
	int regionWidth, regionHeight;
	int regionOriginalWidth, regionOriginalHeight;
	float regionU, regionV, regionU2, regionV2;
	int/*bool*/regionRotate;

	int edgesCount;
	int* edges;
	float width, height;
};

spSkinnedMeshAttachment* spSkinnedMeshAttachment_create (const char* name);
void spSkinnedMeshAttachment_updateUVs (spSkinnedMeshAttachment* self);
void spSkinnedMeshAttachment_computeWorldVertices (spSkinnedMeshAttachment* self, spSlot* slot, float* worldVertices);

#ifdef SPINE_SHORT_NAMES
typedef spMeshAttachment MeshAttachment;
#define MeshAttachment_create(...) spMeshAttachment_create(__VA_ARGS__)
#define MeshAttachment_updateUVs(...) spMeshAttachment_updateUVs(__VA_ARGS__)
#define MeshAttachment_computeWorldVertices(...) spMeshAttachment_computeWorldVertices(__VA_ARGS__)

typedef spSkinnedMeshAttachment SkinnedMeshAttachment;
#define SkinnedMeshAttachment_create(...) spSkinnedMeshAttachment_create(__VA_ARGS__)
#define SkinnedMeshAttachment_updateUVs(...) spSkinnedMeshAttachment_updateUVs(__VA_ARGS__)
#define SkinnedMeshAttachment_computeWorldVertices(...) spSkinnedMeshAttachment_computeWorldVertices(__VA_ARGS__)
#endif

#ifdef __cplusplus
}
#endif

#endif /* SPINE_MESHATTACHMENT_H_ */
