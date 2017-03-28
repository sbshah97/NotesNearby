//
//  TableVC.swift
//  notesNearby_iOS_final
//
//  Created by Aiman Abdullah Anees on 11/03/17.
//  Copyright © 2017 Aiman Abdullah Anees. All rights reserved.
//

import Foundation

class TableVC:UITableViewController{
    
    var titleArray=[String]()
    var imageArray=[String]()
    
    
    
    
    override func viewDidLoad() {
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        titleArray=["Home","Search Notes","Logout"]
        imageArray=["1","2","logout"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: titleArray[indexPath.row], for: indexPath) as UITableViewCell
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: imageArray[indexPath.row])
        
        let textView = cell.viewWithTag(2) as! UILabel
        textView.text = titleArray[indexPath.row]
        
        return cell
        
    }
    
        
    
    
}
