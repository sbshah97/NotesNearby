package com.hrily.notesnearby;
//////////////
// by hrily //
//////////////

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.location.Location;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by krzysztofjackowski on 24/09/15.
 */

public class ARActivity extends Activity implements
        SurfaceHolder.Callback, OnLocationChangedListener, OnAzimuthChangedListener, View.OnClickListener{

    private Camera mCamera;
    private SurfaceHolder mSurfaceHolder;
    private boolean isCameraviewOn = false;
    private List<Note> notes;

    private double mAzimuthReal = 0;

    private static double AZIMUTH_ACCURACY = 25;
    private double mMyLatitude = 0;
    private double mMyLongitude = 0;

    private MyCurrentAzimuth myCurrentAzimuth;
    private MyCurrentLocation myCurrentLocation;

    TextView descriptionTextView;
    List<LinearLayout> pointerIcons;

    TextView note_title, note_desc, note_latlng;
    LinearLayout note;
    RelativeLayout points;
    Button close;

    Display display;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ar);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        setupListeners();
        setupLayout();
        this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        display = ((android.view.WindowManager)getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();

        notes = new ArrayList<>();
        pointerIcons = new ArrayList<>();

        note = (LinearLayout) findViewById(R.id.ar_note);
        note.setVisibility(View.INVISIBLE);
        close = (Button) findViewById(R.id.ar_close);
        close.setVisibility(View.INVISIBLE);
        close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                close.setVisibility(View.INVISIBLE);
                note.setVisibility(View.INVISIBLE);
            }
        });
        points = (RelativeLayout) findViewById(R.id.ar_points);
        note_title = (TextView) findViewById(R.id.ar_title);
        note_desc = (TextView) findViewById(R.id.ar_desc);
        note_latlng = (TextView) findViewById(R.id.ar_latlng);

        Bundle b = getIntent().getExtras();

        double lats[] = b.getDoubleArray("LATS");
        double lngs[] = b.getDoubleArray("LNGS");
        String titles[] = b.getStringArray("TITLES");
        String descs[] = b.getStringArray("DESCS");

        for(int i=0;i<lats.length;i++){
            notes.add(new Note(lats[i], lngs[i], titles[i], descs[i]));
            LinearLayout ll = new LinearLayout(this);
            ll.setGravity(Gravity.CENTER);
            ll.setVisibility(View.INVISIBLE);
            ll.setOrientation(LinearLayout.VERTICAL);
            ll.setTag(notes.get(i));
            ll.setOnClickListener(this);

            TextView tv = new TextView(this);
            tv.setText(titles[i]);
            tv.setPadding(3, 3, 3, 3);
            tv.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            tv.setTextColor(Color.WHITE);
            tv.setBackgroundColor(Color.argb(150,0,0,0));
            ll.addView(tv);

            ImageView img = new ImageView(this);
            img.setImageResource(R.mipmap.ic_note);
            img.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            ll.addView(img);

            TextView dt = new TextView(this);
            dt.setTag("dist");
            dt.setText("m");
            dt.setPadding(3, 3, 3, 3);
            dt.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            dt.setTextColor(Color.WHITE);
            dt.setBackgroundColor(Color.argb(150,0,0,0));
            ll.addView(dt);

            points.addView(ll,new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            pointerIcons.add(ll);
        }

        Log.e("AR", String.valueOf(lats.length));
    }

    public static double haversine(
            double lat1, double lng1, double lat2, double lng2) {
        int r = 6371; // average radius of the earth in km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                        * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double d = r * c;
        return d;
    }

    public double calculateTeoreticalAzimuth(Note mPoi) {
        double dX = mPoi.getLat() - mMyLatitude;
        double dY = mPoi.getLng() - mMyLongitude;

        double phiAngle;
        double tanPhi;
        double azimuth = 0;

        tanPhi = Math.abs(dY / dX);
        phiAngle = Math.atan(tanPhi);
        phiAngle = Math.toDegrees(phiAngle);

        if (dX > 0 && dY > 0) { // I quater
            return azimuth = phiAngle;
        } else if (dX < 0 && dY > 0) { // II
            return azimuth = 180 - phiAngle;
        } else if (dX < 0 && dY < 0) { // III
            return azimuth = 180 + phiAngle;
        } else if (dX > 0 && dY < 0) { // IV
            return azimuth = 360 - phiAngle;
        }

        return phiAngle;
    }

    private List<Double> calculateAzimuthAccuracy(double azimuth) {
        double minAngle = azimuth - AZIMUTH_ACCURACY;
        double maxAngle = azimuth + AZIMUTH_ACCURACY;
        List<Double> minMax = new ArrayList<Double>();

        if (minAngle < 0)
            minAngle += 360;

        if (maxAngle >= 360)
            maxAngle -= 360;

        minMax.clear();
        minMax.add(minAngle);
        minMax.add(maxAngle);

        return minMax;
    }

    private boolean isBetween(double minAngle, double maxAngle, double azimuth) {
        if (minAngle > maxAngle) {
            if (isBetween(0, maxAngle, azimuth) || isBetween(minAngle, 360, azimuth))
                return true;
        } else {
            if (azimuth > minAngle && azimuth < maxAngle)
                return true;
        }
        return false;
    }

    private void updateDescription() {
        descriptionTextView.setText(" latitude "
                + mMyLatitude + " longitude "  + mMyLongitude + " azimuth " + mAzimuthReal);
    }

    @Override
    public void onLocationChanged(Location location) {
        mMyLatitude = location.getLatitude();
        mMyLongitude = location.getLongitude();
        updateDescription();
    }

    @Override
    public void onAzimuthChanged(float azimuthChangedFrom, float azimuthChangedTo) {
        mAzimuthReal = azimuthChangedTo;

        for(int i=0; i<notes.size();i++) {
            Note n = notes.get(i);

            double mAzimuthTeoretical = calculateTeoreticalAzimuth(n);
            // Don't know why to do this, but is giving desired result
            mAzimuthTeoretical = (mAzimuthTeoretical-90+360)%360;

            LinearLayout pointerIcon = pointerIcons.get(i);

            double minAngle = calculateAzimuthAccuracy(mAzimuthTeoretical).get(0);
            double maxAngle = calculateAzimuthAccuracy(mAzimuthTeoretical).get(1);

            if (isBetween(minAngle, maxAngle, mAzimuthReal)) {
                float perc = ((float) (mAzimuthReal - minAngle + 360.0) % 360) / ((float) (maxAngle - minAngle + 360.0) % 360);
                pointerIcon.setTop((int) (display.getHeight() * perc));
                RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                lp.leftMargin = display.getWidth() - (int) (display.getWidth() * perc);
                pointerIcon.setLayoutParams(lp);
                double dist = haversine(n.getLat(), n.getLng(), mMyLatitude, mMyLongitude);
                TextView d = (TextView) pointerIcon.findViewWithTag("dist");
                d.setText(String.format("%.2f", dist*1000)+" m");
                pointerIcon.setVisibility(View.VISIBLE);
            } else {
                pointerIcon.setVisibility(View.INVISIBLE);
            }
        }

        updateDescription();
    }

    @Override
    protected void onStop() {
        myCurrentAzimuth.stop();
        myCurrentLocation.stop();
        super.onStop();
    }

    @Override
    protected void onResume() {
        super.onResume();
        myCurrentAzimuth.start();
        myCurrentLocation.start();
    }

    private void setupListeners() {
        myCurrentLocation = new MyCurrentLocation(this);
        myCurrentLocation.buildGoogleApiClient(this);
        myCurrentLocation.start();

        myCurrentAzimuth = new MyCurrentAzimuth(this, this);
        myCurrentAzimuth.start();
    }

    private void setupLayout() {
        descriptionTextView = (TextView) findViewById(R.id.cameraTextView);

        getWindow().setFormat(PixelFormat.UNKNOWN);
        SurfaceView surfaceView = (SurfaceView) findViewById(R.id.cameraview);
        mSurfaceHolder = surfaceView.getHolder();
        mSurfaceHolder.addCallback(this);
        mSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width,
                               int height) {
        if (isCameraviewOn) {
            mCamera.stopPreview();
            isCameraviewOn = false;
        }

        if (mCamera != null) {
            try {
                mCamera.setPreviewDisplay(mSurfaceHolder);
                mCamera.startPreview();
                isCameraviewOn = true;
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        mCamera = Camera.open();
        mCamera.setDisplayOrientation(0);
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        mCamera.stopPreview();
        mCamera.release();
        mCamera = null;
        isCameraviewOn = false;
    }

    @Override
    public void onClick(View v) {
        try {
            Note n = (Note) v.getTag();
            note_title.setText(n.getTitle());
            note_desc.setText(n.getDesc());
            note_latlng.setText("@ "+n.getLat()+", "+n.getLng());
            note.setVisibility(View.VISIBLE);
            close.setVisibility(View.VISIBLE);
        }catch (Exception e){
            Log.e("AR", e.getMessage());
        }
    }
}
