//
//  RegisterViewController.swift
//  notesNearby_iOS_final
//
//  Created by Aiman Abdullah Anees on 12/03/17.
//  Copyright © 2017 Aiman Abdullah Anees. All rights reserved.
//

import UIKit
import Firebase


class RegisterViewController: UIViewController {

    @IBOutlet var incorrect: UILabel!
    @IBOutlet var register: UIButton!
    @IBOutlet var Name: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!    
    @IBOutlet var re_password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        Name.layer.cornerRadius=3
        Name.clipsToBounds=true
        
        username.layer.cornerRadius=3
        username.clipsToBounds=true
        
        password.layer.cornerRadius=3
        password.clipsToBounds=true
        
        re_password.layer.cornerRadius=3
        re_password.clipsToBounds=true
        
        register.layer.cornerRadius=3
        register.clipsToBounds=true

    }

  
    @IBAction func Register_Tapped(_ sender: UIButton) {
        
        if Name.text != "" && username.text != "" && password.text == re_password.text{
            FIRAuth.auth()?.createUser(withEmail: username.text!, password: password.text! , completion:{(user,error) in
            
                if error == nil{
                    self.incorrect.text="Welcome \(self.Name.text!)"
                    print(self.incorrect.text!)
                    
                        
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "mainVC") as! SWRevealViewController
                    
                    self.present(nextViewController, animated:true, completion:nil)

                                       
                }
                else{
                    self.incorrect.text=error?.localizedDescription
                    print(self.incorrect.text!)
                }
            })
        }
        
        else{
            if self.password.text != self.re_password.text{
                self.incorrect.text="Two passwords are not matching"
                print(self.incorrect.text)
                
            }
            else{self.incorrect.text="Some fields are missing"}
        }
    }
}
