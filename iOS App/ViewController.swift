import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import CoreLocation
import SVProgressHUD


class ViewController: UIViewController, ARDataSource
{
    var activityIndicator:UIActivityIndicatorView=UIActivityIndicatorView()
    
    

    @IBOutlet var viewLoad: UIView!
    
    
    @IBOutlet var button: UIButton!
    var posts = [Firebasepull]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SVProgressHUD.show(withStatus: "Loading")
        UIApplication.shared.beginIgnoringInteractionEvents()
        
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
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
           SVProgressHUD.dismiss()
            UIApplication.shared.endIgnoringInteractionEvents()
        })
       
    }

    
    /// Creates random annotations around predefined center point and presents ARViewController modally
    func showARViewController()
    {
        // Check if device has hardware needed for augmented reality
        let result = ARViewController.createCaptureSession()
        if result.error != nil
        {
            let message = result.error?.userInfo["description"] as? String
            let alertView = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "Close")
            alertView.show()
            return
        }
        let dummyAnnotations = self.getDummyAnnotations()
        
        // Present ARViewController
        let arViewController = ARViewController()
        arViewController.dataSource = self
        arViewController.maxVisibleAnnotations = 100
        arViewController.headingSmoothingFactor = 0.05
        arViewController.setAnnotations(dummyAnnotations)
        self.present(arViewController, animated: true, completion: nil)
    }
    
    /// This method is called by ARViewController, make sure to set dataSource property.
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let annotationView = TestAnnotationView()
        annotationView.frame = CGRect(x: 0,y: 0,width: 150,height: 50)
        return annotationView;
    }
    
    fileprivate func getDummyAnnotations() -> Array<ARAnnotation>
    {
        UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
        var annotations: [ARAnnotation] = []
        
         var i:Int = 0
         while(i < self.posts.count){
            let annotation = ARAnnotation()
        annotation.location=CLLocation(latitude: self.posts[i].latitude, longitude: self.posts[i].longitude)
         annotation.title = self.posts[i].title1
        annotation.note=self.posts[i].note
            annotation.image_url=self.posts[i].image_url
         annotations.append(annotation)
         i=i+1
         }
        SVProgressHUD.dismiss()
        UIApplication.shared.endIgnoringInteractionEvents()
        return annotations
    }
    
    
    @IBAction func buttonTap(_ sender: AnyObject)
    {
        showARViewController()
    }
    
}
