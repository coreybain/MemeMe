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
        updatePasscodeView()
    }
    
    func updatePasscodeView() {
        
        let hasPasscode = configuration.repository.hasPasscode
        touchIDSwitch.on = hasPasscode
        passcodeSwitch.on = hasPasscode
        changePasscodeLabel.alpha = 0.4
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var passcodeVC: PasscodeLockViewController
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
            presentViewController(passcodeVC, animated: true, completion: nil)
        }
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            if passcodeSwitch.on {
                passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: configuration)
                
                passcodeVC.successCallback = { lock in
                    
                    lock.repository.deletePasscode()
                }
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