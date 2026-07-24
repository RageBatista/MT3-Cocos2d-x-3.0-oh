#ifndef _PhotoPicker_h_
#define _PhotoPicker_h_

#include <string>
#include "cocoa/CCArray.h"
#include "CCImage.h"
#include "script_support/CCScriptSupport.h"

NS_CC_BEGIN

class PhotoPicker
{
protected:
    std::string mOnSelectedCallback;
    std::string mOnCancelCallback;
    CCArray mSelectedPhotos;

public:
    PhotoPicker()
    {
    }

    virtual ~PhotoPicker()
    {
        releaseSelectedPhotos();
    }

    static PhotoPicker* shared()
    {
        static PhotoPicker sInstance;
        return &sInstance;
    }

    virtual bool openCamera()
    {
        return false;
    }

    virtual bool openAlbum()
    {
        return false;
    }

    void setOnSelectedCallback(const char* szScript)
    {
        mOnSelectedCallback = szScript ? szScript : "";
    }

    void setOnCancelCallback(const char* szScript)
    {
        mOnCancelCallback = szScript ? szScript : "";
    }

    virtual int getSelectedPhotoCount()
    {
        return mSelectedPhotos.count();
    }

    virtual cocos2d::CCImage* getSelectedPhoto(int index)
    {
        return dynamic_cast<cocos2d::CCImage*>(mSelectedPhotos.objectAtIndex(index));
    }

    virtual void releaseSelectedPhotos()
    {
        mSelectedPhotos.removeAllObjects();
    }

    virtual void addSelectedPhoto(CCImage* pImg)
    {
        if (pImg)
        {
            mSelectedPhotos.addObject(pImg);
        }
    }

    void onSelected()
    {
        if (!mOnSelectedCallback.empty())
        {
            CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction(mOnSelectedCallback.c_str());
        }
    }

    void onCancel()
    {
        if (!mOnCancelCallback.empty())
        {
            CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunction(mOnCancelCallback.c_str());
        }
    }

    void update(float /*dt*/)
    {
    }
};

NS_CC_END

#endif // _PhotoPicker_h_