#define NOMINMAX

#include "CEGUICocos2DRenderer.h"

#include <CEGUIRenderingRoot.h>
#include <CEGUIExceptions.h>
#include <CEGUISystem.h>
#include <CEGUIDefaultResourceProvider.h>
#include <CEGUIPfsResourceProvider.h>

#include "CEGUICocos2DTexture.h"
#include "CEGUICocos2DGeometryBuffer.h"
#include "CEGUICocos2DRenderTarget.h"
#include "CEGUICocos2DViewportTarget.h"
#include "CEGUICocos2DTextureTarget.h"
#include "CEGUILoadingTaskManager.h"

#include <algorithm>
#include <stdio.h>
#include <stdarg.h>
#if defined(ANDROID)
#include <android/log.h>
#define CEGUI_PROBE_LOG(...) __android_log_print(ANDROID_LOG_ERROR, "CEGUIProbe", __VA_ARGS__)
#elif defined(WIN32) && (defined(_DEBUG) || defined(DEBUG))
static void CEGUIProbeLogToFile(const char* fmt, ...)
{
    FILE* fp = NULL;
    if (fopen_s(&fp, "startup_bootstrap.log", "ab") != 0 || !fp)
    {
        return;
    }

    fputs("[MT3_CEGUI_RENDERER] ", fp);
    va_list args;
    va_start(args, fmt);
    vfprintf(fp, fmt, args);
    va_end(args);
    fputs("\r\n", fp);
    fclose(fp);
}
#define CEGUI_PROBE_LOG(...) CEGUIProbeLogToFile(__VA_ARGS__)
#else
#define CEGUI_PROBE_LOG(...) ((void)0)
#endif

static std::string CEGUIProbeHeadBytes(const void* data, size_t size)
{
    if (!data)
    {
        return "(null)";
    }
    if (size == 0)
    {
        return "(empty)";
    }
    const unsigned char* bytes = static_cast<const unsigned char*>(data);
    const size_t count = size < 16 ? size : 16;
    std::string out;
    char part[4];
    for (size_t i = 0; i < count; ++i)
    {
        if (i != 0)
        {
            out += " ";
        }
        sprintf(part, "%02X", bytes[i]);
        out += part;
    }
    return out;
}

#include "CEGUIImageCodec.h"
#include "CEGUIWindow.h"
#include "CEGUIImagesetManager.h"

#define RELEASE_TEXTURE_TIME 100

// Start of CEGUI namespace section
namespace CEGUI
{
	bool g_redraw = false;
	class CTextureLoadData
	{
	public:
		CTextureLoadData(const String& filename, const String& resourceGroup)
			: m_refCount(1), m_filename(filename), m_resourceGroup(resourceGroup)
		{
		}

		void AddRef()
		{
			core::CMutex::Scoped lock(m_refMutex);
			++m_refCount;
		}

		void Release()
		{
			bool deleteSelf = false;
			m_refMutex.Lock();
			if (--m_refCount == 0)
			{
				deleteSelf = true;
			}
			m_refMutex.UNLock();
			if (deleteSelf)
			{
				delete this;
			}
		}

#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
		LJFM::LJFMID& GetFileData() { return m_fileData; }
#else
		RawDataContainer& GetFileData() { return m_fileData; }
#endif
		const String& GetFileName() const { return m_filename; }
		const String& GetResourceGroup() const { return m_resourceGroup; }

	private:
		unsigned int m_refCount;
		core::CMutex m_refMutex;
#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
		LJFM::LJFMID m_fileData;
#else
		RawDataContainer m_fileData;
#endif
		String m_filename;
		String m_resourceGroup;
	};

	class CLoadFileTask : public ITask
	{
		Cocos2DRenderer* m_pRender;
		Cocos2DTexture*  m_pTexture;
		CTextureLoadData* m_pLoadData;
	public:
		CLoadFileTask(Cocos2DRenderer* aPRender, Cocos2DTexture* aPTexture, String filename, String resGroup)
			: ITask(eTPFile)
			, m_pRender(aPRender)
			, m_pTexture(aPTexture)
			, m_pLoadData(new CTextureLoadData(filename, resGroup))
		{}
		virtual ~CLoadFileTask()
		{
			m_pLoadData->Release();
		}

		Cocos2DTexture* GetTexturePtr()
		{
			return m_pTexture;
		}

		virtual bool References(const void* owner) const
		{
			return m_pTexture == owner || m_pRender == owner;
		}

		String GetFileName()
		{
			return m_pLoadData->GetFileName();
		}

		String GetResourceGroup()
		{
			return m_pLoadData->GetResourceGroup();
		}

		CTextureLoadData* GetLoadData() { return m_pLoadData; }

#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
		LJFM::LJFMID& GetFileData()
		{
			return m_pLoadData->GetFileData();
		}
#else
		RawDataContainer& GetFileData()
		{
			return m_pLoadData->GetFileData();
		}
#endif

		virtual void HandleFailure()
		{
			if (!IsCancelled() &&
				m_pRender->OnImageLoadFailed(this, m_pTexture, m_pLoadData->GetFileName()))
			{
				SetDeleteAfterRun(false);
			}
		}

		virtual void Run()
		{
			System::getSingleton().getResourceProvider()->loadRawDataContainer(
				m_pLoadData->GetFileName(), m_pLoadData->GetFileData(), m_pLoadData->GetResourceGroup());

			if (IsCancelled())
			{
				return;
			}

#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
			CEGUI_PROBE_LOG("Renderer async file filename=%s group=%s size=%llu head=%s",
				m_pLoadData->GetFileName().c_str(),
				m_pLoadData->GetResourceGroup().empty() ? "" : m_pLoadData->GetResourceGroup().c_str(),
				(unsigned long long)m_pLoadData->GetFileData().GetSize(),
				CEGUIProbeHeadBytes(m_pLoadData->GetFileData().GetData(), (size_t)m_pLoadData->GetFileData().GetSize()).c_str());
			if (m_pLoadData->GetFileData().GetSize() == 0 ||
				m_pLoadData->GetFileData().GetSize() == -1 ||
				!m_pLoadData->GetFileData().GetData())
			{
				CEGUI_PROBE_LOG("Renderer async file invalid filename=%s size=%llu data=%p",
					m_pLoadData->GetFileName().c_str(),
					(unsigned long long)m_pLoadData->GetFileData().GetSize(),
					m_pLoadData->GetFileData().GetData());
				HandleFailure();
				return;
			}
#else
			if (m_pLoadData->GetFileData().getSize() == 0 ||
				m_pLoadData->GetFileData().getSize() == -1)
			{
				HandleFailure();
				return;
			}
#endif
			if (!IsCancelled() && !m_pRender->OnFileLoaded(this))
			{
				HandleFailure();
			}
		}
	};

