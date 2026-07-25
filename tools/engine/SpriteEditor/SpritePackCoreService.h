#pragma once

#include "SpriteEditorConstants.h"
#include "SpritePackTypes.h"

class CSpriteEditorDoc;
class COldAniPack;

class SpritePackCoreService
{
public:
	explicit SpritePackCoreService(CSpriteEditorDoc& doc)
		: m_doc(doc)
	{
	}

	int BuildAtlas(
		std::vector<SpritePackPic>& vectorPicRect,
		const std::wstring& aniPath,
		Nuclear::XPIMAGE_FILEFORMAT fileFmt,
		Nuclear::XPTEXTURE_FORMAT texFmt,
		std::vector<std::vector<SpritePackPic> >& packingResult,
		std::vector<SIZE>& picSizes,
		std::map<int, SpritePackPosInfo>& picPosInfos,
		int maxTexSize = SpriteEditorConst::kMaxTextureSize);

	int RectPacking(
		std::vector<SpritePackPic>& vectorPicRect,
		std::vector<std::vector<SpritePackPic> >& packingResult,
		int maxTexSize = SpriteEditorConst::kMaxTextureSize);

	int GetBigPicSize(
		const std::vector<std::vector<SpritePackPic> >& packingResult,
		std::vector<SIZE>& picSizes);

	int PicArrange(
		const std::vector<std::vector<SpritePackPic> >& packingResult,
		const std::vector<SIZE>& picSizes,
		const std::wstring& aniPath,
		Nuclear::XPIMAGE_FILEFORMAT fileFmt,
		Nuclear::XPTEXTURE_FORMAT texFmt,
		std::map<int, SpritePackPosInfo>& picPosInfos);

	int WriteConvertedAni(
		const std::map<int, SpritePackPosInfo>& picPosInfos,
		const std::wstring& aniPath,
		const COldAniPack& pack);

	const SpritePackBuildStats& GetLastBuildStats() const { return m_lastBuildStats; }

private:
	struct MaxRectSlot
	{
		Nuclear::CRECT rect;

		int Width() const { return rect.right - rect.left; }
		int Height() const { return rect.bottom - rect.top; }
	};

	struct MaxRectsBin
	{
		std::vector<MaxRectSlot> freeRects;
		std::vector<SpritePackPic> pics;

		explicit MaxRectsBin(int binSize);
	};

	static bool Intersects(const Nuclear::CRECT& a, const Nuclear::CRECT& b);
	static bool Contains(const Nuclear::CRECT& outer, const Nuclear::CRECT& inner);
	static int NextPow2WithinLimit(int value, int limit);
	static void PruneContainedFreeRects(std::vector<MaxRectSlot>& freeRects);
	static void SplitFreeRects(std::vector<MaxRectSlot>& freeRects, const Nuclear::CRECT& usedRect);
	static bool TryPlacePicInBin(
		MaxRectsBin& bin,
		const SpritePackPic& sourcePic,
		SpritePackPic& placedPic,
		int& bestShortSideFit,
		int& bestLongSideFit);

	CSpriteEditorDoc& m_doc;
	SpritePackBuildStats m_lastBuildStats;
};
