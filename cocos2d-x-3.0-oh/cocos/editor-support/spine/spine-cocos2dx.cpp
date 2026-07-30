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
#include <stdlib.h>

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
		const char* lineBreak = pos;
		while (lineBreak < end && *lineBreak != '\n' && *lineBreak != '\r')
			lineBreak++;
		const char* lineEnd = lineBreak;

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

		// Consume one logical line ending so blank lines still delimit atlas pages.
		pos = lineBreak;
		if (pos < end && *pos == '\r')
			pos++;
		if (pos < end && *pos == '\n')
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

// ---- Atlas parsing helpers (from 2.2.6 spine) ----
typedef struct {
	const char* begin;
	const char* end;
} Str;

static void trim (Str* str) {
	while (isspace((unsigned char)*str->begin) && str->begin < str->end)
		(str->begin)++;
	if (str->begin == str->end) return;
	str->end--;
	while (isspace((unsigned char)*str->end) && str->end >= str->begin)
		str->end--;
	str->end++;
}

static int readLine (const char* begin, const char* end, Str* str) {
	static const char* nextStart;
	if (begin) {
		nextStart = begin;
		return 1;
	}
	if (nextStart == end) return 0;
	str->begin = nextStart;

	while (nextStart != end && *nextStart != '\n')
		nextStart++;

	str->end = nextStart;
	trim(str);

	if (nextStart != end) nextStart++;
	return 1;
}

static int beginPast (Str* str, char c) {
	const char* begin = str->begin;
	while (1) {
		char lastSkippedChar = *begin;
		if (begin == str->end) return 0;
		begin++;
		if (lastSkippedChar == c) break;
	}
	str->begin = begin;
	return 1;
}

static int readValue (const char* end, Str* str) {
	readLine(0, end, str);
	if (!beginPast(str, ':')) return 0;
	trim(str);
	return 1;
}

static int readTuple (const char* end, Str tuple[]) {
	int i;
	Str str = {NULL, NULL};
	readLine(0, end, &str);
	if (!beginPast(&str, ':')) return 0;

	for (i = 0; i < 3; ++i) {
		tuple[i].begin = str.begin;
		if (!beginPast(&str, ',')) {
			break;
		}
		tuple[i].end = str.begin - 2;
		trim(&tuple[i]);
	}
	tuple[i].begin = str.begin;
	tuple[i].end = str.end;
	trim(&tuple[i]);
	return i + 1;
}

static char* mallocString (Str* str) {
	int length = (int)(str->end - str->begin);
	char* string = (char*)malloc(length + 1);
	memcpy(string, str->begin, length);
	string[length] = '\0';
	return string;
}

static int indexOf (const char** array, int count, Str* str) {
	int length = (int)(str->end - str->begin);
	int i;
	for (i = count - 1; i >= 0; i--)
		if (strncmp(array[i], str->begin, length) == 0) return i;
	return -1;
}

static int equals (Str* str, const char* other) {
	return strncmp(other, str->begin, str->end - str->begin) == 0;
}

static int toInt (Str* str) {
	return (int)strtol(str->begin, (char**)&str->end, 10);
}

static const char* formatNames[] = {"Alpha", "Intensity", "LuminanceAlpha", "RGB565", "RGBA4444", "RGB888", "RGBA8888"};
static const char* textureFilterNames[] = {"Nearest", "Linear", "MipMap", "MipMapNearestNearest", "MipMapLinearNearest",
		"MipMapNearestLinear", "MipMapLinearLinear"};

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

static void setQuadColor (V3F_C4B_T2F_Quad* quad, GLubyte r, GLubyte g, GLubyte b, GLubyte a) {
	quad->bl.colors.r = r;
	quad->bl.colors.g = g;
	quad->bl.colors.b = b;
	quad->bl.colors.a = a;
	quad->br.colors = quad->bl.colors;
	quad->tl.colors = quad->bl.colors;
	quad->tr.colors = quad->bl.colors;
}

