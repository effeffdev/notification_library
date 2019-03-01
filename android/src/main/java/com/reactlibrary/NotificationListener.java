package com.reactlibrary;

import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;

public class NotificationListener extends NotificationListenerService {

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        if (sbn.getNotification().tickerText == null) {
            return;
        }

        WritableMap params = Arguments.createMap();
        RNNotificationLibraryModule.sendEvent("PopupDetected", params);
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {}
}
