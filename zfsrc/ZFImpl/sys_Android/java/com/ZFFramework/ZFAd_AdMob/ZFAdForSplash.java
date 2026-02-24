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
import com.google.android.gms.ads.appopen.AppOpenAd;

import java.lang.ref.WeakReference;

public class ZFAdForSplash {

    public long zfjniPointerOwnerZFAd = -1;
    public AppOpenAd impl = null;

    public static Object native_nativeAdCreate(
            long zfjniPointerOwnerZFAd
            , String appId
            , String adId
    ) {
        ZFAdForSplash nativeAd = new ZFAdForSplash();
        nativeAd.zfjniPointerOwnerZFAd = zfjniPointerOwnerZFAd;
        nativeAd._adId = adId;
        nativeAd._appIdUpdateTaskId = ZFAd.appIdUpdate(appId, new ZFRunnable.P2<Boolean, String>() {
            @Override
            public void run(Boolean success, String errorHint) {
                nativeAd._appIdUpdateTaskId = ZFTaskId.INVALID;
                if (!success) {
                    if (ZFAd.DEBUG) {
                        ZFAndroidLog.p("[AdMob][splash] %s init fail: %s", nativeAd._adId, errorHint);
                    }
                    native_notifyAdOnError(zfjniPointerOwnerZFAd, errorHint);
                    return;
                }
                nativeAd._update();
            }
        });
        return nativeAd;
    }

    public static void native_nativeAdDestroy(Object nativeAd) {
        ZFAdForSplash nativeAdTmp = (ZFAdForSplash) nativeAd;
        if (nativeAdTmp._appIdUpdateTaskId != ZFTaskId.INVALID) {
            ZFAd.appIdUpdateCancel(nativeAdTmp._appIdUpdateTaskId);
            nativeAdTmp._appIdUpdateTaskId = ZFTaskId.INVALID;
        }
        nativeAdTmp.zfjniPointerOwnerZFAd = -1;
        nativeAdTmp._nativeAdStarted = false;
        nativeAdTmp.impl = null;
    }

    public static void native_nativeAdStart(Object nativeAd, Object window) {
        ZFAdForSplash nativeAdTmp = (ZFAdForSplash) nativeAd;
        nativeAdTmp._nativeAdStarted = true;
        nativeAdTmp._ownerWindow = new WeakReference<>((Activity) window);
        nativeAdTmp._update();
    }

    // ============================================================
    public static native void native_notifyAdOnError(long zfjniPointerOwnerZFAd, String errorHint);

    public static native void native_notifyAdOnDisplay(long zfjniPointerOwnerZFAd);

    public static native void native_notifyAdOnClick(long zfjniPointerOwnerZFAd);

    public static native void native_notifyAdOnStop(long zfjniPointerOwnerZFAd, int resultType);

    // ============================================================
    private int _appIdUpdateTaskId = ZFTaskId.INVALID;
    private String _adId = null;
    private boolean _nativeAdStarted = false;
    private WeakReference<Activity> _ownerWindow = null;
    private int _loadTimeoutTaskId = -1;

    private final FullScreenContentCallback _implListener = new FullScreenContentCallback() {
        @Override
        public void onAdFailedToShowFullScreenContent(AdError error) {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][splash] %s onAdFailedToShowFullScreenContent: %s", _adId, error);
            }
            if (zfjniPointerOwnerZFAd != -1) {
                _nativeAdStarted = false;
                native_notifyAdOnError(zfjniPointerOwnerZFAd, error.toString());
            }
        }

        @Override
        public void onAdShowedFullScreenContent() {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][splash] %s onAdShowedFullScreenContent", _adId);
            }
        }

        @Override
        public void onAdDismissedFullScreenContent() {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][splash] %s onAdDismissedFullScreenContent", _adId);
            }
            if (zfjniPointerOwnerZFAd != -1) {
                _nativeAdStarted = false;
                _ownerWindow = null;
                native_notifyAdOnStop(zfjniPointerOwnerZFAd, ZFResultType.e_Success);
            }
        }

        @Override
        public void onAdImpression() {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][splash] %s onAdImpression", _adId);
            }
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnDisplay(zfjniPointerOwnerZFAd);
            }
        }

        @Override
        public void onAdClicked() {
            if (ZFAd.DEBUG) {
                ZFAndroidLog.p("[AdMob][splash] %s onAdClicked", _adId);
            }
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnClick(zfjniPointerOwnerZFAd);
            }
        }
    };

    private void _update() {
        if (!_nativeAdStarted
                || _appIdUpdateTaskId != ZFTaskId.INVALID
        ) {
            return;
        }
        if (_ownerWindow == null || _ownerWindow.get() == null) {
            _nativeAdStarted = false;
            String errorHint = String.format("[AdMob][splash] %s unable to obtain window", _adId);
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
                        ZFAndroidLog.p("[AdMob][splash] %s onAdLoadTimeout", _adId);
                    }
                    impl = null;
                    _nativeAdStarted = false;
                    native_notifyAdOnError(zfjniPointerOwnerZFAd, "load timeout");
                }
            }, 3000);
            int taskIdRunning = taskId.value;
            AppOpenAd.load(
                    _ownerWindow.get()
                    , _adId
                    , new AdRequest.Builder().build()
                    , new AppOpenAd.AppOpenAdLoadCallback() {
                        @Override
                        public void onAdLoaded(AppOpenAd appOpenAd) {
                            super.onAdLoaded(appOpenAd);
                            if (taskIdRunning != taskId.value) {
                                return;
                            }
                            if (_loadTimeoutTaskId != -1) {
                                ZFAndroidPost.cancel(_loadTimeoutTaskId);
                                _loadTimeoutTaskId = -1;
                            }
                            impl = appOpenAd;
                            if (ZFAd.DEBUG) {
                                ZFAndroidLog.p("[AdMob][splash] %s onAdLoaded", _adId);
                            }
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
                                ZFAndroidLog.p("[AdMob][splash] %s onAdFailedToLoad: %s", _adId, error);
                            }
                            impl = null;
                            _nativeAdStarted = false;
                            native_notifyAdOnError(zfjniPointerOwnerZFAd, error.toString());
                        }
                    }
            );
        } else {
            impl.setFullScreenContentCallback(_implListener);
            impl.show(_ownerWindow.get());
            _ownerWindow.get().overridePendingTransition(
                    android.R.anim.fade_in
                    , android.R.anim.fade_out
            );
        }
    }

}

