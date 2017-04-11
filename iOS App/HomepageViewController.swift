//
//  HomepageViewController.swift
//  notesNearby_iOS_final
//
//  Created by Aiman Abdullah Anees on 12/03/17.
//  Copyright © 2017 Aiman Abdullah Anees. All rights reserved.
//

import UIKit

class HomepageViewController: UIViewController {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var logoImageView: UILabel!
    @IBOutlet var register: UIButton!
    @IBOutlet var signIn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyMotionEffect(toView: backgroundImageView, magnitude: 10)
        applyMotionEffect(toView: logoImageView, magnitude: -20)
        
        signIn.layer.cornerRadius=3
        signIn.clipsToBounds=true
        
        register.layer.cornerRadius=3
        register.clipsToBounds=true
        // Do any additional setup after loading the view.
    }
    
    
    func applyMotionEffect (toView view:UIView, magnitude:Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        
        view.addMotionEffect(group)
    }

    

    
}
