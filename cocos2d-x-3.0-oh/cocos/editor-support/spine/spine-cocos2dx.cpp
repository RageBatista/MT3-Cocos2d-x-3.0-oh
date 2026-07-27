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

#include <spine/spine-cocos2dx.h>
#include <spine/extension.h>
#include <ctype.h>

USING_NS_CC;

namespace spine {

// MT3 custom: parse atlas text to extract texture file paths.
// This reads the atlas text format and builds a map from image path to (null) Texture2D pointer.
// The actual texture loading happens elsewhere.
void spAtlas_parseTextureMap (const char* begin, int length, const char* dir, PathToTextureMap* textureMap) {
	if (!begin || length <= 0 || !dir || !textureMap) return;

	const char* end = begin + length;
	int dirLength = (int)strlen(dir);
	int needsSlash = dirLength > 0 && dir[dirLength - 1] != '/' && dir[dirLength - 1] != '\\';

	bool page = false;
	const char* lineStart = begin;
	const char* pos = begin;
	while (pos < end) {
		// Find end of line
		const char* lineEnd = pos;
		while (lineEnd < end && *lineEnd != '\n' && *lineEnd != '\r')
			lineEnd++;

		// Trim whitespace
		while (lineStart < lineEnd && isspace((unsigned char)*lineStart))
			lineStart++;
		while (lineEnd > lineStart && isspace((unsigned char)*(lineEnd - 1)))
			lineEnd--;

		if (lineStart == lineEnd) {
			// Empty line
			page = false;
		} else if (!page) {
			// New page entry: extract image name
			page = true;
			int nameLen = (int)(lineEnd - lineStart);
			char* name = (char*)malloc(nameLen + 1);
			memcpy(name, lineStart, nameLen);
			name[nameLen] = '\0';

			char* path = (char*)malloc(dirLength + needsSlash + nameLen + 1);
			memcpy(path, dir, dirLength);
			if (needsSlash) path[dirLength] = '/';
			memcpy(path + dirLength + needsSlash, name, nameLen + 1);

			textureMap->insert(std::make_pair(std::string(path), (cocos2d::Texture2D*)0));

			free(name);
			free(path);
		}

		// Advance to next line
		pos = lineEnd;
		while (pos < end && (*pos == '\n' || *pos == '\r'))
			pos++;
		lineStart = pos;
	}
}

// MT3 custom: read atlas with pre-loaded texture map.
// This creates an spAtlas using textures from the provided map instead of loading from disk.
static void createTextureFromMap (spAtlasPage* page, const char* path, const PathToTextureMap& textureMap) {
	PathToTextureMap::const_iterator iter = textureMap.find(path);
	if (iter != textureMap.end() && iter->second) {
		cocos2d::Texture2D* texture = iter->second;
		cocos2d::TextureAtlas* textureAtlas = cocos2d::TextureAtlas::createWithTexture(texture, 4);
		textureAtlas->retain();
		page->rendererObject = textureAtlas;
		page->width = texture->getPixelsWide();
		page->height = texture->getPixelsHigh();
		return;
	}

	_spAtlasPage_createTexture(page, path);
}

// Internal helper: read atlas data using a custom texture map if provided
static spAtlas* spAtlas_readAtlasInternal (const char* begin, int length, const char* dir, const PathToTextureMap* textureMap) {
	int dirLength = (int)strlen(dir);
	int needsSlash = dirLength > 0 && dir[dirLength - 1] != '/' && dir[dirLength - 1] != '\\';

	spAtlas* self = NEW(spAtlas);

	spAtlasPage *page = 0;
	spAtlasPage *lastPage = 0;
	spAtlasRegion *lastRegion = 0;

	const char* end = begin + length;
	Str str;
	Str tuple[4];

	readLine(begin, 0, 0);
	while (readLine(0, end, &str)) {
		if (str.end - str.begin == 0) {
			page = 0;
		} else if (!page) {
			char* name = mallocString(&str);
			char* path = (char*)malloc(dirLength + needsSlash + strlen(name) + 1);
			memcpy(path, dir, dirLength);
			if (needsSlash) path[dirLength] = '/';
			strcpy(path + dirLength + needsSlash, name);

			page = spAtlasPage_create(name);
			free(name);
			if (lastPage)
				lastPage->next = page;
			else
				self->pages = page;
			lastPage = page;

			switch (readTuple(end, tuple)) {
			case 0:
				spAtlas_dispose(self);
				return 0;
			case 2:
				page->width = toInt(tuple);
				page->height = toInt(tuple + 1);
				if (!readTuple(end, tuple)) {
					spAtlas_dispose(self);
					return 0;
				}
			}
			page->format = (spAtlasFormat)indexOf(formatNames, 7, tuple);

			if (!readTuple(end, tuple)) {
				spAtlas_dispose(self);
				return 0;
			}
			page->minFilter = (spAtlasFilter)indexOf(textureFilterNames, 7, tuple);
			page->magFilter = (spAtlasFilter)indexOf(textureFilterNames, 7, tuple + 1);

			if (!readValue(end, &str)) {
				spAtlas_dispose(self);
				return 0;
			}
			if (!equals(&str, "none")) {
				page->uWrap = *str.begin == 'x' ? ATLAS_REPEAT : (*str.begin == 'y' ? ATLAS_CLAMPTOEDGE : ATLAS_REPEAT);
				page->vWrap = *str.begin == 'x' ? ATLAS_CLAMPTOEDGE : (*str.begin == 'y' ? ATLAS_REPEAT : ATLAS_REPEAT);
			}

			if (textureMap)
				createTextureFromMap(page, path, *textureMap);
			else
				_spAtlasPage_createTexture(page, path);
			free(path);
		} else {
			spAtlasRegion *region = spAtlasRegion_create();
			if (lastRegion)
				lastRegion->next = region;
			else
				self->regions = region;
			lastRegion = region;

			region->page = page;
			region->name = mallocString(&str);

			if (!readValue(end, &str)) {
				spAtlas_dispose(self);
				return 0;
			}
			region->rotate = equals(&str, "true");

			if (readTuple(end, tuple) != 2) {
				spAtlas_dispose(self);
				return 0;
			}
			region->x = toInt(tuple);
			region->y = toInt(tuple + 1);

			if (readTuple(end, tuple) != 2) {
				spAtlas_dispose(self);
				return 0;
			}
			region->width = toInt(tuple);
			region->height = toInt(tuple + 1);

			region->u = region->x / (float)page->width;
			region->v = region->y / (float)page->height;
			if (region->rotate) {
				region->u2 = (region->x + region->height) / (float)page->width;
				region->v2 = (region->y + region->width) / (float)page->height;
			} else {
				region->u2 = (region->x + region->width) / (float)page->width;
				region->v2 = (region->y + region->height) / (float)page->height;
			}

			int count;
			if (!(count = readTuple(end, tuple))) {
				spAtlas_dispose(self);
				return 0;
			}
			if (count == 4) {
				region->splits = MALLOC(int, 4);
				region->splits[0] = toInt(tuple);
				region->splits[1] = toInt(tuple + 1);
				region->splits[2] = toInt(tuple + 2);
				region->splits[3] = toInt(tuple + 3);

				if (!(count = readTuple(end, tuple))) {
					spAtlas_dispose(self);
					return 0;
				}
				if (count == 4) {
					region->pads = MALLOC(int, 4);
					region->pads[0] = toInt(tuple);
					region->pads[1] = toInt(tuple + 1);
					region->pads[2] = toInt(tuple + 2);
					region->pads[3] = toInt(tuple + 3);

					if (!readTuple(end, tuple)) {
						spAtlas_dispose(self);
						return 0;
					}
				}
			}

			region->originalWidth = toInt(tuple);
			region->originalHeight = toInt(tuple + 1);

			readTuple(end, tuple);
			region->offsetX = toInt(tuple);
			region->offsetY = toInt(tuple + 1);

			if (!readValue(end, &str)) {
				spAtlas_dispose(self);
				return 0;
			}
			region->index = toInt(&str);
		}
	}

	return self;
}

spAtlas* Atlas_readAtlasWithTextureMap (const char* begin, int length, const char* dir, const PathToTextureMap& textureMap) {
	return spAtlas_readAtlasInternal(begin, length, dir, &textureMap);
}

} // namespace spine

