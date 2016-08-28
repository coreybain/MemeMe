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
        
        if NSUserDefaults.standardUserDefaults().boolForKey("fullVersion") {
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
        
        if (indexPath.section == 1 && indexPath.row == 2) {
            LoadingView.startSpinning(self.view)
        }
        
        if (indexPath.section == 2 && indexPath.row == 0) {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/")!)
        }
        
        if (indexPath.section == 2 && indexPath.row == 1) {
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
            

            AlertView.alertUser("Logout", message: "Do you wish to log out of MemeMe?", actions: [
                UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { Void in
                    do{
                        try FIRAuth.auth()!.signOut()
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("fullVersion")
                        MemeMain.memeShared().presentMemeMeInNewWindow()
                    } catch {
                        AlertView.alertUser("Whoops", message: "Looks like there was an issue logging out, if this keeps happening reinstall the app", actions: [
                            UIAlertAction(title: "Ok", style: UIAlertActionStyle.Destructive, handler: nil)
                            ])
                    }
                }),
                UIAlertAction(title: "No", style: UIAlertActionStyle.Destructive, handler: nil)
            ])
            
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
            statusTF.returnKeyType = .Done
            statusTF.becomeFirstResponder()
        } else {
            statusLabel.hidden = false
            statusTF.hidden = true
            editDoneButton.title = "Edit"
            view.endEditing(true)
        }
    }
    
    //MARK -- App Functions
    
    func getUserInfo() {
        managedObjectContext?.performBlock {
            if let userID = FIRAuth.auth()?.currentUser?.uid {
                
                Users.loadUser(userID, inManagedObjectContext: self.managedObjectContext!, complete: { (user) in
                    if user != nil {
                        print(user?.username)
                        if FIRAuth.auth()?.currentUser?.email != nil {
                            self.usernameLabel.text = FIRAuth.auth()?.currentUser?.email!
                        } else {
                            self.usernameLabel.text = "User not found"
                        }
                        if user?.tagLine != nil {
                            self.statusLabel.text = user?.tagLine!
                            self.statusTF.placeholder = user?.tagLine!
                        } else {
                            self.statusLabel.text = "Try closing the app and trying again."
                        }
                        self.userProfileImage.image = UIImage(named: "placeholder.png")?.circle
                    } else {
                        self.usernameLabel.text = "User not found"
                        self.statusLabel.text = "Try closing the app and trying again."
                        self.userProfileImage.image = UIImage(named: "placeholder.png")?.circle
                    }
                })
                self.settingTableView.reloadData()
            }
        }
    }
    
    func unlockApp() {
        
        if NSUserDefaults.standardUserDefaults().boolForKey("fullVersion") {
            AlertView.alertUser("Switch Versions", message: "Did you want to switch to Version 1 of this app?", actions: [
                UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { Void in
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "fullVersion")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    MemeMain.memeShared().presentMemeMeInNewWindow()
                }),
                UIAlertAction(title: "No", style: UIAlertActionStyle.Destructive, handler: { Void in
                    self.unlockSwitch.setOn(true, animated: true)
                })
            ])
        } else {
            AlertView.alertUser("Switch Versions", message: "Did you want to switch to Version 2 of this app?", actions: [
                UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { Void in
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "fullVersion")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    MemeMain.memeShared().presentMemeMeInNewWindow()
                }),
                UIAlertAction(title: "No", style: UIAlertActionStyle.Destructive, handler: { Void in
                    self.unlockSwitch.setOn(false, animated: true)
                })
            ])
        }
    }
}