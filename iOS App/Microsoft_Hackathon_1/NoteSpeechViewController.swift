//
//  NoteSpeechViewController.swift
//  Microsoft_Hackathon_1
//
//  Created by Aiman Abdullah Anees on 12/11/16.
//  Copyright © 2016 Aiman Abdullah Anees. All rights reserved.
//

import UIKit
import Speech
import Firebase
import FirebaseDatabase
import CoreLocation
import MobileCoreServices
import Firebase
import FirebaseDatabase
import FirebaseStorage


class NoteSpeechViewController: UIViewController,SFSpeechRecognizerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()

    @IBOutlet weak var imageView: UIImageView!
    var outputTitle:String = ""
    var outputNote:String!
    var latitude:Double!
    var longitude:Double!
    var Url1:AnyObject!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(outputTitle)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        
        microphoneButton.isEnabled = false
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        
        
    }
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Speak!", for: .normal)
        } else {
            startRecording()
            microphoneButton.setTitle("STOP", for: .normal)
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
                self.outputNote=self.textView.text
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = "Say something, I'm listening!"
        
    }
    
    func uploadImageToFirebaseStorage(data:NSData){
        var Timestamp: String {
            return "\(NSDate().timeIntervalSince1970 * 1000)"
        }
        let storageRef = FIRStorage.storage().reference(withPath: "\(Timestamp)")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        let uploadTask = storageRef.put(data as Data, metadata: uploadMetadata) {
            (metadata,error) in
            if(error != nil){
                print(error?.localizedDescription)
            }
            else{
                print(metadata)
                let Url:URL = (metadata?.downloadURL())!
                print(Url)
                var url_string:String = "\(Url)"
                self.Url1 = url_string as AnyObject!
                print(self.Url1)
                
                
            }
            
        }
        uploadTask.observe(.progress) {[weak self] (snapshot) in
            guard let strongSelf = self else { return }
            guard let progress = snapshot.progress else{ return }
        }
        
    }
    

    
    
    @IBAction func CameraButton(_ sender: Any) {
        imagePicker.sourceType=UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func PhotoLibraryButton(_ sender: Any) {
        imagePicker.sourceType=UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)

        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image=info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let OriginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let imageData=UIImageJPEGRepresentation(OriginalImage, 0.8){
            uploadImageToFirebaseStorage(data: imageData as NSData)
        }

        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //^^^^POST NOTE^^^^^^^
    @IBAction func PostNote(_ sender: Any) {
        //^^^^^^^POSTING OPERATION^^^^^^^^^
        let post : [String : AnyObject] = ["title" : self.outputTitle as AnyObject,"note": self.outputNote as AnyObject, "latitude" : self.latitude as AnyObject, "longitude" : self.longitude as AnyObject,"image_url":self.Url1 as AnyObject]
        
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Posts").childByAutoId().setValue(post)
        
        
        var alert = UIAlertController(title: "Note Posted!", message: "You can view your post in 'View Map' or 'View in Air' after pressing Done", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    
    
    
    
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        latitude = location?.coordinate.latitude
        longitude = location?.coordinate.longitude
        locationManager.stopUpdatingLocation()
        
    }
       
   

}
