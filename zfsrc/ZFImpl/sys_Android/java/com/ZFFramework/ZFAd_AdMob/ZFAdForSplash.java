package com.ZFFramework.ZFAd_AdMob;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.ZFFramework.NativeUtil.ZFAndroidLog;
import com.ZFFramework.NativeUtil.ZFRunnable;
import com.ZFFramework.NativeUtil.ZFString;
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

    public Object zfnativeImpl() {
        return impl;
    }

    public static Object native_nativeAdCreate(long zfjniPointerOwnerZFAd) {
        ZFAdForSplash nativeAd = new ZFAdForSplash();
        nativeAd.zfjniPointerOwnerZFAd = zfjniPointerOwnerZFAd;
        return nativeAd;
    }

    public static void native_nativeAdDestroy(Object nativeAd) {
        ZFAdForSplash nativeAdTmp = (ZFAdForSplash) nativeAd;
        nativeAdTmp.zfjniPointerOwnerZFAd = -1;
        nativeAdTmp._nativeAdStarted = false;
        nativeAdTmp.impl = null;
    }

    public static void native_nativeAdUpdate(
            Object nativeAd
            , String appId
            , String adId
    ) {
        ZFAdForSplash nativeAdTmp = (ZFAdForSplash) nativeAd;
        if (nativeAdTmp._appIdUpdateTaskId != ZFTaskId.INVALID) {
            ZFAd.appIdUpdateCancel(nativeAdTmp._appIdUpdateTaskId);
        }
        nativeAdTmp._adId = null;
        nativeAdTmp._appIdUpdateTaskId = ZFAd.appIdUpdate(new ZFRunnable.P2<Boolean, String>() {
            @Override
            public void run(Boolean success, String errorHint) {
                nativeAdTmp._appIdUpdateTaskId = ZFTaskId.INVALID;
                nativeAdTmp._adId = adId;
                nativeAdTmp._update();
            }
        });
    }

    public static void native_nativeAdStart(Object nativeAd, Object window) {
        ZFAdForSplash nativeAdTmp = (ZFAdForSplash) nativeAd;
        nativeAdTmp._nativeAdStarted = true;
        nativeAdTmp._window = new WeakReference<>((Activity) window);
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
    private WeakReference<Activity> _window = null;

    private final FullScreenContentCallback _implListener = new FullScreenContentCallback() {
        @Override
        public void onAdFailedToShowFullScreenContent(@NonNull AdError error) {
            ZFAndroidLog.p("[AdMob] onAdFailedToShowFullScreenContent: %s", error);
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnError(zfjniPointerOwnerZFAd, error.toString());
            }
        }

        @Override
        public void onAdShowedFullScreenContent() {
            ZFAndroidLog.p("[AdMob] onAdShowedFullScreenContent");
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnDisplay(zfjniPointerOwnerZFAd);
            }
        }

        @Override
        public void onAdDismissedFullScreenContent() {
            ZFAndroidLog.p("[AdMob] onAdDismissedFullScreenContent");
            if (zfjniPointerOwnerZFAd != -1) {
                _nativeAdStarted = false;
                _window = null;
                native_notifyAdOnStop(zfjniPointerOwnerZFAd, ZFResultType.e_Success);
            }
        }

        @Override
        public void onAdImpression() {
            ZFAndroidLog.p("[AdMob] onAdImpression");
        }

        @Override
        public void onAdClicked() {
            ZFAndroidLog.p("[AdMob] onAdClicked");
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnClick(zfjniPointerOwnerZFAd);
            }
        }
    };

    private void _update() {
        if (!_nativeAdStarted || ZFString.isEmpty(_adId)) {
            return;
        }
        if (_window == null || _window.get() == null) {
            native_notifyAdOnError(zfjniPointerOwnerZFAd, "[AdMob] unable to obtain window");
            return;
        }

        if (impl == null) {
            AppOpenAd.load(
                    _window.get()
                    , _adId
                    , new AdRequest.Builder().build()
                    , new AppOpenAd.AppOpenAdLoadCallback() {
                        @Override
                        public void onAdLoaded(@NonNull AppOpenAd appOpenAd) {
                            super.onAdLoaded(appOpenAd);
                            impl = appOpenAd;
                            ZFAndroidLog.p("[AdMob] onAdLoaded");
                            _update();
                        }

                        @Override
                        public void onAdFailedToLoad(@NonNull LoadAdError error) {
                            super.onAdFailedToLoad(error);
                            ZFAndroidLog.p("[AdMob] onAdFailedToLoad: %s", error);
                            impl = null;
                            native_notifyAdOnError(zfjniPointerOwnerZFAd, error.toString());
                        }
                    }
            );
        } else {
            impl.setFullScreenContentCallback(_implListener);
            impl.show(_window.get());
        }
    }

}

