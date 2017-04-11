//
//  MapViewController.swift
//  notesNearby_iOS_final
//
//  Created by Aiman Abdullah Anees on 11/03/17.
//  Copyright © 2017 Aiman Abdullah Anees. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD

struct Firebasepull {
    let title1 : String!
    let note : String!
    let latitude : Double!
    let longitude : Double!
    let image_url : String!
    let key: String!
}


class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var open: UIBarButtonItem!
    @IBOutlet var Post: UILabel!

    @IBOutlet var AR: UILabel!
    
    var posts = [Firebasepull]()
    var imageURLS=[String]()

    
    


    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Custom Appearance
        AR.layer.cornerRadius = AR.frame.size.width/2
        AR.clipsToBounds=true
        
        AR.layer.borderColor = UIColor.darkGray.cgColor
        AR.layer.borderWidth=0.5
        
        Post.layer.cornerRadius = Post.frame.size.width/2
        Post.clipsToBounds=true
        
        Post.layer.borderColor = UIColor.darkGray.cgColor
        Post.layer.borderWidth=0.5

        
        //Side-Panel Code
        open.target=revealViewController()
        open.action=Selector("revealToggle:")
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
         
        
        
        //Map-Operations
        self.locationManager.delegate = self
        self.mapView.delegate=self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = true
        self.mapView.showsCompass = true
        self.mapView.showsScale = true
        
        
        //^^^^^Pushing Points^^^^^
        
        DispatchQueue.global(qos:.background).async {
            do{
                
                
                let databaseRef = FIRDatabase.database().reference()
                
                databaseRef.child("posts").queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
                    
                    print(snapshot)
                    
                    
                    if let dictionary = snapshot.value as? [String:AnyObject]{
                        let title1 = dictionary["title"] as? String
                        let note = dictionary["note"] as? String
                        let latitude = dictionary["latitude"] as? Double
                        let longitude = dictionary["longitude"] as? Double
                        let image_url=dictionary["image_url"] as? String
                        let key=dictionary["key"] as? String
                        self.posts.insert(Firebasepull(title1:title1,note:note,latitude:latitude,longitude:longitude,image_url:image_url,key:key), at: 0)
                        
                        
                        
                    }
                }, withCancel: nil)
                
                
                print("*********")
                
            }
            catch{
                print("error")
            }
        }
       
        
        
    }
    /*
    func centerMapOnLocation(location:CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    */
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        /*
        let region=MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        
        self.mapView.setRegion(region, animated: true)
        */
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
            
            annotationView.image = UIImage(named: "location-map-flat")
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
    
    
    @IBAction func ARButtonTapped(_ sender: UIButton) {
       
    }
   
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    
    

}
