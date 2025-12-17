package com.ZFFramework.ZFAd_AdMob;

import androidx.annotation.NonNull;

import com.ZFFramework.NativeUtil.ZFAndroidLog;
import com.ZFFramework.NativeUtil.ZFAndroidPost;
import com.ZFFramework.NativeUtil.ZFRunnable;
import com.ZFFramework.NativeUtil.ZFTaskId;
import com.ZFFramework.ZF_impl.ZFMainEntry;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.initialization.AdapterStatus;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;

import java.util.List;
import java.util.Map;

public class ZFAd {

    public static int appIdUpdate(ZFRunnable.P2<Boolean, String> callback) {
        if (!_initRunning && _initSuccess) {
            ZFRunnable.RUN(callback, true, null);
            return ZFTaskId.INVALID;
        }
        if (!_initRunning) {
            _initRunning = true;
            _initSuccess = false;
            MobileAds.initialize(ZFMainEntry.appContext(), new OnInitializationCompleteListener() {
                @Override
                public void onInitializationComplete(@NonNull InitializationStatus initializationStatus) {
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
                    ZFAndroidLog.p("[AdMob] init finish: %s", info);
                    _notifyFinish(!initializationStatus.getAdapterStatusMap().isEmpty(), info);
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

