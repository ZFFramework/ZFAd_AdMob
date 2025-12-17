#include "ZFImpl_sys_iOS_ZFAd_AdMob.h"

#if ZF_ENV_sys_iOS

#import "GDTSDKConfig.h"

ZF_NAMESPACE_GLOBAL_BEGIN

zfautoT<ZFTaskId> ZFImpl_sys_iOS_ZFAd_appId(
        ZF_IN const zfstring &appId
        , ZF_IN_OPT const ZFListener &callback /* = zfnull */
        ) {
    static zfbool _initRunning = zffalse;
    static zfbool _initSuccess = zffalse;
    static zfstring _appId;
    static ZFCoreArray<ZFListener> _callbackList;

    if((_initRunning || _initSuccess) && _appId != appId) {
        callback.execute(ZFArgs()
                .param0(zfobj<v_ZFResultType>(v_ZFResultType::e_Fail))
                .param1(zfobj<v_zfstring>(zfstr("[GDT] registering a different appId: %s => %s", _appId, appId)))
                );
        return zfnull;
    }
    if(!_initRunning && _initSuccess) {
        callback.execute(ZFArgs()
                .param0(zfobj<v_ZFResultType>(v_ZFResultType::e_Success))
                );
        return zfnull;
    }
    if(!_initRunning) {
        if(!appId) {
            callback.execute(ZFArgs()
                    .param0(zfobj<v_ZFResultType>(v_ZFResultType::e_Fail))
                    .param1(zfobj<v_zfstring>("[GDT] null appId"))
                    );
            return zfnull;
        }
        _initRunning = zftrue;
        _initSuccess = zffalse;
        _appId = appId;
        if(![GDTSDKConfig initWithAppId:ZFImpl_sys_iOS_zfstringToNSString(appId)]) {
            _initSuccess = zffalse;
            callback.execute(ZFArgs()
                    .param0(zfobj<v_ZFResultType>(v_ZFResultType::e_Fail))
                    .param1(zfobj<v_zfstring>(zfstr("[GDT] %s appId init fail: %s", _appId)))
                    );
            return zfnull;
        }
        [GDTSDKConfig startWithCompletionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _initRunning = zffalse;
                _initSuccess = success;
                ZFCoreArray<ZFListener> callbackList;
                _callbackList.swap(callbackList);

                ZFArgs zfargs;
                if(success) {
                    zfargs.param0(zfobj<v_ZFResultType>(v_ZFResultType::e_Success));
                }
                else {
                    zfargs.param0(zfobj<v_ZFResultType>(v_ZFResultType::e_Fail));
                    zfargs.param1(zfobj<v_zfstring>(zfstr("[GDT] %s appId setup fail: %s"
                                    , _appId
                                    , ZFImpl_sys_iOS_zfstringFromNSString(error.description)
                                    )));
                }

                for(zfindex i = 0; i < callbackList.count(); ++i) {
                    callbackList[i].execute(zfargs);
                }
            });
        }];
    }
    if(!callback) {
        return zfnull;
    }
    _callbackList.add(callback);
    ZFLISTENER_1(onStop
            , ZFListener, callback
            ) {
        if(_callbackList.removeElement(callback)) {
            callback.execute(ZFArgs()
                    .param0(zfobj<v_ZFResultType>(v_ZFResultType::e_Cancel))
                    );
        }
        zfargs.sender().to<ZFTaskIdBasic *>()->stopImpl(zfnull);
    } ZFLISTENER_END()
    return zfobj<ZFTaskIdBasic>(onStop);
}

ZF_NAMESPACE_GLOBAL_END
#endif // #if ZF_ENV_sys_iOS

