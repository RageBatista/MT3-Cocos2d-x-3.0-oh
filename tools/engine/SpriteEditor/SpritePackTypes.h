#pragma once

#include <vector>

#include "..\engine\common\xptypes.h"

struct SpritePackPosInfo
{
	int m_nFileID;
	Nuclear::CSIZE m_Size;
	Nuclear::CRECT m_Rect;
};

struct SpritePackPic
{
	SpritePackPic& operator=(const SpritePackPic& r)
	{
		m_Dir = r.m_Dir;
		m_nFrame = r.m_nFrame;
		m_nRegion = r.m_nRegion;
		m_Rect = r.m_Rect;
		m_SrcRect = r.m_SrcRect;
		m_nID = r.m_nID;
		m_Handle = r.m_Handle;
		m_PartHandle = r.m_PartHandle;

		return *this;
	}

	void OffsetRect(int x, int y)
	{
		m_Rect.left += x;
		m_Rect.top += y;
		m_Rect.right += x;
		m_Rect.bottom += y;
	}

	int Width() const
	{
		return m_Rect.Width();
	}

	int Height() const
	{
		return m_Rect.Height();
	}

	SpritePackPic()
	{
		m_Dir = 0;
		m_nFrame = 0;
		m_nRegion = 0;
		m_Rect = Nuclear::CRECT(0, 0, 0, 0);
		m_SrcRect = Nuclear::FRECT(0.0f, 0.0f, 1.0f, 1.0f);
		m_nID = 0;
		m_Handle = Nuclear::INVALID_PICTURE_HANDLE;
		m_PartHandle = Nuclear::INVALID_PICTURE_HANDLE;
	}

	Nuclear::PictureHandle m_Handle;
	Nuclear::PictureHandle m_PartHandle;
	int m_nID;
	Nuclear::CRECT m_Rect;
	Nuclear::FRECT m_SrcRect;
	int m_nRegion;
	int m_nFrame;
	int m_Dir;
};

struct SpritePackAtlasBinStat
{
	SIZE textureSize;
	long long usedArea;
	double utilization;
	int picCount;

	SpritePackAtlasBinStat()
		: usedArea(0)
		, utilization(0.0)
		, picCount(0)
	{
		textureSize.cx = 0;
		textureSize.cy = 0;
	}
};

struct SpritePackBuildStats
{
	int picCount;
	int binCount;
	std::vector<SpritePackAtlasBinStat> bins;

	SpritePackBuildStats()
		: picCount(0)
		, binCount(0)
	{
	}

	void Clear()
	{
		picCount = 0;
		binCount = 0;
		bins.clear();
	}
};
