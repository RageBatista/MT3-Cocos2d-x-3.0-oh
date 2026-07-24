/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "JniHelper.h"
#include <android/log.h>
#include <pthread.h>
#include <string.h>

#if 1
#define  LOG_TAG    "JniHelper"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#else
#define  LOGD(...) 
#endif

#define JAVAVM    cocos2d::JniHelper::getJavaVM()

using namespace std;

extern "C"
{

    //////////////////////////////////////////////////////////////////////////
    // java vm helper function
    //////////////////////////////////////////////////////////////////////////

    static pthread_key_t s_threadKey;
    static pthread_once_t s_threadKeyOnce = PTHREAD_ONCE_INIT;
    static jobject s_classLoader = NULL;
    static jmethodID s_loadClassMethod = NULL;

    static void detach_current_thread (void *env) {
        (void)env;
        if (JAVAVM)
        {
            JAVAVM->DetachCurrentThread();
        }
    }

    static void make_thread_key()
    {
        pthread_key_create(&s_threadKey, detach_current_thread);
    }
    
    static bool getEnv(JNIEnv **env)
    {
        bool bRet = false;
        JavaVM *javaVM = JAVAVM;
        if (! javaVM)
        {
            LOGD("%s", "JavaVM is not initialized");
            return false;
        }

        switch(javaVM->GetEnv((void**)env, JNI_VERSION_1_6))
        {
        case JNI_OK:
            bRet = true;
            break;
        case JNI_EDETACHED:
            pthread_once(&s_threadKeyOnce, make_thread_key);
            if (javaVM->AttachCurrentThread(env, 0) < 0)
            {
                LOGD("%s", "Failed to get the environment using AttachCurrentThread()");
                break;
            }
            if (pthread_getspecific(s_threadKey) == NULL)
            {
                pthread_setspecific(s_threadKey, *env);
            }
            bRet = true;
            break;
        default:
            LOGD("%s", "Failed to get the environment using GetEnv()");
            break;
        }      

        return bRet;
    }

    static jclass getClassID_(const char *className, JNIEnv *env)
    {
        JNIEnv *pEnv = env;
        jclass ret = 0;

        do 
        {
            if (! pEnv)
            {
                if (! getEnv(&pEnv))
                {
                    break;
                }
            }
            
            ret = pEnv->FindClass(className);
            if (! ret && pEnv->ExceptionCheck())
            {
                pEnv->ExceptionClear();
            }
            if (! ret && s_classLoader && s_loadClassMethod)
            {
                string loaderClassName(className);
                for (string::iterator it = loaderClassName.begin(); it != loaderClassName.end(); ++it)
                {
                    if (*it == '/')
                    {
                        *it = '.';
                    }
                }

                jstring strClassName = pEnv->NewStringUTF(loaderClassName.c_str());
                if (strClassName)
                {
                    ret = (jclass)pEnv->CallObjectMethod(s_classLoader, s_loadClassMethod, strClassName);
                    pEnv->DeleteLocalRef(strClassName);
                    if (pEnv->ExceptionCheck())
                    {
                        pEnv->ExceptionClear();
                        ret = 0;
                    }
                }
            }
            if (! ret)
            {
                LOGD("Failed to find class of %s", className);
                break;
            }
        } while (0);

        return ret;
    }

    static bool getStaticMethodInfo_(cocos2d::JniMethodInfo &methodinfo, const char *className, const char *methodName, const char *paramCode)
    {
        jmethodID methodID = 0;
        JNIEnv *pEnv = 0;
        bool bRet = false;

        do 
        {
            if (! getEnv(&pEnv))
            {
                break;
            }

            jclass classID = getClassID_(className, pEnv);

            if (! classID)
            {
                break;
            }

            methodID = pEnv->GetStaticMethodID(classID, methodName, paramCode);
            if (! methodID)
            {
                if (pEnv->ExceptionCheck())
                {
                    pEnv->ExceptionClear();
                }
                pEnv->DeleteLocalRef(classID);
                LOGD("Failed to find static method id of %s", methodName);
                break;
            }

            methodinfo.classID = classID;
            methodinfo.env = pEnv;
            methodinfo.methodID = methodID;

            bRet = true;
        } while (0);

        return bRet;
    }

    static bool getMethodInfo_(cocos2d::JniMethodInfo &methodinfo, const char *className, const char *methodName, const char *paramCode)
    {
        jmethodID methodID = 0;
        JNIEnv *pEnv = 0;
        bool bRet = false;

        do 
        {
            if (! getEnv(&pEnv))
            {
                break;
            }

            jclass classID = getClassID_(className, pEnv);

            if (! classID)
            {
                break;
            }

            methodID = pEnv->GetMethodID(classID, methodName, paramCode);
            if (! methodID)
            {
                if (pEnv->ExceptionCheck())
                {
                    pEnv->ExceptionClear();
                }
                pEnv->DeleteLocalRef(classID);
                LOGD("Failed to find method id of %s", methodName);
                break;
            }

            methodinfo.classID = classID;
            methodinfo.env = pEnv;
            methodinfo.methodID = methodID;

            bRet = true;
        } while (0);

        return bRet;
    }

    static string jstring2string_(jstring jstr)
    {
        if (jstr == NULL)
        {
            return "";
        }
        
        JNIEnv *env = 0;

        if (! getEnv(&env))
        {
            return "";
        }

        const char* chars = env->GetStringUTFChars(jstr, NULL);
        if (! chars)
        {
            return "";
        }
        string ret(chars);
        env->ReleaseStringUTFChars(jstr, chars);

        return ret;
    }
}

