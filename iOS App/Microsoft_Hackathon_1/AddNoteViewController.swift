//
//  AddNoteViewController.swift
//  Microsoft_Hackathon_1
//
//  Created by Aiman Abdullah Anees on 12/10/16.
//  Copyright © 2016 Aiman Abdullah Anees. All rights reserved.
//
import UIKit
import MobileCoreServices
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseStorage


class AddNoteViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleView: UITextView!
    
    @IBOutlet weak var noteView: UITextView!
    
    var copyCount:Int = 0
    

    
    
    var imagePicker = UIImagePickerController()
    
    let locationManager = CLLocationManager()
    var note:String!
    var title1:String!
    var copyNote:String!
    var copyTitle:String!
    var latitude:Double!
    var longitude:Double!
    var imageData:UIImage!
    var Url1:AnyObject!
    
    
    //^^^^^^^^SPEAK Variables^^^^^^^^^
    var outputTitle=String()
    var outputNote=String()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        titleView.becomeFirstResponder()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageView.image=
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        titleView.text = self.copyTitle
        noteView.text = self.copyNote
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    
   
    
    
    @IBAction func keyBoardButton(_ sender: AnyObject) {
        titleView.resignFirstResponder()
    }
    
    
  
    
    @IBAction func photoLibraryButton(_ sender: AnyObject) {
        title1 = titleView.text
        note = noteView.text
        copyNote = note
        copyTitle = title1
        print(self.latitude)
        print(self.longitude)
        print(title1)
        print(note)

        
        //^^^^^^^POSTING OPERATION^^^^^^^^^
    
        let post : [String : AnyObject] = ["title" : title1 as AnyObject,"note": note as AnyObject, "latitude" : self.latitude as AnyObject, "longitude" : self.longitude as AnyObject,"image_url":self.Url1 as AnyObject]
        
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Posts").childByAutoId().setValue(post)
        
        
        var alert = UIAlertController(title: "Note Posted!", message: "You can view your post in 'View Map' or 'View in Air'", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        titleView.text = ""
        noteView.text = ""
        print("@@@@@@@@@@@@@")
        
        
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
 
 
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        latitude = location?.coordinate.latitude
        longitude = location?.coordinate.longitude
        locationManager.stopUpdatingLocation()
        
    }
    
    
    @IBAction func cameraButton(_ sender: Any) {
        imagePicker.sourceType=UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func PhotoLibraryButton(_ sender: Any) {
        imagePicker.sourceType=UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image=info[UIImagePickerControllerOriginalImage] as? UIImage
        imageData=imageView.image
        
        if let OriginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let imageData=UIImageJPEGRepresentation(OriginalImage, 0.8){
            uploadImageToFirebaseStorage(data: imageData as NSData)
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    
    
}

