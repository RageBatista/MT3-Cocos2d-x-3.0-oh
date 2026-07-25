#include "stdafx.h"
#include "SpritePackCoreService.h"
#include "SpriteEditorDoc.h"
#include "OldAniPack.h"
#include "..\engine\renderer\renderer.h"

namespace
{
	std::wstring GetFileNameW(const std::wstring& path)
	{
		size_t pos = path.find_last_of(L"\\/");
		if (pos == std::wstring::npos)
			return path;
		return path.substr(pos + 1);
	}

	std::wstring GetDirNameW(const std::wstring& path)
	{
		size_t pos = path.find_last_of(L"\\/");
		if (pos == std::wstring::npos)
			return std::wstring();
		return path.substr(0, pos);
	}

	std::wstring GetFileNameNoExtW(const std::wstring& path)
	{
		std::wstring name = GetFileNameW(path);
		size_t dot = name.find_last_of(L'.');
		if (dot == std::wstring::npos)
			return name;
		return name.substr(0, dot);
	}
}

SpritePackCoreService::MaxRectsBin::MaxRectsBin(int binSize)
{
	MaxRectSlot root;
	root.rect = Nuclear::CRECT(0, 0, binSize, binSize);
	freeRects.push_back(root);
}

bool SpritePackCoreService::Intersects(const Nuclear::CRECT& a, const Nuclear::CRECT& b)
{
	return !(a.left >= b.right || a.right <= b.left || a.top >= b.bottom || a.bottom <= b.top);
}

bool SpritePackCoreService::Contains(const Nuclear::CRECT& outer, const Nuclear::CRECT& inner)
{
	return outer.left <= inner.left && outer.top <= inner.top &&
		outer.right >= inner.right && outer.bottom >= inner.bottom;
}

int SpritePackCoreService::NextPow2WithinLimit(int value, int limit)
{
	int outValue = 1;
	while (outValue < value && outValue < limit)
		outValue <<= 1;
	return outValue;
}

void SpritePackCoreService::PruneContainedFreeRects(std::vector<MaxRectSlot>& freeRects)
{
	for (size_t i = 0; i < freeRects.size(); ++i)
	{
		for (size_t j = i + 1; j < freeRects.size(); )
		{
			if (Contains(freeRects[i].rect, freeRects[j].rect))
			{
				freeRects.erase(freeRects.begin() + j);
				continue;
			}
			if (Contains(freeRects[j].rect, freeRects[i].rect))
			{
				freeRects.erase(freeRects.begin() + i);
				--i;
				break;
			}
			++j;
		}
	}
}

void SpritePackCoreService::SplitFreeRects(std::vector<MaxRectSlot>& freeRects, const Nuclear::CRECT& usedRect)
{
	for (size_t i = 0; i < freeRects.size(); )
	{
		const Nuclear::CRECT freeRect = freeRects[i].rect;
		if (!Intersects(freeRect, usedRect))
		{
			++i;
			continue;
		}

		std::vector<MaxRectSlot> replacements;
		if (usedRect.top > freeRect.top)
		{
			MaxRectSlot topRect;
			topRect.rect = Nuclear::CRECT(freeRect.left, freeRect.top, freeRect.right, usedRect.top);
			if (topRect.Width() > 0 && topRect.Height() > 0)
				replacements.push_back(topRect);
		}
		if (usedRect.bottom < freeRect.bottom)
		{
			MaxRectSlot bottomRect;
			bottomRect.rect = Nuclear::CRECT(freeRect.left, usedRect.bottom, freeRect.right, freeRect.bottom);
			if (bottomRect.Width() > 0 && bottomRect.Height() > 0)
				replacements.push_back(bottomRect);
		}
		if (usedRect.left > freeRect.left)
		{
			MaxRectSlot leftRect;
			leftRect.rect = Nuclear::CRECT(freeRect.left, freeRect.top, usedRect.left, freeRect.bottom);
			if (leftRect.Width() > 0 && leftRect.Height() > 0)
				replacements.push_back(leftRect);
		}
		if (usedRect.right < freeRect.right)
		{
			MaxRectSlot rightRect;
			rightRect.rect = Nuclear::CRECT(usedRect.right, freeRect.top, freeRect.right, freeRect.bottom);
			if (rightRect.Width() > 0 && rightRect.Height() > 0)
				replacements.push_back(rightRect);
		}

		freeRects.erase(freeRects.begin() + i);
		freeRects.insert(freeRects.end(), replacements.begin(), replacements.end());
	}

	PruneContainedFreeRects(freeRects);
}

