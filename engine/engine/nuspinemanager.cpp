#include "nuspinemanager.h"
#include "engine/nuenginebase.h"
#include "engine/nuengine.h"
#include "../common/nufileiomanager.h"
#include "../renderer/nucocos2d_render.h"
#include <spine/spine-cocos2dx.h>
#include <stdarg.h>
#include <stdio.h>

#if defined(MT3_RUNTIME_DIAG_ENABLE) && defined(ANDROID)
#include <android/log.h>
#endif

namespace Nuclear
{
#if defined(WIN32) && (defined(_DEBUG) || defined(DEBUG))
	static void MT3SpineManagerTraceToFile(const char* fmt, ...)
	{
		FILE* fp = NULL;
		if (fopen_s(&fp, "startup_bootstrap.log", "ab") != 0 || !fp)
		{
			return;
		}
		fputs("[MT3_SPINE_MANAGER] ", fp);
		va_list args;
		va_start(args, fmt);
		vfprintf(fp, fmt, args);
		va_end(args);
		fputs("\r\n", fp);
		fclose(fp);
	}
#define MT3_SPINE_MANAGER_TRACE(...) MT3SpineManagerTraceToFile(__VA_ARGS__)
#else
#define MT3_SPINE_MANAGER_TRACE(...)
#endif

#if defined(MT3_RUNTIME_DIAG_ENABLE)
	static void MT3SpineDiagTrace(const char* fmt, ...)
	{
		char buffer[1024];
		va_list args;
		va_start(args, fmt);
#if defined(_MSC_VER)
		_vsnprintf_s(buffer, sizeof(buffer), _TRUNCATE, fmt, args);
#else
		vsnprintf(buffer, sizeof(buffer), fmt, args);
#endif
		va_end(args);

#if defined(ANDROID)
		__android_log_print(ANDROID_LOG_DEBUG, "MT3Diag", "%s", buffer);
#elif defined(WIN32) || defined(_WIN32)
		FILE* fp = NULL;
		if (fopen_s(&fp, "startup_bootstrap.log", "ab") == 0 && fp)
		{
			fputs("[MT3_DIAG] ", fp);
			fputs(buffer, fp);
			fputs("\r\n", fp);
			fclose(fp);
		}
#else
		fprintf(stderr, "%s\n", buffer);
#endif
	}
#define MT3_DIAG_SPINE_LOG(...) MT3SpineDiagTrace(__VA_ARGS__)
#else
#define MT3_DIAG_SPINE_LOG(...)
#endif

	SpineRes::SpineRes()
		: loaded(false)
	{
	}

	SpineRes::~SpineRes()
	{
	}

	class SpineReadTask : public NuclearFileIOManager::AsyncReadTask
	{
	public:
		struct DataImage
		{
			NuclearBuffer imageData;
			cocos2d::CCImage* pImage;
		};

		bool mCancel;

	private:
		std::wstring  mDir;
		std::wstring  mName;
		int64_t		  mTick;
		EngineBase*	  mpEngine;
		NuclearHardRef<SpineRes>     mpSpineRes;
		SpineManager* mpSpineMan;

		std::map<std::wstring, DataImage> mImageMap;

	public:
		SpineReadTask(const std::wstring& dir, const std::wstring& name, EngineBase *pEB, NuclearFileIOManager *pFileIOMan, NuclearHardRef<SpineRes> spineRes, SpineManager* spineMan)
			: NuclearFileIOManager::AsyncReadTask(pFileIOMan, L"", 0, false)
			, mDir(dir)
			, mName(name)
			, mpEngine(pEB)
			, mpSpineRes(spineRes)
			, mpSpineMan(spineMan)
		{
			mCancel = false;
			mTick = GetMilliSeconds();
		}

