//
//  RecentTableViewCell.swift
//  MemeMe
//
//  Created by Corey Baines on 1/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit

class RecentTableViewCell: UITableViewCell {
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var recentImageView: UIView!
    @IBOutlet weak var recentNameLabel: UILabel!
    @IBOutlet weak var recentPrivacyLabel: UILabel!
    @IBOutlet weak var recentImage: UIImageView!
    @IBOutlet weak var uploadIndicator: UIActivityIndicatorView!
    
    //MARK: - Variables
    var isPrivate:Bool = true
    
    
    override func awakeFromNib() {
        uploadIndicator.hidesWhenStopped = true
        
        
        if isPrivate {
            recentPrivacyLabel.text = "Private Photo"
        } else {
            recentPrivacyLabel.text = "Public Photo"
        }
        
        
    }
    
}