bool SpritePackCoreService::TryPlacePicInBin(
	MaxRectsBin& bin,
	const SpritePackPic& sourcePic,
	SpritePackPic& placedPic,
	int& bestShortSideFit,
	int& bestLongSideFit)
{
	bestShortSideFit = INT_MAX;
	bestLongSideFit = INT_MAX;
	int bestIndex = -1;
	Nuclear::CRECT bestRect(0, 0, 0, 0);
	const int picW = sourcePic.Width();
	const int picH = sourcePic.Height();

	for (size_t i = 0; i < bin.freeRects.size(); ++i)
	{
		const MaxRectSlot& freeRect = bin.freeRects[i];
		if (picW > freeRect.Width() || picH > freeRect.Height())
			continue;

		const int leftoverHoriz = freeRect.Width() - picW;
		const int leftoverVert = freeRect.Height() - picH;
		const int shortSideFit = (std::min)(leftoverHoriz, leftoverVert);
		const int longSideFit = (std::max)(leftoverHoriz, leftoverVert);
		if (shortSideFit > bestShortSideFit ||
			(shortSideFit == bestShortSideFit && longSideFit >= bestLongSideFit))
		{
			continue;
		}

		bestIndex = static_cast<int>(i);
		bestShortSideFit = shortSideFit;
		bestLongSideFit = longSideFit;
		bestRect = Nuclear::CRECT(
			freeRect.rect.left,
			freeRect.rect.top,
			freeRect.rect.left + picW,
			freeRect.rect.top + picH);
	}

	if (bestIndex < 0)
		return false;

	placedPic = sourcePic;
	placedPic.m_Rect = bestRect;
	SplitFreeRects(bin.freeRects, bestRect);
	bin.pics.push_back(placedPic);
	return true;
}

int SpritePackCoreService::BuildAtlas(
	std::vector<SpritePackPic>& vectorPicRect,
	const std::wstring& aniPath,
	Nuclear::XPIMAGE_FILEFORMAT fileFmt,
	Nuclear::XPTEXTURE_FORMAT texFmt,
	std::vector<std::vector<SpritePackPic> >& packingResult,
	std::vector<SIZE>& picSizes,
	std::map<int, SpritePackPosInfo>& picPosInfos,
	int maxTexSize)
{
	m_lastBuildStats.Clear();
	m_lastBuildStats.picCount = static_cast<int>(vectorPicRect.size());
	packingResult.clear();
	picSizes.clear();
	picPosInfos.clear();

	if (RectPacking(vectorPicRect, packingResult, maxTexSize) == 0)
		return 0;
	if (GetBigPicSize(packingResult, picSizes) == 0 || picSizes.empty())
		return 0;
	if (PicArrange(packingResult, picSizes, aniPath, fileFmt, texFmt, picPosInfos) == 0)
		return 0;
	return static_cast<int>(packingResult.size());
}