	class CParseImageTask : public ITask
	{
		Cocos2DRenderer*    m_pRender;
		Cocos2DTexture*     m_pTexture;
		CTextureLoadData*   m_pLoadData;
#ifdef PUBLISHED_VERSION
		CodecPrivateData*   m_pCodecData;
#endif
	public:
		CParseImageTask(Cocos2DRenderer* aPRender, Cocos2DTexture* aPTexture, CTextureLoadData* loadData)
			: ITask(eTPParse)
			, m_pRender(aPRender)
			, m_pTexture(aPTexture)
			, m_pLoadData(loadData)
#ifdef PUBLISHED_VERSION
			, m_pCodecData(NULL)
#endif
		{
			m_pLoadData->AddRef();
		}
		virtual ~CParseImageTask()
		{
			m_pLoadData->Release();
#ifdef PUBLISHED_VERSION
			delete m_pCodecData;
#endif
		}

#ifdef PUBLISHED_VERSION
		CodecPrivateData* GetParseData()
		{
			return m_pCodecData;
		}
#endif        
		Cocos2DTexture* GetTexturePtr()
		{
			return m_pTexture;
		}

		virtual bool References(const void* owner) const
		{
			return m_pTexture == owner || m_pRender == owner;
		}

		CTextureLoadData* GetLoadData() { return m_pLoadData; }

		virtual void HandleFailure()
		{
			if (!IsCancelled() &&
				m_pRender->OnImageLoadFailed(this, m_pTexture, m_pLoadData->GetFileName()))
			{
				SetDeleteAfterRun(false);
			}
		}

		virtual void Run()
		{
			if (IsCancelled())
			{
				return;
			}

			System* sys = System::getSingletonPtr();
			if (!sys)
			{
				return;
			}

#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
			CEGUI_PROBE_LOG("Renderer parse begin filename=%s size=%llu head=%s",
				m_pLoadData->GetFileName().c_str(),
				(unsigned long long)m_pLoadData->GetFileData().GetSize(),
				CEGUIProbeHeadBytes(m_pLoadData->GetFileData().GetData(), (size_t)m_pLoadData->GetFileData().GetSize()).c_str());
			Texture* res = sys->getImageCodec().load(m_pLoadData->GetFileData(), m_pTexture, &m_pCodecData, true);
#else
			Texture* res = sys->getImageCodec().load(m_pLoadData->GetFileData(), m_pTexture);
#endif

			if (!res)
			{
#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
				CEGUI_PROBE_LOG("Renderer parse failed filename=%s group=%s size=%llu head=%s",
					m_pLoadData->GetFileName().c_str(),
					m_pLoadData->GetResourceGroup().empty() ? "" : m_pLoadData->GetResourceGroup().c_str(),
					(unsigned long long)m_pLoadData->GetFileData().GetSize(),
					CEGUIProbeHeadBytes(m_pLoadData->GetFileData().GetData(), (size_t)m_pLoadData->GetFileData().GetSize()).c_str());
#endif
				HandleFailure();
				return;
			}
			//                CEGUI_THROW(RendererException("OpenGLTexture::loadFromFile - " +
			//                                              sys->getImageCodec().getIdentifierString() +
			//                                              " failed to load image '" + m_pLoadFileTask->GetFileName() + "'."));

			//tell render that this image is loaded;
			if (!IsCancelled() && m_pRender->OnImageParsed(this))
			{
				SetDeleteAfterRun(false);
			}
		}
	};

	void Cocos2DRenderer::CheckLoadingTexture(Cocos2DTexture* aPTexture)
	{
		if (!aPTexture || aPTexture->m_bDestroyPending)
		{
			return;
		}

		{//sync loaded finished
			core::CMutex::Scoped lockLoaded(m_mutexLoadedTextures);
			std::map<Cocos2DTexture*, STextureLoadItem>::iterator itLoaded = m_mapLoadedTexture.find(aPTexture);
			if (itLoaded != m_mapLoadedTexture.end())
			{
				ITask* completedTask = itLoaded->second.pTask;
				CCEGUITaskManager* taskManager = CCEGUITaskManager::GetExistingInstancePtr();
				if (taskManager && taskManager->IsTaskRunning(completedTask))
				{
					return;
				}
				if (!itLoaded->second.bLoadSucceeded)
				{
					aPTexture->m_bIsLoading = false;
					aPTexture->m_bLoadFailed = true;
					TextureList::iterator failed = std::find(d_loadingTextures.begin(), d_loadingTextures.end(), aPTexture);
					if (failed != d_loadingTextures.end())
					{
						d_loadingTextures.erase(failed);
					}
					delete completedTask;
					m_mapLoadedTexture.erase(itLoaded);
					return;
				}

				CParseImageTask* pTask = static_cast<CParseImageTask*>(completedTask);

#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
				CEGUI::Size sz(pTask->GetParseData()->GetWidth(), pTask->GetParseData()->GetHeight());
				if (pTask->GetParseData()->GetFmt() == Texture::PF_PVR2 || pTask->GetParseData()->GetFmt() == Texture::PF_PVR4 || pTask->GetParseData()->GetFmt() == Texture::PF_ETC)
				{
					aPTexture->loadFromBuffer(pTask->GetLoadData()->GetFileData().GetData(), sz, pTask->GetParseData()->GetFmt());
				}
				else if (pTask->GetParseData()->GetFmt() == Texture::PF_ATC_Exp || pTask->GetParseData()->GetFmt() == Texture::PF_ATC_Int)
				{
					aPTexture->loadFromBuffer(pTask->GetLoadData()->GetFileData().GetData(), sz, pTask->GetParseData()->GetFmt());
				}
				else if (pTask->GetParseData()->GetFmt() == Texture::PF_DXT3 || pTask->GetParseData()->GetFmt() == Texture::PF_DXT5)
				{
					aPTexture->loadFromBuffer(pTask->GetLoadData()->GetFileData().GetData(), sz, pTask->GetParseData()->GetFmt());
				}
				else
				{
					aPTexture->loadFromBuffer(pTask->GetParseData()->GetDataPtr(), sz, pTask->GetParseData()->GetFmt());
				}
#endif
				aPTexture->m_bIsLoading = false;
				aPTexture->m_bLoadFailed = !aPTexture->hasTexture();
				g_redraw = true;
				TextureList::iterator iLd = std::find(d_loadingTextures.begin(), d_loadingTextures.end(), aPTexture);
				if (iLd != d_loadingTextures.end()) {
					d_loadingTextures.erase(iLd);
				}
				delete completedTask;
				m_mapLoadedTexture.erase(itLoaded);
			}
		}
	}

