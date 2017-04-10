package com.hrily.notesnearby;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.os.Handler;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.BitmapImageViewTarget;
import com.microsoft.azure.storage.CloudStorageAccount;
import com.microsoft.azure.storage.StorageUri;
import com.microsoft.azure.storage.blob.CloudBlobClient;
import com.microsoft.azure.storage.blob.CloudBlobContainer;
import com.microsoft.azure.storage.blob.CloudBlockBlob;
import com.microsoft.speech.tts.Synthesizer;
import com.microsoft.speech.tts.Voice;

import java.net.URI;
import java.util.Date;
import java.util.HashMap;
import java.util.logging.LogRecord;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link ShowNoteFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link ShowNoteFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ShowNoteFragment extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String TITLE = "title";
    private static final String DESC = "desc";
    private static final String LAT = "lat";
    private static final String LNG = "lng";
    private static final String IMG = "img";

    private String title;
    private String desc;
    private String img;
    private String imgURL;
    private double lat, lng;

    private TextView Title, Desc, LatLng;
    private Button GoBack;
    private Button Navi;
    private ImageView Img;

    private OnFragmentInteractionListener mListener;

    private Synthesizer m_syn;

    private String storageContainer = "images";
    private String storageConnectionString = "";

    private Handler handler;

    public ShowNoteFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param title Parameter 1.
     * @param desc Parameter 2.
     * @return A new instance of fragment ShowNoteFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static ShowNoteFragment newInstance(String title, String desc, double lat, double lng, String img) {
        ShowNoteFragment fragment = new ShowNoteFragment();
        Bundle args = new Bundle();
        args.putString(TITLE, title);
        args.putString(DESC, desc);
        args.putDouble(LAT, lat);
        args.putDouble(LNG, lng);
        args.putString(IMG, img);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        title = "";
        desc = "";
        img = "";
        lat = 0;
        lng = 0;
        if (getArguments() != null) {
            title = getArguments().getString(TITLE);
            desc = getArguments().getString(DESC);
            lat = getArguments().getDouble(LAT);
            lng = getArguments().getDouble(LNG);
            img = getArguments().getString(IMG);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootView = inflater.inflate(R.layout.fragment_show_note, container, false);
        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if( keyCode == KeyEvent.KEYCODE_BACK ) {
                    back();
                    return true;
                } else {
                    return false;
                }
            }
        });
        Title = (TextView) rootView.findViewById(R.id.show_note_title);
        Desc = (TextView) rootView.findViewById(R.id.show_note_desc);
        LatLng = (TextView) rootView.findViewById(R.id.show_note_latlng);
        GoBack = (Button) rootView.findViewById(R.id.show_note_go_back);
        Img = (ImageView) rootView.findViewById(R.id.show_note_img);
        Navi = (Button) rootView.findViewById(R.id.btn_navi);
        Navi.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Uri gmmIntentUri = Uri.parse("google.navigation:q="+String.valueOf(lat)+","+String.valueOf(lng));
                Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
                mapIntent.setPackage("com.google.android.apps.maps");
                startActivity(mapIntent);
            }
        });
        GoBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                back();
            }
        });
        if(title.length()>0){
            Title.setText(title);
            Desc.setText(desc);
            LatLng.setText("@ "+String.valueOf(lat)+" , "+String.valueOf(lng));
        }
        storageConnectionString = getString(R.string.blobString);
        handler = new Handler() {
            public void handleMessage(Message msg) {
                Glide.with(getActivity())
                        .load(Uri.parse(imgURL))
                        .into(Img);
            }
        };
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                // TTS
                m_syn = new Synthesizer(getString(R.string.primaryKey));
                m_syn.SetServiceStrategy(Synthesizer.ServiceStrategy.AlwaysService);
                Voice v = new Voice("en-US", "Microsoft Server Speech Text to Speech Voice (en-US, ZiraRUS)", Voice.Gender.Female, true);
                m_syn.SetVoice(v, null);
                m_syn.SpeakToAudio("Title: "+title+" ; Description : "+desc);
                try {
                    CloudStorageAccount storageAccount = CloudStorageAccount.parse(storageConnectionString);
                    CloudBlobClient blobClient = storageAccount.createCloudBlobClient();
                    CloudBlobContainer container = blobClient.getContainerReference(storageContainer);
                    CloudBlockBlob blob = container.getBlockBlobReference(img);
                    URI imgURI = blob.getStorageUri().getPrimaryUri();
                    imgURL = imgURI.toString();
                    Log.i("BLOB", imgURL);
                    // TODO: Image show
                    handler.sendEmptyMessage(0);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };
        Thread t = new Thread(runnable);
        t.start();
        return rootView;
    }

    public void back(){
        Fragment fragment = new MapFragment();
        FragmentTransaction ft = getActivity().getSupportFragmentManager().beginTransaction();
        ft.replace(R.id.content_frame, fragment);
        ft.commit();
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
        void onFragmentInteraction(Uri uri);
    }
}