int spMeshAttachment_updateQuad (spMeshAttachment* self, spSlot* slot, const float* vertices, const int* triangle, V3F_C4B_T2F_Quad* quad,
		bool premultipliedAlpha) {
	if (!self || !slot || !vertices || !triangle || !quad || self->verticesCount <= 0 || !self->uvs) return 0;

	int i0 = triangle[0] * 2;
	int i1 = triangle[1] * 2;
	int i2 = triangle[2] * 2;
	if (i0 < 0 || i1 < 0 || i2 < 0 || i0 + 1 >= self->verticesCount || i1 + 1 >= self->verticesCount
			|| i2 + 1 >= self->verticesCount) return 0;

	GLubyte r = static_cast<GLubyte>(slot->skeleton->r * slot->r * self->r * 255);
	GLubyte g = static_cast<GLubyte>(slot->skeleton->g * slot->g * self->g * 255);
	GLubyte b = static_cast<GLubyte>(slot->skeleton->b * slot->b * self->b * 255);
	float normalizedAlpha = slot->skeleton->a * slot->a * self->a;
	if (premultipliedAlpha) {
		r = static_cast<GLubyte>(r * normalizedAlpha);
		g = static_cast<GLubyte>(g * normalizedAlpha);
		b = static_cast<GLubyte>(b * normalizedAlpha);
	}
	setQuadColor(quad, r, g, b, static_cast<GLubyte>(normalizedAlpha * 255));

	quad->bl.vertices.x = vertices[i0];
	quad->bl.vertices.y = vertices[i0 + 1];
	quad->br.vertices.x = vertices[i1];
	quad->br.vertices.y = vertices[i1 + 1];
	quad->tl.vertices.x = vertices[i2];
	quad->tl.vertices.y = vertices[i2 + 1];
	quad->tr.vertices.x = vertices[i2];
	quad->tr.vertices.y = vertices[i2 + 1];

	quad->bl.texCoords.u = self->uvs[i0];
	quad->bl.texCoords.v = self->uvs[i0 + 1];
	quad->br.texCoords.u = self->uvs[i1];
	quad->br.texCoords.v = self->uvs[i1 + 1];
	quad->tl.texCoords.u = self->uvs[i2];
	quad->tl.texCoords.v = self->uvs[i2 + 1];
	quad->tr.texCoords.u = self->uvs[i2];
	quad->tr.texCoords.v = self->uvs[i2 + 1];

	return 1;
}

int spSkinnedMeshAttachment_updateQuad (spSkinnedMeshAttachment* self, spSlot* slot, const float* vertices, const int* triangle,
		V3F_C4B_T2F_Quad* quad, bool premultipliedAlpha) {
	if (!self || !slot || !vertices || !triangle || !quad || self->uvsCount <= 0 || !self->uvs) return 0;

	int i0 = triangle[0] * 2;
	int i1 = triangle[1] * 2;
	int i2 = triangle[2] * 2;
	if (i0 < 0 || i1 < 0 || i2 < 0 || i0 + 1 >= self->uvsCount || i1 + 1 >= self->uvsCount
			|| i2 + 1 >= self->uvsCount) return 0;

	GLubyte r = static_cast<GLubyte>(slot->skeleton->r * slot->r * self->r * 255);
	GLubyte g = static_cast<GLubyte>(slot->skeleton->g * slot->g * self->g * 255);
	GLubyte b = static_cast<GLubyte>(slot->skeleton->b * slot->b * self->b * 255);
	float normalizedAlpha = slot->skeleton->a * slot->a * self->a;
	if (premultipliedAlpha) {
		r = static_cast<GLubyte>(r * normalizedAlpha);
		g = static_cast<GLubyte>(g * normalizedAlpha);
		b = static_cast<GLubyte>(b * normalizedAlpha);
	}
	setQuadColor(quad, r, g, b, static_cast<GLubyte>(normalizedAlpha * 255));

	quad->bl.vertices.x = vertices[i0];
	quad->bl.vertices.y = vertices[i0 + 1];
	quad->br.vertices.x = vertices[i1];
	quad->br.vertices.y = vertices[i1 + 1];
	quad->tl.vertices.x = vertices[i2];
	quad->tl.vertices.y = vertices[i2 + 1];
	quad->tr.vertices.x = vertices[i2];
	quad->tr.vertices.y = vertices[i2 + 1];

	quad->bl.texCoords.u = self->uvs[i0];
	quad->bl.texCoords.v = self->uvs[i0 + 1];
	quad->br.texCoords.u = self->uvs[i1];
	quad->br.texCoords.v = self->uvs[i1 + 1];
	quad->tl.texCoords.u = self->uvs[i2];
	quad->tl.texCoords.v = self->uvs[i2 + 1];
	quad->tr.texCoords.u = self->uvs[i2];
	quad->tr.texCoords.v = self->uvs[i2 + 1];

	return 1;
}
