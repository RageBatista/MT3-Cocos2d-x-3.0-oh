#include "VideoEngineJni.h"

#include "JniHelper.h"
#include "cocoa/CCString.h"

#include <android/log.h>
#include <jni.h>

#define  LOG_TAG    "VideoEngineJni"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;

static const char* CLASS_NAME = "org/cocos2dx/lib/Cocos2dxVideoHelper";

static bool CheckAndClearException(JNIEnv* env, const char* callName)
{
	if (env && env->ExceptionCheck())
	{
		env->ExceptionDescribe();
		env->ExceptionClear();
		LOGD("%s failed with a Java exception", callName);
		return true;
	}
	return false;
}

extern "C"
{
	void createVideoActivityJni()
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "createVideoActivity", "()V"))
		{
			LOGD("createVideoActivityJni");
			t.env->CallStaticVoidMethod(t.classID, t.methodID);
			CheckAndClearException(t.env, "createVideoActivity");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void destroyVideoActivityJni()
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "destroyVideoActivity", "()V"))
		{
			LOGD("destroyVideoActivityJni");
			t.env->CallStaticVoidMethod(t.classID, t.methodID);
			CheckAndClearException(t.env, "destroyVideoActivity");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	int createVideoWidgetJNI()
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "createVideoWidget", "()I"))
		{
			jint index = t.env->CallStaticIntMethod(t.classID, t.methodID);
			if (CheckAndClearException(t.env, "createVideoWidget"))
			{
				index = -1;
			}
			LOGD("createVideoWidgetJNI index=%d", index);

			t.env->DeleteLocalRef(t.classID);

			return index;
		}

		return -1;
	}

	void removeVideoWidgetJNI(int index)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "removeVideoWidget", "(I)V"))
		{
			LOGD("removeVideoWidgetJNI index=%d", index);
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index);
			CheckAndClearException(t.env, "removeVideoWidget");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void setVideoURLJNI(int index, int sourceType, const char* szUrl)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setVideoUrl", "(IILjava/lang/String;)V"))
		{
			jstring jsUrl = t.env->NewStringUTF(szUrl);

			LOGD("setVideoURLJNI index=%d source=%d url=%s", index, sourceType, szUrl ? szUrl : "");
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index, sourceType, jsUrl);
			CheckAndClearException(t.env, "setVideoUrl");

			t.env->DeleteLocalRef(jsUrl);
			t.env->DeleteLocalRef(t.classID);
		}
	}

	void startVideoJNI(int index)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "startVideo", "(I)V"))
		{
			LOGD("startVideoJNI index=%d", index);
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index);
			CheckAndClearException(t.env, "startVideo");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void pauseVideoJNI(int index)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "pauseVideo", "(I)V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index);
			CheckAndClearException(t.env, "pauseVideo");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void resumeVideoJNI(int index)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "resumeVideo", "(I)V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index);
			CheckAndClearException(t.env, "resumeVideo");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void stopVideoJNI(int index)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "stopVideo", "(I)V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index);
			CheckAndClearException(t.env, "stopVideo");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void seekVideoToJNI(int index, int pos)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "seekVideoTo", "(II)V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index, pos);
			CheckAndClearException(t.env, "seekVideoTo");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void setVideoRectJNI(int index, int x, int y, int width, int height)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setVideoRect", "(IIIII)V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index, x, y, width, height);
			CheckAndClearException(t.env, "setVideoRect");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void setVideoVisibleJni(int index, bool bVisible)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setVideoVisible", "(IZ)V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index, bVisible);
			CheckAndClearException(t.env, "setVideoVisible");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void setVideoKeepRatioEnabledJni(int index, bool bEnable)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setVideoKeepRatioEnabled", "(IZ)V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index, bEnable);
			CheckAndClearException(t.env, "setVideoKeepRatioEnabled");

			t.env->DeleteLocalRef(t.classID);
		}
	}

	void setFullScreenEnabledJni(int index, bool bEnable, int width, int height)
	{
		JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setFullScreenEnabled", "(IZII)V"))
		{
			t.env->CallStaticVoidMethod(t.classID, t.methodID, index, bEnable, width, height);
			CheckAndClearException(t.env, "setFullScreenEnabled");

			t.env->DeleteLocalRef(t.classID);
		}
	}
}
