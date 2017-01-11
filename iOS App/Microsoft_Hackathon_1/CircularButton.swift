//
//  CircularButton.swift
//  Microsoft_Hackathon_1
//
//  Created by Aiman Abdullah Anees on 29/12/16.
//  Copyright © 2016 Aiman Abdullah Anees. All rights reserved.
//

import UIKit
@IBDesignable
class CircularButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 30.0{
        didSet{
        layer.cornerRadius=cornerRadius
    }
}
    override func prepareForInterfaceBuilder(){
        setupView()
    }
    
    func setupView(){
        layer.cornerRadius=cornerRadius
        
    }
}
