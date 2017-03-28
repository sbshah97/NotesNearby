//
//  LoginViewController.swift
//  notesNearby_iOS_final
//
//  Created by Aiman Abdullah Anees on 12/03/17.
//  Copyright © 2017 Aiman Abdullah Anees. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet var signIn: UIButton!
    @IBOutlet var incorrect: UILabel!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        username.layer.cornerRadius=3
        username.clipsToBounds=true
        password.layer.cornerRadius=3
        password.clipsToBounds=true
        signIn.layer.cornerRadius=3
        signIn.clipsToBounds=true
        password.isSecureTextEntry=true
        
    }

    
    
    
    @IBAction func signInTapped(_ sender: UIButton) {
        if username.text != "" && password.text != ""{
            
            FIRAuth.auth()?.signIn(withEmail: username.text!, password: password.text!, completion: {(user,error) in
            
                if error == nil{
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "mainVC") as! SWRevealViewController
                    
                    self.present(nextViewController, animated:true, completion:nil)
                    
                
                }
                
                else{
                
                self.incorrect.text=error?.localizedDescription
                
                }
            
            })
        
    }

    
}


}
