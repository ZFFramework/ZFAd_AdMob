#include "ZFImpl_sys_iOS_ZFAd_AdMob.h"
#include "ZFAd/protocol/ZFProtocolZFAdForBanner.h"

// #define _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG 1

#if ZF_ENV_sys_iOS

#import "GDTUnifiedBannerView.h"

@interface _ZFP_ZFImpl_sys_iOS_ZFAdForBanner : UIView<GDTUnifiedBannerViewDelegate>
@property (nonatomic, assign) zfweakT<ZFAdForBanner> ad;
@property (nonatomic, strong) GDTUnifiedBannerView *impl;
@property (nonatomic, assign) zfbool appIdUpdateFinish;
@property (nonatomic, assign) zfautoT<ZFTaskId> appIdUpdateTaskId;
@end
@implementation _ZFP_ZFImpl_sys_iOS_ZFAdForBanner
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onLoad", self.ad.get());
#endif
}
- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onError: %s", self.ad.get(), ZFImpl_sys_iOS_zfstringFromNSString(error.description));
#endif
    ZFPROTOCOL_ACCESS(ZFAdForBanner)->notifyAdOnError(self.ad, ZFImpl_sys_iOS_zfstringFromNSString(error.description));
}
- (void)unifiedBannerViewWillExpose:(GDTUnifiedBannerView *)unifiedBannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onDisplay", self.ad.get());
#endif
    ZFPROTOCOL_ACCESS(ZFAdForBanner)->notifyAdOnDisplay(self.ad);
}
- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onClick", self.ad.get());
#endif
    ZFPROTOCOL_ACCESS(ZFAdForBanner)->notifyAdOnClick(self.ad);
}
- (void)unifiedBannerViewWillPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onShowBegin", self.ad.get());
#endif
}
- (void)unifiedBannerViewDidPresentFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onShowEnd", self.ad.get());
#endif
}
- (void)unifiedBannerViewWillDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onHideBegin", self.ad.get());
#endif
}
- (void)unifiedBannerViewDidDismissFullScreenModal:(GDTUnifiedBannerView *)unifiedBannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onHideEnd", self.ad.get());
#endif
}
- (void)unifiedBannerViewWillLeaveApplication:(GDTUnifiedBannerView *)unifiedBannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onLeaveApp", self.ad.get());
#endif
}
- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("%s onClose", self.ad.get());
#endif
    ZFPROTOCOL_ACCESS(ZFAdForBanner)->notifyAdOnClose(self.ad);
}
@end

ZF_NAMESPACE_GLOBAL_BEGIN

ZFPROTOCOL_IMPLEMENTATION_BEGIN(ZFAdForBanner_sys_iOS, ZFAdForBanner, v_ZFProtocolLevel::e_SystemNormal)
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_HINT("iOS:UIView")
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_BEGIN()
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_ITEM(ZFUIView, "iOS:UIView")
    ZFPROTOCOL_IMPLEMENTATION_PLATFORM_DEPENDENCY_END()

public:
    zfoverride
    virtual void *nativeAdCreate(ZF_IN ZFAdForBanner *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd = [_ZFP_ZFImpl_sys_iOS_ZFAdForBanner new];
        nativeAd.ad = ad;
        return (__bridge_retained void *)nativeAd;
    }
    zfoverride
    virtual void nativeAdDestroy(ZF_IN ZFAdForBanner *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd = (__bridge_transfer _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *)ad->nativeAd();
        if(nativeAd.appIdUpdateTaskId) {
            nativeAd.appIdUpdateTaskId->stop();
            nativeAd.appIdUpdateTaskId = zfnull;
        }
        if(nativeAd.impl != nil) {
            [nativeAd.impl removeFromSuperview];
            nativeAd.impl.delegate = nil;
        }
        nativeAd = nil;
    }

    zfoverride
    virtual ZFUISize nativeAdMeasure(
            ZF_IN ZFAdForBanner *ad
            , ZF_IN const ZFUISize &sizeHint
            ) {
        ZFUIRect rect = ZFUIScaleTypeApply(
                v_ZFUIScaleType::e_FillCenter
                , ZFUIRectCreate(ZFUIPointZero(), ZFUISizeCreate(
                        sizeHint.width >= 0 ? sizeHint.width : _adWidth()
                        , sizeHint.height >= 0 ? sizeHint.height : _adHeight()
                        ))
                , ZFUISizeCreate(_adWidth(), _adHeight())
                );
        return ZFUISizeCreate(rect.width, rect.height);
    }

    zfoverride
    virtual void nativeAdUpdate(ZF_IN ZFAdForBanner *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *)ad->nativeAd();
        if(nativeAd.appIdUpdateTaskId) {
            nativeAd.appIdUpdateTaskId->stop();
        }
        ZFLISTENER_1(onFinish
                , zfweakT<ZFAdForBanner>, ad
                ) {
            ZFCoreAssert(ad);
            v_ZFResultType *resultType = zfargs.param0();
            switch(resultType->zfv()) {
                case v_ZFResultType::e_Success:
                    break;
                case v_ZFResultType::e_Fail:
                    ZFPROTOCOL_ACCESS(ZFAdForBanner)->notifyAdOnError(ad, zfargs.param1().to<v_zfstring *>()->zfv);
                    return;
                case v_ZFResultType::e_Cancel:
                    return;
                default:
                    ZFCoreCriticalShouldNotGoHere();
                    return;
            }
            _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *)ad->nativeAd();
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

private:
    static inline zffloat _adWidth(void) {
        return 300;
    }
    static inline zffloat _adHeight(void) {
        return 75;
    }
    static void _load(ZF_IN ZFAdForBanner *ad, ZF_IN _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd) {
        if(nativeAd.impl != nil) {
            [nativeAd.impl removeFromSuperview];
            nativeAd.impl.delegate = nil;
        }
        nativeAd.impl = [[GDTUnifiedBannerView alloc]
                initWithFrame:nativeAd.bounds
                placementId:ZFImpl_sys_iOS_zfstringToNSString(ad->adId())
                viewController:ZFImpl_sys_iOS_rootWindow().rootViewController
                ];
        [nativeAd addSubview:nativeAd.impl];
        nativeAd.impl.animated = YES;
        nativeAd.impl.frame = nativeAd.bounds;
        nativeAd.impl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        nativeAd.impl.delegate = nativeAd;
        [nativeAd.impl loadAdAndShow];
    }
ZFPROTOCOL_IMPLEMENTATION_END(ZFAdForBanner_sys_iOS)

ZF_NAMESPACE_GLOBAL_END
#endif // #if ZF_ENV_sys_iOS

