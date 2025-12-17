#include "ZFImpl_sys_iOS_ZFAd_AdMob.h"
#include "ZFAd/protocol/ZFProtocolZFAdForSplash.h"

// #define _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG 1

#if ZF_ENV_sys_iOS

#import "GDTSplashAd.h"

@interface _ZFP_ZFImpl_sys_iOS_ZFAdForSplash : UIView<GDTSplashAdDelegate>
@property (nonatomic, assign) zfweakT<ZFAdForSplash> ad;
@property (nonatomic, strong) GDTSplashAd *impl;
@property (nonatomic, assign) zfbool appIdUpdateFinish;
@property (nonatomic, assign) zfbool loadFinish;
@property (nonatomic, assign) zfbool displayFinish;
@property (nonatomic, assign) zfautoT<ZFTaskId> appIdUpdateTaskId;
@property (nonatomic, weak) UIViewController *rootWindow;
@end
@implementation _ZFP_ZFImpl_sys_iOS_ZFAdForSplash
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onRender", self.ad.get());
#endif
}
- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onLoad", self.ad.get());
#endif
    self.loadFinish = zftrue;
    [self.impl showFullScreenAdInWindow:self.rootWindow.view.window withLogoImage:nil skipView:nil];
}
- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onError: %s", self.ad.get(), ZFImpl_sys_iOS_zfstringFromNSString(error.description));
#endif
    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnError(self.ad, ZFImpl_sys_iOS_zfstringFromNSString(error.description));
}
- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onLeaveApp", self.ad.get());
#endif
}
- (void)splashAdExposured:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onDisplay", self.ad.get());
#endif
    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnDisplay(self.ad);
}
- (void)splashAdClicked:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onClick", self.ad.get());
#endif
    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnClick(self.ad);
}
- (void)splashAdWillClosed:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onCloseBegin", self.ad.get());
#endif
}
- (void)splashAdClosed:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onCloseEnd", self.ad.get());
#endif
    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnStop(self.ad, self.displayFinish ? v_ZFResultType::e_Success : v_ZFResultType::e_Cancel);
}
- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onShowBegin", self.ad.get());
#endif
}
- (void)splashAdDidPresentFullScreenModal:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onShowEnd", self.ad.get());
#endif
}
- (void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onHideBegin", self.ad.get());
#endif
}
- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onHideEnd", self.ad.get());
#endif
    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnStop(self.ad, v_ZFResultType::e_Success);
}
- (void)splashAdLifeTime:(NSUInteger)time {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForSplash_DEBUG
    ZFLogTrim("%s onTimer: %s", self.ad.get(), (zfuint)time);
#endif
    if(time <= 0) {
        self.displayFinish = zftrue;
    }
}
@end

ZF_NAMESPACE_GLOBAL_BEGIN

ZFPROTOCOL_IMPLEMENTATION_BEGIN(ZFAdForSplash_sys_iOS, ZFAdForSplash, v_ZFProtocolLevel::e_SystemNormal)
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_HINT("iOS:UIViewController")
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_BEGIN()
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_ITEM(ZFUIView, "iOS:UIView")
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_ITEM(ZFUIRootWindow, "iOS:UIViewController")
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_END()

public:
    zfoverride
    virtual void *nativeAdCreate(ZF_IN ZFAdForSplash *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = [_ZFP_ZFImpl_sys_iOS_ZFAdForSplash new];
        nativeAd.ad = ad;
        return (__bridge_retained void *)nativeAd;
    }
    zfoverride
    virtual void nativeAdDestroy(ZF_IN ZFAdForSplash *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = (__bridge_transfer _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *)ad->nativeAd();
        if(nativeAd.appIdUpdateTaskId) {
            nativeAd.appIdUpdateTaskId->stop();
            nativeAd.appIdUpdateTaskId = zfnull;
        }
        if(nativeAd.impl != nil) {
            nativeAd.impl.delegate = nil;
            nativeAd.impl = nil;
        }
        nativeAd = nil;
    }

    zfoverride
    virtual void nativeAdUpdate(ZF_IN ZFAdForSplash *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *)ad->nativeAd();
        if(nativeAd.appIdUpdateTaskId) {
            nativeAd.appIdUpdateTaskId->stop();
        }
        ZFLISTENER_1(onFinish
                , zfweakT<ZFAdForSplash>, ad
                ) {
            ZFCoreAssert(ad);
            v_ZFResultType *resultType = zfargs.param0();
            switch(resultType->zfv()) {
                case v_ZFResultType::e_Success:
                    break;
                case v_ZFResultType::e_Fail:
                    ZFPROTOCOL_ACCESS(ZFAdForSplash)->notifyAdOnError(ad, zfargs.param1().to<v_zfstring *>()->zfv);
                    return;
                case v_ZFResultType::e_Cancel:
                    return;
                default:
                    ZFCoreCriticalShouldNotGoHere();
                    return;
            }
            _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *)ad->nativeAd();
            if(nativeAd) {
                nativeAd.appIdUpdateTaskId = zfnull;
            }
            nativeAd.appIdUpdateFinish = zftrue;
            if(ad->adId()) {
                _load(ad, nativeAd);
            }
        } ZFLISTENER_END()
        nativeAd.appIdUpdateTaskId = ZFImpl_sys_iOS_ZFAd_appId(ad->appId(), onFinish);
    }

    zfoverride
    virtual void nativeAdStart(
            ZF_IN ZFAdForSplash *ad
            , ZF_IN ZFUIRootWindow *window
            ) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *)ad->nativeAd();
        nativeAd.rootWindow = (__bridge UIViewController *)window->nativeWindow();
        if(nativeAd.appIdUpdateFinish) {
            _load(ad, nativeAd);
            if(nativeAd.loadFinish) {
                [nativeAd.impl showFullScreenAdInWindow:nativeAd.rootWindow.view.window withLogoImage:nil skipView:nil];
            }
        }
    }
    zfoverride
    virtual void nativeAdStop(ZF_IN ZFAdForSplash *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *)ad->nativeAd();
        nativeAd.impl.delegate = nil;
        nativeAd.impl = nil;
    }

private:
    static void _load(ZF_IN ZFAdForSplash *ad, ZF_IN _ZFP_ZFImpl_sys_iOS_ZFAdForSplash *nativeAd) {
        if(nativeAd.impl != nil) {
            return;
        }
        nativeAd.impl = [[GDTSplashAd alloc]
                initWithPlacementId:ZFImpl_sys_iOS_zfstringToNSString(ad->adId())
                ];
        nativeAd.impl.delegate = nativeAd;
        [nativeAd.impl loadFullScreenAd];
    }
ZFPROTOCOL_IMPLEMENTATION_END(ZFAdForSplash_sys_iOS)

ZF_NAMESPACE_GLOBAL_END
#endif // #if ZF_ENV_sys_iOS

