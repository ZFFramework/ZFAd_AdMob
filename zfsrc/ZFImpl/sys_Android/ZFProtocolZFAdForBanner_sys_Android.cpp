#include "ZFImpl_sys_Android_ZFAd_AdMob.h"
#include "ZFAd/protocol/ZFProtocolZFAdForBanner.h"

// #define _ZFP_ZFImpl_sys_Android_ZFAdForBanner_DEBUG 1

#if ZF_ENV_sys_Android
ZF_NAMESPACE_GLOBAL_BEGIN

#define ZFImpl_sys_Android_JNI_ID_ZFAdForBanner ZFImpl_sys_Android_JNI_ID(ZFAd_1AdMob_ZFAdForBanner)
#define ZFImpl_sys_Android_JNI_NAME_ZFAdForBanner ZFImpl_sys_Android_JNI_NAME(ZFAd_AdMob.ZFAdForBanner)
ZFImpl_sys_Android_jclass_DEFINE(ZFImpl_sys_Android_jclassZFAdForBanner, ZFImpl_sys_Android_JNI_NAME_ZFAdForBanner)

zfclass ZFAdForBannerImpl_AdMob : zfextend ZFObject, zfimplement ZFAdForBannerImpl {
    ZFOBJECT_DECLARE(ZFAdForBannerImpl_AdMob, ZFObject)
    ZFIMPLEMENT_DECLARE(ZFAdForBannerImpl)

public:
    zfoverride
    virtual void *nativeAdCreate(
            ZF_IN ZFAdForBanner *ad
            , ZF_IN const zfstring &appId
            , ZF_IN const zfstring &adId
            ) {
        if(zffalse
                || ZFProtocolTryAccess("ZFUIView", "Android:View") == zfnull
                ) {
            return zfnull;
        }

        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForBanner(), "native_nativeAdCreate",
            JNIGetMethodSig(JNIType::S_object_Object(), JNIParamTypeContainer()
                .add(JNIPointerJNIType)
                .add(JNIType::S_object_String())
                .add(JNIType::S_object_String())
            ).c_str());
        jobject tmp = JNIUtilCallStaticObjectMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForBanner(), jmId
                , JNIConvertZFObjectToJNIType(jniEnv, ad)
                , ZFImpl_sys_Android_zfstringToString(appId)
                , ZFImpl_sys_Android_zfstringToString(adId)
                );
        jobject ret = JNIUtilNewGlobalRef(jniEnv, tmp);
        JNIUtilDeleteLocalRef(jniEnv, tmp);
        _ownerWindowUpdateAttach(ad);
        return ret;
    }
    zfoverride
    virtual void nativeAdDestroy(ZF_IN ZFAdForBanner *ad) {
        _ownerWindowUpdateDetach(ad);

        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForBanner(), "native_nativeAdDestroy",
            JNIGetMethodSig(JNIType::S_void(), JNIParamTypeContainer()
                .add(JNIType::S_object_Object())
            ).c_str());
        JNIUtilCallStaticVoidMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForBanner(), jmId
                , (jobject)ad->nativeAd()
                );
        JNIUtilDeleteGlobalRef(jniEnv, (jobject)ad->nativeAd());
    }

    zfoverride
    virtual ZFUISize nativeAdMeasure(
            ZF_IN ZFAdForBanner *ad
            , ZF_IN const ZFUISize &sizeHint
            ) {
        JNIEnv *jniEnv = JNIGetJNIEnv();
        static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForBanner(), "native_nativeAdMeasure",
            JNIGetMethodSig(JNIType::S_array(JNIType::S_int()), JNIParamTypeContainer()
                .add(JNIType::S_object_Object())
                .add(JNIType::S_int())
                .add(JNIType::S_int())
            ).c_str());
        jintArray jSize = (jintArray)JNIUtilCallStaticObjectMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForBanner(), jmId
                , (jobject)ad->nativeAd()
                , (jint)sizeHint.width
                , (jint)sizeHint.height
                );
        jint jSizeBuf[2];
        JNIUtilGetIntArrayRegion(jniEnv, jSize, 0, 2, jSizeBuf);
        return ZFUISizeCreate((zffloat)jSizeBuf[0], (zffloat)jSizeBuf[1]);
    }