		virtual void Execute()
		{
			if (mCancel || mpSpineRes->loaded) return;

			Renderer* pRenderer = mpEngine->GetRenderer();

			// 加载 atlas 文件
			std::wstring pathAtlasFile = mDir + mName + L".atlas";
			mpSpineRes->mMutexForLoadingSpine.Lock();
			m_pFileIOMan->GetFileImage(pathAtlasFile, mpSpineRes->atlasBuffer, false);
			mpSpineRes->mMutexForLoadingSpine.UNLock();

			// 解出 atlas 引用的图片文件名
			spine::PathToTextureMap textureMap;
			std::string strDir = ws2s(mDir);
			spine::spAtlas_parseTextureMap((const char*)mpSpineRes->atlasBuffer.constbegin(), mpSpineRes->atlasBuffer.size(), strDir.c_str(), &textureMap);

			// 加载 atlas 引用的图片成 CCImage
			for (spine::PathToTextureMap::iterator it = textureMap.begin(); it != textureMap.end(); ++it)
			{
				const std::string& texturePath = it->first;

				Nuclear::NuclearPictureInfo picinfo;
				picinfo.fileuri = s2ws(texturePath);

				cocos2d::CCImage* pImage = NULL;
				NuclearBuffer imageData;
				if (m_pFileIOMan->GetFileImage(picinfo.fileuri, imageData))
				{
					pImage = new cocos2d::CCImage;
					if (!pRenderer->LoadCCImageFromMem(pImage, XPTEXFMT_DEFAULT, imageData.constbegin(), imageData.size()))
					{
						CC_SAFE_RELEASE_NULL(pImage);
					}
				}

				DataImage di = { imageData, pImage };
				mImageMap.insert(std::make_pair(picinfo.fileuri, di));
			}

			// 加载 json 文件
			std::wstring pathJsonFile = mDir + mName + L".json";
			mpSpineRes->mMutexForLoadingSpine.Lock();
			m_pFileIOMan->GetFileImage(pathJsonFile, mpSpineRes->jsonBuffer, false);
			mpSpineRes->mMutexForLoadingSpine.UNLock();
		}

		virtual void OnReady()
		{
			int64_t tick = GetMilliSeconds();

			int dataSize = getAllDataSize();
			if (mpSpineRes && dataSize > 0)
			{
				m_pFileIOMan->OnReady(int(tick - mTick), dataSize);  // 统计文件读取

				if (!mpSpineRes->loaded && !mCancel)
				{
					Renderer* pRenderer = mpEngine->GetRenderer();

					// 从 CCImage 或 imageData 创建贴图
					for (std::map<std::wstring, DataImage>::iterator it = mImageMap.begin(); it != mImageMap.end(); ++it)
					{
						DataImage& di = it->second;

						Nuclear::NuclearPictureInfo picinfo;
						picinfo.fileuri = it->first;

						PictureHandle picHandle = INVALID_PICTURE_HANDLE;
						if (di.pImage)
						{
							picHandle = pRenderer->LoadPictureFromCCImage(di.pImage, XPTEXFMT_DEFAULT, &picinfo);
							CC_SAFE_RELEASE_NULL(di.pImage);
						}
						else
						{
							picHandle = pRenderer->LoadPictureFromMem(di.imageData.constbegin(), di.imageData.size(), &picinfo);
						}

						mpSpineRes->mPicHandles.push_back(picHandle);
					}
					
					mpSpineRes->loaded = true;
				}

				for (LoadingSpineNotifySet::iterator sIt = mpSpineRes->notifys.begin(); sIt != mpSpineRes->notifys.end(); ++sIt)
				{
					SpineLoadingNotify* pItNotify = *sIt;
					if (!pItNotify->loaded)
					{
						pItNotify->OnLoaded(mDir, mpSpineRes.get());
						pItNotify->loaded = true;
					}
				}
			}
			mpSpineMan->NotifyFinish(mName);
			delete this;
		}

		virtual void OnDiscard()
		{
			delete this;
		}

