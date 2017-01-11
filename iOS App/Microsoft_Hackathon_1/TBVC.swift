//
//  TBVC.swift
//  Microsoft_Hackathon_1
//
//  Created by Aiman Abdullah Anees on 12/10/16.
//  Copyright © 2016 Aiman Abdullah Anees. All rights reserved.
//
import Foundation
import UIKit

class TableViewController : UITableViewController{
    
    
    var names = [String]()
    var identities = ["B","C","D"]
    var imageArray = ["1","2","4"]
    
    
    override func viewDidLoad() {
        names = ["View Map","Post Note","View in Air"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        //cell?.textLabel?.text = names[indexPath.row]
        let imageView = cell?.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: imageArray[indexPath.row])
        
        let textView = cell?.viewWithTag(2) as! UILabel
        textView.text = names[indexPath.row]
        
        return cell!
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vcName = identities[indexPath.row]
        let viewController = storyboard?.instantiateViewController(withIdentifier: vcName)
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    
}