private:
    void _ownerWindowUpdateAttach(ZF_IN ZFAdForBanner *ad) {
        zfobj<ZFObject> eventHolder;
        ad->objectTag("_ZFP_ZFAdForBanner_sys_Android_eventHolder", eventHolder);
        ZFLISTENER_0(viewTreeInWindowOnUpdate
                ) {
            ZFAdForBanner *ad = zfargs.sender();
            if(ad->viewTreeInWindow()) {
                ZFUIRootWindow *window = ZFUIWindow::rootWindowForView(ad);
                if(window) {
                    JNIEnv *jniEnv = JNIGetJNIEnv();
                    static jmethodID jmId = JNIUtilGetStaticMethodID(jniEnv, ZFImpl_sys_Android_jclassZFAdForBanner(), "native_nativeAdWindowUpdate",
                        JNIGetMethodSig(JNIType::S_void(), JNIParamTypeContainer()
                            .add(JNIType::S_object_Object())
                            .add(JNIType::S_object_Object())
                        ).c_str());
                    JNIUtilCallStaticVoidMethod(jniEnv, ZFImpl_sys_Android_jclassZFAdForBanner(), jmId
                            , (jobject)ad->nativeAd()
                            , (jobject)window->nativeWindow()
                            );
                }
            }
        } ZFLISTENER_END()
        ZFObserverGroup(eventHolder, ad)
            .observerAdd(ZFUIView::E_ViewTreeInWindowOnUpdate(), viewTreeInWindowOnUpdate, ZFLevelZFFrameworkPostNormal)
            ;
    }
    void _ownerWindowUpdateDetach(ZF_IN ZFAdForBanner *ad) {
        zfauto eventHolder = ad->objectTagRemoveAndGet("_ZFP_ZFAdForBanner_sys_Android_eventHolder");
        if(eventHolder) {
            ZFObserverGroupRemove(eventHolder);
        }
    }
};
ZFOBJECT_REGISTER(ZFAdForBannerImpl_AdMob)

ZF_NAMESPACE_GLOBAL_END

// ============================================================
JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForBanner
        , void, native_1notifyAdOnError
        , JNIPointer zfjniPointerOwnerZFAd
        , jstring errorHint
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onError: %s", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd), ZFImpl_sys_Android_zfstringFromString(errorHint));
#endif
    ZFAdForBanner *ad = JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd);
    ZFAdForBannerImpl::implForAd(ad)->notifyAdOnError(ad
            , ZFImpl_sys_Android_zfstringFromString(errorHint)
            );
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForBanner
        , void, native_1notifyAdOnDisplay
        , JNIPointer zfjniPointerOwnerZFAd
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onDisplay", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd));
#endif
    ZFAdForBanner *ad = JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd);
    ZFAdForBannerImpl::implForAd(ad)->notifyAdOnDisplay(ad);
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForBanner
        , void, native_1notifyAdOnClick
        , JNIPointer zfjniPointerOwnerZFAd
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onClick", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd));
#endif
    ZFAdForBanner *ad = JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd);
    ZFAdForBannerImpl::implForAd(ad)->notifyAdOnClick(ad);
}
JNI_METHOD_DECLARE_END()

JNI_METHOD_DECLARE_BEGIN(ZFImpl_sys_Android_JNI_ID_ZFAdForBanner
        , void, native_1notifyAdOnClose
        , JNIPointer zfjniPointerOwnerZFAd
        ) {
#if _ZFP_ZFImpl_sys_Android_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onClose: %s", JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd));
#endif
    ZFAdForBanner *ad = JNIConvertZFObjectFromJNIType(jniEnv, zfjniPointerOwnerZFAd);
    ZFAdForBannerImpl::implForAd(ad)->notifyAdOnClose(ad);
}
JNI_METHOD_DECLARE_END()

#endif // #if ZF_ENV_sys_Android

