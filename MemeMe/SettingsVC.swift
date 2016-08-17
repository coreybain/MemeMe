//
//  SettingsVC.swift
//  MemeMe
//
//  Created by Corey Baines on 10/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreData
import LocalAuthentication

class SettingsVC: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var unlockSwitch: UISwitch!
    @IBOutlet weak var touchIDSwitch: UISwitch!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet var settingTableView: UITableView!
    
    //MARK: - Variables
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var user:Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isUdacityFirstApp {
            unlockSwitch.setOn(true, animated: false)
        } else {
            unlockSwitch.setOn(false, animated: false)
        }
        getUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor(red: 151.0/255, green: 193.0/255, blue: 100.0/255, alpha: 1)
        let font = UIFont(name: "Montserrat", size: 18.0)
        headerView.textLabel!.font = font!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 1) {
            return 0
        }
        return 55
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            unlockApp()
        }
        
        if (indexPath.section == 1 && indexPath.row == 1) {
            
            //if device has touch id
            if #available(iOS 8.0, *) {
                var error: NSError?
                let hasTouchID = LAContext().canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error)
                
                //Show the touch id option if the device has touch id hardware feature (even if the passcode is not set or touch id is not enrolled)
                if(hasTouchID || (error?.code != LAError.TouchIDNotAvailable.rawValue)) {
                   // touchIDContentView.hidden = false
                } 
            }
            
        }
        
        if (indexPath.section == 2 && indexPath.row == 0) {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.spiritdevs.com")!)
        }
        
        if (indexPath.section == 3 && indexPath.row == 0){
            let logoutAlert = UIAlertController(title: "Logout", message: "Do you wish to log out of MemeMe", preferredStyle: .Alert)
            
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
    
    @IBAction func unlockSwitchPressed(sender: AnyObject) {
        unlockApp()
    }
    
    @IBAction func touchIDSwitchPressed(sender: AnyObject) {
    }
    
    func unlock() {
        if isUdacityFirstApp {
            isUdacityFirstApp = false
            unlockSwitch.setOn(false, animated: true)
            MemeMain.memeShared().presentMemeMeInNewWindow()
        } else {
            isUdacityFirstApp = true
            unlockSwitch.setOn(true, animated: true)
            MemeMain.memeShared().presentMemeMeInNewWindow()
        }
    }
    
    func getUserInfo() {
        managedObjectContext?.performBlock {
            if let userID = FIRAuth.auth()?.currentUser?.uid {
                self.user = Users.loadUser(userID, inManagedObjectContext: self.managedObjectContext!)
                if (self.user?.username) != nil {
                    self.usernameLabel.text = self.user?.username!
                }
                if (self.user?.tagLine) != nil {
                    self.statusLabel.text = self.user?.tagLine!
                }
                self.settingTableView.reloadData()
            }
        }
    }
    
    func unlockApp() {
        if !isUdacityFirstApp {
            let unlockAlert = UIAlertController(title: "Unlock app", message: "Are you assessing V2 of the MemeMe app?", preferredStyle: .Alert)
            
            let yesButton = UIAlertAction(title: "Yes", style: .Default, handler: { Void in
                self.unlock()
            })
            let noButton = UIAlertAction(title: "No", style: .Cancel, handler: {
                Void in
                if isUdacityFirstApp {
                    self.unlockSwitch.setOn(false, animated: true)
                } else {
                    self.unlockSwitch.setOn(true, animated: true)
                }
            })
            unlockAlert.addAction(yesButton)
            unlockAlert.addAction(noButton)
            presentViewController(unlockAlert, animated: true, completion: nil)
        } else {
            let unlockAlert = UIAlertController(title: "Revert to V1", message: "Your about to revert the App to V1 for assestment", preferredStyle: .Alert)
            
            let okButton = UIAlertAction(title: "Ok", style: .Default, handler: { Void in
                self.unlock()
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                Void in
                if !isUdacityFirstApp {
                    self.unlockSwitch.setOn(false, animated: true)
                } else {
                    self.unlockSwitch.setOn(true, animated: true)
                }
            })
            unlockAlert.addAction(okButton)
            unlockAlert.addAction(cancelButton)
            presentViewController(unlockAlert, animated: true, completion: nil)
        }
    }
}