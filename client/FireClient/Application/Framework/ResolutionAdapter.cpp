#include "ResolutionAdapter.h"
#include <engine/nuengine.h>
#include <RuntimeViewportCalculator.h>
#ifdef WIN32
#include "platform/desktop/CCGLView.h"
#include <fstream>
#include <iomanip>
#endif

#if defined(ANDROID) && defined(LOGCAT)
#include <android/log.h>
#define  LOG_TAG    "mt3"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#else
#define LOGI
#define LOGE
#define LOGD
#endif

static const float c_aspec_min = 1.0f;
static const float c_aspec_max = 2.0f;

#if defined(ANDROID)
static const float c_max_ui_scale = 2.00f;
#else
static const float c_max_ui_scale = 1.30f;
#endif

#ifdef WIN32
static int c_render_width = 0;
static int c_render_height = 0;
static int c_ui_width = 1280;
static int c_ui_height = 720;
#elif defined(ANDROID)
// Android scene logic resolution must stay at 1080x720-compatible baseline, otherwise UI/layout scripts break.
static const int c_render_width = 1080;
static const int c_render_height = 720;
static const int c_ui_width = 1080;
static const int c_ui_height = 720;
#elif defined(OS_IOS) || defined(_OS_IOS)
// iOS uses same 1080x720 baseline as Android for cross-platform UI consistency.
static const int c_render_width = 1080;
static const int c_render_height = 720;
static const int c_ui_width = 1080;
static const int c_ui_height = 720;
#else
static const int c_render_width = 0;
static const int c_render_height = 0;
static const int c_ui_width = 1080;
static const int c_ui_height = 720;
#endif // WIN32

#ifdef WIN32
static void ExportRuntimeViewportProfileForWysiwyg(const mt3::RuntimeViewportProfile& profile)
{
	std::ofstream out("MT3.runtime-profile.json", std::ios::out | std::ios::binary | std::ios::trunc);
	if (!out.is_open())
	{
		return;
	}

	out << "{\n";
	out << "  \"source\": \"MT3Runtime\",\n";
	out << "  \"profile\": \"ResolutionAdapter UI\",\n";
	out << "  \"platform\": \"Win32\",\n";
	out << "  \"contentScale\": 1.000000,\n";
	out << "  \"physical\": { \"width\": " << profile.screenWidth << ", \"height\": " << profile.screenHeight << " },\n";
	out << "  \"target\": { \"width\": " << profile.targetWidth << ", \"height\": " << profile.targetHeight << " },\n";
	out << "  \"display\": { \"x\": " << profile.displayX << ", \"y\": " << profile.displayY << ", \"width\": " << profile.displayWidth << ", \"height\": " << profile.displayHeight << " },\n";
	out << "  \"safeInset\": { \"left\": " << profile.safeInset.left << ", \"top\": " << profile.safeInset.top << ", \"right\": " << profile.safeInset.right << ", \"bottom\": " << profile.safeInset.bottom << " },\n";
	out << "  \"logic\": { \"width\": " << profile.logicWidth << ", \"height\": " << profile.logicHeight << " },\n";
	out << "  \"uiScale\": " << std::fixed << std::setprecision(6) << profile.uiScale << "\n";
	out << "}\n";
}

static bool TryGetWin32FrameSize(int& width, int& height)
{
	cocos2d::GLView* eglView = cocos2d::Director::getInstance()->getOpenGLView();
	if (!eglView)
	{
		return false;
	}

	const cocos2d::Size& frameSize = eglView->getFrameSize();
	if (frameSize.width <= 0.0f || frameSize.height <= 0.0f)
	{
		return false;
	}

	width = (int)(frameSize.width + 0.5f);
	height = (int)(frameSize.height + 0.5f);
	return width > 0 && height > 0;
}
#endif

ResolutionAdapter::ResolutionAdapter()
{ }

