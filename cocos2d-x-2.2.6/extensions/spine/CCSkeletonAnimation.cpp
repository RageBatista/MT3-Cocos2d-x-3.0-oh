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

#include <spine/CCSkeletonAnimation.h>
#include <spine/extension.h>
#include <spine/spine-cocos2dx.h>
#include <string>
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 && _MSC_VER >= 1800) // Visual Studio 2013
#include <algorithm>
#endif

USING_NS_CC;
using std::min;
using std::max;
using std::vector;

namespace cocos2d { namespace extension {

CCSkeletonAnimation* CCSkeletonAnimation::createWithData (SkeletonData* skeletonData) {
	CCSkeletonAnimation* node = new CCSkeletonAnimation(skeletonData);
	node->autorelease();
	return node;
}

CCSkeletonAnimation* CCSkeletonAnimation::createWithFile (const char* skeletonDataFile, Atlas* atlas, float scale) {
	CCSkeletonAnimation* node = new CCSkeletonAnimation(skeletonDataFile, atlas, scale);
	node->autorelease();
	return node;
}

CCSkeletonAnimation* CCSkeletonAnimation::createWithFile (const char* skeletonDataFile, const char* atlasFile, float scale) {
	CCSkeletonAnimation* node = new CCSkeletonAnimation(skeletonDataFile, atlasFile, scale);
	node->autorelease();
	return node;
}

CCSkeletonAnimation* CCSkeletonAnimation::createWithTextureMap (const char* skeletonRawData, int skeletonRawDataLen, const char* atlasRawData, int atlasRawDataLen, const char* dir, const PathToTextureMap& textureMap, float scale) {
	CCSkeletonAnimation* node = new CCSkeletonAnimation(skeletonRawData, skeletonRawDataLen, atlasRawData, atlasRawDataLen, dir, textureMap, scale);
	node->autorelease();
	return node;
}

CCSkeletonAnimation::CCSkeletonAnimation (SkeletonData *skeletonData)
		: CCSkeleton(skeletonData), mt3OwnedAtlas(0) {
	addAnimationState();
}

CCSkeletonAnimation::CCSkeletonAnimation (const char* skeletonDataFile, Atlas* atlas, float scale)
		: CCSkeleton(skeletonDataFile, atlas, scale), mt3OwnedAtlas(0) {
	addAnimationState();
}

CCSkeletonAnimation::CCSkeletonAnimation (const char* skeletonDataFile, const char* atlasFile, float scale)
		: CCSkeleton(skeletonDataFile, atlasFile, scale), mt3OwnedAtlas(0) {
	addAnimationState();
}

CCSkeletonAnimation::CCSkeletonAnimation (const char* skeletonRawData, int skeletonRawDataLen, const char* atlasRawData, int atlasRawDataLen, const char* dir, const PathToTextureMap& textureMap, float scale)
		: CCSkeleton(), mt3OwnedAtlas(0) {
	mt3OwnedAtlas = Atlas_readAtlasWithTextureMap(atlasRawData, atlasRawDataLen, dir, textureMap);
	CCAssert(mt3OwnedAtlas, "Error reading atlas data.");

	SkeletonJson* json = SkeletonJson_create(mt3OwnedAtlas);
	json->scale = scale;
	std::string skeletonJson(skeletonRawData, skeletonRawDataLen);
	SkeletonData* skeletonData = SkeletonJson_readSkeletonData(json, skeletonJson.c_str());
	CCAssert(skeletonData, json->error ? json->error : "Error reading skeleton data.");
	SkeletonJson_dispose(json);

	setSkeletonData(skeletonData, true);
	addAnimationState();
}

CCSkeletonAnimation::~CCSkeletonAnimation () {
	for (std::vector<AnimationStateData*>::iterator iter = stateDatas.begin(); iter != stateDatas.end(); ++iter)
		AnimationStateData_dispose(*iter);

	for (std::vector<AnimationState*>::iterator iter = states.begin(); iter != states.end(); ++iter)
		AnimationState_dispose(*iter);

	if (mt3OwnedAtlas) {
		Atlas_dispose(mt3OwnedAtlas);
		mt3OwnedAtlas = 0;
	}
}

void CCSkeletonAnimation::update (float deltaTime) {
	super::update(deltaTime);

	deltaTime *= timeScale;
	for (std::vector<AnimationState*>::iterator iter = states.begin(); iter != states.end(); ++iter) {
		AnimationState_update(*iter, deltaTime);
		AnimationState_apply(*iter, skeleton);
	}
	Skeleton_updateWorldTransform(skeleton);
}

void CCSkeletonAnimation::draw (float vpLeft, float vpTop, float drawAlpha) {
	GLubyte oldOpacity = getOpacity();
	if (drawAlpha < 0) drawAlpha = 0;
	if (drawAlpha > 1) drawAlpha = 1;
	setOpacity((GLubyte)(oldOpacity * drawAlpha));

	kmGLPushMatrix();
	kmGLTranslatef(-vpLeft, -vpTop, 0);
	transform();
	super::draw();
	kmGLPopMatrix();

	CCShaderCache* shaderCache = CCShaderCache::sharedShaderCache();
	std::string currentShader = shaderCache->getCurShader();
	CCGLProgram* restoreProgram = currentShader.empty() ? getShaderProgram() : shaderCache->programForKey(currentShader.c_str());
	if (restoreProgram) {
		restoreProgram->use();
		restoreProgram->setUniformsForBuiltins();
	}

	setOpacity(oldOpacity);
}

void CCSkeletonAnimation::addAnimationState (AnimationStateData* stateData) {
	if (!stateData) {
		stateData = AnimationStateData_create(skeleton->data);
		stateDatas.push_back(stateData);
	}
	AnimationState* state = AnimationState_create(stateData);
	states.push_back(state);
}

void CCSkeletonAnimation::setAnimationStateData (AnimationStateData* stateData, int stateIndex) {
	CCAssert(stateIndex >= 0 && stateIndex < (int)states.size(), "stateIndex out of range.");
	CCAssert(stateData, "stateData cannot be null.");

	AnimationState* state = states[stateIndex];
	for (std::vector<AnimationStateData*>::iterator iter = stateDatas.begin(); iter != stateDatas.end(); ++iter) {
		if (state->data == *iter) {
			AnimationStateData_dispose(state->data);
			stateDatas.erase(iter);
			break;
		}
	}
	for (std::vector<AnimationState*>::iterator iter = states.begin(); iter != states.end(); ++iter) {
		if (state == *iter) {
			states.erase(iter);
			break;
		}
	}
	AnimationState_dispose(state);

	state = AnimationState_create(stateData);
	states[stateIndex] = state;
}

void CCSkeletonAnimation::setMix (const char* fromAnimation, const char* toAnimation, float duration, int stateIndex) {
	CCAssert(stateIndex >= 0 && stateIndex < (int)states.size(), "stateIndex out of range.");
	AnimationStateData_setMixByName(states[stateIndex]->data, fromAnimation, toAnimation, duration);
}

void CCSkeletonAnimation::setAnimation (const char* name, bool loop, int stateIndex) {
	CCAssert(stateIndex >= 0 && stateIndex < (int)states.size(), "stateIndex out of range.");
	AnimationState_setAnimationByName(states[stateIndex], name, loop);
}

bool CCSkeletonAnimation::setAnimation (int stateIndex, const char* name, bool loop) {
	if (stateIndex < 0 || stateIndex >= (int)states.size()) return false;

	Animation* animation = name ? SkeletonData_findAnimation(skeleton->data, name) : 0;
	if (!animation) {
		CCLog("Spine: Animation not found: %s", name ? name : "");
		return false;
	}

	AnimationState_setAnimation(states[stateIndex], animation, loop);
	return true;
}

void CCSkeletonAnimation::addAnimation (const char* name, bool loop, float delay, int stateIndex) {
	CCAssert(stateIndex >= 0 && stateIndex < (int)states.size(), "stateIndex out of range.");
	AnimationState_addAnimationByName(states[stateIndex], name, loop, delay);
}

void CCSkeletonAnimation::clearAnimation (int stateIndex) {
	CCAssert(stateIndex >= 0 && stateIndex < (int)states.size(), "stateIndex out of range.");
	AnimationState_clearAnimation(states[stateIndex]);
}

float CCSkeletonAnimation::getAnimationDuration (int stateIndex, const char* name) {
	if (stateIndex < 0 || stateIndex >= (int)states.size()) return 0;

	Animation* animation = name ? SkeletonData_findAnimation(skeleton->data, name) : 0;
	if (!animation) {
		CCLog("Spine: Animation not found: %s", name ? name : "");
		return 0;
	}

	return animation->duration;
}

void CCSkeletonAnimation::setTimeScale (float scale) {
	timeScale = scale;
}

float CCSkeletonAnimation::getTimeScale () const {
	return timeScale;
}

}} // namespace cocos2d { namespace extension {
