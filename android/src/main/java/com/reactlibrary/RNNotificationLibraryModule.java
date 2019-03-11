
package com.reactlibrary;

import android.os.PowerManager;
import android.os.Build;
import android.support.v4.app.NotificationManagerCompat;
import android.content.Intent;
import android.provider.Settings;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.Set;

public class RNNotificationLibraryModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

  private static ReactApplicationContext reactContext;

  public RNNotificationLibraryModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    this.reactContext.addLifecycleEventListener(this);
  }

  @Override
  public String getName() {
    return "RNNotificationLibrary";
  }

  public static void sendEvent(String eventName, WritableMap params) {
    reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
  }

  private boolean isScreenOn() {
    PowerManager powerManager = (PowerManager) getCurrentActivity().getSystemService(getReactApplicationContext().POWER_SERVICE);
    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
        return powerManager.isInteractive();
    } else {
        return powerManager.isScreenOn();
    }
  }

  @Override
  public void onHostResume() {
    WritableMap params = Arguments.createMap();
    sendEvent("AppOpened", params);
  }

  @Override
  public void onHostPause() {
    WritableMap params = Arguments.createMap();
    if (isScreenOn()) {
      sendEvent("AppClosed", params);
    } else {
      sendEvent("ScreenLocked", params);
    }
  }

  @Override
  public void onHostDestroy() {
    WritableMap params = Arguments.createMap();
    sendEvent("AppClosed", params);
  }
}
