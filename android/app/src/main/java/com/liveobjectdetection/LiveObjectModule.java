package com.liveobjectdetection;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import java.util.Map;
import java.util.HashMap;

public class LiveObjectModule extends ReactContextBaseJavaModule {
   LiveObjectModule(ReactApplicationContext context) {
       super(context);
   }

   @Override
    public String getName() {
        return "CalendarModule";
    }

    @ReactMethod
    public void startNewActivity() {
        Intent myIntent = new Intent(CurrentActivity.this, NextActivity.class);
        CurrentActivity.this.startActivity(myIntent);
    }
}