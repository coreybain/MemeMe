//
//  UIViewControllerExtentions.swift
//  MemeMe
//
//  Created by Corey Baines on 14/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit

//#-MARK:Shake to reset Extension of UIViewController:
extension UIViewController {
    
    /* Allow view to become first responder to respond to shake notifications */
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    /* Handle motion events and respond to shake notification */
    override public func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake {
            NSNotificationCenter.defaultCenter().postNotificationName("shake", object: self)
        }
    }
}