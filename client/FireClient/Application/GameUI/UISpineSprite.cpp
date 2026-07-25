#include "stdafx.h"
#include "UISpineSprite.h"
#include "engine/nuengine.h"
#include "GameUIManager.h"
#include "ResolutionAdapter.h"
#include <stdarg.h>
#include <stdio.h>

extern ResolutionAdapter g_adapter;

namespace
{
#if defined(WIN32) && (defined(_DEBUG) || defined(DEBUG))
	void MT3LoginRenderTraceToFile(const char* fmt, ...)
	{
		FILE* fp = NULL;
		if (fopen_s(&fp, "startup_bootstrap.log", "ab") != 0 || !fp)
		{
			return;
		}

		fputs("[MT3_LOGIN_RENDER] ", fp);
		va_list args;
		va_start(args, fmt);
		vfprintf(fp, fmt, args);
		va_end(args);
		fputs("\r\n", fp);
		fclose(fp);
	}
#define MT3_LOGIN_RENDER_TRACE(...) MT3LoginRenderTraceToFile(__VA_ARGS__)
#else
#define MT3_LOGIN_RENDER_TRACE(...)
#endif

	inline int RoundToInt(float value)
	{
		return static_cast<int>(value >= 0.0f ? value + 0.5f : value - 0.5f);
	}

	inline Nuclear::NuclearLocation ConvertUIToSceneLocation(const Nuclear::NuclearLocation& uiLoc)
	{
		Nuclear::NuclearLocation sceneLoc = uiLoc;

		const int uiLogicW = g_adapter.get_ui_logic_w();
		const int uiLogicH = g_adapter.get_ui_logic_h();
		const int sceneLogicW = g_adapter.get_logic_w();
		const int sceneLogicH = g_adapter.get_logic_h();

		if (uiLogicW > 0 && sceneLogicW > 0 && uiLogicW != sceneLogicW)
		{
			sceneLoc.x = RoundToInt((float)uiLoc.x * (float)sceneLogicW / (float)uiLogicW);
		}
		if (uiLogicH > 0 && sceneLogicH > 0 && uiLogicH != sceneLogicH)
		{
			sceneLoc.y = RoundToInt((float)uiLoc.y * (float)sceneLogicH / (float)uiLogicH);
		}

		return sceneLoc;
	}
}

UISpineSprite::UISpineSprite(const std::wstring& modelName)
	: m_modelName(modelName)
	, m_CurActTime(0.f)
{
	m_SpriteHandle = Nuclear::GetEngine()->CreateEngineSprite(modelName, false, true);
	SetDefaultAction(eActionStand);
	PlayAction(eActionStand);

	if (gGetGameUIManager()) {
		gGetGameUIManager()->AddUISpineSprite(this);
	}
}

UISpineSprite::~UISpineSprite()
{
	if (m_SpriteHandle != Nuclear::INVALID_ENGINE_SPRITE_HANDLE)
	{
		Nuclear::GetEngine()->ReleaseEngineSprite(m_SpriteHandle);
		m_SpriteHandle = Nuclear::INVALID_ENGINE_SPRITE_HANDLE;
	}

	if (gGetGameUIManager()) {
		gGetGameUIManager()->RemoveUISpineSprite(this);
	}
}

void UISpineSprite::PlayAction(eActionType actionType)
{
	if (m_SpriteHandle != Nuclear::INVALID_ENGINE_SPRITE_HANDLE)
	{
		std::wstring actionname = GetActionName(actionType);
		Nuclear::GetEngine()->SetEngineSpriteAction(m_SpriteHandle, actionname);
		Nuclear::GetEngine()->GetEngineSpriteActionTimeByName(m_SpriteHandle, actionname, m_CurActTime);
	}
}

void UISpineSprite::SetDefaultAction(eActionType actionType)
{
	if (m_SpriteHandle != Nuclear::INVALID_ENGINE_SPRITE_HANDLE)
	{
		std::wstring actionname = GetActionName(actionType);
		Nuclear::GetEngine()->SetEngineSpriteDefaultAction(m_SpriteHandle, actionname);
	}
}

void UISpineSprite::RenderUISprite()
{
	if (m_SpriteHandle != Nuclear::INVALID_ENGINE_SPRITE_HANDLE)
	{
		static int sRenderCallCount = 0;
		++sRenderCallCount;
		if (sRenderCallCount <= 20 || sRenderCallCount == 60 || sRenderCallCount == 180 || sRenderCallCount == 600)
		{
			MT3_LOGIN_RENDER_TRACE("UISpineSprite::RenderUISprite #%d this=%p handle=%u",
				sRenderCallCount,
				this,
				(unsigned int)m_SpriteHandle);
		}

		Nuclear::GetEngine()->RendererEngineSprite(m_SpriteHandle);
	}
}

void UISpineSprite::SetUILocation(const Nuclear::NuclearLocation& loc)
{
	if (m_SpriteHandle != Nuclear::INVALID_ENGINE_SPRITE_HANDLE)
	{
		Nuclear::GetEngine()->SetEngineSpriteLoc(m_SpriteHandle, ConvertUIToSceneLocation(loc));
	}
}

void UISpineSprite::SetUIScale(const float scale)
{
	if (m_SpriteHandle != Nuclear::INVALID_ENGINE_SPRITE_HANDLE)
	{
		Nuclear::GetEngine()->SetEngineSpriteScale(m_SpriteHandle, scale);
	}
}

void UISpineSprite::SetUIAlpha(unsigned char alpha)
{
	if (m_SpriteHandle != Nuclear::INVALID_ENGINE_SPRITE_HANDLE)
	{
		Nuclear::GetEngine()->SetEngineSpriteAlpha(m_SpriteHandle, alpha);
	}
}

void UISpineSprite::SetSpineModel(const std::wstring &modelname, bool async)
{
	if (m_SpriteHandle != Nuclear::INVALID_ENGINE_SPRITE_HANDLE)
	{
		Nuclear::GetEngine()->SetEngineSpriteModel(m_SpriteHandle, modelname, async);
	}
}

std::wstring UISpineSprite::GetActionName(eActionType type)
{
	return gGetActionName(type);
}