void _spAtlasPage_createTexture (spAtlasPage* self, const char* path) {
    Texture2D* texture = Director::getInstance()->getTextureCache()->addImage(path);
    TextureAtlas* textureAtlas = TextureAtlas::createWithTexture(texture, 4);
    textureAtlas->retain();
    self->rendererObject = textureAtlas;
    // Using getContentSize to make it supports the strategy of loading resources in cocos2d-x.
    // self->width = texture->getPixelsWide();
    // self->height = texture->getPixelsHigh();
    self->width = texture->getContentSize().width;
    self->height = texture->getContentSize().height;
}

void _spAtlasPage_disposeTexture (spAtlasPage* self) {
	((TextureAtlas*)self->rendererObject)->release();
}

char* _spUtil_readFile (const char* path, int* length)
{
    char* ret = nullptr;
    int size = 0;
    Data data = FileUtils::getInstance()->getDataFromFile(path);
    
    if (!data.isNull())
    {
        size = static_cast<int>(data.getSize());
        *length = size;
        // Allocates one more byte for string terminal, it will be safe when parsing JSON file in Spine runtime.
        ret = (char*)malloc(size + 1);
        ret[size] = '\0';
        memcpy(ret, data.getBytes(), size);
    }
    
    return ret;
}

/**/

void spRegionAttachment_updateQuad (spRegionAttachment* self, spSlot* slot, V3F_C4B_T2F_Quad* quad, bool premultipliedAlpha) {
	float vertices[8];
	spRegionAttachment_computeWorldVertices(self, slot->skeleton->x, slot->skeleton->y, slot->bone, vertices);

	GLubyte r = slot->skeleton->r * slot->r * 255;
	GLubyte g = slot->skeleton->g * slot->g * 255;
	GLubyte b = slot->skeleton->b * slot->b * 255;
	float normalizedAlpha = slot->skeleton->a * slot->a;
	if (premultipliedAlpha) {
		r *= normalizedAlpha;
		g *= normalizedAlpha;
		b *= normalizedAlpha;
	}
	GLubyte a = normalizedAlpha * 255;
	quad->bl.colors.r = r;
	quad->bl.colors.g = g;
	quad->bl.colors.b = b;
	quad->bl.colors.a = a;
	quad->tl.colors.r = r;
	quad->tl.colors.g = g;
	quad->tl.colors.b = b;
	quad->tl.colors.a = a;
	quad->tr.colors.r = r;
	quad->tr.colors.g = g;
	quad->tr.colors.b = b;
	quad->tr.colors.a = a;
	quad->br.colors.r = r;
	quad->br.colors.g = g;
	quad->br.colors.b = b;
	quad->br.colors.a = a;

	quad->bl.vertices.x = vertices[VERTEX_X1];
	quad->bl.vertices.y = vertices[VERTEX_Y1];
	quad->tl.vertices.x = vertices[VERTEX_X2];
	quad->tl.vertices.y = vertices[VERTEX_Y2];
	quad->tr.vertices.x = vertices[VERTEX_X3];
	quad->tr.vertices.y = vertices[VERTEX_Y3];
	quad->br.vertices.x = vertices[VERTEX_X4];
	quad->br.vertices.y = vertices[VERTEX_Y4];

	quad->bl.texCoords.u = self->uvs[VERTEX_X1];
	quad->bl.texCoords.v = self->uvs[VERTEX_Y1];
	quad->tl.texCoords.u = self->uvs[VERTEX_X2];
	quad->tl.texCoords.v = self->uvs[VERTEX_Y2];
	quad->tr.texCoords.u = self->uvs[VERTEX_X3];
	quad->tr.texCoords.v = self->uvs[VERTEX_Y3];
	quad->br.texCoords.u = self->uvs[VERTEX_X4];
	quad->br.texCoords.v = self->uvs[VERTEX_Y4];
}
