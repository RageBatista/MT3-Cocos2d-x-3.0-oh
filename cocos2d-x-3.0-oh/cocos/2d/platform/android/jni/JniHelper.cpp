/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2013-2014 Chukong Technologies Inc.

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
#include <algorithm>
#include <android/log.h>
#include <string.h>
#include <pthread.h>

#define  LOG_TAG    "JniHelper"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

static pthread_key_t g_key;
static pthread_once_t g_keyOnce = PTHREAD_ONCE_INIT;

static void detachCurrentThread(void*) {
    JavaVM* javaVM = cocos2d::JniHelper::getJavaVM();
    if (javaVM) {
        javaVM->DetachCurrentThread();
    }
}

static void createThreadKey() {
    pthread_key_create(&g_key, detachCurrentThread);
}

jclass _getClassID(const char *className) {
    if (NULL == className) {
        return NULL;
    }

    JNIEnv* env = cocos2d::JniHelper::getEnv();

    jclass _clazz = env->FindClass(className);
    if (_clazz) {
        return _clazz;
    }
    if (env->ExceptionCheck()) {
        env->ExceptionClear();
    }

    if (!cocos2d::JniHelper::classloader || !cocos2d::JniHelper::loadclassMethod_methodID) {
        return NULL;
    }

    std::string loaderClassName(className);
    std::replace(loaderClassName.begin(), loaderClassName.end(), '/', '.');
    jstring _jstrClassName = env->NewStringUTF(loaderClassName.c_str());

    _clazz = (jclass) env->CallObjectMethod(cocos2d::JniHelper::classloader,
                                            cocos2d::JniHelper::loadclassMethod_methodID,
                                            _jstrClassName);
    if (env->ExceptionCheck()) {
        env->ExceptionClear();
        _clazz = NULL;
    }

    if (NULL == _clazz) {
        LOGD("Classloader failed to find class of %s", className);
    }

    env->DeleteLocalRef(_jstrClassName);
        
    return _clazz;
}

namespace cocos2d {

    JavaVM* JniHelper::_psJavaVM = NULL;
    jmethodID JniHelper::loadclassMethod_methodID = NULL;
    jobject JniHelper::classloader = NULL;

    JavaVM* JniHelper::getJavaVM() {
        pthread_t thisthread = pthread_self();
        LOGD("JniHelper::getJavaVM(), pthread_self() = %ld", thisthread);
        return _psJavaVM;
    }

    void JniHelper::setJavaVM(JavaVM *javaVM) {
        pthread_t thisthread = pthread_self();
        LOGD("JniHelper::setJavaVM(%p), pthread_self() = %ld", javaVM, thisthread);
        _psJavaVM = javaVM;

        pthread_once(&g_keyOnce, createThreadKey);
    }

    JNIEnv* JniHelper::cacheEnv(JavaVM* jvm) {
        JNIEnv* _env = NULL;
        // get jni environment
        if (!jvm) {
            return NULL;
        }
        jint ret = jvm->GetEnv((void**)&_env, JNI_VERSION_1_6);
        
        switch (ret) {
        case JNI_OK :
            // Success!
            return _env;
                
        case JNI_EDETACHED :
            // Thread not attached
                
            if (jvm->AttachCurrentThread(&_env, NULL) < 0)
                {
                    LOGD("Failed to get the environment using AttachCurrentThread()");

                    return NULL;
                } else {
                // Success : Attached and obtained JNIEnv!
                pthread_setspecific(g_key, _env);
                return _env;
            }
                
        case JNI_EVERSION :
            // Cannot recover from this error
            LOGD("JNI interface version 1.6 not supported");
        default :
            LOGD("Failed to get the environment using GetEnv()");
            return NULL;
        }
    }

    JNIEnv* JniHelper::getEnv() {
        pthread_once(&g_keyOnce, createThreadKey);
        JNIEnv *_env = (JNIEnv *)pthread_getspecific(g_key);
        if (_env == NULL)
            _env = JniHelper::cacheEnv(_psJavaVM);
        return _env;
    }

