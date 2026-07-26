//#include "../common/ljfmutil.h"
#include "nucocos2d_render.h"
#include <stdio.h>
#include <stdarg.h>

namespace Nuclear
{
	const float Renderer::Z = 0.5f;

	static void RndTrace(const char* fmt, ...)
	{
		FILE* fp = NULL;
		if (fopen_s(&fp, "startup_bootstrap.log", "ab") != 0 || !fp) return;
		fputs("[MT3_RNDR] ", fp);
		va_list args;
		va_start(args, fmt);
		vfprintf(fp, fmt, args);
		va_end(args);
		fputs("\r\n", fp);
		fclose(fp);
	}

	PictureHandle Renderer::LoadPictureFromNativePath(const std::string &nativepath)
	{
		Nuclear::FileBuffer fb(nativepath.c_str());
		
        int size = fb.Size();
		if( size == 0 ) 
        {
            return INVALID_PICTURE_HANDLE;
        }        
        
		return LoadPictureFromMem(fb.Begin(), size);
	}

	// 创建函数
	XPCREATE_RENDERER_RESULT CreateRenderer(Renderer **ppr, const NuclearDisplayMode &dmode, NuclearFileIOManager *pFileIOMan,DWORD flags, XPRENDERER_VERSION rv, NuclearMultiSampleType mstype)
	{
		RndTrace("CreateRenderer enter ppr=%p dmode=%dx%d flags=%u rv=%d mstype=%d",
			ppr, dmode.width, dmode.height, flags, (int)rv, (int)mstype);
		if( ppr == NULL ) 
			return XPCRR_NULL_POINTER;
		*ppr = NULL;
		switch( rv )
		{		
		case XPRV_DEFAULT:
			assert(false && "default renderer is not supported");
			break;
        case XPRV_COCOS2D:
			RndTrace("CreateRenderer before new Cocos2dRenderer pFileIOMan=%p", pFileIOMan);
            *ppr = new Cocos2dRenderer(pFileIOMan);
			RndTrace("CreateRenderer after new Cocos2dRenderer *ppr=%p", *ppr);
            break;
		default:
			break;
		}
		if( *ppr == NULL ) 
			return XPCRR_NULL_POINTER;
		RndTrace("CreateRenderer before (*ppr)->Create");
		XPCREATE_RENDERER_RESULT result = (*ppr)->Create(dmode, flags, mstype);
		RndTrace("CreateRenderer after (*ppr)->Create result=%d", (int)result);

		if( result != XPCRR_OK )
		{
			(*ppr)->Destroy();
			delete *ppr;
			*ppr = NULL;
		}
		return result;
	}

	// 销毁函数
	void DestroyRenderer(Renderer *r)
	{ 
		if( r != NULL ) 
		{
			r->Destroy();
			delete r;
		}
	}

};
