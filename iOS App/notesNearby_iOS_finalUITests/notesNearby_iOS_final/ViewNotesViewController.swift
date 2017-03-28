//
//  ViewNotesViewController.swift
//  notesNearby_iOS_final
//
//  Created by Aiman Abdullah Anees on 12/03/17.
//  Copyright © 2017 Aiman Abdullah Anees. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MobileCoreServices
import CoreLocation
import Kingfisher
import SVProgressHUD




class ViewNotesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    
    
    var posts = [Firebasepull]()
    
    @IBOutlet var open: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var latitude:Double!
    var longitude:Double!
    
    var ref:FIRDatabaseReference?
    var databaseHandle:FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Location-update
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        //Side-Panel Code
        open.target=revealViewController()
        open.action=Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        
       //Firebase - GET Request
        ref = FIRDatabase.database().reference()
        databaseHandle=ref?.child("posts").observe(.childAdded, with: {(snapshot) in
                    print(snapshot)
            if let dictionary = snapshot.value as? [String:AnyObject]{
                        let title1 = dictionary["title"] as? String
                        let note = dictionary["note"] as? String
                        let latitude = dictionary["latitude"] as? Double
                        let longitude = dictionary["longitude"] as? Double
                        let image_url=dictionary["image_url"] as? String
                        let key=dictionary["key"] as? String
                self.posts.insert(Firebasepull(title1:title1,note:note,latitude:latitude,longitude:longitude,image_url:image_url,key:key), at: 0)
                        
                        self.tableView.reloadData()
                    }
                }, withCancel: nil)
                print("*********")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        /*
        else{
            let alertController=UIAlertController(title: "Note", message: "There are no messages", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            present(alertController,animated: true,completion: nil)
            
            return 0
        }
 */
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        SVProgressHUD.show(withStatus: "Loading")
        let resource=ImageResource(downloadURL: URL(string: posts[indexPath.row].image_url)!, cacheKey: posts[indexPath.row].image_url)
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.kf.setImage(with: resource)
        SVProgressHUD.dismiss()
        
        let textView = cell.viewWithTag(2) as! UILabel
        textView.text = posts[indexPath.row].title1
        return cell
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        latitude = location?.coordinate.latitude
        longitude = location?.coordinate.longitude
        
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertController=UIAlertController(title: "Note", message: "", preferredStyle: .alert)
        
        let updateAction=UIAlertAction(title: "Update", style: .default){(_) in
            let key=self.posts[indexPath.row].key
            let title=alertController.textFields?[0].text
            let note=alertController.textFields?[1].text
            let image_url=self.posts[indexPath.row].image_url
            let latitude=self.posts[indexPath.row].latitude
            let longitude=self.posts[indexPath.row].longitude
            
            self.updateNote(key: key!, title: title!, note: note!, image_url: image_url!, latitude: latitude!, longitude: longitude!)
            
        }
        let deleteAction=UIAlertAction(title: "Delete", style: .default){(_) in
            
            self.deleteNote(key: self.posts[indexPath.row].key)
            
        }
        let navigationAction=UIAlertAction(title: "Route", style: .default){(_) in
            let urlString="https://www.google.com/maps?saddr=\(self.latitude!),\(self.longitude!)&daddr=\(self.posts[indexPath.row].latitude!),\(self.posts[indexPath.row].longitude!)"
            
            let url = URL(string: urlString)
            UIApplication.shared.openURL(url!)
            
        }
        
        alertController.addTextField{(textField) in
            textField.text=self.posts[indexPath.row].title1
        }
        
        alertController.addTextField{(textField) in
            textField.text=self.posts[indexPath.row].note
            
        }
        
        
        
        alertController.addAction(updateAction)
        alertController.addAction(deleteAction)
        alertController.addAction(navigationAction)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        present(alertController,animated: true,completion: nil)
        
    }
    
    func updateNote(key:String,title:String,note:String,image_url:String,latitude:Double,longitude:Double){
        let note = [
            "key":key as AnyObject,
            "title":title as AnyObject,
            "note":note as AnyObject,
            "image_url":image_url as AnyObject,
            "latitude":latitude as AnyObject,
            "longitude":longitude as AnyObject
        ] as [String:AnyObject]
        
       ref?.child("posts").child(key).setValue(note)

    }
    
    func deleteNote(key:String){
        ref?.child("posts").child(key).setValue(nil)
    }
    

   

    

}