		int getAllDataSize() const
		{
			int dataSize = 0;

			if (mpSpineRes)
			{
				dataSize += mpSpineRes->atlasBuffer.size();
				dataSize += mpSpineRes->jsonBuffer.size();

				for (std::map<std::wstring, DataImage>::const_iterator it = mImageMap.begin(); it != mImageMap.end(); ++it)
				{
					const DataImage& di = it->second;
					dataSize += di.imageData.size();
				}
			}
			
			return dataSize;
		}

		virtual ~SpineReadTask()
		{
			for (std::map<std::wstring, DataImage>::iterator it = mImageMap.begin(); it != mImageMap.end(); ++it)
			{
				DataImage& di = it->second;
				CC_SAFE_RELEASE_NULL(di.pImage);
			}
			mImageMap.clear();
		}
	};

	SpineResLoadingParam::SpineResLoadingParam(NuclearHardRef<SpineRes> res, SpineReadTask* task)
		: spineRes(res)
		, readTask(task)
	{

	}

	SpineResLoadingParam::~SpineResLoadingParam()
	{
		if (spineRes)
		{
			spineRes->loaded = true;
			//delete spineRes;
			spineRes = NuclearHardRef<SpineRes>();
		}
		if (readTask)
		{
			readTask->mCancel = true;
			readTask->Discard();
			readTask = NULL;
		}
	}

	SpineManager::SpineManager(EngineBase *pEB)
		: m_pEB(pEB)
	{
	}

	SpineManager::~SpineManager()
	{
		Destroy();
	}

	void SpineManager::Destroy()
	{
		MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=destroy loadingMap=%d", (int)m_SpineResLoadingMap.size());
		for (SpineResLoadintMap::iterator it = m_SpineResLoadingMap.begin(); it != m_SpineResLoadingMap.end(); ++it)
		{
			delete it->second;
		}
		m_SpineResLoadingMap.clear();
	}
	void SpineManager::NotifyFinish(const std::wstring &name)
	{
		SpineResLoadintMap::iterator it = m_SpineResLoadingMap.find(name);
		if (it != m_SpineResLoadingMap.end())
		{
			SpineResLoadingParam* param = it->second;
			param->readTask = NULL;
		}
	}
	bool SpineManager::ASyncLoadSpineRes(const std::wstring &name, const std::wstring& dir, SpineLoadingNotify* pNotify)
	{
		if (!pNotify) return false;

		pNotify->loaded = false;
		MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=async_load_begin loadingMap=%d", (int)m_SpineResLoadingMap.size());

		SpineResLoadintMap::iterator it = m_SpineResLoadingMap.find(name);
		if (it != m_SpineResLoadingMap.end())
		{
			SpineResLoadingParam* param = it->second;
			param->spineRes->notifys.insert(pNotify);
			MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=async_load_cache_hit loaded=%d notifys=%d pictures=%d",
				param->spineRes->loaded ? 1 : 0,
				(int)param->spineRes->notifys.size(),
				(int)param->spineRes->mPicHandles.size());

			if (param->spineRes->loaded)
			{
				pNotify->OnLoaded(dir, param->spineRes.get());
			}
			return true;
		}

		NuclearHardRef<SpineRes> spineRes(new SpineRes);
		spineRes->notifys.insert(pNotify);

		SpineReadTask* pTask = new SpineReadTask(dir, name, m_pEB, m_pEB->GetFileIOManager(), spineRes, this);
		if (pTask->Submit())
		{
			SpineResLoadingParam* param = new SpineResLoadingParam(spineRes, pTask);

			m_SpineResLoadingMap[name] = param;
			MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=async_load_submit result=1 loadingMap=%d notifys=%d",
				(int)m_SpineResLoadingMap.size(),
				(int)spineRes->notifys.size());

