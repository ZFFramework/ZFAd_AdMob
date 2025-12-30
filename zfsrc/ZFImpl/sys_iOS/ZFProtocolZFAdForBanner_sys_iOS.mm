#include "ZFImpl_sys_iOS_ZFAd_AdMob.h"
#include "ZFAd/protocol/ZFProtocolZFAdForBanner.h"

// #define _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG 1

#if ZF_ENV_sys_iOS

#import "GoogleMobileAds/GADBannerView.h"

@interface _ZFP_ZFImpl_sys_iOS_ZFAdForBanner : UIView<GADBannerViewDelegate>
@property (nonatomic, strong) GADBannerView *impl;
@property (nonatomic, assign) zfweakT<ZFAdForBanner> _ad;
@property (nonatomic, assign) zfautoT<ZFTaskId> _appIdUpdateTaskId;
@property (nonatomic, assign) zfstring _adId;
@property (nonatomic, weak) UIViewController *_ownerWindow;
@property (nonatomic, assign) int _widthPrev;
@end
@implementation _ZFP_ZFImpl_sys_iOS_ZFAdForBanner
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.impl.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    zfstring errorHint;
    ZFImpl_sys_iOS_zfstringFromNSString(errorHint, error.description);
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("[AdMob][banner] %s bannerView:didFailToReceiveAdWithError: %s", self._adId, errorHint);
#endif
    ZFAdForBannerImpl::implForAd(self._ad)->notifyAdOnError(self._ad, errorHint);
}
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("[AdMob][banner] %s bannerViewDidReceiveAd", self._adId);
#endif
}
- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("[AdMob][banner] %s bannerViewDidRecordImpression", self._adId);
#endif
    ZFAdForBannerImpl::implForAd(self._ad)->notifyAdOnDisplay(self._ad);
}
- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("[AdMob][banner] %s bannerViewDidRecordClick", self._adId);
#endif
    ZFAdForBannerImpl::implForAd(self._ad)->notifyAdOnClick(self._ad);
}
- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("[AdMob][banner] %s bannerViewWillPresentScreen", self._adId);
#endif
}
- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
}
- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
    ZFLogTrim("[AdMob][banner] %s bannerViewDidDismissScreen", self._adId);
#endif
}
@end

ZF_NAMESPACE_GLOBAL_BEGIN

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
            || ZFProtocolTryAccess("ZFUIView", "iOS:UIView") == zfnull
            ) {
            return zfnull;
        }

        _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd = [_ZFP_ZFImpl_sys_iOS_ZFAdForBanner new];
        nativeAd._ad = ad;
        nativeAd._adId = adId;
        ZFLISTENER_1(onFinish
                , zfweakT<ZFAdForBanner>, ad
                ) {
            zfbool success = zfargs.param0().to<v_zfbool *>()->zfv;
            const zfstring &errorHint = zfargs.param1().to<v_zfstring *>()->zfv;
            _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *)ad->nativeAd();
            nativeAd._appIdUpdateTaskId = zfnull;
            if(!success) {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
                ZFLogTrim("[AdMob][banner] %s init fail: %s", nativeAd._adId, errorHint);
#endif
                return;
            }
            _update(nativeAd);
        } ZFLISTENER_END()
        nativeAd._appIdUpdateTaskId = ZFImpl_sys_iOS_ZFAd_appIdUpdate(appId, onFinish);

        _ownerWindowUpdateAttach(ad);
        return (__bridge_retained void *)nativeAd;
    }
    zfoverride
    virtual void nativeAdDestroy(ZF_IN ZFAdForBanner *ad) {
        _ownerWindowUpdateDetach(ad);

        _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd = (__bridge_transfer _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *)ad->nativeAd();
        if(nativeAd._appIdUpdateTaskId) {
            nativeAd._appIdUpdateTaskId->stop();
            nativeAd._appIdUpdateTaskId = zfnull;
        }
        if(nativeAd.impl != nil) {
            [nativeAd.impl removeFromSuperview];
            nativeAd.impl.delegate = nil;
            nativeAd.impl = nil;
        }
        nativeAd = nil;
    }

    zfoverride
    virtual ZFUISize nativeAdMeasure(
                ZF_IN ZFAdForBanner *ad
                , ZF_IN const ZFUISize &sizeHint
                ) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *)ad->nativeAd();
        if(nativeAd._ownerWindow == nil) {
            return ZFUISizeZero();
        }
        GADAdSize implSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth([UIApplication sharedApplication].delegate.window.frame.size.width);
        if(nativeAd._widthPrev != sizeHint.width) {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
            ZFLogTrim("[AdMob][banner] %s size update: %s (%s, %s)", nativeAd._adId, sizeHint.width, implSize.size.width, implSize.size.height);
#endif
            nativeAd.impl.adSize = implSize;
            [nativeAd.impl loadRequest:[GADRequest request]];
        }
        return ZFUISizeCreate(sizeHint.width, (zffloat)implSize.size.height);
    }

