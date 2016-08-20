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
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i += 1){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    //MARK: -- TouchID Functions
    func touchIDAuth(reason:String?)  {
        
        
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        var reasonString:String = ""
        if reason == nil {
            reasonString = "Authentication is needed to access your memes."
        } else {
            reasonString = reason!
        }
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                if success {
                    
                }
                else{
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    print(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        print("Authentication was cancelled by the system")
                        
                    case LAError.UserCancel.rawValue:
                        print("Authentication was cancelled by the user")
                        
                    case LAError.UserFallback.rawValue:
                        print("User selected to enter custom password")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                          //  self.showPasswordAlert()
                        })
                        
                    default:
                        print("Authentication failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                           // self.showPasswordAlert()
                        })
                    }
                }
            })]
        }
        else {
            
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                print("TouchID is not enrolled")
                
            case LAError.PasscodeNotSet.rawValue:
                print("A passcode has not been set")
                
            default:
                // The LAError.TouchIDNotAvailable case.
                print("TouchID not available")
            }
            
            // Optionally the error description can be displayed on the console.
            print(error?.localizedDescription)
            
            // Show the custom alert view to allow users to enter the password.
           // self.showPasswordAlert()
        }
 
    }
    
    //MARK: - Alerts
    
    
    
}

enum LAError : Int {
    case AuthenticationFailed
    case UserCancel
    case UserFallback
    case SystemCancel
    case PasscodeNotSet
    case TouchIDNotAvailable
    case TouchIDNotEnrolled
}


