package com.liveobjectdetection;

import com.facebook.react.ReactActivity;
import com.facebook.react.ReactActivityDelegate;
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.fabricEnabled;
import com.facebook.react.defaults.DefaultReactActivityDelegate;

public class NewActivity extends Activity {
 
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Log.i(this.getLocalClassName(),"Activity created.");
    }
 
    @Override
    protected void onRestart() {
        super.onRestart();
        Log.i(this.getLocalClassName(), "Activity restarted.");
    }
 
    @Override
    protected void onStart() {
        super.onStart();
        Log.i(this.getLocalClassName(), "Activity started.");
    }
 
    @Override
    protected void onResume() {
        super.onResume();
        Log.i(this.getLocalClassName(), "Activity resumed.");
    }
 
    @Override
    protected void onPause() {
        super.onPause();
        Log.i(this.getLocalClassName(), "Activity paused.");
    }
 
    @Override
    protected void onStop() {
        super.onStop();
        Log.i(this.getLocalClassName(), "Activity stopped.");
    }
 
    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i(this.getLocalClassName(), "Activity destroyed.");
    }
 
    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        Log.i(this.getLocalClassName(), "Restore instance.");
    }
 
    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        Log.i(this.getLocalClassName(), "Save instance.");
 
    }
}