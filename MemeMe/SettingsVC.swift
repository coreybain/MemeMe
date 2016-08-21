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
    @IBOutlet weak var statusTF: UITextField!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet var settingTableView: UITableView!
    @IBOutlet weak var editDoneButton: UIBarButtonItem!
    @IBOutlet var profileImage: UITapGestureRecognizer!
    
    //MARK: - Variables
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var user:Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusTF.hidden = true
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
        if (indexPath.section == 0 && indexPath.row == 0) {
            return 80
        }
        if (indexPath.section == 1 && indexPath.row == 1) {
            //if device has touch id
            var error: NSError?
            
            if error?.code == LAError.TouchIDNotAvailable.rawValue {
                return 0
            }
        }
        return 47
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.section == 1 && indexPath.row == 0) {
            unlockApp()
        }
        
        if (indexPath.section == 1 && indexPath.row == 1) {
            performSegueWithIdentifier("SegueSecurity", sender: nil)
            
            
            
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
    
    //MARK: -- Actions
    
    @IBAction func unlockSwitchPressed(sender: AnyObject) {
        unlockApp()
    }
    
    @IBAction func profileImagePressed(sender: AnyObject) {
        
        
        
    }
    
    @IBAction func editDoneButtonPressed(sender: AnyObject) {
        if editDoneButton.title == "Edit" {
            statusLabel.hidden = true
            statusTF.hidden = false
            editDoneButton.title = "Done"
            statusTF.becomeFirstResponder()
        } else {
            statusLabel.hidden = false
            statusTF.hidden = true
            editDoneButton.title = "Edit"
            view.endEditing(true)
        }
    }
    
    //MARK -- App Functions
    
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
                    self.statusTF.text = self.user?.tagLine!
                }
                self.userProfileImage.image = UIImage(named: "placeholder.png")?.circle
                //self.touchIDSwitch.setOn(false, animated: false)
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