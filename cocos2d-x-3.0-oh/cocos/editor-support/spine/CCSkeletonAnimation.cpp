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

#include <spine/CCSkeletonAnimation.h>
#include <spine/extension.h>
#include <spine/spine-cocos2dx.h>
#include "MT3SpineDiagnostic.h"
#include <stdio.h>

USING_NS_CC;
using std::min;
using std::max;
using std::vector;

namespace spine {

// Diagnostic log: output to spine_draw_debug.log, only first 5 frames and frame 60/180/600
static int g_spineDrawLogCount = 0;
static bool MT3SpineDrawShouldLog()
{
	++g_spineDrawLogCount;
	return (g_spineDrawLogCount <= 5 || g_spineDrawLogCount == 60 || g_spineDrawLogCount == 180 || g_spineDrawLogCount == 600);
}

static void callback (spAnimationState* state, int trackIndex, spEventType type, spEvent* event, int loopCount) {
	((SkeletonAnimation*)state->context)->onAnimationStateEvent(trackIndex, type, event, loopCount);
}

SkeletonAnimation* SkeletonAnimation::createWithData (spSkeletonData* skeletonData) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonData);
	node->autorelease();
	return node;
}

SkeletonAnimation* SkeletonAnimation::createWithFile (const char* skeletonDataFile, spAtlas* atlas, float scale) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonDataFile, atlas, scale);
	node->autorelease();
	return node;
}

SkeletonAnimation* SkeletonAnimation::createWithFile (const char* skeletonDataFile, const char* atlasFile, float scale) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonDataFile, atlasFile, scale);
	node->autorelease();
	return node;
}

SkeletonAnimation* SkeletonAnimation::createWithTextureMap (const char* skeletonRawData, int skeletonRawDataLen, const char* atlasRawData, int atlasRawDataLen, const char* dir, const PathToTextureMap& textureMap, float scale) {
	PathToTextureMap atlasTextures;
	spAtlas_parseTextureMap(atlasRawData, atlasRawDataLen, dir, &atlasTextures);
	for (PathToTextureMap::const_iterator iter = atlasTextures.begin(); iter != atlasTextures.end(); ++iter) {
		PathToTextureMap::const_iterator texture = textureMap.find(iter->first);
		if (texture == textureMap.end() || !texture->second) return 0;
	}
	if (atlasTextures.empty()) return 0;

	SkeletonAnimation* node = new SkeletonAnimation(skeletonRawData, skeletonRawDataLen, atlasRawData, atlasRawDataLen, dir, textureMap, scale);
	node->autorelease();
	return node;
}

void SkeletonAnimation::initialize () {
	listenerInstance = 0;
	listenerMethod = 0;

	ownsAnimationStateData = true;
	state = spAnimationState_create(spAnimationStateData_create(skeleton->data));
	state->context = this;
	state->listener = callback;
}

SkeletonAnimation::SkeletonAnimation (spSkeletonData *skeletonData)
		: Skeleton(skeletonData) {
	initialize();
}

SkeletonAnimation::SkeletonAnimation (const char* skeletonDataFile, spAtlas* atlas, float scale)
		: Skeleton(skeletonDataFile, atlas, scale) {
	initialize();
}

SkeletonAnimation::SkeletonAnimation (const char* skeletonDataFile, const char* atlasFile, float scale)
		: Skeleton(skeletonDataFile, atlasFile, scale) {
	initialize();
}

SkeletonAnimation::SkeletonAnimation (const char* skeletonRawData, int skeletonRawDataLen, const char* atlasRawData, int atlasRawDataLen, const char* dir, const PathToTextureMap& textureMap, float scale)
		: Skeleton(), _mt3OwnedAtlas(0) {
	_mt3OwnedAtlas = Atlas_readAtlasWithTextureMap(atlasRawData, atlasRawDataLen, dir, textureMap);
	CCAssert(_mt3OwnedAtlas, "Error reading atlas data.");

	spSkeletonJson* json = spSkeletonJson_create(_mt3OwnedAtlas);
	json->scale = scale == 0 ? (1 / Director::getInstance()->getContentScaleFactor()) : scale;
	std::string skeletonJson(skeletonRawData, skeletonRawDataLen);
	spSkeletonData* skeletonData = spSkeletonJson_readSkeletonData(json, skeletonJson.c_str());
	CCAssert(skeletonData, json->error ? json->error : "Error reading skeleton data.");
	spSkeletonJson_dispose(json);

	setSkeletonData(skeletonData, true);
	initialize();
}

