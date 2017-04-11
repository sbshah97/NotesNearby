//
//  SettingsViewController.swift
//  notesNearby_iOS_final
//
//  Created by Aiman Abdullah Anees on 11/03/17.
//  Copyright © 2017 Aiman Abdullah Anees. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var open: UIBarButtonItem!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    
    var nameString:String?
    var usernameString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        open.target=revealViewController()
        open.action=Selector("revealToggle:")
        
         self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        nameLabel.text=nameString!
        usernameLabel.text=usernameString!
        

    }
    
    @IBAction func signOut(_ sender: UIButton) {
    }

     

}
