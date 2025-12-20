package com.ZFFramework.ZFAd_AdMob;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.ZFFramework.NativeUtil.ZFAndroidLog;
import com.ZFFramework.NativeUtil.ZFRunnable;
import com.ZFFramework.NativeUtil.ZFString;
import com.ZFFramework.NativeUtil.ZFTaskId;
import com.ZFFramework.ZF_impl.ZFMainEntry;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.LoadAdError;

import java.lang.ref.WeakReference;

public class ZFAdForBanner extends FrameLayout {

    public long zfjniPointerOwnerZFAd = -1;
    public AdView impl = null;

    public Object zfnativeImpl() {
        return impl;
    }

    public static Object native_nativeAdCreate(
            long zfjniPointerOwnerZFAd
            , String appId
            , String adId
    ) {
        ZFAdForBanner nativeAd = new ZFAdForBanner(ZFMainEntry.appContext());
        nativeAd.zfjniPointerOwnerZFAd = zfjniPointerOwnerZFAd;
        nativeAd._adId = adId;
        nativeAd._appIdUpdateTaskId = ZFAd.appIdUpdate(new ZFRunnable.P2<Boolean, String>() {
            @Override
            public void run(Boolean success, String error) {
                nativeAd._appIdUpdateTaskId = ZFTaskId.INVALID;
                if (success) {
                    nativeAd._update();
                } else {
                    ZFAndroidLog.p("[AdMob][banner] %s init fail: %s", nativeAd._adId, error);
                }
            }
        });
        return nativeAd;
    }

    public static void native_nativeAdDestroy(Object nativeAd) {
        ZFAdForBanner nativeAdTmp = (ZFAdForBanner) nativeAd;
        if (nativeAdTmp._appIdUpdateTaskId != ZFTaskId.INVALID) {
            ZFAd.appIdUpdateCancel(nativeAdTmp._appIdUpdateTaskId);
            nativeAdTmp._appIdUpdateTaskId = ZFTaskId.INVALID;
        }
        nativeAdTmp.zfjniPointerOwnerZFAd = -1;
        nativeAdTmp.impl = null;
    }

    public static int[] native_nativeAdMeasure(
            Object nativeAd
            , int widthHint
            , int heightHint
    ) {
        ZFAdForBanner nativeAdTmp = (ZFAdForBanner) nativeAd;
        if (nativeAdTmp._window == null || nativeAdTmp._window.get() == null) {
            return new int[]{0, 0};
        }
        Context context = nativeAdTmp._window.get();
        if (widthHint < 0) {
            DisplayMetrics dm = new DisplayMetrics();
            ((WindowManager) context.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getMetrics(dm);
            widthHint = dm.widthPixels;
            if (widthHint < 0) {
                widthHint = 240;
            }
        }
        AdSize implSize = AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(context, widthHint);
        if (nativeAdTmp._widthPrev != widthHint) {
            ZFAndroidLog.p("[AdMob][banner] %s size update: %s (%s %s)", nativeAdTmp._adId, widthHint, implSize.getWidth(), implSize.getHeight());
            nativeAdTmp.impl.setAdSize(implSize);
            nativeAdTmp.impl.loadAd(new AdRequest.Builder().build());
        }
        return new int[]{widthHint, implSize.getHeight()};
    }

    public static void native_nativeAdWindowUpdate(Object nativeAd, Object window) {
        if (window == null) {
            ZFAndroidLog.shouldNotGoHere();
            return;
        }
        ZFAdForBanner nativeAdTmp = (ZFAdForBanner) nativeAd;
        if (nativeAdTmp._window != null && nativeAdTmp._window.get() != null && nativeAdTmp._window.get() != window) {
            ZFAndroidLog.shouldNotGoHere();
            return;
        }
        nativeAdTmp._window = new WeakReference<>((Activity) window);
        nativeAdTmp._update();
    }

    // ============================================================
    public static native void native_notifyAdOnError(long zfjniPointerOwnerZFAd, String errorHint);

    public static native void native_notifyAdOnDisplay(long zfjniPointerOwnerZFAd);

    public static native void native_notifyAdOnClick(long zfjniPointerOwnerZFAd);

    public static native void native_notifyAdOnClose(long zfjniPointerOwnerZFAd);

    // ============================================================
    public ZFAdForBanner(Context context) {
        super(context);
    }

    public ZFAdForBanner(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ZFAdForBanner(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public ZFAdForBanner(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    // ============================================================
    private int _appIdUpdateTaskId = ZFTaskId.INVALID;
    private String _adId = null;
    private WeakReference<Activity> _window = null;
    private int _widthPrev = -1;

    private final AdListener _implListener = new AdListener() {
        @Override
        public void onAdClosed() {
            ZFAndroidLog.p("[AdMob][banner] %s onAdClosed", _adId);
        }

        @Override
        public void onAdFailedToLoad(@NonNull LoadAdError error) {
            ZFAndroidLog.p("[AdMob][banner] %s onAdFailedToLoad: %s", _adId, error);
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnError(zfjniPointerOwnerZFAd, error.toString());
            }
        }

        @Override
        public void onAdOpened() {
            ZFAndroidLog.p("[AdMob][banner] %s onAdOpened", _adId);
        }

        @Override
        public void onAdLoaded() {
            ZFAndroidLog.p("[AdMob][banner] %s onAdLoaded", _adId);
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnDisplay(zfjniPointerOwnerZFAd);
            }
        }

        @Override
        public void onAdClicked() {
            ZFAndroidLog.p("[AdMob][banner] %s onAdClicked", _adId);
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnClick(zfjniPointerOwnerZFAd);
            }
        }

        @Override
        public void onAdImpression() {
            ZFAndroidLog.p("[AdMob][banner] %s onAdImpression", _adId);
            if (zfjniPointerOwnerZFAd != -1) {
                native_notifyAdOnClose(zfjniPointerOwnerZFAd);
            }
        }

        @Override
        public void onAdSwipeGestureClicked() {
            ZFAndroidLog.p("[AdMob][banner] %s onAdSwipeGestureClicked", _adId);
        }
    };

    private void _update() {
        if (ZFString.isEmpty(_adId)
                || _window == null || _window.get() == null
        ) {
            return;
        }

        if (impl == null) {
            impl = new AdView(_window.get());
            this.addView(impl, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            impl.setAdListener(_implListener);
        }
        impl.setAdUnitId(_adId);
        ZFAndroidLog.p("[AdMob][banner] %s update", _adId);
    }

}