bool ResolutionAdapter::init()
{
	GLint vp[4];
	glGetIntegerv(GL_VIEWPORT, vp);
#if (defined WINAPI_FAMILY && WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
	m_screenW = vp[2];
	m_screenH = vp[3];
#elif defined _OS_IOS
    m_screenW = (vp[2] > vp[3] ? vp[2]: vp[3]);
    m_screenH = (vp[2] > vp[3] ? vp[3]: vp[2]);
#elif defined WIN32
	if (!TryGetWin32FrameSize(m_screenW, m_screenH))
	{
		m_screenW = vp[2];
		m_screenH = vp[3];
	}
#else
	m_screenW = vp[2];
	m_screenH = vp[3];
#endif

	int renderTargetW = c_render_width;
	int renderTargetH = c_render_height;
	int uiTargetW = c_ui_width;
	int uiTargetH = c_ui_height;
	int sceneRenderTargetW = renderTargetW;
	int sceneRenderTargetH = renderTargetH;

//MT的需求
#ifdef WIN32
	std::FILE *fp = std::fopen("frameResolutionSize.txt", "r");
	if (fp)
	{
		long value[6] = { 0 };
		int count = 0;
		while (count < 6 && std::fscanf(fp, "%ld", &value[count]) == 1)
		{
			++count;
		}
		fclose(fp);

		if (count >= 2)
		{
			renderTargetW = (int)value[0];
			renderTargetH = (int)value[1];
		}
		if (count >= 4)
		{
			uiTargetW = (int)value[2];
			uiTargetH = (int)value[3];
		}
		if (count >= 6)
		{
			sceneRenderTargetW = (int)value[4];
			sceneRenderTargetH = (int)value[5];
		}
	}
#endif // WIN32

	mt3::RuntimeViewportProfile uiViewportProfile;
	mt3::ComputeRuntimeViewportProfile(m_screenW, m_screenH, uiTargetW, uiTargetH, mt3::RuntimeSafeInset(), c_max_ui_scale, uiViewportProfile);
	mt3::ComputeRuntimeLogicSize(m_screenW, m_screenH, renderTargetW, renderTargetH, m_logicW, m_logicH);
	m_logicUIW = uiViewportProfile.logicWidth;
	m_logicUIH = uiViewportProfile.logicHeight;
	mt3::ComputeRuntimeLogicSize(m_screenW, m_screenH, sceneRenderTargetW, sceneRenderTargetH, m_sceneRenderW, m_sceneRenderH);

    m_displayX = 0;
    m_displayY = 0;
    
    m_displayW = m_screenW;
    m_displayH = m_screenH;
    
    m_screenUIW = uiViewportProfile.screenWidth;
    m_screenUIH = uiViewportProfile.screenHeight;
    
    m_displayUIX = uiViewportProfile.displayX;
    m_displayUIY = uiViewportProfile.displayY;
    
    m_displayUIW = uiViewportProfile.displayWidth;
    m_displayUIH = uiViewportProfile.displayHeight;

#ifdef WIN32
	ExportRuntimeViewportProfileForWysiwyg(uiViewportProfile);
#endif
    
    LOGD("m_logicW ------ %d", m_logicW);
    LOGD("m_logicH ------ %d", m_logicH);
    LOGD("m_screenW ----- %d", m_screenW);
    LOGD("m_screenH ----- %d", m_screenH);
    LOGD("m_displayX ---- %d", m_displayX);
    LOGD("m_displayY ---- %d", m_displayY);
    LOGD("m_displayW ---- %d", m_displayW);
    LOGD("m_displayH ---- %d", m_displayH);
    LOGD("m_logicUIW ---- %d", m_logicUIW);
    LOGD("m_logicUIH ---- %d", m_logicUIH);
    LOGD("m_sceneRenderW %d", m_sceneRenderW);
    LOGD("m_sceneRenderH %d", m_sceneRenderH);
    LOGD("m_maxUIScale -- %.2f", c_max_ui_scale);
    LOGD("m_runtimeUIScale %.3f", uiViewportProfile.uiScale);
    LOGD("m_screenUIW --- %d", m_screenUIW);
    LOGD("m_screenUIH --- %d", m_screenUIH);
    LOGD("m_displayUIX -- %d", m_displayUIX);
    LOGD("m_displayUIY -- %d", m_displayUIY);
    LOGD("m_displayUIW -- %d", m_displayUIW);
    LOGD("m_displayUIH -- %d", m_displayUIH);
    return true;
}

void ResolutionAdapter::SetScreenHeight(int h)
{
	m_screenUIH = h;
}

void ResolutionAdapter::SetDisplayOffsetY(int y)
{
	m_displayUIY = y;
}

int ResolutionAdapter::GetDisplayHeight()
{
	return m_displayUIH;
}

int ResolutionAdapter::GetDisplayWidth()
{
	return m_displayUIW;
}

int ResolutionAdapter::GetDisplayOffsetY()
{
	return m_displayUIY;
}

int ResolutionAdapter::GetDisplayOffsetX()
{
	return m_displayUIX;
}

int ResolutionAdapter::GetScreenHeight()
{
	return m_screenUIH;
}

int ResolutionAdapter::GetScreenWidth()
{
	return m_screenUIW;
}

int ResolutionAdapter::GetLogicHeight()
{
	return m_logicUIH;
}

int ResolutionAdapter::GetLogicWidth()
{
	return m_logicUIW;
}

int ResolutionAdapter::get_display_h()
{
	return m_displayH;
}

int ResolutionAdapter::get_display_w()
{
	return m_displayW;
}

int ResolutionAdapter::get_display_y()
{
	return m_displayY;
}

int ResolutionAdapter::get_display_x()
{
	return m_displayX;
}

int ResolutionAdapter::get_logic_h()
{
	return m_logicH;
}

int ResolutionAdapter::get_logic_w()
{
	return m_logicW;
}

int ResolutionAdapter::get_ui_logic_h()
{
	return m_logicUIH;
}

int ResolutionAdapter::get_ui_logic_w()
{
	return m_logicUIW;
}

int ResolutionAdapter::get_scene_render_h()
{
	return m_sceneRenderH;
}

int ResolutionAdapter::get_scene_render_w()
{
	return m_sceneRenderW;
}

int ResolutionAdapter::get_screen_h()
{
    return m_screenH;
}

int ResolutionAdapter::get_screen_w()
{
    return m_screenW;
}
