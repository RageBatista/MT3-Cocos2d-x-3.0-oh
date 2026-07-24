/*******************************************************************************
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
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
 ******************************************************************************/

#ifndef SPINE_MESHATTACHMENT_H_
#define SPINE_MESHATTACHMENT_H_

#include <spine/Attachment.h>
#include <spine/Atlas.h>
#include <spine/Slot.h>

namespace cocos2d { namespace extension {

typedef struct MeshAttachment MeshAttachment;
struct MeshAttachment {
	Attachment super;
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

CC_EX_DLL MeshAttachment* MeshAttachment_create (const char* name);
CC_EX_DLL void MeshAttachment_updateUVs (MeshAttachment* self);
CC_EX_DLL void MeshAttachment_computeWorldVertices (MeshAttachment* self, Slot* slot, float* worldVertices);

typedef struct SkinnedMeshAttachment SkinnedMeshAttachment;
struct SkinnedMeshAttachment {
	Attachment super;
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

CC_EX_DLL SkinnedMeshAttachment* SkinnedMeshAttachment_create (const char* name);
CC_EX_DLL void SkinnedMeshAttachment_updateUVs (SkinnedMeshAttachment* self);
CC_EX_DLL void SkinnedMeshAttachment_computeWorldVertices (SkinnedMeshAttachment* self, Slot* slot, float* worldVertices);

}} // namespace cocos2d { namespace extension {

#endif /* SPINE_MESHATTACHMENT_H_ */