int SpritePackCoreService::WriteConvertedAni(
	const std::map<int, SpritePackPosInfo>& picPosInfos,
	const std::wstring& aniPath,
	const COldAniPack& pack)
{
	if (aniPath.empty())
		return 0;

	Nuclear::PAniPack newPack;
	newPack.SetFileFmt(pack.GetFileFormat());
	newPack.SetTexFmt(pack.GetTexFormat());
	newPack.SetBlend(pack.GetBlend());
	newPack.SetTime(pack.GetTime());
	newPack.SetRegionCount(pack.GetRegionCount());
	newPack.SetFrameCount(pack.GetFrameCount());
	newPack.SetDirMode(static_cast<Nuclear::XPANI_DIRECTIONMODE>(pack.GetDirMode()));
	newPack.SetColor(pack.GetColor());
	newPack.SetSystemLevel(pack.GetSystemLevel());
	newPack.SetEffectBindType(pack.GetEffectBindType());
	newPack.SetCenter(pack.GetCenter());
	Nuclear::CRECT border;
	if (pack.GetBorder(border))
		newPack.SetBorder(border);

	const std::vector<int>& oldDirs = pack.GetDirs();
	newPack.GetDirs() = oldDirs;
	if (newPack.GetDirs().empty())
		newPack.GetDirs().push_back(0);

	const std::vector<std::vector<std::vector<COldAniPack::sFileSec> > >& oldData = pack.GetData();
	const bool bVersion10 = (pack.GetVersion() > 9);

	newPack.GetDatas().resize(oldDirs.size());
	int picId = 0;

	for (size_t dirIdx = 0; dirIdx < oldDirs.size() && dirIdx < oldData.size(); ++dirIdx)
	{
		const std::vector<std::vector<COldAniPack::sFileSec> >& frames = oldData[dirIdx];
		newPack.GetDatas()[dirIdx].resize(pack.GetFrameCount());

		for (int frameIdx = 0; frameIdx < pack.GetFrameCount() && frameIdx < static_cast<int>(frames.size()); ++frameIdx)
		{
			const std::vector<COldAniPack::sFileSec>& regions = frames[frameIdx];
			newPack.GetDatas()[dirIdx][frameIdx].resize(pack.GetRegionCount());

			for (int regionIdx = 0; regionIdx < pack.GetRegionCount() && regionIdx < static_cast<int>(regions.size()); ++regionIdx)
			{
				const COldAniPack::sFileSec& oldSec = regions[regionIdx];
				Nuclear::PAniPack::FileSec newSec;

				std::map<int, SpritePackPosInfo>::const_iterator posIt = picPosInfos.find(picId);
				if (posIt != picPosInfos.end())
				{
					const SpritePackPosInfo& posInfo = posIt->second;

					wchar_t texName[64];
					swprintf_s(texName, _countof(texName), L"_res%03d.png", posInfo.m_nFileID);
					newSec.strPicPath = texName;

					if (posInfo.m_Size.x > 0 && posInfo.m_Size.y > 0)
					{
						newSec.rctData = Nuclear::FRECT(
							static_cast<float>(posInfo.m_Rect.left) / posInfo.m_Size.x,
							static_cast<float>(posInfo.m_Rect.top) / posInfo.m_Size.y,
							static_cast<float>(posInfo.m_Rect.right) / posInfo.m_Size.x,
							static_cast<float>(posInfo.m_Rect.bottom) / posInfo.m_Size.y);
					}
					else
					{
						newSec.rctData = Nuclear::FRECT(0.0f, 0.0f, 1.0f, 1.0f);
					}

					if (bVersion10)
					{
						newSec.offset = oldSec.m_OffsetVersion10;
					}
					else
					{
						const int picW = posInfo.m_Rect.right - posInfo.m_Rect.left;
						const int picH = posInfo.m_Rect.bottom - posInfo.m_Rect.top;
						newSec.offset = Nuclear::CRECT(
							oldSec.m_Offset.x,
							oldSec.m_Offset.y,
							oldSec.m_Offset.x + picW,
							oldSec.m_Offset.y + picH);
					}
				}
				else if (bVersion10)
				{
					newSec.strPicPath = oldSec.m_strPicPathVersion10;
					newSec.rctData = oldSec.m_rctDataVersion10;
					newSec.offset = oldSec.m_OffsetVersion10;
				}
				else
				{
					newSec.strPicPath = L"";
					newSec.rctData = Nuclear::FRECT(0.0f, 0.0f, 1.0f, 1.0f);
					newSec.offset = Nuclear::CRECT(
						oldSec.m_Offset.x,
						oldSec.m_Offset.y,
						oldSec.m_Offset.x + 64,
						oldSec.m_Offset.y + 64);
				}

				newSec.outLinePoints.clear();
				newPack.GetDatas()[dirIdx][frameIdx][regionIdx] = newSec;
				++picId;
			}
		}
	}

	if (!newPack.SaveToNativePath(aniPath.c_str()))
	{
		XPLOG_ERROR(L"[WriteNewAniFile] SaveToNativePath failed: %s\n", aniPath.c_str());
		return 0;
	}

	XPLOG_INFO(L"[WriteNewAniFile] success: %s (dirs=%d, frames=%d, regions=%d, pics=%d)\n",
		aniPath.c_str(), static_cast<int>(newPack.GetDirs().size()), pack.GetFrameCount(), pack.GetRegionCount(), picId);
	return 1;
}