    bool JniHelper::setClassLoaderFrom(jobject activityinstance) {
        if (!activityinstance) {
            return false;
        }
        JniMethodInfo _getclassloaderMethod;
        if (!JniHelper::getMethodInfo_DefaultClassLoader(_getclassloaderMethod,
                                                         "android/content/Context",
                                                         "getClassLoader",
                                                         "()Ljava/lang/ClassLoader;")) {
            return false;
        }

        jobject _c = cocos2d::JniHelper::getEnv()->CallObjectMethod(activityinstance,
                                                                    _getclassloaderMethod.methodID);

        if (NULL == _c) {
            return false;
        }

        JniMethodInfo _m;
        if (!JniHelper::getMethodInfo_DefaultClassLoader(_m,
                                                         "java/lang/ClassLoader",
                                                         "loadClass",
                                                         "(Ljava/lang/String;)Ljava/lang/Class;")) {
            return false;
        }

        JNIEnv* env = cocos2d::JniHelper::getEnv();
        if (JniHelper::classloader) {
            env->DeleteGlobalRef(JniHelper::classloader);
        }
        JniHelper::classloader = env->NewGlobalRef(_c);
        JniHelper::loadclassMethod_methodID = _m.methodID;

        env->DeleteLocalRef(_m.classID);
        env->DeleteLocalRef(_c);
        env->DeleteLocalRef(_getclassloaderMethod.classID);

        return true;
    }

    bool JniHelper::getStaticMethodInfo(JniMethodInfo &methodinfo,
                                        const char *className, 
                                        const char *methodName,
                                        const char *paramCode) {
        if ((NULL == className) ||
            (NULL == methodName) ||
            (NULL == paramCode)) {
            return false;
        }

        JNIEnv *pEnv = JniHelper::getEnv();
        if (!pEnv) {
            LOGD("Failed to get JNIEnv");
            return false;
        }
            
        jclass classID = _getClassID(className);
        if (! classID) {
            LOGD("Failed to find class %s", className);
            return false;
        }

        jmethodID methodID = pEnv->GetStaticMethodID(classID, methodName, paramCode);
        if (! methodID) {
            LOGD("Failed to find static method id of %s", methodName);
            return false;
        }
            
        methodinfo.classID = classID;
        methodinfo.env = pEnv;
        methodinfo.methodID = methodID;
        return true;
    }

    bool JniHelper::getMethodInfo_DefaultClassLoader(JniMethodInfo &methodinfo,
                                                     const char *className,
                                                     const char *methodName,
                                                     const char *paramCode) {
        if ((NULL == className) ||
            (NULL == methodName) ||
            (NULL == paramCode)) {
            return false;
        }

        JNIEnv *pEnv = JniHelper::getEnv();
        if (!pEnv) {
            return false;
        }

        jclass classID = pEnv->FindClass(className);
        if (! classID) {
            LOGD("Failed to find class %s", className);
            return false;
        }

        jmethodID methodID = pEnv->GetMethodID(classID, methodName, paramCode);
        if (! methodID) {
            LOGD("Failed to find method id of %s", methodName);
            return false;
        }

        methodinfo.classID = classID;
        methodinfo.env = pEnv;
        methodinfo.methodID = methodID;

        return true;
    }

    bool JniHelper::getMethodInfo(JniMethodInfo &methodinfo,
                                  const char *className,
                                  const char *methodName,
                                  const char *paramCode) {
        if ((NULL == className) ||
            (NULL == methodName) ||
            (NULL == paramCode)) {
            return false;
        }

        JNIEnv *pEnv = JniHelper::getEnv();
        if (!pEnv) {
            return false;
        }

        jclass classID = _getClassID(className);
        if (! classID) {
            LOGD("Failed to find class %s", className);
            pEnv->ExceptionClear();
            return false;
        }

        jmethodID methodID = pEnv->GetMethodID(classID, methodName, paramCode);
        if (! methodID) {
            LOGD("Failed to find method id of %s", methodName);
            pEnv->ExceptionClear();
            return false;
        }

        methodinfo.classID = classID;
        methodinfo.env = pEnv;
        methodinfo.methodID = methodID;

        return true;
    }

    std::string JniHelper::jstring2string(jstring jstr) {
        if (jstr == NULL) {
            return "";
        }
        
        JNIEnv *pEnv = JniHelper::getEnv();
        if (!pEnv) {
            return "";
        }

        const char* chars = pEnv->GetStringUTFChars(jstr, NULL);
        std::string ret(chars);
        pEnv->ReleaseStringUTFChars(jstr, chars);

        return ret;
    }

} //namespace cocos2d
