//
//  AlertView.swift
//  MemeMe
//
//  Created by Corey Baines on 27/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit

class AlertView {
    
    
    class func alertUser(title: String, message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(ac, animated: true, completion: nil)
        })
    }
    
    
    
}