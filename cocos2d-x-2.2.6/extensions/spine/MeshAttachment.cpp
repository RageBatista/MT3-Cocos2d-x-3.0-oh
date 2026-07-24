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
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/

#include <spine/MeshAttachment.h>
#include <spine/extension.h>

namespace cocos2d { namespace extension {

static void _MeshAttachment_dispose (Attachment* attachment) {
	MeshAttachment* self = SUB_CAST(MeshAttachment, attachment);
	_Attachment_deinit(attachment);
	FREE(self->path);
	FREE(self->vertices);
	FREE(self->regionUVs);
	FREE(self->uvs);
	FREE(self->triangles);
	FREE(self->edges);
}

MeshAttachment* MeshAttachment_create (const char* name) {
	MeshAttachment* self = NEW(MeshAttachment);
	self->r = 1;
	self->g = 1;
	self->b = 1;
	self->a = 1;
	_Attachment_init(SUPER(self), name, ATTACHMENT_MESH, _MeshAttachment_dispose);
	return self;
}

void MeshAttachment_updateUVs (MeshAttachment* self) {
	int i;
	float width = self->regionU2 - self->regionU;
	float height = self->regionV2 - self->regionV;
	FREE(self->uvs);
	self->uvs = MALLOC(float, self->verticesCount);
	if (self->regionRotate) {
		for (i = 0; i < self->verticesCount; i += 2) {
			self->uvs[i] = self->regionU + self->regionUVs[i + 1] * width;
			self->uvs[i + 1] = self->regionV + height - self->regionUVs[i] * height;
		}
	} else {
		for (i = 0; i < self->verticesCount; i += 2) {
			self->uvs[i] = self->regionU + self->regionUVs[i] * width;
			self->uvs[i + 1] = self->regionV + self->regionUVs[i + 1] * height;
		}
	}
}

void MeshAttachment_computeWorldVertices (MeshAttachment* self, Slot* slot, float* worldVertices) {
	int i;
	float* vertices = self->vertices;
	const Bone* bone = slot->bone;
	float x = slot->skeleton->x + bone->worldX;
	float y = slot->skeleton->y + bone->worldY;
	for (i = 0; i < self->verticesCount; i += 2) {
		const float vx = vertices[i];
		const float vy = vertices[i + 1];
		worldVertices[i] = vx * bone->m00 + vy * bone->m01 + x;
		worldVertices[i + 1] = vx * bone->m10 + vy * bone->m11 + y;
	}
}

static void _SkinnedMeshAttachment_dispose (Attachment* attachment) {
	SkinnedMeshAttachment* self = SUB_CAST(SkinnedMeshAttachment, attachment);
	_Attachment_deinit(attachment);
	FREE(self->path);
	FREE(self->bones);
	FREE(self->weights);
	FREE(self->regionUVs);
	FREE(self->uvs);
	FREE(self->triangles);
	FREE(self->edges);
}

SkinnedMeshAttachment* SkinnedMeshAttachment_create (const char* name) {
	SkinnedMeshAttachment* self = NEW(SkinnedMeshAttachment);
	self->r = 1;
	self->g = 1;
	self->b = 1;
	self->a = 1;
	_Attachment_init(SUPER(self), name, ATTACHMENT_SKINNED_MESH, _SkinnedMeshAttachment_dispose);
	return self;
}

void SkinnedMeshAttachment_updateUVs (SkinnedMeshAttachment* self) {
	int i;
	float width = self->regionU2 - self->regionU;
	float height = self->regionV2 - self->regionV;
	FREE(self->uvs);
	self->uvs = MALLOC(float, self->uvsCount);
	if (self->regionRotate) {
		for (i = 0; i < self->uvsCount; i += 2) {
			self->uvs[i] = self->regionU + self->regionUVs[i + 1] * width;
			self->uvs[i + 1] = self->regionV + height - self->regionUVs[i] * height;
		}
	} else {
		for (i = 0; i < self->uvsCount; i += 2) {
			self->uvs[i] = self->regionU + self->regionUVs[i] * width;
			self->uvs[i + 1] = self->regionV + self->regionUVs[i + 1] * height;
		}
	}
}

void SkinnedMeshAttachment_computeWorldVertices (SkinnedMeshAttachment* self, Slot* slot, float* worldVertices) {
	int w = 0, v = 0, b = 0;
	float x = slot->skeleton->x;
	float y = slot->skeleton->y;
	Bone** skeletonBones = slot->skeleton->bones;
	for (; v < self->bonesCount; w += 2) {
		float wx = 0;
		float wy = 0;
		const int nn = self->bones[v] + v;
		v++;
		for (; v <= nn; v++, b += 3) {
			const Bone* bone = skeletonBones[self->bones[v]];
			const float vx = self->weights[b];
			const float vy = self->weights[b + 1];
			const float weight = self->weights[b + 2];
			wx += (vx * bone->m00 + vy * bone->m01 + bone->worldX) * weight;
			wy += (vx * bone->m10 + vy * bone->m11 + bone->worldY) * weight;
		}
		worldVertices[w] = wx + x;
		worldVertices[w + 1] = wy + y;
	}
}

}} // namespace cocos2d { namespace extension {
