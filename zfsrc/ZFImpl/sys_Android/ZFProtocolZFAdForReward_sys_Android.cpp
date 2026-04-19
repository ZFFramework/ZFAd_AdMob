#include "ZFImpl_sys_Android_ZFAd_AdMob.h"
#include "ZFAd/protocol/ZFProtocolZFAdForReward.h"

// #define _ZFP_ZFImpl_sys_Android_ZFAdForReward_DEBUG 1

#if ZF_ENV_sys_Android
ZF_NAMESPACE_GLOBAL_BEGIN

#define ZFImpl_sys_Android_JNI_ID_ZFAdForReward ZFImpl_sys_Android_JNI_ID(ZFAd_1AdMob_ZFAdForReward)
#define ZFImpl_sys_Android_JNI_NAME_ZFAdForReward ZFImpl_sys_Android_JNI_NAME(ZFAd_AdMob.ZFAdForReward)
ZFImpl_sys_Android_jclass_DEFINE(ZFImpl_sys_Android_jclassZFAdForReward, ZFImpl_sys_Android_JNI_NAME_ZFAdForReward)

zfclass ZFAdForRewardImpl_AdMob : zfextend ZFObject, zfimplement ZFAdForRewardImpl {
    ZFOBJECT_DECLARE(ZFAdForRewardImpl_AdMob, ZFObject)
    ZFIMPLEMENT_DECLARE(ZFAdForRewardImpl)

public:
    zfoverride
    virtual void *nativeAdCreate(
            ZF_IN ZFAdForReward *ad
            , ZF_IN const zfstring &appId
            , ZF_IN const zfstring &adId
            ) {
        if(zffalse
                || ZFProtocolTryAccess("ZFUIView", "Android:View") == zfnull
                || ZFProtocolTryAccess("ZFUIRootWindow", "Android:Activity") == zfnull
                ) {
            return zfnull;
        }

        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), "native_nativeAdCreate",
            JNIGetMethodSig(JNIType::S_object_Object(), JNIParamTypeContainer()
                .add(JNIPointerJNIType)
                .add(JNIType::S_object_String())
                .add(JNIType::S_object_String())
            ).c_str());
        jobject tmp = JNIUtilCallStaticObjectMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), jmId
                , JNIConvertZFObjectToJNIType(jniEnv, ad)
                , ZFImpl_sys_Android_zfstringToString(appId)
                , ZFImpl_sys_Android_zfstringToString(adId)
                );
        jobject ret = JNIUtilNewGlobalRef(jniEnv, tmp);
        JNIUtilDeleteLocalRef(jniEnv, tmp);
        return ret;
    }
    zfoverride
    virtual void nativeAdDestroy(ZF_IN ZFAdForReward *ad) {
        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), "native_nativeAdDestroy",
            JNIGetMethodSig(JNIType::S_void(), JNIParamTypeContainer()
                .add(JNIType::S_object_Object())
            ).c_str());
        JNIUtilCallStaticVoidMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), jmId
                , (jobject)ad->nativeAd()
                );
        JNIUtilDeleteGlobalRef(jniEnv, (jobject)ad->nativeAd());
    }

    zfoverride
    virtual void nativeAdLoad(ZF_IN ZFAdForReward *ad) {
        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), "native_nativeAdLoad",
            JNIGetMethodSig(JNIType::S_void(), JNIParamTypeContainer()
                .add(JNIType::S_object_Object())
                .add(JNIType::S_object_Object())
            ).c_str());
        JNIUtilCallStaticVoidMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), jmId
                , (jobject)ad->nativeAd()
                , (jobject)ad->window()->nativeWindow()
                );
    }
    zfoverride
    virtual zfbool nativeAdLoaded(ZF_IN ZFAdForReward *ad) {
        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), "native_nativeAdLoaded",
            JNIGetMethodSig(JNIType::S_boolean(), JNIParamTypeContainer()
                .add(JNIType::S_object_Object())
            ).c_str());
        return (zfbool)JNIUtilCallStaticBooleanMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), jmId
            , (jobject)ad->nativeAd()
            );
    }

    zfoverride
    virtual void nativeAdStart(ZF_IN ZFAdForReward *ad) {
        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), "native_nativeAdStart",
            JNIGetMethodSig(JNIType::S_void(), JNIParamTypeContainer()
                .add(JNIType::S_object_Object())
                .add(JNIType::S_object_Object())
            ).c_str());
        JNIUtilCallStaticVoidMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForReward(), jmId
                , (jobject)ad->nativeAd()
                , (jobject)ad->window()->nativeWindow()
                );
    }
};
ZFOBJECT_REGISTER(ZFAdForRewardImpl_AdMob)

ZF_NAMESPACE_GLOBAL_END

// ============================================================
JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForReward
        , void, native_1notifyAdOnError
        , JNIPointer zfjniPointerOwnerZFAd
        , jstring errorHint
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForReward_DEBUG
    ZFLogTrim("%s onError: %s", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd), ZFImpl_sys_Android_zfstringFromString(errorHint));
#endif
    ZFAdForReward *ad = JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd);
    ZFAdForRewardImpl::implForAd(ad)->notifyAdOnError(ad
            , ZFImpl_sys_Android_zfstringFromString(errorHint)
            );
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForReward
        , void, native_1notifyAdOnDisplay
        , JNIPointer zfjniPointerOwnerZFAd
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForReward_DEBUG
    ZFLogTrim("%s onDisplay", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd));
#endif
    ZFAdForReward *ad = JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd);
    ZFAdForRewardImpl::implForAd(ad)->notifyAdOnDisplay(ad);
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForReward
        , void, native_1notifyAdOnClick
        , JNIPointer zfjniPointerOwnerZFAd
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForReward_DEBUG
    ZFLogTrim("%s onClick", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd));
#endif
    ZFAdForReward *ad = JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd);
    ZFAdForRewardImpl::implForAd(ad)->notifyAdOnClick(ad);
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForReward
        , void, native_1notifyAdOnLoad
        , JNIPointer zfjniPointerOwnerZFAd
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForReward_DEBUG
    ZFLogTrim("%s onLoad", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd));
#endif
    ZFAdForReward *ad = JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd);
    ZFAdForRewardImpl::implForAd(ad)->notifyAdOnLoad(ad);
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForReward
        , void, native_1notifyAdOnStop
        , JNIPointer zfjniPointerOwnerZFAd
        , jint resultType
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForReward_DEBUG
    ZFLogTrim("%s onStop", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd), (ZFResultType)resultType);
#endif
    ZFAdForReward *ad = JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd);
    ZFAdForRewardImpl::implForAd(ad)->notifyAdOnStop(ad
            , (ZFResultType)resultType
            );
}
JNI_METHOD_DECLARE_END()

#endif // #if ZF_ENV_sys_Android

