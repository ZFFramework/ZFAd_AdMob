#include "ZFImpl_sys_Android_ZFAd_AdMob.h"
#include "ZFAd/protocol/ZFProtocolZFAdForSplash.h"

// #define _ZFP_ZFImpl_sys_Android_ZFAdForSplash_DEBUG 1

#if ZF_ENV_sys_Android
ZF_NAMESPACE_GLOBAL_BEGIN

#define ZFImpl_sys_Android_JNI_ID_ZFAdForSplash ZFImpl_sys_Android_JNI_ID(ZFAd_1impl_ZFAdForSplash)
#define ZFImpl_sys_Android_JNI_NAME_ZFAdForSplash ZFImpl_sys_Android_JNI_NAME(ZFAd_AdMob.ZFAdForSplash)
ZFImpl_sys_Android_jclass_DEFINE(ZFImpl_sys_Android_jclassZFAdForSplash, ZFImpl_sys_Android_JNI_NAME_ZFAdForSplash)

ZFPROTOCOL_IMPLEMENTATION_BEGIN(ZFAdForSplash_sys_Android, ZFAdForSplash, v_ZFProtocolLevel::e_SystemNormal)
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_HINT("Android:Activity")
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_BEGIN()
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_ITEM(ZFUIView, "Android:View")
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_ITEM(ZFUIRootWindow, "Android:Activity")
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_END()

public:
    zfoverride
    virtual void *nativeAdCreate(ZF_IN ZFAdForSplash *ad) {
        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForSplash(), "native_nativeAdCreate",
            JNIGetMethodSig(JNIType::S_object_Object(), JNIParamTypeContainer()
                .add(JNIPointerJNIType)
            ).c_str());
        jobject tmp = JNIUtilCallStaticObjectMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForSplash(), jmId
                , JNIConvertZFObjectToJNIType(jniEnv, ad)
                );
        jobject ret = JNIUtilNewGlobalRef(jniEnv, tmp);
        JNIUtilDeleteLocalRef(jniEnv, tmp);
        return ret;
    }
    zfoverride
    virtual void nativeAdDestroy(ZF_IN ZFAdForSplash *ad) {
        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForSplash(), "native_nativeAdDestroy",
            JNIGetMethodSig(JNIType::S_void(), JNIParamTypeContainer()
                .add(JNIType::S_object_Object())
            ).c_str());
        JNIUtilCallStaticVoidMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForSplash(), jmId
                , (jobject)ad->nativeAd()
                );
        JNIUtilDeleteGlobalRef(jniEnv, (jobject)ad->nativeAd());
    }

    zfoverride
    virtual void nativeAdUpdate(ZF_IN ZFAdForSplash *ad) {
        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForSplash(), "native_nativeAdUpdate",
            JNIGetMethodSig(JNIType::S_void(), JNIParamTypeContainer()
                .add(JNIType::S_object_Object())
                .add(JNIType::S_object_String())
                .add(JNIType::S_object_String())
            ).c_str());
        JNIUtilCallStaticVoidMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForSplash(), jmId
                , (jobject)ad->nativeAd()
                , (jobject)ZFImpl_sys_Android_zfstringToString(ad->appId())
                , (jobject)ZFImpl_sys_Android_zfstringToString(ad->adId())
                );
    }

    zfoverride
    virtual void nativeAdStart(
            ZF_IN ZFAdForSplash *ad
            , ZF_IN ZFUIRootWindow *window
            ) {
        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForSplash(), "native_nativeAdStart",
            JNIGetMethodSig(JNIType::S_void(), JNIParamTypeContainer()
                .add(JNIType::S_object_Object())
                .add(JNIType::S_object_Object())
            ).c_str());
        JNIUtilCallStaticVoidMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForSplash(), jmId
                , (jobject)ad->nativeAd()
                , (jobject)window->nativeWindow()
                );
    }
ZFPROTOCOL_IMPLEMENTATION_END(ZFAdForSplash_sys_Android)

ZF_NAMESPACE_GLOBAL_END

// ============================================================
JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForSplash
        , void, native_1notifyAdOnError
        , JNIPointer zfjniPointerOwnerZFAd
        , jstring errorHint
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onError: %s", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd), ZFImpl_sys_Android_zfstringFromString(errorHint));
#endif
    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnError(
            JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd)
            , ZFImpl_sys_Android_zfstringFromString(errorHint)
            );
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForSplash
        , void, native_1notifyAdOnDisplay
        , JNIPointer zfjniPointerOwnerZFAd
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onDisplay", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd));
#endif
    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnDisplay(
            JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd)
            );
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForSplash
        , void, native_1notifyAdOnClick
        , JNIPointer zfjniPointerOwnerZFAd
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onClick", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd));
#endif
    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnClick(
            JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd)
            );
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForSplash
        , void, native_1notifyAdOnStop
        , JNIPointer zfjniPointerOwnerZFAd
        , jint resultType
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onStop", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd), (ZFResultType)resultType);
#endif
    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnStop(
            JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd)
            , (ZFResultType)resultType
            );
}
JNI_METHOD_DECLARE_END()

#endif // #if ZF_ENV_sys_Android

