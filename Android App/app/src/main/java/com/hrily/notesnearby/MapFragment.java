package com.hrily.notesnearby;
//////////////
// by hrily //
//////////////
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.util.ArrayMap;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.Toast;


import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.ClusterManager;
import com.microsoft.windowsazure.mobileservices.*;
import com.microsoft.windowsazure.mobileservices.http.ServiceFilterResponse;
import com.microsoft.windowsazure.mobileservices.table.MobileServiceTable;
import com.microsoft.windowsazure.mobileservices.table.TableQueryCallback;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Random;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link MapFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link MapFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class MapFragment extends Fragment implements OnMapReadyCallback,
        GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener,
        LocationListener {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    private OnFragmentInteractionListener mListener;

    private static final long INTERVAL = 500;
    private static final long FAST_INTERVAL = 1;
    private static final String TAG = "LOC";
    private static double NOTE_RANGE = 0.002;

    private GoogleMap mMap;
    private GoogleApiClient mGoogleApiClient;
    private LocationRequest mLocationRequest;
    private LocationManager mLocationManager;
    private List<String> provider;
    private ArrayList<Note> notes;
    private ArrayList<Marker> markers;
    ClusterManager<ClusterMarkerLocation> clusterManager;

    private MobileServiceClient mClient;
    private MobileServiceTable<Note> mTable;

    public LatLng mCurrentLocation;

    private FloatingActionButton fab;
    private RelativeLayout cluster_list_layout;
    private ListView cluster_list;
    private ArrayAdapter<String> cluster_adapter;
    private ArrayList<String> titles;

    public MapFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment MapFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static MapFragment newInstance(String param1, String param2) {
        MapFragment fragment = new MapFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    public void  addNote(Note note){
        clusterManager.addItem(new ClusterMarkerLocation(new LatLng(note.getLat(), note.getLng()), note));
        /*
        Marker m = mMap.addMarker(new MarkerOptions()
                .position(new LatLng(note.getLat(), note.getLng()))
                .title(note.getTitle()));
        markers.add(m);
        */
    }

    public void putNotesNearby(){
        double  lat = mCurrentLocation.latitude,
                lng = mCurrentLocation.longitude;
        // Remove existing markers out of range
        /*
        for(int i=markers.size()-1;i>=0;i--){
            Marker  m = markers.get(i);
            double  mlat = m.getPosition().latitude,
                    mlng = m.getPosition().longitude;
            double  d = Math.sqrt(Math.pow(lat-mlat,2)+Math.pow(lng-mlng,2));
            if(d<=NOTE_RANGE)
                m.remove();
            markers.remove(i);
        }
        */
        clusterManager.clearItems();
        // Add additional markers
        for(Note n:notes){
            double  nlat = n.getLat(),
                    nlng = n.getLng();
            double  d = Math.sqrt(Math.pow(lat-nlat,2)+Math.pow(lng-nlng,2));
            if(d<=NOTE_RANGE)
                addNote(n);
        }
        clusterManager.cluster();
    }

    protected synchronized void buildGoogleApiClient() {
        Log.i(TAG, "Building GoogleApiClient");
        mGoogleApiClient = new GoogleApiClient.Builder(getActivity())
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();
        createLocationRequest();
    }

    protected void createLocationRequest() {
        mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(INTERVAL);
        mLocationRequest.setFastestInterval(FAST_INTERVAL);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootView = inflater.inflate(R.layout.fragment_map, container, false);
        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if( keyCode == KeyEvent.KEYCODE_BACK ) {
                    cluster_list_layout.setVisibility(View.INVISIBLE);
                    return true;
                } else {
                    return false;
                }
            }
        });
        fab = (FloatingActionButton) getActivity().findViewById(R.id.fab);
        fab.setVisibility(View.VISIBLE);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                fab.setVisibility(View.INVISIBLE);
                Fragment fragment = AddNoteFragment.newInstance(mCurrentLocation.latitude, mCurrentLocation.longitude);
                FragmentTransaction ft = getActivity().getSupportFragmentManager().beginTransaction();
                ft.replace(R.id.content_frame, fragment);
                ft.commit();
            }
        });
        SupportMapFragment mapFragment = (SupportMapFragment) getChildFragmentManager().findFragmentById(R.id.map);
        cluster_list = (ListView) rootView.findViewById(R.id.cluster_list);
        cluster_list_layout = (RelativeLayout) rootView.findViewById(R.id.cluster_list_layout);
        cluster_list_layout.setVisibility(View.INVISIBLE);
        titles = new ArrayList<>();
        cluster_adapter = new ArrayAdapter<>(getActivity(), android.R.layout.simple_list_item_1, titles);
        cluster_list.setAdapter(cluster_adapter);
        cluster_list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                cluster_list_layout.setVisibility(View.INVISIBLE);
                String title = titles.get(position);
                for(Note n: notes) {
                    if (n.getTitle().equals(title)) {
                        showNote(n);
                        break;
                    }
                }
            }
        });
        View rect = (View) rootView.findViewById(R.id.rect);
        rect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cluster_list_layout.setVisibility(View.INVISIBLE);
            }
        });
        mapFragment.getMapAsync(this);
        buildGoogleApiClient();
        notes = new ArrayList<>();
        markers = new ArrayList<>();
        //initNotes();

        try {
            mClient = new MobileServiceClient(
                    "https://notesnearby.azurewebsites.net",
                    getActivity()
            );
            mTable = mClient.getTable(Note.class);
        } catch (MalformedURLException e) {
            Toast.makeText(getActivity(), "Error connecting to server.",Toast.LENGTH_LONG).show();
            Log.e(TAG, "Error connecting to server");
            e.printStackTrace();
        }

        return rootView;
    }

    private void showNote(Note n){
        fab.setVisibility(View.INVISIBLE);
        Fragment fragment = ShowNoteFragment.newInstance(n.getTitle(), n.getDesc(), n.getLat(), n.getLng(), n.getImg());
        FragmentTransaction ft = getActivity().getSupportFragmentManager().beginTransaction();
        ft.replace(R.id.content_frame, fragment);
        ft.commit();
    }

    private void  getNotesNearby(){
        Log.i(TAG,"Getting Notes");
        mTable.where()
                .field("lat").le(mCurrentLocation.latitude+NOTE_RANGE).and()
                .field("lat").ge(mCurrentLocation.latitude-NOTE_RANGE).and()
                .field("lng").le(mCurrentLocation.longitude+NOTE_RANGE).and()
                .field("lng").ge(mCurrentLocation.longitude-NOTE_RANGE)
                .execute(new TableQueryCallback<Note>() {
            @Override
            public void onCompleted(List<Note> result, int count, Exception exception, ServiceFilterResponse response) {
                if(exception==null) {
                    notes = (ArrayList<Note>) result;
                    if (mListener != null) {
                        mListener.onFragmentInteraction(mCurrentLocation, notes);
                    }
                    Log.i(TAG, "Got "+String.valueOf(notes.size())+" Notes");
                    putNotesNearby();
                }else{
                    Toast.makeText(getActivity(), "Error getting data", Toast.LENGTH_LONG).show();
                    Log.e(TAG, exception.getMessage());
                }
            }
        });
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    @Override
    public void onConnected(@Nullable Bundle bundle) {

    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onLocationChanged(Location location) {
        Log.i("LOC","New loc : "+location.getLatitude()+","+location.getLongitude());
        //Place current location marker
        LatLng latLng = new LatLng(location.getLatitude(), location.getLongitude());

        mCurrentLocation = latLng;

        getNotesNearby();

        if (mListener != null) {
            mListener.onFragmentInteraction(mCurrentLocation, notes);
        }

        CameraPosition cameraPosition = new CameraPosition.Builder()
                .target(latLng)
                .zoom(18)
                .bearing(0)
                .tilt(30)
                .build();
        //move map camera
        mMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }

    @Override
    public void onProviderDisabled(String provider) {

    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {

    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        mLocationManager = (LocationManager) getActivity().getSystemService(Context.LOCATION_SERVICE);
        //Criteria criteria = new Criteria();
        //provider = mLocationManager.getAllProviders();//(criteria, true);
        if (ActivityCompat.checkSelfPermission(getActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(getActivity(), android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            new AlertDialog.Builder(getActivity())
                    .setTitle("Location Permissions")
                    .setMessage("Location Permissions aren't enabled for this app. Please enable...")
                    .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            // continue with delete
                        }
                    }).show();
            return;
        }
        mMap.setMyLocationEnabled(true);
        mMap.setPadding(50,50,50,50);
        //mLocationManager.requestLocationUpdates(mLocationManager.GPS_PROVIDER, INTERVAL, FAST_INTERVAL, this);
        Criteria cri=new Criteria();
        mLocationManager.requestLocationUpdates(INTERVAL, FAST_INTERVAL, cri, this, null);
        String provider = mLocationManager.getBestProvider(cri,false);
        Location location = mLocationManager.getLastKnownLocation(provider);
        try {
            onLocationChanged(location);
        }catch (Exception e){
            Log.e(TAG, "No Last Location found...");
        }
        clusterManager = new ClusterManager<>(getActivity(), mMap);
        clusterManager.setRenderer(new CustomRenderer<>(getActivity(), mMap, clusterManager));
        clusterManager.setOnClusterClickListener(new ClusterManager.OnClusterClickListener<ClusterMarkerLocation>() {
            @Override
            public boolean onClusterClick(Cluster<ClusterMarkerLocation> cluster) {
                cluster_list_layout.setVisibility(View.VISIBLE);
                titles.clear();
                Collection<ClusterMarkerLocation> markers = cluster.getItems();
                for(ClusterMarkerLocation m: markers)
                    titles.add(m.getNote().getTitle());
                cluster_adapter.notifyDataSetChanged();
                Log.d(TAG, titles.toString());
                return false;
            }
        });
        clusterManager.setOnClusterItemClickListener(new ClusterManager.OnClusterItemClickListener<ClusterMarkerLocation>() {
            @Override
            public boolean onClusterItemClick(ClusterMarkerLocation clusterMarkerLocation) {
                double  lat = clusterMarkerLocation.getPosition().latitude,
                        lng = clusterMarkerLocation.getPosition().longitude;
                for(Note n: notes) {
                    if(n.getLat()==lat && n.getLng()==lng){
                        showNote(n);
                        break;
                    }
                }
                return true;
            }
        });
        mMap.setOnCameraChangeListener(clusterManager);
        mMap.setOnMarkerClickListener(clusterManager);
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p/>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        void onFragmentInteraction(LatLng loc, ArrayList<Note> n);
    }
}