SkeletonAnimation::~SkeletonAnimation () {
	if (ownsAnimationStateData) spAnimationStateData_dispose(state->data);
	spAnimationState_dispose(state);
	if (_mt3OwnedAtlas) {
		spAtlas_dispose(_mt3OwnedAtlas);
		_mt3OwnedAtlas = 0;
	}
}

void SkeletonAnimation::update (float deltaTime) {
	super::update(deltaTime);

	deltaTime *= timeScale;
	spAnimationState_update(state, deltaTime);
	spAnimationState_apply(state, skeleton);
	spSkeleton_updateWorldTransform(skeleton);
}

void SkeletonAnimation::setAnimationStateData (spAnimationStateData* stateData) {
	CCAssert(stateData, "stateData cannot be null.");

	if (ownsAnimationStateData) spAnimationStateData_dispose(state->data);
	spAnimationState_dispose(state);

	ownsAnimationStateData = false;
	state = spAnimationState_create(stateData);
	state->context = this;
	state->listener = callback;
}

void SkeletonAnimation::setMix (const char* fromAnimation, const char* toAnimation, float duration) {
	spAnimationStateData_setMixByName(state->data, fromAnimation, toAnimation, duration);
}

void SkeletonAnimation::setAnimationListener (Ref* instance, SEL_AnimationStateEvent method) {
	listenerInstance = instance;
	listenerMethod = method;
}

spTrackEntry* SkeletonAnimation::setAnimation (int trackIndex, const char* name, bool loop) {
	spAnimation* animation = spSkeletonData_findAnimation(skeleton->data, name);
	if (!animation) {
		log("Spine: Animation not found: %s", name);
		return 0;
	}
	return spAnimationState_setAnimation(state, trackIndex, animation, loop);
}

spTrackEntry* SkeletonAnimation::addAnimation (int trackIndex, const char* name, bool loop, float delay) {
	spAnimation* animation = spSkeletonData_findAnimation(skeleton->data, name);
	if (!animation) {
		log("Spine: Animation not found: %s", name);
		return 0;
	}
	return spAnimationState_addAnimation(state, trackIndex, animation, loop, delay);
}

spTrackEntry* SkeletonAnimation::getCurrent (int trackIndex) { 
	return spAnimationState_getCurrent(state, trackIndex);
}

void SkeletonAnimation::clearTracks () {
	spAnimationState_clearTracks(state);
}

void SkeletonAnimation::clearTrack (int trackIndex) {
	spAnimationState_clearTrack(state, trackIndex);
}

void SkeletonAnimation::setTimeScale (float scale) {
	timeScale = scale;
}

float SkeletonAnimation::getTimeScale () const {
	return timeScale;
}

float SkeletonAnimation::getAnimationDuration (const char* name) {
	spAnimation* animation = name ? spSkeletonData_findAnimation(skeleton->data, name) : 0;
	if (!animation) {
		log("Spine: Animation not found: %s", name ? name : "");
		return 0;
	}
	return animation->duration;
}

float SkeletonAnimation::getAnimationDuration (int stateIndex, const char* name) {
	return getAnimationDuration(name);
}