int SpritePackCoreService::PicArrange(
	const std::vector<std::vector<SpritePackPic> >& packingResult,
	const std::vector<SIZE>& picSizes,
	const std::wstring& aniPath,
	Nuclear::XPIMAGE_FILEFORMAT fileFmt,
	Nuclear::XPTEXTURE_FORMAT texFmt,
	std::map<int, SpritePackPosInfo>& picPosInfos)
{
	picPosInfos.clear();

	if (packingResult.empty() || picSizes.empty())
		return 0;

	for (size_t binIdx = 0; binIdx < packingResult.size() && binIdx < picSizes.size(); ++binIdx)
	{
		const std::vector<SpritePackPic>& bin = packingResult[binIdx];
		const SIZE& texSize = picSizes[binIdx];

		for (size_t picIdx = 0; picIdx < bin.size(); ++picIdx)
		{
			const SpritePackPic& pic = bin[picIdx];

			SpritePackPosInfo posInfo;
			posInfo.m_nFileID = static_cast<int>(binIdx);
			posInfo.m_Size.x = texSize.cx;
			posInfo.m_Size.y = texSize.cy;
			posInfo.m_Rect = pic.m_Rect;
			picPosInfos[pic.m_nID] = posInfo;
		}
	}

	Nuclear::Renderer* renderer = m_doc.GetRenderer();
	if (renderer && !aniPath.empty())
	{
		const std::wstring baseDir = GetDirNameW(aniPath);
		const std::wstring aniStem = GetFileNameNoExtW(aniPath);

		for (size_t binIdx = 0; binIdx < packingResult.size() && binIdx < picSizes.size(); ++binIdx)
		{
			const std::vector<SpritePackPic>& bin = packingResult[binIdx];
			const SIZE& texSize = picSizes[binIdx];
			if (bin.empty())
				continue;

			wchar_t suffix[16];
			swprintf_s(suffix, _countof(suffix), L"_res%03d", static_cast<int>(binIdx));
			const std::wstring texName = aniStem + suffix;

			std::wstring ext;
			switch (fileFmt)
			{
			case Nuclear::XPIFF_PNG: ext = L".png"; break;
			case Nuclear::XPIFF_DDS: ext = L".dds"; break;
			case Nuclear::XPIFF_TGA: ext = L".tga"; break;
			default: ext = L".png"; break;
			}

			const std::wstring texPath = baseDir + L"\\" + texName + ext;
			Nuclear::PictureHandle renderTarget = renderer->CreateRenderTarget(texSize.cx, texSize.cy, texFmt);
			if (renderTarget == Nuclear::INVALID_PICTURE_HANDLE)
			{
				XPLOG_ERROR(L"[PicArrange] CreateRenderTarget failed: %dx%d\n", texSize.cx, texSize.cy);
				continue;
			}

			if (!renderer->PushRenderTarget(renderTarget))
			{
				renderer->FreeRenderTarget(renderTarget);
				XPLOG_ERROR(L"[PicArrange] PushRenderTarget failed\n");
				continue;
			}

			renderer->Clear(0x00000000);
			for (size_t picIdx = 0; picIdx < bin.size(); ++picIdx)
			{
				const SpritePackPic& pic = bin[picIdx];
				if (pic.m_Handle == Nuclear::INVALID_PICTURE_HANDLE)
					continue;

				Nuclear::FRECT dstRect = pic.m_Rect.ToFRECT();
				Nuclear::XPCOLOR color = 0xFFFFFFFF;
				Nuclear::DrawPictureParam drawParam;
				drawParam.handle = pic.m_Handle;
				drawParam.pRect = &dstRect;
				drawParam.pSrcrect = &pic.m_SrcRect;
				drawParam.pColor = &color;
				drawParam.colorCount = 1;
				renderer->DrawPicture(drawParam);
			}

			renderer->PopRenderTarget();
			if (!renderer->SaveTextureToFile(renderTarget, fileFmt, texPath))
			{
				XPLOG_ERROR(L"[PicArrange] SaveTextureToFile failed: %s\n", texPath.c_str());
			}
			else
			{
				XPLOG_INFO(L"[PicArrange] saved texture: %s (%dx%d, %d pics)\n",
					texPath.c_str(), texSize.cx, texSize.cy, static_cast<int>(bin.size()));
			}

			renderer->FreeRenderTarget(renderTarget);
		}
	}

	XPLOG_INFO(L"[PicArrange] mapped %d pictures to %d textures\n",
		static_cast<int>(picPosInfos.size()), static_cast<int>(packingResult.size()));
	return static_cast<int>(packingResult.size());
}

