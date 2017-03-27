package com.hrily.notesnearby;
//////////////
// by hrily //
//////////////

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.microsoft.azure.storage.CloudStorageAccount;
import com.microsoft.azure.storage.blob.CloudBlobClient;
import com.microsoft.azure.storage.blob.CloudBlobContainer;
import com.microsoft.azure.storage.blob.CloudBlockBlob;
import com.microsoft.azure.storage.file.FileInputStream;
import com.microsoft.windowsazure.mobileservices.*;
import com.microsoft.windowsazure.mobileservices.http.ServiceFilterResponse;
import com.microsoft.windowsazure.mobileservices.table.TableOperationCallback;

import com.microsoft.bing.speech.SpeechClientStatus;
import com.microsoft.cognitiveservices.speechrecognition.ISpeechRecognitionServerEvents;
import com.microsoft.cognitiveservices.speechrecognition.MicrophoneRecognitionClient;
import com.microsoft.cognitiveservices.speechrecognition.RecognitionResult;
import com.microsoft.cognitiveservices.speechrecognition.SpeechRecognitionMode;
import com.microsoft.cognitiveservices.speechrecognition.SpeechRecognitionServiceFactory;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URI;
import java.util.Date;
import java.util.concurrent.ThreadFactory;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link AddNoteFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link AddNoteFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class AddNoteFragment extends Fragment implements ISpeechRecognitionServerEvents {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String LAT = "lat";
    private static final String LNG = "lng";

    private double lat, lng;
    private String fileName;
    private Note new_note;

    private OnFragmentInteractionListener mListener;

    EditText title, desc;
    Button add_note_btn;
    ProgressDialog PD;

    ImageView voice_title, voice_desc;
    RelativeLayout voice_layout;
    TextView voice_text;

    Button add_img;

    private MobileServiceClient mClient;

    MicrophoneRecognitionClient micClient = null;
    int title_desc = 0;
    private SpeechRecognitionMode mode = SpeechRecognitionMode.ShortPhrase;

    private String storageContainer = "images";
    private String storageConnectionString = "";
    private int PICK_IMAGE_REQUEST = 1;
    private InputStream fileStream;
    private byte[] bitmapdata;


    public AddNoteFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param lat Parameter 1.
     * @param lng Parameter 2.
     * @return A new instance of fragment AddNoteFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static AddNoteFragment newInstance(double lat, double lng) {
        AddNoteFragment fragment = new AddNoteFragment();
        Bundle args = new Bundle();
        args.putDouble(LAT, lat);
        args.putDouble(LNG, lng);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            lat = getArguments().getDouble(LAT);
            lng = getArguments().getDouble(LNG);
        }
    }

    public static void hideKeyboard(Context ctx) {
        InputMethodManager inputManager = (InputMethodManager) ctx
                .getSystemService(Context.INPUT_METHOD_SERVICE);

        // check if no view has focus:
        View v = ((Activity) ctx).getCurrentFocus();
        if (v == null)
            return;

        inputManager.hideSoftInputFromWindow(v.getWindowToken(), 0);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootView = inflater.inflate(R.layout.fragment_add_note, container, false);
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
        title = (EditText) rootView.findViewById(R.id.note_title);
        desc = (EditText) rootView.findViewById(R.id.note_description);
        add_note_btn = (Button) rootView.findViewById(R.id.add_note_btn);
        add_note_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (lat != 0) {
                    if(title.length()==0){
                        Toast.makeText(getActivity(), "Please Enter Title...", Toast.LENGTH_SHORT).show();
                        return;
                    }
                    if(desc.length()==0){
                        Toast.makeText(getActivity(), "Please Enter Description...", Toast.LENGTH_SHORT).show();
                        return;
                    }
                    PD.show();
                    Runnable runnable = new Runnable() {
                        @Override
                        public void run() {
                            addNote();
                        }
                    };
                    new Thread(runnable).start();
                } else {
                    Toast.makeText(getActivity(),"No location data available. Can't post Note", Toast.LENGTH_LONG).show();
                }
            }
        });
        add_img = (Button) rootView.findViewById(R.id.add_note_img);
        add_img.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                intent.setType("image/*");
                intent.setAction(Intent.ACTION_GET_CONTENT);
                startActivityForResult(Intent.createChooser(intent, "Select Picture"), PICK_IMAGE_REQUEST);
            }
        });
        try {
            mClient = new MobileServiceClient(
                    "https://notesnearby.azurewebsites.net",
                    getActivity()
            );
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        PD = new ProgressDialog(getActivity());
        PD.setMessage("Adding note...");
        PD.setCancelable(false);
        voice_title = (ImageView) rootView.findViewById(R.id.img_voice_title);
        voice_desc = (ImageView) rootView.findViewById(R.id.img_voice_desc);
        voice_layout = (RelativeLayout) rootView.findViewById(R.id.voice_layout);
        voice_layout.setVisibility(View.INVISIBLE);
        voice_text = (TextView) rootView.findViewById(R.id.voice_text);
        voice_title.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                title_desc = 0;
                startVoiceCapture();
            }
        });
        voice_desc.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                title_desc = 1;
                startVoiceCapture();
            }
        });
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                startSTTService();
            }
        };
        new Thread(runnable).start();
        storageConnectionString = getString(R.string.blobString);
        return rootView;
    }

    public void back(){
        Fragment fragment = new MapFragment();
        FragmentTransaction ft = getActivity().getSupportFragmentManager().beginTransaction();
        ft.replace(R.id.content_frame, fragment);
        ft.commit();
    }

    public void addNote(){
        if(!uploadImage(bitmapdata))
            fileName = "";
        String note_title = title.getText().toString();
        String note_desc = desc.getText().toString();
        new_note = new Note(lat, lng, note_title, note_desc, fileName);
        hideKeyboard(getActivity());
        mClient.getTable(Note.class).insert(new_note, new TableOperationCallback<Note>() {
            @Override
            public void onCompleted(Note entity, Exception exception, ServiceFilterResponse response) {
                if (exception == null) {
                    // Insert succeeded
                    // Done Posting, Go back
                    Toast.makeText(getActivity(), "Note posted to your location", Toast.LENGTH_LONG).show();
                    Fragment fragment = new MapFragment();
                    FragmentTransaction ft = getActivity().getSupportFragmentManager().beginTransaction();
                    ft.replace(R.id.content_frame, fragment);
                    PD.hide();
                    ft.commit();
                } else {
                    // Insert failed
                    PD.hide();
                    Log.e("ADDNOTE", exception.getMessage());
                    Toast.makeText(getActivity(), "Failed to post the Note. Please try again later.", Toast.LENGTH_LONG).show();
                }
            }
        });
    }

    public String getPrimaryKey() {
        return this.getString(R.string.primaryKey);
    }

    public void startSTTService(){
        // STT
        micClient = SpeechRecognitionServiceFactory.createMicrophoneClient(
                getActivity(), mode, "en-us", this, getPrimaryKey());
    }

    public void startVoiceCapture(){
        Log.d("VOICE", "Starting voice api...");
        voice_text.setText("");
        if(micClient==null) {
            startSTTService();
        }
        voice_layout.setVisibility(View.VISIBLE);
        micClient.startMicAndRecognition();
    }

    public boolean uploadImage(byte[] buffer){
        try {
            CloudStorageAccount storageAccount = CloudStorageAccount.parse(storageConnectionString);
            CloudBlobClient blobClient = storageAccount.createCloudBlobClient();
            Date date = new Date();
            fileName = date.getTime() + ".png";
            Log.i("IMG","file: "+fileName+" size: "+buffer.length);
            CloudBlobContainer container = blobClient.getContainerReference(storageContainer);
            CloudBlockBlob blob = container.getBlockBlobReference(fileName);
            blob.uploadFromByteArray(buffer, 0, buffer.length);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
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
    public void onPartialResponseReceived(String s) {
        Log.d("VOICE", "Partial Response: "+s);
        voice_text.setText(s+" ...");
    }

    @Override
    public void onFinalResponseReceived(RecognitionResult recognitionResult) {
        micClient.endMicAndRecognition();
        Log.d("VOICE", "Done speaking: "+recognitionResult.Results);
        voice_layout.setVisibility(View.INVISIBLE);
        if(recognitionResult.Results.length>0) {
            String response = recognitionResult.Results[0].DisplayText;
            //Toast.makeText(getActivity(), response, Toast.LENGTH_SHORT).show();
            if(title_desc==0)
                title.setText(response);
            else
                desc.setText(response);
        }
    }

    @Override
    public void onIntentReceived(String s) {

    }

    @Override
    public void onError(int i, String s) {
        Log.d("VOICE", "Error code: " + SpeechClientStatus.fromInt(i) + " " + i);
        Log.d("VOICE", "Error text: " + s);
        Toast.makeText(getActivity(), "Error Occurred", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onAudioEvent(boolean b) {
        if(b)
            Toast.makeText(getActivity(), "Start speaking", Toast.LENGTH_SHORT).show();
        else
            Toast.makeText(getActivity(), "Done", Toast.LENGTH_SHORT).show();
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

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == PICK_IMAGE_REQUEST && resultCode == Activity.RESULT_OK && data != null && data.getData() != null) {

            Uri uri = data.getData();
            try {
                final Bitmap bitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), uri);
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.PNG, 0, outputStream);
                bitmapdata = outputStream.toByteArray();
                fileStream = new ByteArrayInputStream(bitmapdata);
                add_img.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, R.drawable.ic_check, 0);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

}
