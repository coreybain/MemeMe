//
//  SecurityVC.swift
//  MemeMe
//
//  Created by Corey Baines on 20/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import PasscodeLock
import Firebase
import CoreData
import LocalAuthentication

class SecurityVC: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var touchIDSwitch: UISwitch!
    @IBOutlet weak var changePasscodeLabel: UILabel!
    @IBOutlet weak var passcodeUnlockLabel: UILabel!
    
    //MARK: - Variables
    var user:Users?
    private let configuration: PasscodeLockConfigurationType
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    //MARK: - App Lifecycle
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
        navigationController?.navigationItem.title = "Security"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updatePasscodeView()
    }
    
    
    //MARK: - Actions
    @IBAction func touchIDSwitch(sender: AnyObject) {
        touchIDActive()
    }
    
    @IBAction func passcodeSwitch(sender: AnyObject) {
        passcodeActive()
    }
    
    
    //MARK: - App Functions
    func updatePasscodeView() {
        
        let hasPasscode = configuration.repository.hasPasscode
        let touchToken = NSUserDefaults.standardUserDefaults().objectForKey("touchID") as? Bool
        print(touchToken)
        
        if (touchToken != nil) && (touchToken == true){
            touchIDSwitch.on = true
        } else {
            touchIDSwitch.on = false
        }
        passcodeSwitch.on = hasPasscode
        if !passcodeSwitch.on {
            changePasscodeLabel.alpha = 0.4
            passcodeUnlockLabel.text = "Turn on Passcode Unlock"
        } else {
            changePasscodeLabel.alpha = 1.0
            passcodeUnlockLabel.text = "Turn off Passcode Unlock"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var passcodeVC: PasscodeLockViewController
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            touchIDActive()
        }
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            passcodeActive()
        }
        
        if (indexPath.section == 1 && indexPath.row == 1) {
            let hasPasscode = configuration.repository.hasPasscode
            if hasPasscode {
                passcodeVC = PasscodeLockViewController(state: .ChangePasscode, configuration: configuration)
                presentViewController(passcodeVC, animated: true, completion: nil)
            }
        }
        
        if (indexPath.section == 2 && indexPath.row == 0) {
            //This is the wipe local data
            
            let resetAlert = UIAlertController(title: "Reset Local Data", message: "Are you sure you want to reset all local data and redownload?", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { [unowned self] Void in
                Memes.shared.deleteMemes((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: self.managedObjectContext!)
                Users.deleteUsers((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: self.managedObjectContext!)
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            resetAlert.addAction(okButton)
            resetAlert.addAction(cancelButton)
            presentViewController(resetAlert, animated: true, completion: nil)
            
            
            
        }
        
        if (indexPath.section == 3 && indexPath.row == 0){
            let user = FIRAuth.auth()?.currentUser
            
            let deleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your MemeMe account?", preferredStyle: .Alert)
            
            let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { [unowned self] Void in
                
                let authAlert = UIAlertController(title: "SpritID Password", message: "Enter the ApiritID password for \(user!.email!) to delete your account.", preferredStyle: .Alert)
                authAlert.addTextFieldWithConfigurationHandler({ (password) in
                    password.placeholder = "Enter password here"
                    password.secureTextEntry = true
                    password.clearButtonMode = .WhileEditing
                })
                authAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
                    let passField = authAlert.textFields![0] as UITextField
                    if passField.text != "" {
                        let credential = FIREmailPasswordAuthProvider.credentialWithEmail((user?.email)!, password: passField.text!)
                        // Prompt the user to re-provide their sign-in credentials
                        user?.reauthenticateWithCredential(credential) { error in
                            if let error = error {
                                print(error.localizedDescription)
                                //This is where the error alert would go
                            } else {
                                NSUserDefaults.standardUserDefaults().removeObjectForKey("touchID")
                                NSUserDefaults.standardUserDefaults().removeObjectForKey("passcode.lock.passcode")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                Memes.shared.deleteMemes((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: self.managedObjectContext!)
                                Users.deleteUsers((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: self.managedObjectContext!)
                                DataService.ds().removeAccount(user!, complete: { (complete) in
                                    if complete {
                                        user?.deleteWithCompletion { error in
                                            if let error = error {
                                                print(error.localizedDescription)
                                            } else {
                                                MemeMain.memeShared().presentMemeMeInNewWindow()
                                            }
                                        }
                                    } else {
                                        print("error")
                                    }
                                })
                            }
                        }

                    }
                }))
                authAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                self.presentViewController(authAlert, animated: true, completion: nil)
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            deleteAlert.addAction(okButton)
            deleteAlert.addAction(cancelButton)
            presentViewController(deleteAlert, animated: true, completion: nil)
            
            
        }
    }
    
    func touchIDActive() {
        var passcodeVC: PasscodeLockViewController
        if touchIDCheck() {
            if !NSUserDefaults.standardUserDefaults().boolForKey("passcode") {
                passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
                
                passcodeVC.successCallback = { [unowned self] Void in
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "touchID")
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "passcode")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.touchIDSwitch.on = true
                }
                
                presentViewController(passcodeVC, animated: true, completion: nil)
            } else if !NSUserDefaults.standardUserDefaults().boolForKey("touchID") {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "touchID")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.touchIDSwitch.on = true
            } else {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "touchID")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.touchIDSwitch.on = false
            }
        } else {
            let touchIDFail = UIAlertController(title: "Touch ID not active", message: "You need to go to settings and setup touch ID to work with this device.", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            touchIDFail.addAction(okButton)
            presentViewController(touchIDFail, animated: true, completion: nil)
            touchIDSwitch.on = false
        }
    }
    
    func passcodeActive() {
        var passcodeVC: PasscodeLockViewController
        if NSUserDefaults.standardUserDefaults().boolForKey("passcode") {
            passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: configuration)
            
            passcodeVC.successCallback = { [unowned self] lock in
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "touchID")
                NSUserDefaults.standardUserDefaults().synchronize()
                lock.repository.deletePasscode()
                self.passcodeSwitch.on = false
                self.changePasscodeLabel.alpha = 0.4
                self.passcodeUnlockLabel.text = "Turn on Passcode Unlock"
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "touchID")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.touchIDSwitch.on = false
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "passcode")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            presentViewController(passcodeVC, animated: true, completion: nil)
            
        } else {
            passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
            presentViewController(passcodeVC, animated: true, completion: nil)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "passcode")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func touchIDCheck() -> Bool {
        
        
        
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            return true
        } else {
            return false
        }
    }
    
}