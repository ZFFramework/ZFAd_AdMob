#include "ZFImpl_sys_iOS_ZFAd_AdMob.h"

#if ZF_ENV_sys_iOS

#import "GoogleMobileAds/GADMobileAds.h"

ZF_NAMESPACE_GLOBAL_BEGIN

zfautoT<ZFTaskId> ZFImpl_sys_iOS_ZFAd_appIdUpdate(
        ZF_IN const zfstring &appId
        , ZF_IN_OPT const ZFListener &callback /* = zfnull */
        ) {
    static zfbool _initRunning = zffalse;
    static zfbool _initSuccess = zffalse;
    static zfstring _appId;
    static ZFCoreArray<ZFListener> _callbackList;
    zfclassNotPOD _NotifyFinish {
    public:
        static void a(ZF_IN zfbool success, ZF_IN const zfstring &errorHint) {
            _initRunning = zffalse;
            _initSuccess = success;
            ZFCoreArray<ZFListener> callbackList;
            _callbackList.swap(callbackList);
            ZFArgs zfargs;
            zfargs.param0(zfobj<v_zfbool>(success));
            zfargs.param1(zfobj<v_zfstring>(errorHint));
            for(zfindex i = 0; i < callbackList.count(); ++i) {
                callbackList[i].execute(zfargs);
            }
        }
    };

    if((_initRunning || _initSuccess) && _appId != appId) {
        callback.execute(ZFArgs()
                .param0(zfobj<v_zfbool>(zffalse))
                .param1(zfobj<v_zfstring>(zfstr("[AdMob] registering a different appId: %s => %s", _appId, appId)))
                );
        return zfnull;
    }
    if(!_initRunning && _initSuccess) {
        callback.execute(ZFArgs()
                .param0(zfobj<v_zfbool>(zftrue))
                .param1(zfobj<v_zfstring>())
                );
        return zfnull;
    }
    if(!_initRunning) {
        _initRunning = zftrue;
        _initSuccess = zffalse;
        _appId = appId;
        [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
            zfbool success = (status.adapterStatusesByClassName.count != 0);
            zfstring errorHint;
            if(!success) {
                zfstringAppend(errorHint
                        ,"[AdMob] %s appId setup fail"
                        , _appId
                        );
            }
            _NotifyFinish::a(success, errorHint);
        }];
    }
    if(!callback) {
        return zfnull;
    }
    _callbackList.add(callback);
    ZFLISTENER_1(onStop
            , ZFListener, callback
            ) {
        _callbackList.removeElement(callback);
        zfargs.sender().to<ZFTaskIdBasic *>()->stopImpl(zfnull);
    } ZFLISTENER_END()
    return zfobj<ZFTaskIdBasic>(onStop);
}

ZF_NAMESPACE_GLOBAL_END
#endif // #if ZF_ENV_sys_iOS

