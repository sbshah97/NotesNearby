//
//  PostViewController.swift
//  notesNearby_iOS_final
//
//  Created by Aiman Abdullah Anees on 11/03/17.
//  Copyright © 2017 Aiman Abdullah Anees. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD


class PostViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate {

    @IBOutlet var TitleBox: UITextField!
    @IBOutlet var Note: UITextView!
    @IBOutlet var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    
    var databaseRef:FIRDatabaseReference!
    
    //For Firebase Functions
    var note1:String!
    var title1:String!
    var copyNote:String!
    var copyTitle:String!
    var latitude:Double!
    var longitude:Double!
    var imageData:UIImage!
    var Url1:AnyObject!
    
    var outputTitle=String()
    var outputNote=String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imageView.layer.cornerRadius=imageView.frame.size.width/2
        imageView.clipsToBounds=true
        
        imageView.layer.borderColor=UIColor.lightGray.cgColor
        imageView.layer.borderWidth=0.5
        
        TitleBox.text=self.copyTitle
        Note.text=self.copyNote
        
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        databaseRef=FIRDatabase.database().reference().child("posts")
        
    }
    
    
    
    


    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        imagePicker.sourceType=UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func photoLibrary(_ sender: UIBarButtonItem) {
        imagePicker.sourceType=UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)

        
    }
    

    @IBAction func post(_ sender: UIButton) {
        
        title1 = TitleBox.text
        note1 = Note.text
        copyNote = note1
        copyTitle = title1
        print(self.latitude)
        print(self.longitude)
        print(title1)
        print(note1)
        
        //^^^^^^^POSTING OPERATION^^^^^^^^^
        let key=databaseRef.childByAutoId().key
        let post : [String : AnyObject] = ["title" : title1 as AnyObject,"note": note1 as AnyObject, "latitude" : self.latitude as AnyObject, "longitude" : self.longitude as AnyObject,"image_url":self.Url1 as AnyObject,"key":key as AnyObject]
        
        //let databaseRef = FIRDatabase.database().reference()
        //databaseRef.child("Posts").childByAutoId().setValue(post)
        
        databaseRef.child(key).setValue(post)
        
        
        var alert = UIAlertController(title: "Note Posted!", message: "You can view your post in map or AR", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        TitleBox.text = ""
        Note.text = ""
        imageView.image=UIImage(named: "image")
        
        
        print("@@@@@@@@@@@@@")

    }
    
    func uploadImageToFirebaseStorage(data:NSData){
        SVProgressHUD.show(withStatus: "Loading")
        UIApplication.shared.beginIgnoringInteractionEvents()
        var Timestamp: String {
            return "\(NSDate().timeIntervalSince1970 * 1000)"
        }
        DispatchQueue.global(qos:.background).async {
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
                    do{
                        print(Url)
                        var url_string:String = "\(Url)"
                        self.Url1 = url_string as AnyObject!
                        print(self.Url1)
                        SVProgressHUD.dismiss()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    
                    catch{
                        
                        print("Error")
                    }
                    
                    
                    
                }
                
            }
            uploadTask.observe(.progress) {[weak self] (snapshot) in
                guard let strongSelf = self else { return }
                guard let progress = snapshot.progress else{ return }
            }

            
        }
        
    }

   
    
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        latitude = location?.coordinate.latitude
        longitude = location?.coordinate.longitude
        locationManager.stopUpdatingLocation()
        
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