void SkeletonAnimation::draw (float vpLeft, float vpTop, float drawAlpha) {
	bool shouldLog = MT3SpineDrawShouldLog();
	GLubyte oldOpacity = getOpacity();
	if (drawAlpha < 0) drawAlpha = 0;
	if (drawAlpha > 1) drawAlpha = 1;
	setOpacity((GLubyte)(oldOpacity * drawAlpha));

	if (shouldLog)
	{
		Point pos = getPosition();
		MT3SpineTrace("=== SkeletonAnimation::draw #%d vpLeft=%f vpTop=%f drawAlpha=%f pos=(%f,%f) scale=(%f,%f) opacity=%d/%d ===",
			g_spineDrawLogCount, vpLeft, vpTop, drawAlpha, pos.x, pos.y, getScaleX(), getScaleY(), oldOpacity, getOpacity());
	}

	// FIX: CEGUI's endRendering leaves matrix mode at KM_GL_PROJECTION without restoring
	// KM_GL_MODELVIEW. Must explicitly switch to MODELVIEW before push/translate/mult,
	// otherwise nodeTransform gets applied to the wrong stack.
	kmGLMatrixMode(KM_GL_MODELVIEW);

	// Diagnostic: record matrices before push
	kmMat4 projBefore, mvBefore;
	kmGLGetMatrix(KM_GL_PROJECTION, &projBefore);
	kmGLGetMatrix(KM_GL_MODELVIEW, &mvBefore);
	if (shouldLog)
	{
		MT3SpineTrace("  PROJ before: [0]=%.2f [5]=%.2f [10]=%.2f [12]=%.2f [13]=%.2f [14]=%.2f [15]=%.2f",
			projBefore.mat[0], projBefore.mat[5], projBefore.mat[10], projBefore.mat[12], projBefore.mat[13], projBefore.mat[14], projBefore.mat[15]);
		MT3SpineTrace("  MV before:   [0]=%.2f [5]=%.2f [12]=%.2f [13]=%.2f",
			mvBefore.mat[0], mvBefore.mat[5], mvBefore.mat[12], mvBefore.mat[13]);
	}

	// FIX: The engine's 3D perspective projection is active when Spine renders
	// (outside CEGUI's beginRendering/endRendering). Override with a 2D ortho
	// projection matching the viewport so UI Spine renders in screen space.
	GLint viewport[4];
	glGetIntegerv(GL_VIEWPORT, viewport);
	if (shouldLog)
	{
		MT3SpineTrace("  viewport: [%d,%d,%d,%d] vpLeft=%f vpTop=%f",
			viewport[0], viewport[1], viewport[2], viewport[3], vpLeft, vpTop);
	}
	kmGLMatrixMode(KM_GL_PROJECTION);
	kmGLPushMatrix();
	kmGLLoadIdentity();
	kmMat4 ortho;
	kmMat4OrthographicProjection(&ortho,
		0.0f, (float)viewport[2],
		(float)viewport[3], 0.0f,
		-1.0f, 1.0f);
	kmGLMultMatrix(&ortho);
	kmGLMatrixMode(KM_GL_MODELVIEW);

	kmGLPushMatrix();
	kmGLLoadIdentity(); // Reset MV so engine camera offset doesn't shift UI Spine
	kmGLTranslatef(-vpLeft, -vpTop, 0);

	// Apply node's own transform (position, scale, rotation)
	kmMat4 nodeTransform = getNodeToParentTransform();
	if (shouldLog)
	{
		MT3SpineTrace("  nodeTransform: [0]=%.4f [5]=%.4f [12]=%.2f [13]=%.2f",
			nodeTransform.mat[0], nodeTransform.mat[5], nodeTransform.mat[12], nodeTransform.mat[13]);
	}
	kmGLMultMatrix(&nodeTransform);

	// Get the current modelview matrix for the shader
	kmMat4 currentMV;
	kmGLGetMatrix(KM_GL_MODELVIEW, &currentMV);
	kmMat4 currentProj;
	kmGLGetMatrix(KM_GL_PROJECTION, &currentProj);
	if (shouldLog)
	{
		MT3SpineTrace("  currentMV: [0]=%.4f [5]=%.4f [12]=%.2f [13]=%.2f",
			currentMV.mat[0], currentMV.mat[5], currentMV.mat[12], currentMV.mat[13]);
		MT3SpineTrace("  currentProj: [0]=%.4f [5]=%.4f [10]=%.4f [12]=%.2f [13]=%.2f [15]=%.2f",
			currentProj.mat[0], currentProj.mat[5], currentProj.mat[10], currentProj.mat[12], currentProj.mat[13], currentProj.mat[15]);
	}

	onDraw(currentMV, true);

	kmGLPopMatrix();

	// Restore projection to what it was before our 2D ortho override
	kmGLMatrixMode(KM_GL_PROJECTION);
	kmGLPopMatrix();
	kmGLMatrixMode(KM_GL_MODELVIEW);

	// Restore shader program that may have been changed by pushShader/popShader
	ShaderCache* shaderCache = ShaderCache::getInstance();
	std::string currentShader = shaderCache->getCurShader();
	GLProgram* restoreProgram = currentShader.empty() ? getShaderProgram() : shaderCache->getProgram(currentShader.c_str());
	if (restoreProgram) {
		restoreProgram->use();
		restoreProgram->setUniformsForBuiltins();
	}

	setOpacity(oldOpacity);
}

void SkeletonAnimation::onAnimationStateEvent (int trackIndex, spEventType type, spEvent* event, int loopCount) {
	if (listenerInstance) (listenerInstance->*listenerMethod)(this, trackIndex, type, event, loopCount);
}

}