int SpritePackCoreService::GetBigPicSize(
	const std::vector<std::vector<SpritePackPic> >& packingResult,
	std::vector<SIZE>& picSizes)
{
	picSizes.clear();
	m_lastBuildStats.bins.clear();
	if (packingResult.empty())
		return 0;

	for (size_t binIdx = 0; binIdx < packingResult.size(); ++binIdx)
	{
		const std::vector<SpritePackPic>& bin = packingResult[binIdx];
		int maxRight = 0;
		int maxBottom = 0;
		long long usedArea = 0;
		for (size_t picIdx = 0; picIdx < bin.size(); ++picIdx)
		{
			const SpritePackPic& pic = bin[picIdx];
			maxRight = (std::max)(maxRight, static_cast<int>(pic.m_Rect.right));
			maxBottom = (std::max)(maxBottom, static_cast<int>(pic.m_Rect.bottom));
			usedArea += static_cast<long long>(pic.Width()) * pic.Height();
		}

		SIZE sz = { 0, 0 };
		sz.cx = NextPow2WithinLimit(maxRight, SpriteEditorConst::kMaxTextureSize);
		sz.cy = NextPow2WithinLimit(maxBottom, SpriteEditorConst::kMaxTextureSize);
		picSizes.push_back(sz);

		const long long textureArea = static_cast<long long>(sz.cx) * sz.cy;
		const double utilization = (textureArea > 0)
			? (static_cast<double>(usedArea) * 100.0 / static_cast<double>(textureArea))
			: 0.0;

		SpritePackAtlasBinStat binStat;
		binStat.textureSize = sz;
		binStat.usedArea = usedArea;
		binStat.utilization = utilization;
		binStat.picCount = static_cast<int>(bin.size());
		m_lastBuildStats.bins.push_back(binStat);

		XPLOG_INFO(L"[GetBigPicSize] bin=%d texture=%dx%d usedArea=%lld utilization=%.2f%%\n",
			static_cast<int>(binIdx), sz.cx, sz.cy, usedArea, utilization);
	}

	XPLOG_INFO(L"[GetBigPicSize] bins=%d\n", static_cast<int>(picSizes.size()));
	return static_cast<int>(picSizes.size());
}

