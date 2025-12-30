package com.ZFFramework.ZFAd_AdMob;

import com.ZFFramework.NativeUtil.ZFAndroidAsync;
import com.ZFFramework.NativeUtil.ZFAndroidPost;
import com.ZFFramework.NativeUtil.ZFRunnable;
import com.ZFFramework.NativeUtil.ZFString;
import com.ZFFramework.NativeUtil.ZFTaskId;
import com.ZFFramework.ZF_impl.ZFMainEntry;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.initialization.AdapterStatus;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;

import java.util.List;
import java.util.Map;

/**
 * see https://developers.google.com/admob/android/quick-start
 */
public class ZFAd {

    public static boolean DEBUG = false;

    // callback(Boolean success, String errorHint)
    public static int appIdUpdate(String appId, ZFRunnable.P2<Boolean, String> callback) {
        if ((_initRunning || _initSuccess) && !ZFString.isEqual(_appId, appId)) {
            ZFRunnable.RUN(callback, false, String.format("[AdMob] registering a different appId: %s => %s", _appId, appId));
            return ZFTaskId.INVALID;
        }
        if (!_initRunning && _initSuccess) {
            ZFRunnable.RUN(callback, true, null);
            return ZFTaskId.INVALID;
        }
        if (!_initRunning) {
            _initRunning = true;
            _initSuccess = false;
            _appId = appId;
            ZFAndroidAsync.run(new Runnable() {
                @Override
                public void run() {
                    int resultCode = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(ZFMainEntry.appContext());
                    if (resultCode != ConnectionResult.SUCCESS) {
                        _notifyFinish(false, String.format("[AdMob] google play service not available: %s"
                                , GoogleApiAvailability.getInstance().getErrorString(resultCode)
                        ));
                        return;
                    }
                    MobileAds.initialize(ZFMainEntry.appContext(), new OnInitializationCompleteListener() {
                        @Override
                        public void onInitializationComplete(InitializationStatus initializationStatus) {
                            String info;
                            {
                                StringBuilder sb = new StringBuilder();
                                for (Map.Entry<String, AdapterStatus> entry : initializationStatus.getAdapterStatusMap().entrySet()) {
                                    if (sb.length() > 0) {
                                        sb.append(", ");
                                    }
                                    sb.append(entry.getKey());
                                    sb.append("=");
                                    sb.append(entry.getValue().getDescription());
                                }
                                info = sb.toString();
                            }
                            boolean success = !initializationStatus.getAdapterStatusMap().isEmpty();
                            _notifyFinish(success, info);
                        }
                    });
                }
            });
        }
        return _taskMap.obtain(callback);
    }

    public static void appIdUpdateCancel(int taskId) {
        _taskMap.release(taskId);
    }

    private static boolean _initRunning = false;
    private static boolean _initSuccess = false;
    private static String _appId = null;
    private static final ZFTaskId<ZFRunnable.P2<Boolean, String>> _taskMap = new ZFTaskId<>();

    private static void _notifyFinish(boolean success, String errorHint) {
        ZFAndroidPost.run(new Runnable() {
            @Override
            public void run() {
                _initRunning = false;
                _initSuccess = success;
                List<ZFRunnable.P2<Boolean, String>> tasks = _taskMap.releaseAll();
                for (ZFRunnable.P2<Boolean, String> task : tasks) {
                    task.run(success, errorHint);
                }
            }
        });
    }

}