	bool Cocos2DRenderer::OnFileLoaded(ITask* aPTask)
	{
		if (!aPTask || aPTask->IsCancelled())
		{
			return false;
		}

		CLoadFileTask* loadTask = static_cast<CLoadFileTask*>(aPTask);
		if (!loadTask->GetTexturePtr() || loadTask->GetTexturePtr()->m_bDestroyPending)
		{
			return false;
		}
		CCEGUITaskManager* taskManager = CCEGUITaskManager::GetInstancePtr();
		ITask* pTask = new CParseImageTask(this, loadTask->GetTexturePtr(), loadTask->GetLoadData());
		if (!taskManager->QueueTask(pTask))
		{
			delete pTask;
			return false;
		}
		// The texture can be cancelled between the first check and QueueTask.
		// Remove the newly queued parse task before the owner is released.
		if (aPTask->IsCancelled() || loadTask->GetTexturePtr()->m_bDestroyPending)
		{
			if (taskManager)
			{
				taskManager->CancelTasks(loadTask->GetTexturePtr());
			}
			return false;
		}
		return true;
	}

	bool Cocos2DRenderer::OnImageParsed(ITask* aPTask)
	{
		if (!aPTask || aPTask->IsCancelled())
		{
			return false;
		}

		CParseImageTask* parseTask = static_cast<CParseImageTask*>(aPTask);
		if (!parseTask->GetTexturePtr() || parseTask->GetTexturePtr()->m_bDestroyPending)
		{
			return false;
		}
		{
			core::CMutex::Scoped lockLoading(m_mutexLoadingTextures);
			m_mapLoadingTexture.erase(parseTask->GetLoadData()->GetFileName());
		}
		ITask* replacedTask = NULL;
		{
			core::CMutex::Scoped lockLoaded(m_mutexLoadedTextures);
			STextureLoadItem item;
			item.pTask = aPTask;
			item.bLoadSucceeded = true;
			std::map<Cocos2DTexture*, STextureLoadItem>::iterator existing =
				m_mapLoadedTexture.find(parseTask->GetTexturePtr());
			if (existing != m_mapLoadedTexture.end())
			{
				replacedTask = existing->second.pTask;
				existing->second = item;
			}
			else
			{
				m_mapLoadedTexture.insert(std::make_pair(parseTask->GetTexturePtr(), item));
			}
		}
		if (replacedTask && replacedTask != aPTask)
		{
			replacedTask->Cancel();
			CCEGUITaskManager* taskManager = CCEGUITaskManager::GetExistingInstancePtr();
			if (taskManager && taskManager->IsTaskRunning(replacedTask))
			{
				replacedTask->SetDeleteAfterRun(true);
			}
			else
			{
				delete replacedTask;
			}
		}
		return true;
	}

	bool Cocos2DRenderer::OnImageLoadFailed(ITask* aPTask,
		Cocos2DTexture* texture,
		const String& filename)
	{
		if (!aPTask || !texture || aPTask->IsCancelled() || texture->m_bDestroyPending)
		{
			return false;
		}

		{
			core::CMutex::Scoped lockLoading(m_mutexLoadingTextures);
			m_mapLoadingTexture.erase(filename);
		}
		ITask* replacedTask = NULL;
		{
			core::CMutex::Scoped lockLoaded(m_mutexLoadedTextures);
			STextureLoadItem item;
			item.pTask = aPTask;
			item.bLoadSucceeded = false;
			std::map<Cocos2DTexture*, STextureLoadItem>::iterator existing = m_mapLoadedTexture.find(texture);
			if (existing != m_mapLoadedTexture.end())
			{
				replacedTask = existing->second.pTask;
				existing->second = item;
			}
			else
			{
				m_mapLoadedTexture.insert(std::make_pair(texture, item));
			}
		}
		if (replacedTask && replacedTask != aPTask)
		{
			replacedTask->Cancel();
			CCEGUITaskManager* taskManager = CCEGUITaskManager::GetExistingInstancePtr();
			if (taskManager && taskManager->IsTaskRunning(replacedTask))
			{
				replacedTask->SetDeleteAfterRun(true);
			}
			else
			{
				delete replacedTask;
			}
		}
		return true;
	}
	extern int g_loadingTextCount;
	void Cocos2DRenderer::OnFrameEnd()
	{
		collectPendingTextureDeletes();
		//check if loaded texture is been used
		std::vector<Cocos2DTexture*> expiredTextures;
		std::vector<ITask*> expiredTasks;
		{
			core::CMutex::Scoped mutexLoaded(m_mutexLoadedTextures);

			bool bRedraw = false;
			std::map<Cocos2DTexture*, STextureLoadItem>::iterator iter = m_mapLoadedTexture.begin();
			for (; iter != m_mapLoadedTexture.end();)
			{
				CCEGUITaskManager* taskManager = CCEGUITaskManager::GetExistingInstancePtr();
				if (iter->second.iCheckCount >= RELEASE_TEXTURE_TIME &&
					(!taskManager || !taskManager->IsTaskRunning(iter->second.pTask)))
				{
					TextureList::iterator iLd = std::find(d_loadingTextures.begin(), d_loadingTextures.end(), iter->first);
					if (iLd != d_loadingTextures.end())
					{
						d_loadingTextures.erase(iLd);
					}
					expiredTextures.push_back(iter->first);
					expiredTasks.push_back(iter->second.pTask);
					m_mapLoadedTexture.erase(iter++);
				}
				else
				{
					iter->second.iCheckCount++;
					++iter;
				}
				bRedraw = true;
			}
			if (bRedraw)
			{
				System::getSingleton().getGUISheet()->invalidate(true);
			}
		}
		for (size_t i = 0; i < expiredTasks.size(); ++i)
		{
			delete expiredTasks[i];
		}
		for (size_t i = 0; i < expiredTextures.size(); ++i)
		{
			destroyTexture(expiredTextures[i]);
		}

		if (g_redraw)
		{
			System::getSingleton().getGUISheet()->invalidate(true);
			g_redraw = false;
		}
		collectPendingTextureDeletes();

		static bool bLastLoadingState = false;
		g_bIsTextLoading = (!CCEGUITaskManager::GetInstancePtr()->LoadingFontEmpty()) || (g_loadingTextCount != 0);
		if (g_bIsTextLoading != bLastLoadingState)
		{
			if (g_bIsTextLoading == false)
			{
				bLastLoadingState = false;
				g_bIsTextLoading = true;
			}
			else
			{
				bLastLoadingState = g_bIsTextLoading;
			}
		}
	}

