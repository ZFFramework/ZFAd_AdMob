#include "ZFImpl_sys_iOS_ZFAd_AdMob.h"
#include "ZFAd/protocol/ZFProtocolZFAdForReward.h"

#define _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG 1

#if ZF_ENV_sys_iOS

#import "GoogleMobileAds/GADRewardedAd.h"

@interface _ZFP_ZFImpl_sys_iOS_ZFAdForReward : NSObject<GADFullScreenContentDelegate>
@property (nonatomic, strong) GADRewardedAd *impl;
@property (nonatomic, assign) zfweakT<ZFAdForReward> _ad;
@property (nonatomic, assign) zfautoT<ZFTaskId> _appIdUpdateTaskId;
@property (nonatomic, assign) zfstring _adId;
@property (nonatomic, assign) zftimet _nativeAdLoadTime;
@property (nonatomic, assign) zfbool _nativeAdLoadFlag;
@property (nonatomic, assign) zfbool _nativeAdStartFlag;
@property (nonatomic, assign) zfbool _nativeAdShowFlag;
@property (nonatomic, weak) UIViewController *_ownerWindow;
@property (nonatomic, assign) zfautoT<ZFTaskId> _loadTimeoutTaskId;
@end
@implementation _ZFP_ZFImpl_sys_iOS_ZFAdForReward
- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    self._nativeAdStartFlag = zffalse;
    self._nativeAdShowFlag = zffalse;
    zfstring errorHint;
    ZFImpl_sys_iOS_zfstringFromNSString(errorHint, error.description);
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
    ZFLogTrim("[AdMob][reward] %s ad:didFailToPresentFullScreenContentWithError: %s", self._adId, errorHint);
#endif
    ZFAdForRewardImpl::implForAd(self._ad)->notifyAdOnError(self._ad, errorHint);
}
- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
    ZFLogTrim("[AdMob][reward] %s adWillPresentFullScreenContent", self._adId);
#endif
}
- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
}
- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
    ZFLogTrim("[AdMob][reward] %s adDidDismissFullScreenContent", self._adId);
#endif
    self._nativeAdStartFlag = zffalse;
    self._nativeAdShowFlag = zffalse;
    self._ownerWindow = nil;
    ZFAdForRewardImpl::implForAd(self._ad)->notifyAdOnStop(self._ad, v_ZFResultType::e_Success);
}
- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
    ZFLogTrim("[AdMob][reward] %s adDidRecordImpression", self._adId);
#endif
    ZFAdForRewardImpl::implForAd(self._ad)->notifyAdOnDisplay(self._ad);
}
- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
    ZFLogTrim("[AdMob][reward] %s adDidRecordClick", self._adId);
#endif
    ZFAdForRewardImpl::implForAd(self._ad)->notifyAdOnClick(self._ad);
}
@end

