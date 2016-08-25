//
//  ViewController.swift
//  MemeMe
//
//  Created by Corey Baines on 1/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import UIKit
import SnapKit
import LocalAuthentication
import PasscodeLock

class LoadingVC: UIViewController, UIAlertViewDelegate {
    
    
    @IBOutlet weak var spinView: UIView!
    let container = UIView()
    private let configuration: PasscodeLockConfigurationType
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        LoadingView.startSpinning(view)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let hasPasscode = configuration.repository.hasPasscode
        let touchToken = NSUserDefaults.standardUserDefaults().objectForKey("touchID") as? Bool
        let firstRun = NSUserDefaults.standardUserDefaults().objectForKey("firstRun") as? Bool
        var passcodeVC: PasscodeLockViewController
        print(touchToken)
        if (touchToken != nil) && (touchToken == true) && (firstRun == nil) {
            self.touchIDAuth()
        } else if hasPasscode && (firstRun == nil) {
            passcodeVC = PasscodeLockViewController(state: .EnterPasscode, configuration: configuration)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstRun")
            
            passcodeVC.successCallback = { Void in
                dispatch_async(dispatch_get_main_queue(), {
                    MemeMain.memeShared().presentMemeMeInNewWindow()
                })
            }
            
            presentViewController(passcodeVC, animated: true, completion: nil)
        } else if (firstRun == nil) {
            dispatch_async(dispatch_get_main_queue(), {
                MemeMain.memeShared().presentMemeMeInNewWindow()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -- TouchID Functions
    func touchIDAuth()  {
        
        
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        let reasonString = "Authentication is needed to access your memes."
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        LoadingView.stopSpinning()
                        MemeMain.memeShared().presentMemeMeInNewWindow()
                    })
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
                            self.passcode()
                        })
                        
                    default:
                        print("Authentication failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.passcode()
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
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "touchID")
                passcode()
            case LAError.PasscodeNotSet.rawValue:
                print("A passcode has not been set")
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "touchID")
                passcode()
            default:
                // The LAError.TouchIDNotAvailable case.
                print("TouchID not available")
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "touchID")
                passcode()
            }
            
            // Optionally the error description can be displayed on the console.
            print(error?.localizedDescription)
            
            // Show the custom alert view to allow users to enter the password.
             self.passcode()
        }
        
    }
    
    func passcode() {
        
        let hasPasscode = configuration.repository.hasPasscode
        var passcodeVC: PasscodeLockViewController
        passcodeVC = PasscodeLockViewController(state: .EnterPasscode, configuration: configuration)
        passcodeVC.successCallback = { void in
            dispatch_async(dispatch_get_main_queue(), {
                LoadingView.stopSpinning()
                MemeMain.memeShared().presentMemeMeInNewWindow()
            })
        }
        presentViewController(passcodeVC, animated: true, completion: nil)
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



}

