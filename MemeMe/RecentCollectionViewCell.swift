//
//  RecentCollectionViewCell.swift
//  MemeMe
//
//  Created by Corey Baines on 1/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit

class RecentCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var recentCollectionImage: UIImageView!
    @IBOutlet weak var recentCollectionTick: UIImageView!
    
    func cellSelected(selected: Bool) {
        if selected {
            recentCollectionTick.hidden = false
        } else {
            recentCollectionTick.hidden = true
        }
    }
    
}