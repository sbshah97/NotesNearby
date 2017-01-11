//
//  ImagesTableViewController.swift
//  Microsoft_Hackathon_1
//
//  Created by Aiman Abdullah Anees on 31/12/16.
//  Copyright © 2016 Aiman Abdullah Anees. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseDatabase
import FirebaseStorage



class ImagesTableViewController: UITableViewController {

     var posts = [Firebasepull]()

        override func viewDidLoad() {
        super.viewDidLoad()
        
            //^^^^^Getting Data^^^^^
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child("Posts").queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
            
            print(snapshot)
            
            
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let title1 = dictionary["title"] as? String
                let note = dictionary["note"] as? String
                let latitude = dictionary["latitude"] as? Double
                let longitude = dictionary["longitude"] as? Double
                let image_url=dictionary["image_url"] as? String
                self.posts.insert(Firebasepull(title1:title1,note:note,latitude:latitude,longitude:longitude,image_url:image_url), at: 0)
                
                
            }
        }, withCancel: nil)
        
        
        print("*********")


    }
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let textView=cell.viewWithTag(2) as! UILabel
        textView.text=posts[indexPath.row].note
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.sd_setImage(with: URL(string: self.posts[indexPath.row].image_url))
        return cell
    }
    
   
    
    
    
    

   
}
