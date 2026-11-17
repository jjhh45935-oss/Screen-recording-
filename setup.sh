#!/bin/bash
set -e

mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/xml
mkdir -p app/src/main/java/com/screen/recorder

cat << 'EOF' > settings.gradle
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "ScreenRecorderApp"
include ':app'
EOF

cat << 'EOF' > build.gradle
plugins {
    id 'com.android.application' version '8.9.1' apply false
}
EOF

cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=false
EOF

cat << 'EOF' > app/build.gradle
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.screen.recorder'
    compileSdk 35

    defaultConfig {
        applicationId "com.screen.recorder"
        minSdk 24
        targetSdk 35
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.7.0'
    implementation 'com.google.android.material:material:1.12.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.2.0'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
}
EOF

cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        android:allowBackup="true"
        android:icon="@drawable/ic_rec_logo"
        android:label="@string/app_name"
        android:roundIcon="@drawable/ic_rec_logo"
        android:supportsRtl="true"
        android:theme="@style/Theme.ScreenRec">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity
            android:name=".ProjectionRequestActivity"
            android:excludeFromRecents="true"
            android:exported="false"
            android:theme="@style/Theme.Transparent" />

        <service
            android:name=".ScreenRecordService"
            android:exported="false"
            android:foregroundServiceType="specialUse|mediaProjection|microphone">
            <property
                android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
                android:value="Floating screen recorder overlay controls" />
        </service>

        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="com.screen.recorder.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>

    </application>
</manifest>
EOF

cat << 'EOF' > app/src/main/res/xml/file_paths.xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-files-path name="movies" path="." />
    <cache-path name="cache" path="." />
</paths>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_rec_logo.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#DC2626"
        android:pathData="M12,2A10,10 0 1,0 22,12A10,10 0 0,0 12,2Z" />
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M12,7A5,5 0 1,0 17,12A5,5 0 0,0 12,7Z" />
</vector>
EOF

cat << 'EOF' > app/src/main/res/drawable/bg_floating_pill.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#E6111827" />
    <corners android:radius="26dp" />
    <stroke android:width="1.5dp" android:color="#4B5563" />
</shape>
EOF

cat << 'EOF' > app/src/main/res/values/colors.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary">#DC2626</color>
    <color name="primary_dark">#991B1B</color>
    <color name="accent">#2563EB</color>
    <color name="bg_light">#F3F4F6</color>
    <color name="white">#FFFFFF</color>
    <color name="text_dark">#111827</color>
    <color name="text_gray">#6B7280</color>
    <color name="green">#10B981</color>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/strings.xml
<resources>
    <string name="app_name">Pro Screen Recorder</string>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/themes.xml
<resources>
    <style name="Theme.ScreenRec" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/primary</item>
        <item name="colorPrimaryVariant">@color/primary_dark</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="android:statusBarColor">@color/primary_dark</item>
    </style>

    <style name="Theme.Transparent" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="android:windowIsTranslucent">true</item>
        <item name="android:windowBackground">@android:color/transparent</item>
        <item name="android:windowContentOverlay">@null</item>
        <item name="android:windowNoTitle">true</item>
        <item name="android:backgroundDimEnabled">false</item>
    </style>
</resources>
EOF

cat << 'EOF' > app/src/main/res/layout/activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/bg_light"
    android:orientation="vertical">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="@color/primary"
        android:orientation="vertical"
        android:padding="16dp">

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Pro Screen Recorder"
            android:textColor="@color/white"
            android:textSize="21sp"
            android:textStyle="bold" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="2dp"
            android:text="Floating Bubble + Pencil Draw + Mic ON/OFF"
            android:textColor="#FEE2E2"
            android:textSize="13sp" />
    </LinearLayout>

    <com.google.android.material.card.MaterialCardView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_margin="14dp"
        app:cardCornerRadius="14dp"
        app:cardElevation="3dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:padding="16dp">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:gravity="center_vertical"
                android:orientation="horizontal">

                <TextView
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="Microphone Audio (Mic ON/OFF)"
                    android:textColor="@color/text_dark"
                    android:textSize="15sp"
                    android:textStyle="bold" />

                <androidx.appcompat.widget.SwitchCompat
                    android:id="@+id/switchMic"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:checked="true" />
            </LinearLayout>

            <TextView
                android:id="@+id/tvPermStatus"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:text="Display Over Apps: Checking..."
                android:textColor="@color/text_gray"
                android:textSize="12sp" />

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnShowFloating"
                android:layout_width="match_parent"
                android:layout_height="52dp"
                android:layout_marginTop="14dp"
                android:text="Start Floating Recorder Bubble"
                android:textAllCaps="false"
                android:textSize="15sp"
                android:textStyle="bold"
                app:cornerRadius="12dp" />

        </LinearLayout>
    </com.google.android.material.card.MaterialCardView>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:paddingHorizontal="16dp">

        <TextView
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Saved Recordings"
            android:textColor="@color/text_dark"
            android:textSize="16sp"
            android:textStyle="bold" />

        <Button
            android:id="@+id/btnRefresh"
            style="?android:attr/borderlessButtonStyle"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Refresh"
            android:textAllCaps="false"
            android:textColor="@color/accent" />
    </LinearLayout>

    <TextView
        android:id="@+id/tvEmptyVideos"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center"
        android:padding="28dp"
        android:text="Abhi koi recording nahi hai. Upar Floating Bubble start karein!"
        android:textColor="@color/text_gray"
        android:visibility="gone" />

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rvVideos"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:paddingHorizontal="12dp"
        android:paddingBottom="12dp" />

