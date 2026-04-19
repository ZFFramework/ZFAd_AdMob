package com.ZFFramework.ZFAd_AdMob;

import android.app.Activity;

import com.ZFFramework.NativeUtil.ZFAndroidLog;
import com.ZFFramework.NativeUtil.ZFAndroidPost;
import com.ZFFramework.NativeUtil.ZFAndroidValue;
import com.ZFFramework.NativeUtil.ZFRunnable;
import com.ZFFramework.NativeUtil.ZFTaskId;
import com.ZFFramework.ZF_impl.ZFResultType;
import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.OnUserEarnedRewardListener;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;

import java.lang.ref.WeakReference;

public class ZFAdForReward {

    public long zfjniPointerOwnerZFAd = -1;
    public RewardedAd impl = null;

    public static Object native_nativeAdCreate(
            long zfjniPointerOwnerZFAd
            , String appId
            , String adId
    ) {
        ZFAdForReward nativeAd = new ZFAdForReward();
        nativeAd.zfjniPointerOwnerZFAd = zfjniPointerOwnerZFAd;
        nativeAd._adId = adId;
        nativeAd._appIdUpdateTaskId = ZFAd.appIdUpdate(appId, new ZFRunnable.P2<Boolean, String>() {
            @Override
            public void run(Boolean success, String errorHint) {
                nativeAd._appIdUpdateTaskId = ZFTaskId.INVALID;
                if (!success) {
                    if (ZFAd.DEBUG) {
                        ZFAndroidLog.p("[AdMob][reward] %s init fail: %s", nativeAd._adId, errorHint);
                    }
                    nativeAd._nativeAdShowFlag = false;
                    native_notifyAdOnError(zfjniPointerOwnerZFAd, errorHint);
                    return;
                }
                nativeAd._update();
            }
        });
        return nativeAd;
    }

    public static void native_nativeAdDestroy(Object nativeAd) {
        ZFAdForReward nativeAdTmp = (ZFAdForReward) nativeAd;
        if (nativeAdTmp._appIdUpdateTaskId != ZFTaskId.INVALID) {
            ZFAd.appIdUpdateCancel(nativeAdTmp._appIdUpdateTaskId);
            nativeAdTmp._appIdUpdateTaskId = ZFTaskId.INVALID;
        }
        nativeAdTmp.zfjniPointerOwnerZFAd = -1;
        nativeAdTmp._nativeAdStartFlag = false;
        nativeAdTmp.impl = null;
    }

    public static void native_nativeAdLoad(Object nativeAd, Object window) {
        ZFAdForReward nativeAdTmp = (ZFAdForReward) nativeAd;
        nativeAdTmp._nativeAdLoadFlag = true;
        nativeAdTmp._nativeAdShowFlag = false;
        nativeAdTmp._ownerWindow = new WeakReference<>((Activity) window);
        nativeAdTmp.impl = null;
        nativeAdTmp._update();
    }

    public static boolean native_nativeAdLoaded(Object nativeAd) {
        ZFAdForReward nativeAdTmp = (ZFAdForReward) nativeAd;
        return nativeAdTmp._nativeAdLoadTime != 0
                && System.currentTimeMillis() - nativeAdTmp._nativeAdLoadTime < 60 * 60 * 1000
                ;
    }

    public static void native_nativeAdStart(Object nativeAd, Object window) {
        ZFAdForReward nativeAdTmp = (ZFAdForReward) nativeAd;
        nativeAdTmp._nativeAdStartFlag = true;
        nativeAdTmp._ownerWindow = new WeakReference<>((Activity) window);
        nativeAdTmp._update();
    }

    // ============================================================
    public static native void native_notifyAdOnError(long zfjniPointerOwnerZFAd, String errorHint);

    public static native void native_notifyAdOnDisplay(long zfjniPointerOwnerZFAd);

    public static native void native_notifyAdOnClick(long zfjniPointerOwnerZFAd);

    public static native void native_notifyAdOnLoad(long zfjniPointerOwnerZFAd);

    public static native void native_notifyAdOnStop(long zfjniPointerOwnerZFAd, int resultType);

    // ============================================================
    private int _appIdUpdateTaskId = ZFTaskId.INVALID;
    private String _adId = null;
    private long _nativeAdLoadTime = 0;
    private boolean _nativeAdLoadFlag = false;
    private boolean _nativeAdStartFlag = false;
    private boolean _nativeAdShowFlag = false;
    private WeakReference<Activity> _ownerWindow = null;
    private int _loadTimeoutTaskId = -1;

