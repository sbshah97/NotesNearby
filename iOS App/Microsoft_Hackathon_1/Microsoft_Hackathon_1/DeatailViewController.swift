//
//  DeatailViewController.swift
//  Microsoft_Hackathon_1
//
//  Created by Aiman Abdullah Anees on 12/10/16.
//  Copyright © 2016 Aiman Abdullah Anees. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseDatabase
import FirebaseStorage


struct Firebasepull {
    let title1 : String!
    let note : String!
    let latitude : Double!
    let longitude : Double!
    let image_url : String!
}



class DeatailViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    

   
    
    var posts = [Firebasepull]()
    var imageURLS=[String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.mapView.delegate=self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
                
        
        //^^^^^Pushing Points^^^^^
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
    
    func centerMapOnLocation(location:CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        
        var i:Int = 0
        while(i < self.posts.count){
            let annotation = MKPointAnnotation()
            let anno_center = CLLocationCoordinate2DMake(self.posts[i].latitude, self.posts[i].longitude)
            annotation.coordinate = anno_center
            annotation.title = self.posts[i].title1
            annotation.subtitle = self.posts[i].note
            imageURLS.append(self.posts[i].image_url)
            mapView.addAnnotation(annotation)
            
            i=i+1
        
        }
        
        
        
    }

    
 
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
            
        } else {
        
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            
            annotationView.image = UIImage(named: "abc")
            annotationView.frame.size=CGSize(width: 30.0, height: 30.0)
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.canShowCallout = true
            return annotationView
        }

   
}
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
            guard let annotation = view.annotation else
            {
            return
            }
            let urlString="https://www.google.com/maps?saddr=\(self.mapView.userLocation.coordinate.latitude),\(self.mapView.userLocation.coordinate.longitude)&daddr=\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"
            guard let url = URL(string: urlString) else
            {
                return
            }
            UIApplication.shared.openURL(url)
        
        
    
        
        
    }
 




    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
}
