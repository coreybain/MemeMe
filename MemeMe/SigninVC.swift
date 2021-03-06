//
//  SigninVC.swift
//  MemeMe
//
//  Created by Corey Baines on 2/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class SigninVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var udacityButton: UIButton!
    @IBOutlet weak var constraintTopLogo: NSLayoutConstraint!
    @IBOutlet weak var loginButtons: UIStackView!
    
    
    //MARK: - Variables
    let facebookLogin = FBSDKLoginManager()
    let alertView = AlertView()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isUdacityApp {
            udacityButton.hidden = true
        }
        
        
    }
    
    //MARK: - App functions
    
    func checkUsername(username:String, complete:(Bool) -> ()) {
        DataService.ds().checkUsername(username) { (usernameUsed) in
            if usernameUsed {
                complete(true)
            } else {
                complete(false)
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func facebookButtonPressed(sender: AnyObject) {
        facebookLogin.logInWithReadPermissions(["email"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
                self.alertView.alertUser("Facebook failed", message: "Facebook login failed. Error \(facebookError.localizedDescription).", actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil)], fromController: self)
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.loading(true)
                })
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    if error != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.loading(false)
                        })
                        print("Login failed. \(error)")
                        self.alertView.alertUser("Facebook failed", message: "Login with facebook failed try again in a little while.", actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil)], fromController: self)
                    } else {
                        print("Logged in! \((user?.email)!)")
                        
                        
                        self.checkUsername((user?.email)!) {(isUsed) in
                            if !isUsed {
                                DataService.ds().addUsernameToList((user?.email)!)
                                DataService.ds().setupUser(user!.email!, userID: user!, complete: {
                                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "fullVersion")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    dispatch_async(dispatch_get_main_queue(), {
                                        MemeMain.memeShared().presentMemeMeInNewWindow()
                                    })
                                })
                            } else {
                                DataService.ds().loginUser((user?.email)!, password:nil, facebook:true, userID:(user?.uid)!, complete: {
                                    print("COMPLETE")
                                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "fullVersion")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    MemeMain.memeShared().presentMemeMeInNewWindow()
                                    }, error: { userError in
                                        print(userError)
                                })
                            }
                        }

                        
                        
                        
                        
                        
                        DataService.ds().addUsernameToList(user!.email!)
                        DataService.ds().setupUser(user!.email!, userID: user!, complete: {
                            dispatch_async(dispatch_get_main_queue(), {
                                MemeMain.memeShared().presentMemeMeInNewWindow()
                            })
                        })
                    }

                }
            }
        })
    }
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("SegueSignin", sender: nil)
    }
    @IBAction func udacityButtonPressed(sender: AnyObject) {
        
        alertView.alertUser("Udacity Instructor", message: "Which version of the app are you assessing?", actions: [
            UIAlertAction(title: "Version 1", style: UIAlertActionStyle.Default, handler: { Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.loading(true)
                })
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "fullVersion")
                NSUserDefaults.standardUserDefaults().synchronize()
                DataService.ds().udacityLogin({ 
                    dispatch_async(dispatch_get_main_queue(), {
                        MemeMain.memeShared().presentMemeMeInNewWindow()
                    })
                    }, error: { userError in
                        self.loading(false)
                        print(userError)
                        self.alertView.alertUser("Udacity Login Error", message: "Um well thats embarrising, there was an error logging in..", actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil)], fromController: self)
                })
            }),
            UIAlertAction(title: "Version 2", style: UIAlertActionStyle.Default, handler: { Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.loading(true)
                })
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "fullVersion")
                NSUserDefaults.standardUserDefaults().synchronize()
                DataService.ds().udacityLogin({
                    dispatch_async(dispatch_get_main_queue(), {
                        MemeMain.memeShared().presentMemeMeInNewWindow()
                    })
                    }, error: { userError in
                        self.loading(false)
                        print(userError)
                        self.alertView.alertUser("Udacity Login Error", message: "Um well thats embarrising, there was an error logging in..", actions: [UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil)], fromController: self)
                })
            })
        ], fromController: self)
    }
    
    func loading(loading:Bool) {
        if loading {
            udacityButton.hidden = true
            loginButtons.hidden = true
            LoadingView.startSpinning(view)
        } else {
            udacityButton.hidden = false
            loginButtons.hidden = false
            LoadingView.stopSpinning()
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
    let alertView = AlertView()
    
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
                                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "fullVersion")
                                            NSUserDefaults.standardUserDefaults().synchronize()
                                            dispatch_async(dispatch_get_main_queue(), {
                                                MemeMain.memeShared().presentMemeMeInNewWindow()
                                            })
                                        }
                                    }, userError: { error in
                                        self.loadingUi(false)
                                        self.alertView.alertUser("Signup failed", message: error.localizedDescription, actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)], fromController: self)
                                    })
                                } else {
                                    self.loadingUi(false)
                                    print("password did not conform to requirements")
                                    self.alertView.alertUser("Password to short", message: "Your password should be at least 6 characters", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)], fromController: self)
                                    self.errorPassView("Your password should be at least 6 characters")
                                }
                            } else {
                                if self.checkPassword(password) {
                                    DataService.ds().loginUser(username, password: password, facebook:false, userID:nil, complete: {
                                        print("COMPLETE")
                                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "fullVersion")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                        dispatch_async(dispatch_get_main_queue(), {
                                            MemeMain.memeShared().presentMemeMeInNewWindow()
                                        })
                                        }, error: { userError in
                                            print(userError)
                                            print(userError.localizedDescription)
                                            self.displayError(userError.code)
                                    })
                                } else {
                                    self.loadingUi(false)
                                    print("password did not conform to requirements")
                                    self.alertView.alertUser("Password to short", message: "Your password should be at least 6 characters", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)], fromController: self)
                                    self.errorPassView("Your password should be at least 6 characters")
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
    func displayError(errorCode:Int) {
        switch errorCode {
        case 17009:
            loadingUi(false)
            self.alertView.alertUser("Password Error", message: "Looks like you entered the wrong username or password", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)], fromController: self)
        default:
            break
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
            self.alertView.alertUser("Email not valid", message: "Your email address is not valid", actions: [UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)], fromController: self)
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
    
    //MARK: Keyboard Functions
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //Next responder for keyboard after clicking done/return
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        switch textField
        {
        case usernameTF:
            usernameTF.resignFirstResponder()
            passwordTF.returnKeyType = .Done
            passwordTF.becomeFirstResponder()
            break
        case passwordTF:
            passwordTF.resignFirstResponder()
            self.signLogin()
            break
        default:
            textField.resignFirstResponder()
        }
        return true
    }

    
    //MARK: - Actions
    @IBAction func signLoginButtonPressed(sender: AnyObject) {
        signLogin()
    }
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