ZF_NAMESPACE_GLOBAL_BEGIN

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
                || ZFProtocolTryAccess("ZFUIView", "iOS:UIView") == zfnull
                || ZFProtocolTryAccess("ZFUIRootWindow", "iOS:UIViewController") == zfnull
                ) {
            return zfnull;
        }

        _ZFP_ZFImpl_sys_iOS_ZFAdForReward *nativeAd = [_ZFP_ZFImpl_sys_iOS_ZFAdForReward new];
        nativeAd._ad = ad;
        nativeAd._adId = adId;
        ZFLISTENER_1(onFinish
                , zfweakT<ZFAdForReward>, ad
                ) {
            zfbool success = zfargs.param0().to<v_zfbool *>()->zfv;
            _ZFP_ZFImpl_sys_iOS_ZFAdForReward *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForReward *)ad->nativeAd();
            nativeAd._appIdUpdateTaskId = zfnull;
            if(!success) {
                const zfstring &errorHint = zfargs.param1().to<v_zfstring *>()->zfv;
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
                ZFLogTrim("[AdMob][reward] %s init fail: %s", nativeAd._adId
                          , errorHint
                          );
#endif
                nativeAd._nativeAdShowFlag = zffalse;
                ZFAdForRewardImpl::implForAd(nativeAd._ad)->notifyAdOnError(nativeAd._ad, errorHint);
                return;
            }
            _update(ad);
        } ZFLISTENER_END()
        nativeAd._appIdUpdateTaskId = ZFImpl_sys_iOS_ZFAd_appIdUpdate(appId, onFinish);

        return (__bridge_retained void *)nativeAd;
    }
    zfoverride
    virtual void nativeAdDestroy(ZF_IN ZFAdForReward *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForReward *nativeAd = (__bridge_transfer _ZFP_ZFImpl_sys_iOS_ZFAdForReward *)ad->nativeAd();
        if(nativeAd._appIdUpdateTaskId) {
            nativeAd._appIdUpdateTaskId->stop();
            nativeAd._appIdUpdateTaskId = zfnull;
        }
        nativeAd._nativeAdLoadFlag = zffalse;
        nativeAd._nativeAdStartFlag = zffalse;
        nativeAd.impl.fullScreenContentDelegate = nil;
        nativeAd.impl = nil;
        nativeAd = nil;
    }

    zfoverride
    virtual void nativeAdLoad(ZF_IN ZFAdForReward *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForReward *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForReward *)ad->nativeAd();
        nativeAd._nativeAdLoadFlag = zftrue;
        nativeAd._nativeAdShowFlag = zffalse;
        nativeAd._ownerWindow = (__bridge UIViewController *)ad->window()->nativeWindow();
        nativeAd.impl.fullScreenContentDelegate = nil;
        nativeAd.impl = nil;
        _update(ad);
    }
    zfoverride
    virtual zfbool nativeAdLoaded(ZF_IN ZFAdForReward *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForReward *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForReward *)ad->nativeAd();
        return nativeAd._nativeAdLoadTime != 0
            && ZFTime::currentTime() - nativeAd._nativeAdLoadTime < zftimetOneHour()
            ;
    }

    zfoverride
    virtual void nativeAdStart(ZF_IN ZFAdForReward *ad) {
        _ZFP_ZFImpl_sys_iOS_ZFAdForReward *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForReward *)ad->nativeAd();
        nativeAd._nativeAdStartFlag = zftrue;
        nativeAd._ownerWindow = (__bridge UIViewController *)ad->window()->nativeWindow();
        _update(ad);
    }