int SpritePackCoreService::RectPacking(
	std::vector<SpritePackPic>& vectorPicRect,
	std::vector<std::vector<SpritePackPic> >& packingResult,
	int maxTexSize)
{
	packingResult.clear();
	if (vectorPicRect.empty())
		return 0;

	int maxTextureSize = maxTexSize;
	if (maxTextureSize <= 0)
		maxTextureSize = SpriteEditorConst::kMaxTextureSize;
	maxTextureSize = (std::min)(maxTextureSize, SpriteEditorConst::kMaxTextureSize);

	std::sort(vectorPicRect.begin(), vectorPicRect.end(),
		[](const SpritePackPic& a, const SpritePackPic& b)
		{
			const int areaA = a.Width() * a.Height();
			const int areaB = b.Width() * b.Height();
			if (areaA != areaB)
				return areaA > areaB;
			const int shortSideA = (std::min)(a.Width(), a.Height());
			const int shortSideB = (std::min)(b.Width(), b.Height());
			if (shortSideA != shortSideB)
				return shortSideA > shortSideB;
			return a.Width() > b.Width();
		});

	std::vector<MaxRectsBin> bins;
	for (size_t i = 0; i < vectorPicRect.size(); ++i)
	{
		const SpritePackPic& sourcePic = vectorPicRect[i];
		bool placed = false;
		int bestBinIndex = -1;
		int bestShortSideFit = INT_MAX;
		int bestLongSideFit = INT_MAX;
		MaxRectsBin bestBinState(maxTextureSize);
		SpritePackPic bestPic;

		for (size_t binIdx = 0; binIdx < bins.size(); ++binIdx)
		{
			MaxRectsBin candidateBin = bins[binIdx];
			SpritePackPic candidate;
			int shortSideFit = INT_MAX;
			int longSideFit = INT_MAX;
			if (!TryPlacePicInBin(candidateBin, sourcePic, candidate, shortSideFit, longSideFit))
				continue;

			if (!placed ||
				shortSideFit < bestShortSideFit ||
				(shortSideFit == bestShortSideFit && longSideFit < bestLongSideFit))
			{
				placed = true;
				bestBinIndex = static_cast<int>(binIdx);
				bestShortSideFit = shortSideFit;
				bestLongSideFit = longSideFit;
				bestPic = candidate;
				bestBinState = candidateBin;
			}
		}

		if (placed)
		{
			bins[bestBinIndex] = bestBinState;
			vectorPicRect[i] = bestPic;
			continue;
		}

		{
			MaxRectsBin newBin(maxTextureSize);
			SpritePackPic candidate;
			int shortSideFit = INT_MAX;
			int longSideFit = INT_MAX;
			if (!TryPlacePicInBin(newBin, sourcePic, candidate, shortSideFit, longSideFit))
			{
				XPLOG_ERROR(L"[RectPacking] pic too large: id=%d w=%d h=%d\n",
					sourcePic.m_nID, sourcePic.Width(), sourcePic.Height());
				continue;
			}

			bins.push_back(newBin);
			vectorPicRect[i] = candidate;
		}
	}

	for (size_t binIdx = 0; binIdx < bins.size(); ++binIdx)
	{
		if (!bins[binIdx].pics.empty())
			packingResult.push_back(bins[binIdx].pics);
	}

	m_lastBuildStats.binCount = static_cast<int>(packingResult.size());

	XPLOG_INFO(L"[RectPacking] packed %d pics into %d bins using MaxRects\n",
		static_cast<int>(vectorPicRect.size()), static_cast<int>(packingResult.size()));
	return static_cast<int>(packingResult.size());
}
