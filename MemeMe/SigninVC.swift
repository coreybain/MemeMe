//
//  SigninVC.swift
//  MemeMe
//
//  Created by Corey Baines on 2/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit

class SigninVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var udacityButton: UIButton!
    
    //MARK: - Variables
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isUdacityApp {
            udacityButton.hidden = true
        }
        
        
    }
    
    //MARK: - App functions
    
    //MARK: - Actions
    
    @IBAction func facebookButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("SegueSignin", sender: nil)
    }
    @IBAction func udacityButtonPressed(sender: AnyObject) {
        DataService.ds().udacityLogin {
            print("HELLO")
            MemeMain.memeShared().presentMemeMeInNewWindow()
        }
    }
}

class SigninContVC: UIViewController {
    
    
    //MARK: - Outlets
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signLoginButton: UIButton!
    
    //MARK: - Variables
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        
        
    }
    
    //MARK: - App functions
    func signLogin() {
        if let username = usernameTF.text {
            if let password = passwordTF.text {
                if username != "" {
                    if password != "" {
                        checkUsername(username) {(isUsed) in
                            if !isUsed {
                                if self.checkPassword(password) {
                                    self.activityMode(3)
                                    DataService.ds().signUpUser(username, password: password, complete: { (complete) in
                                        if complete {
                                            print("signup complete")
                                            self.activityIndicator.stopAnimating()
                                            MemeMain.memeShared().presentMemeMeInNewWindow()
                                        } else {
                                            print("signup failes")
                                            self.alertUser("Signup failed", message: "Creating your user on MemeMe failed", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)])
                                        }
                                    })
                                } else {
                                    print("password did not conform to requirements")
                                    self.alertUser("Password to short", message: "Your password should be at least 6 characters", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)])
                                    self.activityMode(3)
                                    self.errorPassView("Your password should be at least 6 characters")
                                }
                            } else {
                                if self.checkPassword(password) {
                                    DataService.ds().loginUser(username, password: password, complete: { 
                                        print("COMPLETE")
                                        self.activityMode(2)
                                        MemeMain.memeShared().presentMemeMeInNewWindow()
                                    })
                                }
                            }
                        }
                    } else {
                        errorPassView("Password incorrect... Please retype")
                        self.activityMode(1)
                    }
                } else {
                    errorUsernameView()
                    if password == "" {
                        errorPassView("Password incorrect... Please retype")
                    }
                    self.activityMode(1)
                }
            }
        }
    }
    
    func checkUsername(username:String, complete:(Bool) -> ()) {
        if isValidEmail(username) {
            DataService.ds().checkUsername(username) { (usernameUsed) in
                if usernameUsed {
                    complete(true)
                } else {
                    complete(false)
                }
            }
        } else {
            self.alertUser("Email not valid", message: "Your email address is not valid", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)])
            self.activityMode(1)
        }
        
    }
    
    func activityMode(status:Int) {
        switch status {
        case 1:
            self.activityIndicator.stopAnimating()
            self.signLoginButton.enabled = true
            self.signLoginButton.setTitle("Signup/Login", forState: .Normal)
        case 2:
            self.activityIndicator.startAnimating()
            self.signLoginButton.enabled = false
            self.signLoginButton.setTitle("Working", forState: .Normal)
        case 3:
            self.activityIndicator.stopAnimating()
            self.signLoginButton.enabled = true
            self.signLoginButton.setTitle("Register User", forState: .Normal)
        case 4:
            self.activityIndicator.stopAnimating()
            self.signLoginButton.enabled = true
            self.signLoginButton.setTitle("Login", forState: .Normal)
        default:
            self.activityIndicator.stopAnimating()
            self.signLoginButton.enabled = true
            self.signLoginButton.setTitle("Signup/Login", forState: .Normal)
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func checkPassword(password:String) -> Bool {
        if password.characters.count >= 6 {
            return true
        }
        return false
    }
    
    func errorPassView(placeholder:String) {
        self.passwordTF.text = ""
        self.passwordTF.placeholder = placeholder
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.passwordTF.backgroundColor = TEXT_ERROR_COLOR
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.passwordTF.backgroundColor = UIColor.clearColor()
                })
        })
    }
    func errorUsernameView() {
        self.usernameTF.placeholder = "Username incorrect... Please retype"
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.usernameTF.backgroundColor = TEXT_ERROR_COLOR
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.usernameTF.backgroundColor = UIColor.clearColor()
                })
        })
    }
    
    func alertUser(title: String, message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    

    
    //MARK: - Actions
    @IBAction func signLoginButtonPressed(sender: AnyObject) {
        self.activityMode(2)
        signLogin()
    }
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}