	//----------------------------------------------------------------------------//
	String Cocos2DRenderer::d_rendererID(
		"CEGUI::Cocos2DRenderer - Cocos2D renderer "
		"module.");

	//----------------------------------------------------------------------------//
	static const float s_identityMatrix[16] =
	{
		1.0, 0.0, 0.0, 0.0,
		0.0, 1.0, 0.0, 0.0,
		0.0, 0.0, 1.0, 0.0,
		0.0, 0.0, 0.0, 1.0
	};

	//----------------------------------------------------------------------------//
	Cocos2DRenderer& Cocos2DRenderer::bootstrapSystem(cocos2d::CCLayer* parent, const char* logFile)
	{
		if (System::getSingletonPtr())
			CEGUI_THROW(InvalidRequestException("OpenGLRenderer::bootstrapSystem: "
			"CEGUI::System object is already initialised."));

		Cocos2DRenderer& renderer(create());
		renderer.d_pParent = parent;

		//renderer.d_pDebugTexture = &dynamic_cast<Cocos2DTexture&>(renderer.createTexture("logo.png", "imagesets"));
		return renderer;
	}

	void Cocos2DRenderer::destroySystem()
	{
		System* sys;
		if (!(sys = System::getSingletonPtr()))
			CEGUI_THROW(InvalidRequestException("OpenGLRenderer::destroySystem: "
			"CEGUI::System object is not created or was already destroyed."));

		Cocos2DRenderer* renderer = static_cast<Cocos2DRenderer*>(sys->getRenderer());
#ifdef PUBLISHED_VERSION
		PFSResourceProvider* rp = static_cast<PFSResourceProvider*>(sys->getResourceProvider());
#else
		DefaultResourceProvider* rp = static_cast<DefaultResourceProvider*>(sys->getResourceProvider());
#endif

		System::destroy();
		delete rp;
		destroy(*renderer);
	}

	//----------------------------------------------------------------------------//
	Cocos2DRenderer& Cocos2DRenderer::create()
	{
		return *new Cocos2DRenderer();
	}

	void Cocos2DRenderer::destroy(Cocos2DRenderer& renderer)
	{
		delete &renderer;
	}

	//----------------------------------------------------------------------------//
	RenderingRoot& Cocos2DRenderer::getDefaultRenderingRoot()
	{
		return *d_defaultRoot;
	}

	//----------------------------------------------------------------------------//
	GeometryBuffer& Cocos2DRenderer::createGeometryBuffer()
	{
		Cocos2DGeometryBuffer* b = new Cocos2DGeometryBuffer();
		d_geometryBuffers.push_back(b);
		return *b;
	}

	void Cocos2DRenderer::destroyGeometryBuffer(const GeometryBuffer* buffer)
	{
		GeometryBufferList::iterator i = std::find(d_geometryBuffers.begin(),
			d_geometryBuffers.end(),
			buffer);

		if (d_geometryBuffers.end() != i)
		{
			d_geometryBuffers.erase(i);

			// ycl destroyGeometryBuffer ֮ǰ����ȷ���� GeometryBuffer �Ѿ��� RenderQueue ���Ƴ���
			getDefaultRenderingRoot().removeGeometryBuffer(RQ_BASE, buffer);

			delete buffer;
		}
	}

	void Cocos2DRenderer::destroyAllGeometryBuffers()
	{
		while (!d_geometryBuffers.empty())
			destroyGeometryBuffer(*d_geometryBuffers.begin());
	}

	//----------------------------------------------------------------------------//
	TextureTarget* Cocos2DRenderer::createTextureTarget()
	{
		TextureTarget* t = new Cocos2DTextureTarget(*this);
		d_textureTargets.push_back(t);
		return t;
	}

	void Cocos2DRenderer::destroyTextureTarget(TextureTarget* target)
	{
		TextureTargetList::iterator i = std::find(d_textureTargets.begin(),
			d_textureTargets.end(),
			target);

		if (d_textureTargets.end() != i)
		{
			d_textureTargets.erase(i);
			delete target;
		}
	}

	void Cocos2DRenderer::destroyAllTextureTargets()
	{
		while (!d_textureTargets.empty())
			destroyTextureTarget(*d_textureTargets.begin());
	}

	//----------------------------------------------------------------------------//
	//Texture ops
	Texture& Cocos2DRenderer::createTexture()
	{
		Cocos2DTexture* tex = new Cocos2DTexture(*this);
		d_textures.push_back(tex);
		return *tex;
	}