</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/item_video.xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="10dp"
    app:cardCornerRadius="12dp"
    app:cardElevation="2dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:padding="12dp">

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/tvVidName"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:ellipsize="end"
                android:maxLines="1"
                android:text="Rec_1234.mp4"
                android:textColor="@color/text_dark"
                android:textSize="14sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/tvVidMeta"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="2dp"
                android:text="4.2 MB"
                android:textColor="@color/text_gray"
                android:textSize="12sp" />
        </LinearLayout>

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnPlay"
            android:layout_width="wrap_content"
            android:layout_height="38dp"
            android:layout_marginEnd="6dp"
            android:backgroundTint="@color/green"
            android:text="Play"
            android:textAllCaps="false"
            android:textSize="12sp" />

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnShare"
            style="@style/Widget.MaterialComponents.Button.OutlinedButton"
            android:layout_width="wrap_content"
            android:layout_height="38dp"
            android:layout_marginEnd="6dp"
            android:text="Share"
            android:textAllCaps="false"
            android:textSize="12sp" />

        <TextView
            android:id="@+id/btnDelete"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:padding="8dp"
            android:text="✕"
            android:textColor="@color/primary"
            android:textSize="16sp"
            android:textStyle="bold" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat << 'EOF' > app/src/main/res/layout/layout_floating_panel.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:background="@drawable/bg_floating_pill"
    android:gravity="center_vertical"
    android:orientation="horizontal"
    android:paddingHorizontal="10dp"
    android:paddingVertical="6dp">

    <TextView
        android:id="@+id/tvDragHandle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:paddingHorizontal="6dp"
        android:paddingVertical="4dp"
        android:text="⋮⋮"
        android:textColor="#9CA3AF"
        android:textSize="16sp"
        android:textStyle="bold" />

    <TextView
        android:id="@+id/tvFloatTimer"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginEnd="6dp"
        android:text="00:00"
        android:textColor="#FBBF24"
        android:textSize="13sp"
        android:textStyle="bold"
        android:visibility="gone" />

    <TextView
        android:id="@+id/btnFloatRec"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginHorizontal="4dp"
        android:background="#DC2626"
        android:paddingHorizontal="10dp"
        android:paddingVertical="5dp"
        android:text="● REC"
        android:textColor="#FFFFFF"
        android:textSize="12sp"
        android:textStyle="bold" />

    <TextView
        android:id="@+id/btnFloatMic"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginHorizontal="4dp"
        android:background="#059669"
        android:paddingHorizontal="8dp"
        android:paddingVertical="5dp"
        android:text="MIC ON"
        android:textColor="#FFFFFF"
        android:textSize="11sp"
        android:textStyle="bold" />

    <TextView
        android:id="@+id/btnFloatPause"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginHorizontal="4dp"
        android:background="#2563EB"
        android:paddingHorizontal="9dp"
        android:paddingVertical="5dp"
        android:text="⏸"
        android:textColor="#FFFFFF"
        android:textSize="13sp"
        android:textStyle="bold"
        android:visibility="gone" />

    <TextView
        android:id="@+id/btnFloatPencil"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginHorizontal="4dp"
        android:background="#D97706"
        android:paddingHorizontal="9dp"
        android:paddingVertical="5dp"
        android:text="✏️"
        android:textColor="#FFFFFF"
        android:textSize="13sp"
        android:visibility="gone" />

    <TextView
        android:id="@+id/btnFloatStop"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginHorizontal="4dp"
        android:background="#DC2626"
        android:paddingHorizontal="10dp"
        android:paddingVertical="5dp"
        android:text="⏹ SAVE"
        android:textColor="#FFFFFF"
        android:textSize="11sp"
        android:textStyle="bold"
        android:visibility="gone" />

    <TextView
        android:id="@+id/btnFloatClose"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:paddingHorizontal="8dp"
        android:paddingVertical="4dp"
        android:text="✕"
        android:textColor="#F87171"
        android:textSize="15sp"
        android:textStyle="bold" />
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/layout_draw_toolbar.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:background="@drawable/bg_floating_pill"
    android:gravity="center_vertical"
    android:orientation="horizontal"
    android:paddingHorizontal="10dp"
    android:paddingVertical="8dp">

    <View
        android:id="@+id/colRed"
        android:layout_width="26dp"
        android:layout_height="26dp"
        android:layout_marginHorizontal="4dp"
        android:background="#EF4444" />

    <View
        android:id="@+id/colYellow"
        android:layout_width="26dp"
        android:layout_height="26dp"
        android:layout_marginHorizontal="4dp"
        android:background="#FACC15" />

    <View
        android:id="@+id/colBlue"
        android:layout_width="26dp"
        android:layout_height="26dp"
        android:layout_marginHorizontal="4dp"
        android:background="#3B82F6" />

    <View
        android:id="@+id/colGreen"
        android:layout_width="26dp"
        android:layout_height="26dp"
        android:layout_marginHorizontal="4dp"
        android:background="#22C55E" />

    <View
        android:id="@+id/colWhite"
        android:layout_width="26dp"
        android:layout_height="26dp"
        android:layout_marginHorizontal="4dp"
        android:background="#FFFFFF" />

    <TextView
        android:id="@+id/btnBrushUndo"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="8dp"
        android:background="#374151"
        android:paddingHorizontal="8dp"
        android:paddingVertical="5dp"
        android:text="Undo"
        android:textColor="#FFFFFF"
        android:textSize="12sp"
        android:textStyle="bold" />

    <TextView
        android:id="@+id/btnBrushClear"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="6dp"
        android:background="#374151"
        android:paddingHorizontal="8dp"
        android:paddingVertical="5dp"
        android:text="Clear"
        android:textColor="#FFFFFF"
        android:textSize="12sp"
        android:textStyle="bold" />

    <TextView
        android:id="@+id/btnBrushDone"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="6dp"
        android:background="#10B981"
        android:paddingHorizontal="9dp"
        android:paddingVertical="5dp"
        android:text="✓ Done"
        android:textColor="#FFFFFF"
        android:textSize="12sp"
        android:textStyle="bold" />
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/java/com/screen/recorder/DrawOverlayView.java
package com.screen.recorder;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.view.MotionEvent;
import android.view.View;

