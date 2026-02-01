#include "ZFImpl_sys_iOS_ZFAd_AdMob.h"
#include "ZFAd/protocol/ZFProtocolZFAdForSplash.h"

// #define _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG 1

#if ZF_ENV_sys_iOS

#import "GoogleMobileAds/GADAppOpenAd.h"

@interface _ZFP_ZFImpl_sys_iOS_ZFAdForSplash : UIView<GADFullScreenContentDelegate>
@property (nonatomic, strong) GADAppOpenAd *impl;
@property (nonatomic, assign) zfweakT<ZFAdForSplash> _ad;
@property (nonatomic, assign) zfautoT<ZFTaskId> _appIdUpdateTaskId;
@property (nonatomic, assign) zfstring _adId;
@property (nonatomic, assign) zfbool _nativeAdStarted;
@property (nonatomic, weak) UIViewController *_ownerWindow;
@end
@implementation _ZFP_ZFImpl_sys_iOS_ZFAdForSplash
- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    zfstring errorHint;
    ZFImpl_sys_iOS_zfstringFromNSString(errorHint, error.description);
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("[AdMob][splash] %s ad:didFailToPresentFullScreenContentWithError: %s", self._adId, errorHint);
#endif
    ZFAdForSplashImpl::implForAd(self._ad)->notifyAdOnError(self._ad, errorHint);
}
- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("[AdMob][splash] %s adWillPresentFullScreenContent", self._adId);
#endif
}
- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
}
- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("[AdMob][splash] %s adDidDismissFullScreenContent", self._adId);
#endif
    self._nativeAdStarted = zffalse;
    self._ownerWindow = nil;
    ZFAdForSplashImpl::implForAd(self._ad)->notifyAdOnStop(self._ad, v_ZFResultType::e_Success);
}
- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("[AdMob][splash] %s adDidRecordImpression", self._adId);
#endif
    ZFAdForSplashImpl::implForAd(self._ad)->notifyAdOnDisplay(self._ad);
}
- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("[AdMob][splash] %s adDidRecordClick", self._adId);
#endif
    ZFAdForSplashImpl::implForAd(self._ad)->notifyAdOnClick(self._ad);
}
@end

ZF_NAMESPACE_GLOBAL_BEGIN

zfclass ZFAdForSplashImpl_AdMob : zfextend ZFObject, zfimplement ZFAdForSplashImpl {
    ZFOBJECT_DECLARE(ZFAdForSplashImpl_AdMob, ZFObject)
    ZFIMPLEMENT_DECLARE(ZFAdForSplashImpl)

public:
    zfoverride
    virtual void *nativeAdCreate(
            ZF_IN ZFAdForSplash *ad
            , ZF_IN const zfstring &appId
            , ZF_IN const zfstring &adId
            ) {
        if(zffalse
                || ZFProtocolTryAccess("ZFUIView", "iOS:UIView") == zfnull
                || ZFProtocolTryAccess("ZFUIRootWindow", "iOS:UIViewController") == zfnull
                ) {
            return zfnull;
        }

        _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = [_ZFP_ZFImpl_sys_iOS_ZFAdForSplash new];
        nativeAd._ad = ad;
        nativeAd._adId = adId;
        ZFLISTENER_1(onFinish
                , zfweakT<ZFAdForSplash>, ad
                ) {
            zfbool success = zfargs.param0().to<v_zfbool *>()->zfv;
            _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *)ad->nativeAd();
            nativeAd._appIdUpdateTaskId = zfnull;
            if(!success) {
                const zfstring &errorHint = zfargs.param1().to<v_zfstring *>()->zfv;
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
                ZFLogTrim("[AdMob][splash] %s init fail: %s", nativeAd._adId
                          , errorHint
                          );
#endif
                ZFAdForSplashImpl::implForAd(nativeAd._ad)->notifyAdOnError(nativeAd._ad, errorHint);
                return;
            }
            _update(nativeAd);
        } ZFLISTENER_END()
        nativeAd._appIdUpdateTaskId = ZFImpl_sys_iOS_ZFAd_appIdUpdate(appId, onFinish);

        return (__bridge_retained void *)nativeAd;
    }
    zfoverride
    virtual void nativeAdDestroy(ZF_IN ZFAdForSplash *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = (__bridge_transfer _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *)ad->nativeAd();
        if(nativeAd._appIdUpdateTaskId) {
            nativeAd._appIdUpdateTaskId->stop();
            nativeAd._appIdUpdateTaskId = zfnull;
        }
        nativeAd._nativeAdStarted = zffalse;
        nativeAd.impl.fullScreenContentDelegate = nil;
        nativeAd.impl = nil;
        nativeAd = nil;
    }

    zfoverride
    virtual void nativeAdStart(
            ZF_IN ZFAdForSplash *ad
            , ZF_IN ZFUIRootWindow *window
            ) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *)ad->nativeAd();
        nativeAd._nativeAdStarted = zftrue;
        nativeAd._ownerWindow = (__bridge UIViewController *)window->nativeWindow();
        _update(nativeAd);
    }

private:
    static void _update(ZF_IN _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd) {
        if(!nativeAd._nativeAdStarted
                || nativeAd._appIdUpdateTaskId
        ) {
            return;
        }
        if(nativeAd._ownerWindow == nil) {
            nativeAd._nativeAdStarted = zffalse;
            zfstring errorHint;
            zfstringAppend(errorHint, "[AdMob][splash] %s unable to obtain window", nativeAd._adId);
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
            ZFLogTrim("%s", errorHint);
#endif
            ZFAdForSplashImpl::implForAd(nativeAd._ad)->notifyAdOnError(nativeAd._ad, errorHint);
            return;
        }

        if(nativeAd.impl == nil) {
            [GADAppOpenAd loadWithAdUnitID:ZFImpl_sys_iOS_zfstringToNSString(nativeAd._adId)
                request:[GADRequest request]
                completionHandler:^(GADAppOpenAd *appOpenAd, NSError *error) {
                    if(!error) {
                        nativeAd.impl = appOpenAd;
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
                        ZFLogTrim("[AdMob][splash] %s onAdLoaded", nativeAd._adId);
#endif
                        _update(nativeAd);
                    }
                    else {
                        zfstring errorHint;
                        ZFImpl_sys_iOS_zfstringFromNSString(errorHint, error.description);
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
                        ZFLogTrim("[AdMob][splash] %s onAdFailedToLoad: %s", nativeAd._adId, errorHint);
#endif
                        nativeAd.impl.fullScreenContentDelegate = nil;
                        nativeAd.impl = nil;
                        nativeAd._nativeAdStarted = zffalse;
                        ZFAdForSplashImpl::implForAd(nativeAd._ad)->notifyAdOnError(nativeAd._ad, errorHint);
                    }
                }];
        }
        else {
            nativeAd.impl.fullScreenContentDelegate = nativeAd;
            [nativeAd.impl presentFromRootViewController:nativeAd._ownerWindow];
        }
    }
};
ZFOBJECT_REGISTER(ZFAdForSplashImpl_AdMob)

ZF_NAMESPACE_GLOBAL_END
#endif // #if ZF_ENV_sys_iOS