	Texture& Cocos2DRenderer::createTexture(const String& filename, const String& resourceGroup, float priority, bool synload)
	{
#if (defined WIN7_32) && (defined _DEBUG)
		std::wstring strFileName = PFSResourceProvider::GUIStringToWString(filename);
#endif

#ifdef PUBLISHED_VERSION
		if (synload) // �첽����.
#endif
		{
			core::CMutex::Scoped lockLoading(m_mutexLoadingTextures);
			std::map<String, Cocos2DTexture*>::iterator iterLoaded = m_mapLoadingTexture.find(filename);
			if (iterLoaded == m_mapLoadingTexture.end())
			{
				Cocos2DTexture* pTex = new Cocos2DTexture(*this, filename, resourceGroup);
				ITask* pTask = new CLoadFileTask(this, pTex, filename, resourceGroup);
				pTask->SetPriority(priority);
				d_textures.push_back(pTex);
				d_loadingTextures.push_back(pTex);
				pTex->m_bIsLoading = true;
				m_mapLoadingTexture.insert(std::make_pair(filename, pTex));
				if (!CCEGUITaskManager::GetInstancePtr()->QueueTask(pTask))
				{
					delete pTask;
					m_mapLoadingTexture.erase(filename);
					TextureList::iterator loading =
						std::find(d_loadingTextures.begin(), d_loadingTextures.end(), pTex);
					if (loading != d_loadingTextures.end())
					{
						d_loadingTextures.erase(loading);
					}
					pTex->m_bIsLoading = false;
					pTex->m_bLoadFailed = true;
				}
				return *pTex;
			}
			else
			{
				return *iterLoaded->second;
			}
		}
#if (defined PUBLISHED_VERSION) && !(defined FORCEGUIEDITOR)
		else // 同步加载.
		{
			Cocos2DTexture* pTex = new Cocos2DTexture(*this, filename, resourceGroup);
			LJFM::LJFMID texFile;
			System::getSingleton().getResourceProvider()->loadRawDataContainer(filename, texFile, resourceGroup);
			CEGUI_PROBE_LOG("Renderer sync file filename=%s group=%s size=%llu head=%s",
				filename.c_str(),
				resourceGroup.empty() ? "" : resourceGroup.c_str(),
				(unsigned long long)texFile.GetSize(),
				CEGUIProbeHeadBytes(texFile.GetData(), (size_t)texFile.GetSize()).c_str());

			CodecPrivateData* pCodecData = NULL;
			Texture* res = System::getSingleton().getImageCodec().load(texFile, pTex, &pCodecData, false);
			if (!res)
			{
				CEGUI_PROBE_LOG("Renderer sync parse failed filename=%s group=%s size=%llu head=%s",
					filename.c_str(),
					resourceGroup.empty() ? "" : resourceGroup.c_str(),
					(unsigned long long)texFile.GetSize(),
					CEGUIProbeHeadBytes(texFile.GetData(), (size_t)texFile.GetSize()).c_str());
			}
			pTex->m_bIsLoading = false;
			pTex->m_bIsLoadFromFile = false;
			pTex->m_bLoadFailed = !res || !pTex->hasTexture();
			d_textures.push_back(pTex);
			delete pCodecData;
			return *pTex;
		}
#endif
	}

	Texture& Cocos2DRenderer::createTexture(const Size& size)
	{
		Cocos2DTexture* tex = new Cocos2DTexture(*this, size);
		d_textures.push_back(tex);
		return *tex;
	}

	Texture& Cocos2DRenderer::createTexture(cocos2d::CCTexture2D* pTexture)
	{
		Cocos2DTexture* tex = new Cocos2DTexture(*this, pTexture);
		d_textures.push_back(tex);
		return *tex;
	}

	void Cocos2DRenderer::destroyTexture(Texture* texture)
	{
		if (!texture)
		{
			return;
		}

		Cocos2DTexture* cocosTex = static_cast<Cocos2DTexture*>(texture);
		if (cocosTex->m_bDestroyPending)
		{
			collectPendingTextureDeletes();
			return;
		}

		if (std::find(d_textures.begin(), d_textures.end(), cocosTex) == d_textures.end() &&
			std::find(d_loadingTextures.begin(), d_loadingTextures.end(), cocosTex) == d_loadingTextures.end())
		{
			return;
		}

		CCEGUITaskManager* taskManager = CCEGUITaskManager::GetExistingInstancePtr();
		if (taskManager)
		{
			taskManager->CancelTasks(cocosTex);
		}
		cocosTex->m_bDestroyPending = true;
		detachTexture(cocosTex, false);

		if (taskManager && taskManager->HasTaskFor(cocosTex))
		{
			d_pendingDestroyTextures.push_back(cocosTex);
			return;
		}

		detachTexture(cocosTex, true);

#if (defined WIN7_32) && (defined _DEBUG)
		std::wstring strName;
		Cocos2DTexture* debugTex = dynamic_cast<Cocos2DTexture*>(texture);
		if (debugTex)
		{
			strName = PFSResourceProvider::GUIStringToWString(debugTex->getFileName());
		}
#endif
		delete cocosTex;
	}

	void Cocos2DRenderer::destroyAllTextures()
	{
		CCEGUITaskManager* taskManager = CCEGUITaskManager::GetExistingInstancePtr();
		if (taskManager)
		{
			taskManager->CancelTasks(this);
		}

		while (!d_textures.empty())
		{
			destroyTexture(d_textures.front());
		}
		collectPendingTextureDeletes();
	}

	void Cocos2DRenderer::notifyGeometryBuffersTextureReleased(Cocos2DTexture* texture)
	{
		for (GeometryBufferList::iterator it = d_geometryBuffers.begin();
			it != d_geometryBuffers.end(); ++it)
		{
			(*it)->releaseTexture(texture);
		}
	}

	void Cocos2DRenderer::detachTexture(Cocos2DTexture* texture, bool deleteLoadedTask)
	{
		if (!deleteLoadedTask)
		{
			TextureList::iterator textureIt = std::find(d_textures.begin(), d_textures.end(), texture);
			if (textureIt != d_textures.end())
			{
				d_textures.erase(textureIt);
			}
			TextureList::iterator loadingIt = std::find(d_loadingTextures.begin(), d_loadingTextures.end(), texture);
			if (loadingIt != d_loadingTextures.end())
			{
				d_loadingTextures.erase(loadingIt);
			}
			RenderTextureList::iterator renderIt = std::find(d_RenderTextures.begin(), d_RenderTextures.end(), texture);
			if (renderIt != d_RenderTextures.end())
			{
				d_RenderTextures.erase(renderIt);
			}

			{
				core::CMutex::Scoped lockLoading(m_mutexLoadingTextures);
				for (std::map<String, Cocos2DTexture*>::iterator it = m_mapLoadingTexture.begin();
					it != m_mapLoadingTexture.end();)
				{
					if (it->second == texture)
					{
						std::map<String, Cocos2DTexture*>::iterator eraseIt = it++;
						m_mapLoadingTexture.erase(eraseIt);
					}
					else
					{
						++it;
					}
				}
			}

			notifyGeometryBuffersTextureReleased(texture);
			if (ImagesetManager::getSingletonPtr())
			{
				ImagesetManager::getSingleton().notifyTextureReleased(texture);
			}
			return;
		}

		ITask* completedTask = NULL;
		{
			core::CMutex::Scoped lockLoaded(m_mutexLoadedTextures);
			std::map<Cocos2DTexture*, STextureLoadItem>::iterator loaded = m_mapLoadedTexture.find(texture);
			if (loaded != m_mapLoadedTexture.end())
			{
				completedTask = loaded->second.pTask;
				m_mapLoadedTexture.erase(loaded);
			}
		}
		delete completedTask;
	}

