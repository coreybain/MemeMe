//
//  MemeMain.swift
//  MemeMe
//
//  Created by Corey Baines on 1/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import LocalAuthentication

class MemeMain {
    
    static let shared = MemeMain()
    
    static func memeShared() -> MemeMain {
        return shared
    }
    
    
    // MARK: - Variables
    
    // Setup and Binding to window
    private(set) var bindedToWindow: UIWindow!
    private(set) var isStarted: Bool = false
    var uploading:Bool = false

    
    //MARK: - Create MemeMe
    func createMemeMe() {
        
        //Add in here any func that need to run at startup
        
        isStarted = true
    }
    
    // MARK: - Create and connect to view
    func presentMemeMeInNewWindow() {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds);
        window.backgroundColor = UIColor.whiteColor()
        presentMemeInWindow(window)
        window.makeKeyAndVisible()
    }
    
    
    func presentMemeInWindow(window: UIWindow) {
        
        // This will stop the app and revert back if MemeMe is not started correctly: BEWARE!
        
        if !isStarted {
            fatalError("You got here without initiating MemeMe lol")
        }
        
        //This beings the following view code to this window ref -> presentBeaconInNewWindow()
        self.bindedToWindow = window
        
        if (FIRAuth.auth()?.currentUser) != nil {
            // User is signed in.
            print("Signing in user")
            //user is logged in so show main view
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewControllerWithIdentifier("MainVC")
            window.rootViewController = mainVC
            
        } else {
            
            // No user is signed in.
            print("NOT SIGNED IN")
            //if not logged in then show the welcome view in storyboard
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let welcomeVC = storyboard.instantiateViewControllerWithIdentifier("WelcomeVC")
            window.rootViewController = welcomeVC

        }
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    //MARK: - Alerts
    
    
    
}