private:
    static void _update(ZF_IN zfweakT<ZFAdForReward> const &ad) {
        if(!ad) {
            return;
        }
        _ZFP_ZFImpl_sys_iOS_ZFAdForReward *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForReward *)ad->nativeAd();
        if(nativeAd._appIdUpdateTaskId
                || (!nativeAd._nativeAdLoadFlag && !nativeAd._nativeAdStartFlag)
        ) {
            return;
        }
        if(nativeAd._nativeAdStartFlag && nativeAd._ownerWindow == nil) {
            nativeAd._nativeAdStartFlag = zffalse;
            nativeAd._nativeAdShowFlag = zffalse;
            zfstring errorHint;
            zfstringAppend(errorHint, "[AdMob][reward] %s unable to obtain window", nativeAd._adId);
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
            ZFLogTrim("%s", errorHint);
#endif
            ZFAdForRewardImpl::implForAd(nativeAd._ad)->notifyAdOnError(nativeAd._ad, errorHint);
            return;
        }

        if(nativeAd.impl == nil) {
            zfobj<v_zfint> taskId(zfmRand());
            if(nativeAd._loadTimeoutTaskId) {
                nativeAd._loadTimeoutTaskId->stop();
            }
            ZFLISTENER_2(onTimeout
                    , zfweakT<ZFAdForReward>, ad
                    , zfautoT<v_zfint>, taskId
                    ) {
                if(!ad) {
                    return;
                }
                _ZFP_ZFImpl_sys_iOS_ZFAdForReward *nativeAd = (__bridge _ZFP_ZFImpl_sys_iOS_ZFAdForReward *)ad->nativeAd();
                nativeAd._loadTimeoutTaskId = zfnull;
                ++(taskId->zfv);
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
                ZFLogTrim("[AdMob][reward] %s onAdLoadTimeout", nativeAd._adId);
#endif
                nativeAd.impl = nil;
                nativeAd._nativeAdStartFlag = zffalse;
                nativeAd._nativeAdShowFlag = zffalse;
                if(nativeAd._nativeAdLoadFlag) {
                    nativeAd._nativeAdLoadFlag = zffalse;
                    ZFAdForRewardImpl::implForAd(ad)->notifyAdOnLoad(ad);
                }
                ZFAdForRewardImpl::implForAd(ad)->notifyAdOnError(ad, "load timeout");
            } ZFLISTENER_END()
            nativeAd._loadTimeoutTaskId = ZFTimerOnce(10000, onTimeout);

            zfint taskIdRunning = taskId->zfv;
            [GADRewardedAd loadWithAdUnitID:ZFImpl_sys_iOS_zfstringToNSString(nativeAd._adId)
                request:[GADRequest request]
                completionHandler:^(GADRewardedAd *rewardedAd, NSError *error) {
                    if(taskIdRunning != taskId->zfv) {
                        return;
                    }
                    if(nativeAd._loadTimeoutTaskId) {
                        nativeAd._loadTimeoutTaskId->stop();
                        nativeAd._loadTimeoutTaskId = zfnull;
                    }
                    if(!error) {
                        nativeAd.impl = rewardedAd;
                        nativeAd._nativeAdLoadTime = ZFTime::currentTime();
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
                        ZFLogTrim("[AdMob][reward] %s onAdLoaded", nativeAd._adId);
#endif
                        ZFAdForRewardImpl::implForAd(nativeAd._ad)->notifyAdOnLoad(nativeAd._ad);
                        _update(nativeAd._ad);
                    }
                    else {
                        zfstring errorHint;
                        ZFImpl_sys_iOS_zfstringFromNSString(errorHint, error.description);
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
                        ZFLogTrim("[AdMob][reward] %s onAdFailedToLoad: %s", nativeAd._adId, errorHint);
#endif
                        nativeAd.impl.fullScreenContentDelegate = nil;
                        nativeAd.impl = nil;
                        nativeAd._nativeAdStartFlag = zffalse;
                        nativeAd._nativeAdShowFlag = zffalse;
                        if(nativeAd._nativeAdLoadFlag) {
                            nativeAd._nativeAdLoadFlag = zffalse;
                            ZFAdForRewardImpl::implForAd(nativeAd._ad)->notifyAdOnLoad(nativeAd._ad);
                        }
                        ZFAdForRewardImpl::implForAd(nativeAd._ad)->notifyAdOnError(nativeAd._ad, errorHint);
                    }
                }];
        }
        else if(nativeAd._nativeAdStartFlag && !nativeAd._nativeAdStartFlag) {
            nativeAd._nativeAdStartFlag = zftrue;
            nativeAd.impl.fullScreenContentDelegate = nativeAd;
            [nativeAd.impl presentFromRootViewController:nativeAd._ownerWindow
                                userDidEarnRewardHandler:^{
#if _ZFP_ZFImpl_sys_iOS_ZFAdForReward_DEBUG
                ZFLogTrim("[AdMob][reward] %s onAdGotReward", nativeAd._adId);
#endif
                nativeAd._nativeAdStartFlag = zffalse;
                ZFAdForRewardImpl::implForAd(nativeAd._ad)->notifyAdOnStop(nativeAd._ad, v_ZFResultType::e_Success);
            }];
        }
    }
};
ZFOBJECT_REGISTER(ZFAdForRewardImpl_AdMob)

ZF_NAMESPACE_GLOBAL_END
#endif // #if ZF_ENV_sys_iOS