	void Cocos2DRenderer::collectPendingTextureDeletes()
	{
		CCEGUITaskManager* taskManager = CCEGUITaskManager::GetExistingInstancePtr();
		for (TextureList::iterator it = d_pendingDestroyTextures.begin();
			it != d_pendingDestroyTextures.end();)
		{
			Cocos2DTexture* texture = *it;
			if (taskManager && taskManager->HasTaskFor(texture))
			{
				++it;
				continue;
			}

			detachTexture(texture, true);
			delete texture;
			it = d_pendingDestroyTextures.erase(it);
		}
	}

	//----------------------------------------------------------------------------//
	void Cocos2DRenderer::beginRendering()
	{
		StateManager state;
		captureRenderState(state);
		d_stateStack.push_back(state);

		kmGLMatrixMode(KM_GL_PROJECTION);
		kmGLPushMatrix();
		kmGLMatrixMode(KM_GL_MODELVIEW);
		kmGLPushMatrix();

		glEnable(GL_BLEND);
		cocos2d::ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		glEnable(GL_SCISSOR_TEST);
		m_program = cocos2d::CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor);
		if (m_program)
		{
			m_program->use();
			m_program->setUniformsForBuiltins();
			ccGLEnableVertexAttribs(cocos2d::kCCVertexAttribFlag_PosColorTex);
		}
	}

	void Cocos2DRenderer::InitRenderStateType()
	{
	}

	void Cocos2DRenderer::SaveXPRenderState()
	{
		if (d_stateStack.empty())
		{
			return;
		}
		++d_externalPassDepth;
		if (d_externalPassDepth != 1)
		{
			return;
		}
		StateManager state;
		captureRenderState(state);
		d_externalStateStack.push_back(state);
		kmGLMatrixMode(KM_GL_PROJECTION);
		kmGLPopMatrix();
		kmGLMatrixMode(KM_GL_MODELVIEW);
		kmGLPopMatrix();
		restoreRenderState(d_stateStack.back());
	}
	void Cocos2DRenderer::SaveUIRenderState()
	{
		StateManager state;
		captureRenderState(state);
		d_externalStateStack.push_back(state);
	}
	void Cocos2DRenderer::RestoreXPRenderState()
	{
		if (d_externalPassDepth == 0)
		{
			return;
		}
		--d_externalPassDepth;
		if (d_externalPassDepth != 0 || d_externalStateStack.empty())
		{
			return;
		}
		StateManager state = d_externalStateStack.back();
		d_externalStateStack.pop_back();
		kmGLMatrixMode(KM_GL_PROJECTION);
		kmGLPushMatrix();
		kmGLMatrixMode(KM_GL_MODELVIEW);
		kmGLPushMatrix();
		restoreRenderState(state);
	}

	void Cocos2DRenderer::RestorUIRenderState()
	{
		if (!d_externalStateStack.empty())
		{
			StateManager state = d_externalStateStack.back();
			d_externalStateStack.pop_back();
			restoreRenderState(state);
		}
	}

	void Cocos2DRenderer::endRendering()
	{
		if (d_stateStack.empty())
		{
			return;
		}
		kmGLMatrixMode(KM_GL_PROJECTION);
		kmGLPopMatrix();
		kmGLMatrixMode(KM_GL_MODELVIEW);
		kmGLPopMatrix();
		StateManager state = d_stateStack.back();
		d_stateStack.pop_back();
		restoreRenderState(state);
	}

	void Cocos2DRenderer::captureRenderState(StateManager& state)
	{
		state.d_ScissorEnabled = glIsEnabled(GL_SCISSOR_TEST);
		state.d_BlendEnabled = glIsEnabled(GL_BLEND);
		state.d_DepthEnabled = glIsEnabled(GL_DEPTH_TEST);
		state.d_StencilEnabled = glIsEnabled(GL_STENCIL_TEST);
		state.d_CullEnabled = glIsEnabled(GL_CULL_FACE);
		glGetBooleanv(GL_COLOR_WRITEMASK, state.d_ColorMask);
		glGetIntegerv(GL_SCISSOR_BOX, state.d_ScissorBox);
		glGetIntegerv(GL_VIEWPORT, state.d_Viewport);
		glGetIntegerv(GL_CURRENT_PROGRAM, &state.d_CurrentProgram);
		state.d_ShaderKey = cocos2d::CCShaderCache::sharedShaderCache()->getCurShader();
		glGetIntegerv(GL_ACTIVE_TEXTURE, &state.d_ActiveTexture);
		glGetIntegerv(GL_BLEND_SRC_RGB, &state.d_BlendSrcRGB);
		glGetIntegerv(GL_BLEND_DST_RGB, &state.d_BlendDstRGB);
		glGetIntegerv(GL_BLEND_SRC_ALPHA, &state.d_BlendSrcAlpha);
		glGetIntegerv(GL_BLEND_DST_ALPHA, &state.d_BlendDstAlpha);
		glGetIntegerv(GL_UNPACK_ALIGNMENT, &state.d_UnpackAlignment);
		glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &state.d_ArrayBuffer);
		glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &state.d_ElementArrayBuffer);

		for (int unit = 0; unit < 2; ++unit)
		{
			cocos2d::ccGLActiveTexture(GL_TEXTURE0 + unit);
			glGetIntegerv(GL_TEXTURE_BINDING_2D, &state.d_TextureBindings[unit]);
		}
		cocos2d::ccGLActiveTexture(static_cast<GLenum>(state.d_ActiveTexture));

		const GLuint attributes[3] =
		{
			cocos2d::kCCVertexAttrib_Position,
			cocos2d::kCCVertexAttrib_Color,
			cocos2d::kCCVertexAttrib_TexCoords
		};
		for (int i = 0; i < 3; ++i)
		{
			GLint attributeEnabled = GL_FALSE;
			glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_ENABLED, &attributeEnabled);
			state.d_VertexAttribEnabled[i] = attributeEnabled ? GL_TRUE : GL_FALSE;
			glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_SIZE, &state.d_VertexAttribSize[i]);
			glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_TYPE, &state.d_VertexAttribType[i]);
			glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_NORMALIZED, &state.d_VertexAttribNormalized[i]);
			glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_STRIDE, &state.d_VertexAttribStride[i]);
			glGetVertexAttribiv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, &state.d_VertexAttribBuffer[i]);
			glGetVertexAttribPointerv(attributes[i], GL_VERTEX_ATTRIB_ARRAY_POINTER, &state.d_VertexAttribPointer[i]);
		}
	}

	void Cocos2DRenderer::restoreRenderState(const StateManager& state)
	{
		glColorMask(state.d_ColorMask[0], state.d_ColorMask[1], state.d_ColorMask[2], state.d_ColorMask[3]);
		glViewport(state.d_Viewport[0], state.d_Viewport[1], state.d_Viewport[2], state.d_Viewport[3]);
		glScissor(state.d_ScissorBox[0], state.d_ScissorBox[1], state.d_ScissorBox[2], state.d_ScissorBox[3]);
		cocos2d::ccGLBlendFunc(static_cast<GLenum>(state.d_BlendSrcRGB), static_cast<GLenum>(state.d_BlendDstRGB));
		glBlendFuncSeparate(static_cast<GLenum>(state.d_BlendSrcRGB), static_cast<GLenum>(state.d_BlendDstRGB),
			static_cast<GLenum>(state.d_BlendSrcAlpha), static_cast<GLenum>(state.d_BlendDstAlpha));
		glPixelStorei(GL_UNPACK_ALIGNMENT, state.d_UnpackAlignment);
		const GLenum capabilities[5] = { GL_SCISSOR_TEST, GL_BLEND, GL_DEPTH_TEST, GL_STENCIL_TEST, GL_CULL_FACE };
		const GLboolean enabled[5] = { state.d_ScissorEnabled, state.d_BlendEnabled,
			state.d_DepthEnabled, state.d_StencilEnabled, state.d_CullEnabled };
		for (int i = 0; i < 5; ++i)
		{
			if (enabled[i])
			{
				glEnable(capabilities[i]);
			}
			else
			{
				glDisable(capabilities[i]);
			}
		}

		for (int unit = 0; unit < 2; ++unit)
		{
			cocos2d::ccGLBindTexture2DN(unit, static_cast<GLuint>(state.d_TextureBindings[unit]));
		}
		cocos2d::ccGLActiveTexture(static_cast<GLenum>(state.d_ActiveTexture));
		if (!state.d_ShaderKey.empty())
		{
			cocos2d::CCShaderCache::sharedShaderCache()->pushShader(state.d_ShaderKey);
			cocos2d::CCShaderCache::sharedShaderCache()->popShader();
		}
		cocos2d::ccGLUseProgram(static_cast<GLuint>(state.d_CurrentProgram));

		const GLuint attributes[3] =
		{
			cocos2d::kCCVertexAttrib_Position,
			cocos2d::kCCVertexAttrib_Color,
			cocos2d::kCCVertexAttrib_TexCoords
		};
		unsigned int attributeFlags = 0;
		if (state.d_VertexAttribEnabled[0]) attributeFlags |= cocos2d::kCCVertexAttribFlag_Position;
		if (state.d_VertexAttribEnabled[1]) attributeFlags |= cocos2d::kCCVertexAttribFlag_Color;
		if (state.d_VertexAttribEnabled[2]) attributeFlags |= cocos2d::kCCVertexAttribFlag_TexCoords;
		cocos2d::ccGLEnableVertexAttribs(attributeFlags);
		for (int i = 0; i < 3; ++i)
		{
			if (!state.d_VertexAttribEnabled[i])
			{
				glDisableVertexAttribArray(attributes[i]);
			}
			glBindBuffer(GL_ARRAY_BUFFER, state.d_VertexAttribBuffer[i]);
			glVertexAttribPointer(attributes[i], state.d_VertexAttribSize[i],
				static_cast<GLenum>(state.d_VertexAttribType[i]),
				state.d_VertexAttribNormalized[i] ? GL_TRUE : GL_FALSE,
				state.d_VertexAttribStride[i], state.d_VertexAttribPointer[i]);
		}
		glBindBuffer(GL_ARRAY_BUFFER, state.d_ArrayBuffer);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, state.d_ElementArrayBuffer);
	}

	//----------------------------------------------------------------------------//
	void Cocos2DRenderer::setDisplaySize(const Size& sz)
	{
		if (sz != d_displaySize)
		{
			d_displaySize = sz;

			// FIXME: This is probably not the right thing to do in all cases.
			Rect area(d_defaultTarget->getArea());
			area.setSize(sz);
			d_defaultTarget->setArea(area);
		}
	}

	const Size& Cocos2DRenderer::getDisplaySize() const
	{
		return d_displaySize;
	}

	const Vector2& Cocos2DRenderer::getDisplayDPI() const
	{
		return d_displayDPI;
	}

	uint Cocos2DRenderer::getMaxTextureSize() const
	{
		return d_maxTextureSize;
	}

	const String& Cocos2DRenderer::getIdentifierString() const
	{
		return d_rendererID;
	}

	//----------------------------------------------------------------------------//
	Cocos2DRenderer::Cocos2DRenderer() :
		d_displaySize(getViewportSize()),
		d_displayDPI(384, 384),
		d_defaultRoot(0),
		d_defaultTarget(0),
		d_SeparateAlphaBlendCap(false),
		d_externalPassDepth(0),
		m_program(NULL)
	{
		GLint max_tex_size;
		glGetIntegerv(GL_MAX_TEXTURE_SIZE, &max_tex_size);
		d_maxTextureSize = max_tex_size;

		/* d_supportNonSquareTex = !(caps.TextureCaps & D3DPTEXTURECAPS_SQUAREONLY);

		 d_supportNPOTTex = !(caps.TextureCaps & D3DPTEXTURECAPS_POW2) ||
		 (caps.TextureCaps & D3DPTEXTURECAPS_NONPOW2CONDITIONAL);
		 d_SeparateAlphaBlendCap=(caps.PrimitiveMiscCaps & D3DPMISCCAPS_SEPARATEALPHABLEND) != 0;*/

		d_supportNonSquareTex = false;
		d_supportNPOTTex = cocos2d::CCConfiguration::sharedConfiguration()->supportsNPOT();

		d_SeparateAlphaBlendCap = false;

		d_defaultTarget = new Cocos2DViewportTarget(*this);
		d_defaultRoot = new RenderingRoot(*d_defaultTarget);

		//InitRenderStateType();
	}

	Cocos2DRenderer::~Cocos2DRenderer()
	{
		destroyAllGeometryBuffers();
		destroyAllTextureTargets();
		destroyAllTextures();

		delete d_defaultRoot;
		delete d_defaultTarget;
	}

	Size Cocos2DRenderer::getViewportSize()
	{
		GLint vp[4];
		glGetIntegerv(GL_VIEWPORT, vp);
		return Size(static_cast<float>(vp[2]), static_cast<float>(vp[3]));
	}

	//----------------------------------------------------------------------------//
	void Cocos2DRenderer::preD3DReset()
	{
		// perform pre-reset on texture targets
		//   TextureTargetList::iterator target_iterator = d_textureTargets.begin();
		//   for (; target_iterator != d_textureTargets.end(); ++target_iterator)
		//       static_cast<Direct3D9TextureTarget*>(*target_iterator)->preD3DReset();

		//   // perform pre-reset on textures
		//   TextureList::iterator texture_iterator = d_textures.begin();
		//   for (; texture_iterator != d_textures.end(); ++texture_iterator)
		//       (*texture_iterator)->preD3DReset();

		//if (d_UISatteBlock)
		//{
		//	d_UISatteBlock->Release();
		//	d_UISatteBlock=NULL;
		//}

		//if (d_XPStateBlock)
		//{
		//	d_XPStateBlock->Release();
		//	d_XPStateBlock=NULL;
		//}
	}

	void Cocos2DRenderer::postD3DReset()
	{
		// perform post-reset on textures
		//TextureList::iterator texture_iterator = d_textures.begin();
		//for (; texture_iterator != d_textures.end(); ++texture_iterator)
		//    (*texture_iterator)->postD3DReset();

		//// perform post-reset on texture targets
		//TextureTargetList::iterator target_iterator = d_textureTargets.begin();
		//for (; target_iterator != d_textureTargets.end(); ++target_iterator)
		//    static_cast<Direct3D9TextureTarget*>(*target_iterator)->postD3DReset();

		//// notify system about the (possibly) new viewport size.
		//System::getSingleton().notifyDisplaySizeChanged(getViewportSize());
	}

	//----------------------------------------------------------------------------//
	//Texture& Cocos2DRenderer::createTexture(LPDIRECT3DTEXTURE9 texture)
	//{
	//    Cocos2DTexture* tex = new Cocos2DTexture(*this, texture);
	//    d_textures.push_back(tex);
	//    return *tex;
	//}

	//----------------------------------------------------------------------------//
	bool Cocos2DRenderer::supportsNonSquareTexture()
	{
		return d_supportNonSquareTex;
	}

	//----------------------------------------------------------------------------//
	bool Cocos2DRenderer::supportsNPOTTextures()
	{
		return d_supportNPOTTex;
	}

	//----------------------------------------------------------------------------//
	Size Cocos2DRenderer::getAdjustedSize(const Size& sz)
	{
		Size s(sz);

		if (!d_supportNPOTTex)
		{
			s.d_width = getSizeNextPOT(sz.d_width);
			s.d_height = getSizeNextPOT(sz.d_height);
		}
		if (!d_supportNonSquareTex)
			s.d_width = s.d_height =
			ceguimax(s.d_width, s.d_height);

		return s;
	}

	float Cocos2DRenderer::getSizeNextPOT(float sz) const
	{
		uint size = static_cast<uint>(sz);

		// if not power of 2
		if ((size & (size - 1)) || !size)
		{
			int log = 0;

			// get integer log of 'size' to base 2
			while (size >>= 1)
				++log;

			// use log to calculate value to use as size.
			size = (2 << log);
		}

		return static_cast<float>(size);
	}

	void Cocos2DRenderer::Reset()
	{
		//d_defaultRoot->Reset();
	}

	void Cocos2DRenderer::ResetRenderTextures()  //???\u2019\u2030\u00F7??\u03C0?\u03BC????\u00EC
	{
		d_RenderTextures.clear();
	}

	void Cocos2DRenderer::MarkRenderTexture(Texture* pTexture)
	{
		RenderTextureList::iterator it = std::find(d_RenderTextures.begin(),
			d_RenderTextures.end(), pTexture);
		if (it == d_RenderTextures.end())
		{
			d_RenderTextures.push_back(static_cast<Cocos2DTexture*>(pTexture));
		}
	}

	bool Cocos2DRenderer::isTextureRender(Texture& texture)
	{
		RenderTextureList::iterator it = std::find(d_RenderTextures.begin(), d_RenderTextures.end(), &texture);
		if (it != d_RenderTextures.end())
		{
			return true;
		}
		return false;
	}

	void Cocos2DRenderer::ReleaseTexture(Texture* texture)
	{
		RenderTextureList::iterator it = std::find(d_RenderTextures.begin(), d_RenderTextures.end(), texture);
		if (it != d_RenderTextures.end())
		{
			d_RenderTextures.erase(it);
		}
		destroyTexture(texture);
	}

	bool Cocos2DRenderer::isTextureValid(Cocos2DTexture* pCocos2DTexture)
	{
		TextureList::iterator it = std::find(d_textures.begin(), d_textures.end(),
			pCocos2DTexture);
		return it != d_textures.end();

		//TextureList::iterator it=d_textures.begin();
		//for (;it!=d_textures.end();++it)
		//{
		//	//Direct3D9Texture* pTexture=(*it);
		//	if ((*it) == pCocos2DTexture)
		//	{
		//		return true;
		//	}
		//}
		//return false;
	}

	void Cocos2DRenderer::MarkRenderTexture(Cocos2DTexture* pCocos2DTexture)
	{
		if (isTextureValid(pCocos2DTexture))
		{
			MarkRenderTexture((Texture*)(pCocos2DTexture));
		}
	}

	void Cocos2DRenderer::SetPointMode(bool b)
	{
		//	d_PointMode=b;
	}


} // End of  CEGUI namespace section