import java.util.ArrayList;
import java.util.List;

public class DrawOverlayView extends View {

    private static class Stroke {
        Path path;
        Paint paint;

        Stroke(Path path, Paint paint) {
            this.path = path;
            this.paint = paint;
        }
    }

    private final List<Stroke> strokes = new ArrayList<>();
    private Path currentPath;
    private Paint currentPaint;
    private int activeColor = Color.RED;

    public DrawOverlayView(Context context) {
        super(context);
    }

    public void setBrushColor(int color) {
        this.activeColor = color;
    }

    public void undo() {
        if (!strokes.isEmpty()) {
            strokes.remove(strokes.size() - 1);
            invalidate();
        }
    }

    public void clearAll() {
        strokes.clear();
        invalidate();
    }

    private Paint createPaint(int color) {
        Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
        p.setColor(color);
        p.setStyle(Paint.Style.STROKE);
        p.setStrokeWidth(10f);
        p.setStrokeCap(Paint.Cap.ROUND);
        p.setStrokeJoin(Paint.Join.ROUND);
        return p;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        for (Stroke s : strokes) {
            canvas.drawPath(s.path, s.paint);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        float x = event.getX();
        float y = event.getY();

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                currentPath = new Path();
                currentPath.moveTo(x, y);
                currentPaint = createPaint(activeColor);
                strokes.add(new Stroke(currentPath, currentPaint));
                invalidate();
                return true;
            case MotionEvent.ACTION_MOVE:
                if (currentPath != null) {
                    currentPath.lineTo(x, y);
                    invalidate();
                }
                return true;
            case MotionEvent.ACTION_UP:
                return true;
        }
        return super.onTouchEvent(event);
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/screen/recorder/ProjectionRequestActivity.java
package com.screen.recorder;

import android.app.Activity;
import android.content.Intent;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.Bundle;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

public class ProjectionRequestActivity extends AppCompatActivity {

    private ActivityResultLauncher<Intent> launcher;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        launcher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    if (result.getResultCode() == Activity.RESULT_OK && result.getData() != null) {
                        Intent serviceIntent = new Intent(this, ScreenRecordService.class);
                        serviceIntent.setAction(ScreenRecordService.ACTION_START_RECORDING);
                        serviceIntent.putExtra(ScreenRecordService.EXTRA_RESULT_CODE, result.getResultCode());
                        serviceIntent.putExtra(ScreenRecordService.EXTRA_RESULT_DATA, result.getData());
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(serviceIntent);
                        } else {
                            startService(serviceIntent);
                        }
                    } else {
                        Toast.makeText(this, "Screen recording permission cancel hui", Toast.LENGTH_SHORT).show();
                    }
                    finish();
                }
        );

        MediaProjectionManager mpm = (MediaProjectionManager) getSystemService(MEDIA_PROJECTION_SERVICE);
        if (mpm != null) {
            launcher.launch(mpm.createScreenCaptureIntent());
        } else {
            finish();
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/screen/recorder/ScreenRecordService.java
package com.screen.recorder;

import android.Manifest;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.ContentValues;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ServiceInfo;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.MediaRecorder;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.provider.MediaStore;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class ScreenRecordService extends Service {

    public static final String ACTION_SHOW_FLOATING = "com.screen.recorder.SHOW_FLOATING";
    public static final String ACTION_START_RECORDING = "com.screen.recorder.START_RECORDING";
    public static final String ACTION_SET_MIC = "com.screen.recorder.SET_MIC";
    public static final String EXTRA_RESULT_CODE = "result_code";
    public static final String EXTRA_RESULT_DATA = "result_data";
    public static final String EXTRA_MIC_ENABLED = "mic_enabled";

    private static final String CHANNEL_ID = "screen_rec_channel";
    private static final int NOTIF_ID = 101;

    private WindowManager windowManager;
    private View floatingView;
    private WindowManager.LayoutParams floatingParams;

    private DrawOverlayView drawOverlayView;
    private View drawToolbarView;

    private TextView tvTimer, btnRec, btnMic, btnPause, btnPencil, btnStop, btnClose;

    private MediaProjectionManager projectionManager;
    private MediaProjection mediaProjection;
    private VirtualDisplay virtualDisplay;
    private MediaRecorder mediaRecorder;

    private File currentOutputFile;
    private boolean isRecording = false;
    private boolean isPaused = false;
    private boolean micEnabled = true;
    private boolean isDrawingOpen = false;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private int elapsedSeconds = 0;

    private final Runnable timerRunnable = new Runnable() {
        @Override
        public void run() {
            if (isRecording && !isPaused) {
                elapsedSeconds++;
                int mins = elapsedSeconds / 60;
                int secs = elapsedSeconds % 60;
                if (tvTimer != null) {
                    tvTimer.setText(String.format(Locale.getDefault(), "%02d:%02d", mins, secs));
                }
            }
            if (isRecording) {
                handler.postDelayed(this, 1000);
            }
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        projectionManager = (MediaProjectionManager) getSystemService(MEDIA_PROJECTION_SERVICE);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null) return START_NOT_STICKY;
        String action = intent.getAction();

        if (ACTION_SET_MIC.equals(action)) {
            micEnabled = intent.getBooleanExtra(EXTRA_MIC_ENABLED, true);
            updateMicUi();
            return START_STICKY;
        }

        if (ACTION_SHOW_FLOATING.equals(action)) {
            micEnabled = intent.getBooleanExtra(EXTRA_MIC_ENABLED, micEnabled);
            startForegroundCompat("Floating Recorder Ready", false, false);
            showFloatingControls();
            return START_STICKY;
        }

        if (ACTION_START_RECORDING.equals(action)) {
            int code = intent.getIntExtra(EXTRA_RESULT_CODE, -1);
            Intent data = intent.getParcelableExtra(EXTRA_RESULT_DATA);
            if (code != -1 && data != null) {
                startScreenRecording(code, data);
            }
        }
        return START_STICKY;
    }

    private void startForegroundCompat(String text, boolean projectionActive, boolean useMic) {
        Notification notif = buildNotification(text);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            int types;
            if (projectionActive) {
                types = ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION;
                if (useMic) {
                    types |= ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE;
                }
            } else {
                types = ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE;
            }
            startForeground(NOTIF_ID, notif, types);
        } else {
            startForeground(NOTIF_ID, notif);
        }
    }

    private Notification buildNotification(String text) {
        Intent openIntent = new Intent(this, MainActivity.class);
        PendingIntent pi = PendingIntent.getActivity(this, 0, openIntent, PendingIntent.FLAG_IMMUTABLE);

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Pro Screen Recorder")
                .setContentText(text)
                .setSmallIcon(R.drawable.ic_rec_logo)
                .setContentIntent(pi)
                .setOngoing(true)
                .build();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel ch = new NotificationChannel(CHANNEL_ID, "Screen Recording", NotificationManager.IMPORTANCE_LOW);
            NotificationManager nm = getSystemService(NotificationManager.class);
            if (nm != null) nm.createNotificationChannel(ch);
        }
    }

    private void showFloatingControls() {
        if (floatingView != null) {
            updateMicUi();
            return;
        }

        int overlayType = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                : WindowManager.LayoutParams.TYPE_PHONE;

        floatingParams = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                overlayType,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
        );
        floatingParams.gravity = Gravity.TOP | Gravity.START;
        floatingParams.x = 30;
        floatingParams.y = 220;

        floatingView = LayoutInflater.from(this).inflate(R.layout.layout_floating_panel, null);

        View dragHandle = floatingView.findViewById(R.id.tvDragHandle);
        tvTimer = floatingView.findViewById(R.id.tvFloatTimer);
        btnRec = floatingView.findViewById(R.id.btnFloatRec);
        btnMic = floatingView.findViewById(R.id.btnFloatMic);
        btnPause = floatingView.findViewById(R.id.btnFloatPause);
        btnPencil = floatingView.findViewById(R.id.btnFloatPencil);
        btnStop = floatingView.findViewById(R.id.btnFloatStop);
        btnClose = floatingView.findViewById(R.id.btnFloatClose);

        dragHandle.setOnTouchListener(new View.OnTouchListener() {
            private int initX, initY;
            private float touchX, touchY;

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        initX = floatingParams.x;
                        initY = floatingParams.y;
                        touchX = event.getRawX();
                        touchY = event.getRawY();
                        return true;
                    case MotionEvent.ACTION_MOVE:
                        floatingParams.x = initX + (int) (event.getRawX() - touchX);
                        floatingParams.y = initY + (int) (event.getRawY() - touchY);
                        windowManager.updateViewLayout(floatingView, floatingParams);
                        return true;
                }
                return false;
            }
        });

        btnRec.setOnClickListener(v -> {
            Intent req = new Intent(this, ProjectionRequestActivity.class);
            req.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(req);
        });

        btnMic.setOnClickListener(v -> {
            if (isRecording) {
                Toast.makeText(this, "Recording ke dauran mic change nahi hoga, Stop karke toggle karein", Toast.LENGTH_SHORT).show();
                return;
            }
            micEnabled = !micEnabled;
            updateMicUi();
        });

        btnPause.setOnClickListener(v -> togglePause());
        btnPencil.setOnClickListener(v -> toggleDrawingMode());
        btnStop.setOnClickListener(v -> stopRecordingAndSave());
        btnClose.setOnClickListener(v -> {
            if (isRecording) stopRecordingAndSave();
            stopSelf();
        });

        updateMicUi();
        windowManager.addView(floatingView, floatingParams);
    }

    private void updateMicUi() {
        if (btnMic == null) return;
        if (micEnabled) {
            btnMic.setText("MIC ON");
            btnMic.setBackgroundColor(Color.parseColor("#059669"));
        } else {
            btnMic.setText("MIC OFF");
            btnMic.setBackgroundColor(Color.parseColor("#6B7280"));
        }
    }

    private void startScreenRecording(int resultCode, Intent data) {
        if (isRecording) return;

        boolean hasAudioPerm = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;
        boolean useMic = micEnabled && hasAudioPerm;

        startForegroundCompat("Screen Recording Active...", true, useMic);
        showFloatingControls();

        try {
            mediaProjection = projectionManager.getMediaProjection(resultCode, data);
            if (mediaProjection == null) {
                Toast.makeText(this, "MediaProjection fail hua", Toast.LENGTH_SHORT).show();
                return;
            }

            mediaProjection.registerCallback(new MediaProjection.Callback() {
                @Override
                public void onStop() {
                    if (isRecording) {
                        stopRecordingAndSave();
                    }
                }
            }, handler);

            DisplayMetrics metrics = getResources().getDisplayMetrics();
            int density = metrics.densityDpi;
            int rawW = metrics.widthPixels;
            int rawH = metrics.heightPixels;

            // Scale cleanly to max 720p width & multiple of 16 for 100% hardware compatibility
            int width = Math.min(rawW, 720);
            int height = (int) ((double) width * rawH / rawW);
            width = (width / 16) * 16;
            height = (height / 16) * 16;
            if (width <= 0) width = 720;
            if (height <= 0) height = 1280;

            File dir = getExternalFilesDir(Environment.DIRECTORY_MOVIES);
            if (dir != null && !dir.exists()) dir.mkdirs();
            String ts = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
            currentOutputFile = new File(dir, "Rec_" + ts + ".mp4");

            mediaRecorder = new MediaRecorder();
            if (useMic) {
                mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
            }
            mediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
            mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            mediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
            if (useMic) {
                mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
                mediaRecorder.setAudioEncodingBitRate(128000);
                mediaRecorder.setAudioSamplingRate(44100);
            }
            mediaRecorder.setVideoEncodingBitRate(5000000);
            mediaRecorder.setVideoFrameRate(30);
            mediaRecorder.setVideoSize(width, height);
            mediaRecorder.setOutputFile(currentOutputFile.getAbsolutePath());
            mediaRecorder.prepare();

            virtualDisplay = mediaProjection.createVirtualDisplay(
                    "ProScreenRec",
                    width, height, density,
                    DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                    mediaRecorder.getSurface(),
                    null, null
            );

            mediaRecorder.start();
            isRecording = true;
            isPaused = false;
            elapsedSeconds = 0;
            handler.postDelayed(timerRunnable, 1000);
            updateRecordingUi(true);
            Toast.makeText(this, "Recording Shuru Ho Gayi!", Toast.LENGTH_SHORT).show();

        } catch (Exception e) {
            Toast.makeText(this, "Recording Error: " + e.getMessage(), Toast.LENGTH_LONG).show();
            cleanupProjection();
            updateRecordingUi(false);
        }
    }

    private void togglePause() {
        if (!isRecording || mediaRecorder == null) return;
        try {
            if (!isPaused) {
                mediaRecorder.pause();
                isPaused = true;
                btnPause.setText("▶");
            } else {
                mediaRecorder.resume();
                isPaused = false;
                btnPause.setText("⏸");
            }
        } catch (Exception ignored) {}
    }

    private void stopRecordingAndSave() {
        isRecording = false;
        isPaused = false;
        handler.removeCallbacks(timerRunnable);
        hideDrawingMode();

        try {
            if (mediaRecorder != null) {
                mediaRecorder.stop();
            }
        } catch (Exception ignored) {}

        cleanupProjection();
        updateRecordingUi(false);
        startForegroundCompat("Floating Recorder Ready", false, false);

        if (currentOutputFile != null && currentOutputFile.exists() && currentOutputFile.length() > 0) {
            exportToGallery(currentOutputFile);
            Toast.makeText(this, "Recording Save Ho Gayi: " + currentOutputFile.getName(), Toast.LENGTH_LONG).show();
        }
    }

    private void exportToGallery(File source) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                ContentValues cv = new ContentValues();
                cv.put(MediaStore.Video.Media.DISPLAY_NAME, source.getName());
                cv.put(MediaStore.Video.Media.MIME_TYPE, "video/mp4");
                cv.put(MediaStore.Video.Media.RELATIVE_PATH, Environment.DIRECTORY_MOVIES + "/ScreenRecorder");
                Uri uri = getContentResolver().insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, cv);
                if (uri != null) {
                    OutputStream os = getContentResolver().openOutputStream(uri);
                    if (os != null) {
                        FileInputStream fis = new FileInputStream(source);
                        byte[] buf = new byte[8192];
                        int len;
                        while ((len = fis.read(buf)) > 0) os.write(buf, 0, len);
                        fis.close();
                        os.close();
                    }
                }
            } catch (Exception ignored) {}
        }
    }

    private void cleanupProjection() {
        try {
            if (mediaRecorder != null) {
                mediaRecorder.reset();
                mediaRecorder.release();
                mediaRecorder = null;
            }
        } catch (Exception ignored) {}

        if (virtualDisplay != null) {
            virtualDisplay.release();
            virtualDisplay = null;
        }
        if (mediaProjection != null) {
            mediaProjection.stop();
            mediaProjection = null;
        }
    }

    private void updateRecordingUi(boolean recording) {
        if (btnRec == null) return;
        btnRec.setVisibility(recording ? View.GONE : View.VISIBLE);
        btnMic.setVisibility(recording ? View.GONE : View.VISIBLE);
        tvTimer.setVisibility(recording ? View.VISIBLE : View.GONE);
        btnPause.setVisibility(recording ? View.VISIBLE : View.GONE);
        btnPencil.setVisibility(recording ? View.VISIBLE : View.GONE);
        btnStop.setVisibility(recording ? View.VISIBLE : View.GONE);
        if (!recording) {
            tvTimer.setText("00:00");
            btnPause.setText("⏸");
        }
    }

    private void toggleDrawingMode() {
        if (isDrawingOpen) {
            hideDrawingMode();
        } else {
            showDrawingMode();
        }
    }

    private void showDrawingMode() {
        if (isDrawingOpen) return;
        isDrawingOpen = true;

        int overlayType = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                : WindowManager.LayoutParams.TYPE_PHONE;

        drawOverlayView = new DrawOverlayView(this);
        WindowManager.LayoutParams canvasParams = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                overlayType,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
        );
        windowManager.addView(drawOverlayView, canvasParams);

        drawToolbarView = LayoutInflater.from(this).inflate(R.layout.layout_draw_toolbar, null);
        WindowManager.LayoutParams barParams = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                overlayType,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
        );
        barParams.gravity = Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;
        barParams.y = 80;

        drawToolbarView.findViewById(R.id.colRed).setOnClickListener(v -> drawOverlayView.setBrushColor(Color.parseColor("#EF4444")));
        drawToolbarView.findViewById(R.id.colYellow).setOnClickListener(v -> drawOverlayView.setBrushColor(Color.parseColor("#FACC15")));
        drawToolbarView.findViewById(R.id.colBlue).setOnClickListener(v -> drawOverlayView.setBrushColor(Color.parseColor("#3B82F6")));
        drawToolbarView.findViewById(R.id.colGreen).setOnClickListener(v -> drawOverlayView.setBrushColor(Color.parseColor("#22C55E")));
        drawToolbarView.findViewById(R.id.colWhite).setOnClickListener(v -> drawOverlayView.setBrushColor(Color.WHITE));
        drawToolbarView.findViewById(R.id.btnBrushUndo).setOnClickListener(v -> drawOverlayView.undo());
        drawToolbarView.findViewById(R.id.btnBrushClear).setOnClickListener(v -> drawOverlayView.clearAll());
        drawToolbarView.findViewById(R.id.btnBrushDone).setOnClickListener(v -> hideDrawingMode());

        windowManager.addView(drawToolbarView, barParams);
    }

    private void hideDrawingMode() {
        isDrawingOpen = false;
        if (drawOverlayView != null) {
            try { windowManager.removeView(drawOverlayView); } catch (Exception ignored) {}
            drawOverlayView = null;
        }
        if (drawToolbarView != null) {
            try { windowManager.removeView(drawToolbarView); } catch (Exception ignored) {}
            drawToolbarView = null;
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(timerRunnable);
        hideDrawingMode();
        cleanupProjection();
        if (floatingView != null) {
            try { windowManager.removeView(floatingView); } catch (Exception ignored) {}
            floatingView = null;
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/screen/recorder/VideoItem.java
package com.screen.recorder;

import java.io.File;

public class VideoItem {
    public File file;
    public String name;
    public String sizeText;

    public VideoItem(File file, String name, String sizeText) {
        this.file = file;
        this.name = name;
        this.sizeText = sizeText;
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/screen/recorder/VideoAdapter.java
package com.screen.recorder;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;

import java.util.List;

public class VideoAdapter extends RecyclerView.Adapter<VideoAdapter.VidVH> {

    public interface Listener {
        void onPlay(VideoItem item);
        void onShare(VideoItem item);
        void onDelete(VideoItem item);
    }

    private final List<VideoItem> list;
    private final Listener listener;

    public VideoAdapter(List<VideoItem> list, Listener listener) {
        this.list = list;
        this.listener = listener;
    }

    @NonNull
    @Override
    public VidVH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_video, parent, false);
        return new VidVH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VidVH holder, int position) {
        VideoItem item = list.get(position);
        holder.tvName.setText(item.name);
        holder.tvMeta.setText(item.sizeText);
        holder.btnPlay.setOnClickListener(v -> listener.onPlay(item));
        holder.btnShare.setOnClickListener(v -> listener.onShare(item));
        holder.btnDelete.setOnClickListener(v -> listener.onDelete(item));
    }

    @Override
    public int getItemCount() {
        return list.size();
    }

    static class VidVH extends RecyclerView.ViewHolder {
        TextView tvName, tvMeta, btnDelete;
        MaterialButton btnPlay, btnShare;

        VidVH(@NonNull View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvVidName);
            tvMeta = itemView.findViewById(R.id.tvVidMeta);
            btnPlay = itemView.findViewById(R.id.btnPlay);
            btnShare = itemView.findViewById(R.id.btnShare);
            btnDelete = itemView.findViewById(R.id.btnDelete);
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/screen/recorder/MainActivity.java
package com.screen.recorder;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private static final int REQ_PERMS = 201;

    private SwitchCompat switchMic;
    private TextView tvPermStatus, tvEmptyVideos;
    private final List<VideoItem> videoList = new ArrayList<>();
    private VideoAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        switchMic = findViewById(R.id.switchMic);
        tvPermStatus = findViewById(R.id.tvPermStatus);
        tvEmptyVideos = findViewById(R.id.tvEmptyVideos);

        RecyclerView rvVideos = findViewById(R.id.rvVideos);
        rvVideos.setLayoutManager(new LinearLayoutManager(this));
        adapter = new VideoAdapter(videoList, new VideoAdapter.Listener() {
            @Override
            public void onPlay(VideoItem item) {
                Uri uri = FileProvider.getUriForFile(MainActivity.this, "com.screen.recorder.fileprovider", item.file);
                Intent play = new Intent(Intent.ACTION_VIEW);
                play.setDataAndType(uri, "video/mp4");
                play.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                try {
                    startActivity(play);
                } catch (Exception e) {
                    Toast.makeText(MainActivity.this, "Video player nahi mila", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onShare(VideoItem item) {
                Uri uri = FileProvider.getUriForFile(MainActivity.this, "com.screen.recorder.fileprovider", item.file);
                Intent share = new Intent(Intent.ACTION_SEND);
                share.setType("video/mp4");
                share.putExtra(Intent.EXTRA_STREAM, uri);
                share.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                startActivity(Intent.createChooser(share, "Share Recording"));
            }

            @Override
            public void onDelete(VideoItem item) {
                if (item.file.delete()) {
                    loadVideos();
                    Toast.makeText(MainActivity.this, "Video deleted", Toast.LENGTH_SHORT).show();
                }
            }
        });
        rvVideos.setAdapter(adapter);

        switchMic.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked && ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                requestNeededPermissions();
            }
            Intent micIntent = new Intent(this, ScreenRecordService.class);
            micIntent.setAction(ScreenRecordService.ACTION_SET_MIC);
            micIntent.putExtra(ScreenRecordService.EXTRA_MIC_ENABLED, isChecked);
            startService(micIntent);
        });

        findViewById(R.id.btnShowFloating).setOnClickListener(v -> launchFloatingRecorder());
        findViewById(R.id.btnRefresh).setOnClickListener(v -> loadVideos());

        requestNeededPermissions();
    }

    @Override
    protected void onResume() {
        super.onResume();
        updatePermissionLabel();
        loadVideos();
    }

    private void updatePermissionLabel() {
        boolean overlayOk = Settings.canDrawOverlays(this);
        boolean micOk = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;
        tvPermStatus.setText("Display Over Apps: " + (overlayOk ? "Allowed ✓" : "Required ✗")
                + "  |  Mic: " + (micOk ? "Allowed ✓" : "Ask on Start"));
    }

    private void requestNeededPermissions() {
        List<String> perms = new ArrayList<>();
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            perms.add(Manifest.permission.RECORD_AUDIO);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
                && ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            perms.add(Manifest.permission.POST_NOTIFICATIONS);
        }
        if (!perms.isEmpty()) {
            ActivityCompat.requestPermissions(this, perms.toArray(new String[0]), REQ_PERMS);
        }
    }

    private void launchFloatingRecorder() {
        if (!Settings.canDrawOverlays(this)) {
            Toast.makeText(this, "Kripya 'Display over other apps' permission Allow karein", Toast.LENGTH_LONG).show();
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + getPackageName()));
            startActivity(intent);
            return;
        }

        if (switchMic.isChecked() && ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            requestNeededPermissions();
            Toast.makeText(this, "Mic permission Allow karein aur dubara tap karein", Toast.LENGTH_SHORT).show();
            return;
        }

        Intent svc = new Intent(this, ScreenRecordService.class);
        svc.setAction(ScreenRecordService.ACTION_SHOW_FLOATING);
        svc.putExtra(ScreenRecordService.EXTRA_MIC_ENABLED, switchMic.isChecked());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(svc);
        } else {
            startService(svc);
        }
        moveTaskToBack(true);
    }

    private void loadVideos() {
        videoList.clear();
        File dir = getExternalFilesDir(Environment.DIRECTORY_MOVIES);
        if (dir != null && dir.exists()) {
            File[] files = dir.listFiles((d, name) -> name.endsWith(".mp4"));
            if (files != null) {
                Arrays.sort(files, (a, b) -> Long.compare(b.lastModified(), a.lastModified()));
                for (File f : files) {
                    double mb = f.length() / (1024.0 * 1024.0);
                    videoList.add(new VideoItem(f, f.getName(), String.format(Locale.getDefault(), "%.2f MB", mb)));
                }
            }
        }
        tvEmptyVideos.setVisibility(videoList.isEmpty() ? View.VISIBLE : View.GONE);
        adapter.notifyDataSetChanged();
    }
}
EOF

echo "Pro Screen Recorder files created!"