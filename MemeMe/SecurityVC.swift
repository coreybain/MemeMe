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

class SecurityVC: UITableViewController {
    
    var user:Users?
    private let configuration: PasscodeLockConfigurationType
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var touchIDSwitch: UISwitch!
    @IBOutlet weak var changePasscodeLabel: UILabel!
    @IBOutlet weak var passcodeUnlockLabel: UILabel!
    
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
            if !passcodeSwitch.on {
                passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
                
                passcodeVC.successCallback = { [unowned self] Void in
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "touchID")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.touchIDSwitch.on = true
                }
                
                presentViewController(passcodeVC, animated: true, completion: nil)
            } else if !touchIDSwitch.on {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "touchID")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.touchIDSwitch.on = true
            } else {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "touchID")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.touchIDSwitch.on = false
            }
        }
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            if passcodeSwitch.on {
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
                }
                presentViewController(passcodeVC, animated: true, completion: nil)
                
            } else {
                passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
                presentViewController(passcodeVC, animated: true, completion: nil)
            }
        }
        
        if (indexPath.section == 1 && indexPath.row == 1) {
            let hasPasscode = configuration.repository.hasPasscode
            if hasPasscode {
                passcodeVC = PasscodeLockViewController(state: .ChangePasscode, configuration: configuration)
                presentViewController(passcodeVC, animated: true, completion: nil)
            }
        }
        
        if (indexPath.section == 1 && indexPath.row == 1) {
            var error:NSError?
            
            
            
        }
        
        if (indexPath.section == 2 && indexPath.row == 0) {
            //This is the wipe local data
        }
        
        if (indexPath.section == 3 && indexPath.row == 0){
            let logoutAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your MemeMe account?", preferredStyle: .Alert)
            
            let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { Void in
                do{
                    try FIRAuth.auth()!.signOut()
                    MemeMain.memeShared().presentMemeMeInNewWindow()
                } catch {
                    print("ERROR")
                }
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            logoutAlert.addAction(okButton)
            logoutAlert.addAction(cancelButton)
            presentViewController(logoutAlert, animated: true, completion: nil)
            
            
        }
    }
    
}