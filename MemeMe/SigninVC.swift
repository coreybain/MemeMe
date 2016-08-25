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
    @IBOutlet weak var signLoginButton: UIButton!
    @IBOutlet weak var memeMeLogo: UIImageView!
    @IBOutlet weak var loginFields: UIStackView!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Variables
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps and then closes the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SigninContVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //MARK: - App functions
    func signLogin() {
        if let username = usernameTF.text {
            if let password = passwordTF.text {
                if username != "" {
                    if password != "" {
                        loadingUi(true)
                        checkUsername(username) {(isUsed) in
                            if !isUsed {
                                if self.checkPassword(password) {
                                    DataService.ds().signUpUser(username, password: password, complete: { (complete) in
                                        if complete {
                                            print("signup complete")
                                            MemeMain.memeShared().presentMemeMeInNewWindow()
                                        } else {
                                            print("signup failes")
                                            self.loadingUi(false)
                                            self.alertUser("Signup failed", message: "Creating your user on MemeMe failed", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)])
                                        }
                                    })
                                } else {
                                    self.loadingUi(false)
                                    print("password did not conform to requirements")
                                    self.alertUser("Password to short", message: "Your password should be at least 6 characters", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)])
                                    self.errorPassView("Your password should be at least 6 characters")
                                }
                            } else {
                                if self.checkPassword(password) {
                                    DataService.ds().loginUser(username, password: password, complete: { 
                                        print("COMPLETE")
                                        MemeMain.memeShared().presentMemeMeInNewWindow()
                                    })
                                }
                            }
                        }
                    } else {
                        errorPassView("Password incorrect... Please retype")
                    }
                } else {
                    errorUsernameView()
                    if password == "" {
                        errorPassView("Password incorrect... Please retype")
                    }
                }
            }
        }
    }
    
    func loadingUi(loading:Bool) {
        if loading {
            backButton.hidden = true
            loginFields.hidden = true
            backButton.hidden = true
            signLoginButton.hidden = true
            LoadingView.startSpinning(view)
        } else {
            backButton.hidden = false
            loginFields.hidden = false
            backButton.hidden = false
            signLoginButton.hidden = false
            LoadingView.stopSpinning()
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
            loadingUi(false)
            self.alertUser("Email not valid", message: "Your email address is not valid", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)])
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
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    
    //MARK: - Actions
    @IBAction func signLoginButtonPressed(sender: AnyObject) {
        signLogin()
    }
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