    private final FullScreenContentCallback _implListener = new FullScreenContentCallback() {
        @Override
        public void onAdFailedToShowFullScreenContent(AdError error) {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][reward] %s onAdFailedToShowFullScreenContent: %s", _adId, error);
            }
            if (zfjniPointerOwnerZFAd != -1) {
                _nativeAdStartFlag = false;
                _nativeAdShowFlag = false;
                native_notifyAdOnError(zfjniPointerOwnerZFAd, error.toString());
            }
        }

        @Override
        public void onAdShowedFullScreenContent() {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][reward] %s onAdShowedFullScreenContent", _adId);
            }
        }

        @Override
        public void onAdDismissedFullScreenContent() {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][reward] %s onAdDismissedFullScreenContent", _adId);
            }
            if (zfjniPointerOwnerZFAd != -1) {
                _nativeAdStartFlag = false;
                _nativeAdShowFlag = false;
                _ownerWindow = null;
                native_notifyAdOnStop(zfjniPointerOwnerZFAd, ZFResultType.e_Success);
            }
        }

        @Override
        public void onAdImpression() {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][reward] %s onAdImpression", _adId);
            }
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnDisplay(zfjniPointerOwnerZFAd);
            }
        }

        @Override
        public void onAdClicked() {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][reward] %s onAdClicked", _adId);
            }
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnClick(zfjniPointerOwnerZFAd);
            }
        }
    };

    private void _update() {
        if (_appIdUpdateTaskId != ZFTaskId.INVALID
                || (!_nativeAdLoadFlag && !_nativeAdStartFlag)
        ) {
            return;
        }
        if (_nativeAdStartFlag && (_ownerWindow == null || _ownerWindow.get() == null)) {
            _nativeAdStartFlag = false;
            _nativeAdShowFlag = false;
            String errorHint = String.format("[AdMob][reward] %s unable to obtain window", _adId);
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p(errorHint);
            }
            native_notifyAdOnError(zfjniPointerOwnerZFAd, errorHint);
            return;
        }

        if (impl == null) {
            ZFAndroidValue<Integer> taskId = new ZFAndroidValue<>((int) (Math.random() * 65536));
            if (_loadTimeoutTaskId != -1) {
                ZFAndroidPost.cancel(_loadTimeoutTaskId);
            }
            _loadTimeoutTaskId = ZFAndroidPost.run(new Runnable() {
                @Override
                public void run() {
                    _loadTimeoutTaskId = -1;
                    ++(taskId.value);
                    if (ZFAd.DEBUG) {
                        ZFAndroidLog.p("[AdMob][reward] %s onAdLoadTimeout", _adId);
                    }
                    impl = null;
                    _nativeAdStartFlag = false;
                    _nativeAdShowFlag = false;
                    if (_nativeAdLoadFlag) {
                        _nativeAdLoadFlag = false;
                        native_notifyAdOnLoad(zfjniPointerOwnerZFAd);
                    }
                    native_notifyAdOnError(zfjniPointerOwnerZFAd, "load timeout");
                }
            }, 10000);
            int taskIdRunning = taskId.value;
            RewardedAd.load(
                    _ownerWindow.get()
                    , _adId
                    , new AdRequest.Builder().build()
                    , new RewardedAdLoadCallback() {
                        @Override
                        public void onAdLoaded(RewardedAd rewardedAd) {
                            super.onAdLoaded(rewardedAd);
                            if (taskIdRunning != taskId.value) {
                                return;
                            }
                            if (_loadTimeoutTaskId != -1) {
                                ZFAndroidPost.cancel(_loadTimeoutTaskId);
                                _loadTimeoutTaskId = -1;
                            }
                            impl = rewardedAd;
                            _nativeAdLoadTime = System.currentTimeMillis();
                            if (ZFAd.DEBUG) {
                                ZFAndroidLog.p("[AdMob][reward] %s onAdLoaded", _adId);
                            }
                            native_notifyAdOnLoad(zfjniPointerOwnerZFAd);
                            _update();
                        }

                        @Override
                        public void onAdFailedToLoad(LoadAdError error) {
                            super.onAdFailedToLoad(error);
                            if (taskIdRunning != taskId.value) {
                                return;
                            }
                            if (_loadTimeoutTaskId != -1) {
                                ZFAndroidPost.cancel(_loadTimeoutTaskId);
                                _loadTimeoutTaskId = -1;
                            }
                            if (ZFAd.DEBUG) {
                                ZFAndroidLog.p("[AdMob][reward] %s onAdFailedToLoad: %s", _adId, error);
                            }
                            impl = null;
                            _nativeAdStartFlag = false;
                            _nativeAdShowFlag = false;
                            if (_nativeAdLoadFlag) {
                                _nativeAdLoadFlag = false;
                                native_notifyAdOnLoad(zfjniPointerOwnerZFAd);
                            }
                            native_notifyAdOnError(zfjniPointerOwnerZFAd, error.toString());
                        }
                    }
            );
        } else if (_nativeAdStartFlag && !_nativeAdShowFlag) {
            _nativeAdShowFlag = true;
            impl.setFullScreenContentCallback(_implListener);
            impl.show(_ownerWindow.get(), new OnUserEarnedRewardListener() {
                @Override
                public void onUserEarnedReward(RewardItem rewardItem) {
                    if (ZFAd.DEBUG) {
                        ZFAndroidLog.p("[AdMob][reward] %s onAdGotReward: %s", _adId);
                    }
                    _nativeAdShowFlag = false;
                    native_notifyAdOnStop(zfjniPointerOwnerZFAd, ZFResultType.e_Success);
                }
            });
            _ownerWindow.get().overridePendingTransition(
                    android.R.anim.fade_in
                    , android.R.anim.fade_out
            );
        }
    }

}