private:
    static void _ownerWindowUpdateAttach(ZF_IN ZFAdForBanner *ad) {
        zfobj<ZFObject> eventHolder;
        ad->objectTag("_ZFP_ZFAdForBanner_sys_iOS_eventHolder", eventHolder);
        ZFLISTENER_0(viewTreeInWindowOnUpdate
                ) {
            ZFAdForBanner *ad = zfargs.sender();
            if(ad->viewTreeInWindow()) {
                ZFUIRootWindow *window = ZFUIWindow::rootWindowForView(ad);
                if(window) {
                    _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *)ad->nativeAd();
                    _nativeAdWindowUpdate(nativeAd, (__bridge UIViewController *)window->nativeWindow());
                }
            }
        } ZFLISTENER_END()
        ZFObserverGroup(eventHolder, ad)
            .observerAdd(ZFUIView::E_ViewTreeInWindowOnUpdate(), viewTreeInWindowOnUpdate, ZFLevelZFFrameworkPostNormal)
            ;
    }
    static void _ownerWindowUpdateDetach(ZF_IN ZFAdForBanner *ad) {
        zfauto eventHolder = ad->objectTagRemoveAndGet("_ZFP_ZFAdForBanner_sys_iOS_eventHolder");
        if(eventHolder) {
            ZFObserverGroupRemove(eventHolder);
        }
    }
    static void _nativeAdWindowUpdate(ZF_IN _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd, ZF_IN UIViewController *window) {
        if(window == nil) {
            ZFCoreCriticalShouldNotGoHere();
            return;
        }
        if(nativeAd._ownerWindow != nil && nativeAd._ownerWindow != window) {
            ZFCoreCriticalShouldNotGoHere();
            return;
        }
        nativeAd._ownerWindow = window;
        _update(nativeAd);
    }
    static void _update(ZF_IN _ZFP_ZFImpl_sys_iOS_ZFAdForBanner *nativeAd) {
        if(!nativeAd._adId
                || nativeAd._ownerWindow == nil
                ) {
            return;
        }
        if(nativeAd.impl == nil) {
            nativeAd.impl = [GADBannerView new];
            nativeAd.impl.translatesAutoresizingMaskIntoConstraints = NO;
            nativeAd.impl.autoresizingMask = UIViewAutoresizingNone;
            nativeAd.impl.delegate = nativeAd;
            nativeAd.impl.adUnitID = ZFImpl_sys_iOS_zfstringToNSString(nativeAd._adId);
            [nativeAd addSubview:nativeAd.impl];
        }
#if _ZFP_ZFImpl_sys_iOS_ZFAdForBanner_DEBUG
        ZFLogTrim("[AdMob][banner] %s update", nativeAd._adId);
#endif
    }
};
ZFOBJECT_REGISTER(ZFAdForBannerImpl_AdMob)

ZF_NAMESPACE_GLOBAL_END
#endif // #if ZF_ENV_sys_iOS