			return true;
		}
		else
		{
			delete pTask;
			MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=async_load_submit result=0 loadingMap=%d", (int)m_SpineResLoadingMap.size());
			return false;
		}

		return false;
	}

	bool SpineManager::SyncLoadSpineRes(const std::wstring &name, const std::wstring& dir, SpineLoadingNotify* pNotify)
	{
		if (name.empty() || !pNotify) return false;
		std::string traceName = ws2s(name);
		std::string traceDir = ws2s(dir);
		MT3_SPINE_MANAGER_TRACE("SyncLoad enter name=%s dir=%s notify=%p", traceName.c_str(), traceDir.c_str(), pNotify);

		NuclearFileIOManager *pFIOMan = m_pEB->GetFileIOManager();
		Renderer* pRenderer = m_pEB->GetRenderer();

		NuclearHardRef<SpineRes> spineRes = NuclearHardRef<SpineRes>();;
		pNotify->loaded = false;

		SpineResLoadintMap::iterator it = m_SpineResLoadingMap.find(name);
		if (it != m_SpineResLoadingMap.end())
		{
			spineRes = it->second->spineRes;
			spineRes->notifys.insert(pNotify);
			MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=sync_load_cache_hit loaded=%d notifys=%d pictures=%d",
				spineRes->loaded ? 1 : 0,
				(int)spineRes->notifys.size(),
				(int)spineRes->mPicHandles.size());
		}
		else
		{
			//spineRes = new SpineRes;
			spineRes = NuclearHardRef<SpineRes>(new SpineRes());
			spineRes->notifys.insert(pNotify);

			SpineResLoadingParam* param = new SpineResLoadingParam(spineRes, NULL);
			m_SpineResLoadingMap[name] = param;
			MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=sync_load_create loadingMap=%d", (int)m_SpineResLoadingMap.size());
		}

		if (spineRes)
		{
			if (!spineRes->loaded)
			{

				// 加载 atlas 文件
				std::wstring pathAtlasFile = dir + name + L".atlas";
				spineRes->mMutexForLoadingSpine.Lock();
				bool atlasLoaded = pFIOMan->GetFileImage(pathAtlasFile, spineRes->atlasBuffer, false);
				spineRes->mMutexForLoadingSpine.UNLock();
				MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=sync_atlas loaded=%d bytes=%d",
					atlasLoaded ? 1 : 0,
					(int)spineRes->atlasBuffer.size());
				MT3_SPINE_MANAGER_TRACE("SyncLoad atlas name=%s loaded=%d size=%d path=%s",
					traceName.c_str(),
					atlasLoaded ? 1 : 0,
					(int)spineRes->atlasBuffer.size(),
					ws2s(pathAtlasFile).c_str());

				// 解析 atlas 引用的图片文件名
				spine::PathToTextureMap textureMap;
				std::string strDir = ws2s(dir);
				MT3_SPINE_MANAGER_TRACE("SyncLoad before parseTextureMap name=%s atlasSize=%d", traceName.c_str(), (int)spineRes->atlasBuffer.size());
				spine::spAtlas_parseTextureMap((const char*)spineRes->atlasBuffer.constbegin(), spineRes->atlasBuffer.size(), strDir.c_str(), &textureMap);
				MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=sync_texture_map count=%d", (int)textureMap.size());
				MT3_SPINE_MANAGER_TRACE("SyncLoad after parseTextureMap name=%s textureCount=%d", traceName.c_str(), (int)textureMap.size());

				// 加载 atlas 引用的图片
				for (spine::PathToTextureMap::iterator it = textureMap.begin(); it != textureMap.end(); ++it)
				{
					const std::string& texturePath = it->first;

					Nuclear::NuclearPictureInfo picinfo;
					picinfo.fileuri = s2ws(texturePath);

					PictureHandle picHandle = INVALID_PICTURE_HANDLE;
					if (!pRenderer->GetPictureHandle(picHandle, picinfo.fileuri))
					{
						NuclearBuffer data;
						bool imageLoaded = pFIOMan->GetFileImage(picinfo.fileuri, data);
						MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=sync_image loaded=%d bytes=%d",
							imageLoaded ? 1 : 0,
							(int)data.size());
						MT3_SPINE_MANAGER_TRACE("SyncLoad image name=%s loaded=%d size=%d path=%s",
							traceName.c_str(),
							imageLoaded ? 1 : 0,
							(int)data.size(),
							texturePath.c_str());

						picHandle = pRenderer->LoadPictureFromMem(data.constbegin(), data.size(), &picinfo);
					}

					spineRes->mPicHandles.push_back(picHandle);
				}

				// 加载 json 文件
				std::wstring pathJsonFile = dir + name + L".json";
				spineRes->mMutexForLoadingSpine.Lock();
				bool jsonLoaded = pFIOMan->GetFileImage(pathJsonFile, spineRes->jsonBuffer, false);
				spineRes->mMutexForLoadingSpine.UNLock();
				MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=sync_json loaded=%d bytes=%d pictures=%d",
					jsonLoaded ? 1 : 0,
					(int)spineRes->jsonBuffer.size(),
					(int)spineRes->mPicHandles.size());
				MT3_SPINE_MANAGER_TRACE("SyncLoad json name=%s loaded=%d size=%d path=%s",
					traceName.c_str(),
					jsonLoaded ? 1 : 0,
					(int)spineRes->jsonBuffer.size(),
					ws2s(pathJsonFile).c_str());

				spineRes->loaded = true;
			}

			// 通知每一个监听器
			for (LoadingSpineNotifySet::iterator sIt = spineRes->notifys.begin(); sIt != spineRes->notifys.end(); ++sIt)
			{
				SpineLoadingNotify* pItNotify = *sIt;
				if (!pItNotify->loaded)
				{
					MT3_SPINE_MANAGER_TRACE("SyncLoad notify begin name=%s notify=%p", traceName.c_str(), pItNotify);
					pItNotify->OnLoaded(dir, spineRes.get());
					pItNotify->loaded = true;
					MT3_SPINE_MANAGER_TRACE("SyncLoad notify end name=%s notify=%p", traceName.c_str(), pItNotify);
				}
			}
		}

		return true;
	}

	void SpineManager::FreeSpineRes(const std::wstring& name, SpineLoadingNotify* pNotify)
	{
		SpineResLoadintMap::iterator it = m_SpineResLoadingMap.find(name);
		if (it != m_SpineResLoadingMap.end())
		{
			SpineResLoadingParam* param = it->second;
			MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=free_begin notifys=%d pictures=%d loadingMap=%d",
				(int)param->spineRes->notifys.size(),
				(int)param->spineRes->mPicHandles.size(),
				(int)m_SpineResLoadingMap.size());
			for (LoadingSpineNotifySet::iterator sIt = param->spineRes->notifys.begin(); sIt != param->spineRes->notifys.end(); ++sIt)
			{
				if (*sIt == pNotify)
				{
					param->spineRes->notifys.erase(sIt);
					break;
				}
			}

			if (param->spineRes->notifys.empty())
			{
				int freePictures = 0;
				for (SpineRes::PictureHandleArray::iterator itHFPair = param->spineRes->mPicHandles.begin(); itHFPair != param->spineRes->mPicHandles.end(); ++itHFPair)
				{
					PictureHandle& picHandle = *itHFPair;
					if (picHandle != INVALID_PICTURE_HANDLE)
					{
						m_pEB->GetRenderer()->FreePicture(picHandle);
						picHandle = INVALID_PICTURE_HANDLE;
						++freePictures;
					}
				}

				delete param;
				m_SpineResLoadingMap.erase(it);
				MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=free_release pictures=%d loadingMap=%d",
					freePictures,
					(int)m_SpineResLoadingMap.size());
			}
		}
		else
		{
			MT3_DIAG_SPINE_LOG("MT3_DIAG_SPINE event=free_miss loadingMap=%d", (int)m_SpineResLoadingMap.size());
		}
	}
}