NS_CC_BEGIN

JavaVM* JniHelper::m_psJavaVM = NULL;

JavaVM* JniHelper::getJavaVM()
{
    return m_psJavaVM;
}

void JniHelper::setJavaVM(JavaVM *javaVM)
{
    m_psJavaVM = javaVM;
}

void JniHelper::setClassLoaderFrom(jobject activity)
{
    if (! activity)
    {
        return;
    }

    JNIEnv *env = 0;
    if (! getEnv(&env))
    {
        return;
    }

    jclass activityClass = env->GetObjectClass(activity);
    if (! activityClass)
    {
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
        return;
    }

    jmethodID getClassLoader = env->GetMethodID(activityClass, "getClassLoader", "()Ljava/lang/ClassLoader;");
    if (! getClassLoader)
    {
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
        env->DeleteLocalRef(activityClass);
        return;
    }

    jobject classLoader = env->CallObjectMethod(activity, getClassLoader);
    if (env->ExceptionCheck())
    {
        env->ExceptionClear();
        classLoader = NULL;
    }
    if (! classLoader)
    {
        env->DeleteLocalRef(activityClass);
        return;
    }

    jclass classLoaderClass = env->GetObjectClass(classLoader);
    if (! classLoaderClass)
    {
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
        env->DeleteLocalRef(classLoader);
        env->DeleteLocalRef(activityClass);
        return;
    }

    jmethodID loadClass = env->GetMethodID(classLoaderClass, "loadClass", "(Ljava/lang/String;)Ljava/lang/Class;");
    if (! loadClass)
    {
        if (env->ExceptionCheck())
        {
            env->ExceptionClear();
        }
        env->DeleteLocalRef(classLoaderClass);
        env->DeleteLocalRef(classLoader);
        env->DeleteLocalRef(activityClass);
        return;
    }

    if (s_classLoader)
    {
        env->DeleteGlobalRef(s_classLoader);
    }
    s_classLoader = env->NewGlobalRef(classLoader);
    s_loadClassMethod = s_classLoader ? loadClass : NULL;

    env->DeleteLocalRef(classLoaderClass);
    env->DeleteLocalRef(classLoader);
    env->DeleteLocalRef(activityClass);
}

jclass JniHelper::getClassID(const char *className, JNIEnv *env)
{
    return getClassID_(className, env);
}

bool JniHelper::getStaticMethodInfo(JniMethodInfo &methodinfo, const char *className, const char *methodName, const char *paramCode)
{
    return getStaticMethodInfo_(methodinfo, className, methodName, paramCode);
}

bool JniHelper::getMethodInfo(JniMethodInfo &methodinfo, const char *className, const char *methodName, const char *paramCode)
{
    return getMethodInfo_(methodinfo, className, methodName, paramCode);
}

string JniHelper::jstring2string(jstring str)
{
    return jstring2string_(str);
}

NS_CC_END
