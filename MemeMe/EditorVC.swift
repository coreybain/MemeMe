//
//  EditorVC.swift
//  MemeMe
//
//  Created by Corey Baines on 2/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class EditorVC: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate, SwiftColorPickerDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    
    //MARK: - Outlets
    // TOP BAR
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var locationIcon: UIBarButtonItem!
    
    // BOTTOM BAR
    @IBOutlet weak var fontButton: UIBarButtonItem!
    @IBOutlet weak var colorButton: UIBarButtonItem!
    @IBOutlet weak var galleryButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    // MIDDLE SECTION
    @IBOutlet weak var topLabel: UITextField!
    @IBOutlet weak var bottomLabel: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomLabelCon: NSLayoutConstraint!
    
    //MARK: - Variables
    var meme: Meme?
    var fontAttributer: FontAttribute!
    var imagePickerController: UIImagePickerController!
    var editingMeme:Bool = false
    var memeImage: UIImage!
    weak var recentVC : RecentVC?
    weak var memeDetailVC: MemeDetailVC?
    var activeTextField: UITextField?
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var bottomLabelConOriginal:CGFloat!
    
    //Location variables
    let locationManager = CLLocationManager()
    var memeLocation: CLLocation?
    
    //MARK: - App Lifecycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        //if simulator or camera not working disable camera button
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        // Setup View based on version
        UIToggle()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomLabelConOriginal = bottomLabelCon.constant
        
        subscribeToKeyboardNotification()
        //subscribeToShakeNotifications()
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        subscribeToKeyboardNotification()
        //subscribeToShakeNotifications()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            self.memeLocation = location
            self.locationManager.stopUpdatingLocation()
        }
        
    }
    
    // Hide status bar from editor view
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - App Functions
    func UIToggle() {
        let memeLabelArray = [topLabel, bottomLabel]
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("fullVersion") {
            fontButton.enabled = false
            colorButton.enabled = false
        }
        
        if NSUserDefaults.standardUserDefaults().boolForKey("locationOn") {
            locationIcon.image = UIImage(named: "locationOn")
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        } else {
            locationIcon.image = UIImage(named: "locationOff")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "locationOn")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        if let editMeme = meme {
            // Settings for editing your or others existing meme
            navigationBar.topItem?.title = "Edit your Meme"
            topLabel.text = editMeme.topLabel
            bottomLabel.text = editMeme.bottomLabel
            imageView.image = editMeme.savedImage
            fontAttributer = editMeme.fontAttribute
            setuplabels(memeLabelArray)
        } else {
            //Setting for creating new Memes
            navigationBar.topItem?.title = "Create new Meme"
            fontAttributer = FontAttribute()
            shareButton.enabled = false
            setuplabels(memeLabelArray)
        }
        
        
        shareButton.enabled = editingMeme
        cancelButton.enabled = editingMeme
        saveButton.enabled = editingMeme
        
        setuplabels(memeLabelArray)
        
    }
    
    // Setup top and bottom Labels for Meme Editor
    func setuplabels(labels: [UITextField!]){
        for label in labels{
            label.delegate = self
            
            // Define attibutes of Meme Text Labels
            let memeTextAttributes = [
                NSStrokeColorAttributeName: UIColor.blackColor(),
                NSForegroundColorAttributeName: fontAttributer.fontColor,
                NSFontAttributeName: UIFont(name: fontAttributer.fontName, size: fontAttributer.fontSize)!,
                NSStrokeWidthAttributeName : -4.0
            ]
            label.defaultTextAttributes = memeTextAttributes
            label.textAlignment = .Center
        }
    }
    
    func alertUser(title: String, message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func clearMeme() {
        imageView.image = nil
        topLabel.text = nil
        bottomLabel.text = nil
    }
    
    func updateFonts() {
        setuplabels([topLabel, bottomLabel])
    }
    
    func canSave() -> Bool {
        if imageView.image == nil {
            return false
        }
        
        if (topLabel.text == nil) && (bottomLabel.text == nil) {
            return false
        }
        
        return true
    }
    
    func compileMeme() -> UIImage {
        // Disable everything while saving
        savingMeme(true)
        
        // Render the screen view into a UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        memeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // enable buttons in view again
        savingMeme(false)
        
        return memeImage
    }
    
    
    func savingMeme(saving:Bool) {
        navigationController?.setNavigationBarHidden(saving, animated: false)
        navigationBar.hidden = saving
        bottomBar.hidden = saving
    }
    
    //MARK: - Actions
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        if !editingMeme {
            if topLabel.text != "" || bottomLabel.text != "" || imageView.image != nil {
                alertForReset("Reset or Cancel", message: "Do you want to reset the meme or go back to your recent memes?", shake: false)
            } else {
                dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func galleryButtonPressed(sender: AnyObject) {
        // Check if gallery is available to app
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            // Setup the image picker controller and display editor
            imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePickerController.allowsEditing = false
            
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        // Create cameraVC based on check done in viewdidload
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if canSave() {
            let meme:Meme?
            topLabel.resignFirstResponder()
            bottomLabel.resignFirstResponder()
            var originalMemeID:String?
            var originalSavedMeme:String?
            if editingMeme {
                originalMemeID = self.meme!.memeID
                originalSavedMeme = self.meme!.savedMeme
            }
            
            if CLLocationManager.locationServicesEnabled() && NSUserDefaults.standardUserDefaults().boolForKey("locationOn") {
                let lat = memeLocation?.coordinate.latitude
                let long = memeLocation?.coordinate.longitude
                print(long)
                
                meme = Meme(topLabel: topLabel.text, bottomLabel: bottomLabel.text, savedImage: imageView.image!, savedMeme: originalSavedMeme, memedImage: compileMeme(), memedImageData: nil, fontAttributer: fontAttributer, memeID: originalMemeID, memedImageString: nil, savedImageString: nil, latitude: lat!, longitude: long!, privacyLabel: "Public")
                print(topLabel.text)
            } else {
                
                meme = Meme(topLabel: topLabel.text, bottomLabel: bottomLabel.text, savedImage: imageView.image!, savedMeme: originalSavedMeme, memedImage: compileMeme(), memedImageData: nil, fontAttributer: fontAttributer, memeID: originalMemeID, memedImageString: nil, savedImageString: nil, latitude: 0.0, longitude: 0.0, privacyLabel: "Public")
                print(topLabel.text)
            }
                // Upload meme to server
                MemeFunctions.saveMeme(meme!, memeID: originalMemeID, complete: {
                    print("upload complete and working")
                    
                    // this set the bool for saved reload to true so the tableview is reloaded on save
                    if self.editingMeme {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.memeDetailVC?.imageView.image = meme!.memedImage
                        })
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            
        } else {
            alertUser("Problem Saving", message: "The meme is missing the following: ", actions: [UIAlertAction(title: "Ok", style: .Default, handler: nil)])
        }
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        
        let shareVC = UIActivityViewController(activityItems: [compileMeme()], applicationActivities: nil)
        shareVC.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.saveButtonPressed(self)
            }
        }
        presentViewController(shareVC, animated: true, completion: nil)
    }
    
    
    @IBAction func locationIconPressed(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().boolForKey("locationOn") {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "locationOn")
            NSUserDefaults.standardUserDefaults().synchronize()
            locationIcon.image = UIImage(named: "locationOff")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "locationOn")
            NSUserDefaults.standardUserDefaults().synchronize()
            locationIcon.image = UIImage(named: "locationOn")
        }
    }
    
    //MARK: Segue overrides for color and font picker
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFontPopover" {
            let popoverVC = segue.destinationViewController as! TextPickerView
            popoverVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverVC.popoverPresentationController!.delegate = self
            popoverVC.fontAttributer = fontAttributer
        }
        
        if segue.identifier == "segueColorPickerPopover" {
            /* Launch color picker in popover view */
            let colorPopover = segue.destinationViewController as! SwiftColorPickerViewController
            colorPopover.delegate = self
            colorPopover.modalPresentationStyle = UIModalPresentationStyle.Popover
            colorPopover.popoverPresentationController!.delegate = self
        }
        
    }
    
    /* Popover delegate method */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    /* SwiftColorPickerDelegate function */
    func colorSelectionChanged(selectedColor color: UIColor) {
        fontAttributer.fontColor = color
        setuplabels([topLabel, bottomLabel])
    }
    
}


//MARK: - Shake to reset while editing meme
extension EditorVC {
    
    // Respond the the shake notification
    func alertForReset(title:String, message:String, shake:Bool) {
        
        let resetAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let resetAll = UIAlertAction(title: "Reset Meme", style: .Default, handler: { Void in
            /* Reset to default values and update the Meme's font */
            /*
             self.setFontAttributeDefaults(40.0, fontName: "HelveticaNeue-CondensedBlack", fontColor: UIColor.whiteColor())
            self.updateMemeFont() 
            */
            self.clearMeme()
        })
        var resetAction = UIAlertAction()
        var cancelAction = UIAlertAction()
        if shake {
            resetAction = UIAlertAction(title: "Reset Font", style: .Default, handler: { Void in
                /*
                 self.setFontAttributeDefaults(40.0, fontName: "HelveticaNeue-CondensedBlack", fontColor: UIColor.whiteColor())
                 self.updateMemeFont()
                 */
            })
            cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            resetAlert.addAction(resetAction)
        } else {
            cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        resetAlert.addAction(resetAll)
        resetAlert.addAction(cancelAction)
        //Present reset alert as popup with reset
        presentViewController(resetAlert, animated: true, completion: nil)
    }
    
    /* Subsribe to shake notifications */
    func subscribeToShakeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditorVC.alertForReset), name: "shake", object: nil)
    }
    
    /* Unsubsribe to shake notifications */
    func unsubsribeToShakeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "shake", object: nil)
    }
}

//MARK: - Keyboard Functions with Labels
extension EditorVC {
    
    
    //Subscribe to Keyboard Notifications from system
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditorVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditorVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Unsubscribe to Keyboard Notifications from system
    func unsubsribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // slide the bottom textfield up when keyboard it showing
        print(bottomLabelCon.constant)
        print(bottomLabelConOriginal)
        
        if bottomLabelCon.constant == bottomLabelConOriginal {
            
            bottomLabelCon.constant = self.bottomLabelConOriginal + getKeyboardHeight(notification)
            saveButton.enabled = false
            
        }
    }
    
    //Push bottom label down on keyboard hide
    func keyboardWillHide(notification: NSNotification) {
        bottomLabelCon.constant = self.bottomLabelConOriginal
        saveButton.enabled = canSave()
    }
    
    //Keyboard height from dict notification
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    //Hide the keyboard when the user taps anywhere else on the view is tapped
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        // Check if fields are filled and user can save image -- if so enable save button
        saveButton.enabled = canSave()
        
        setuplabels([topLabel, bottomLabel])
    }

}




//MARK: -  Extend UIImagePickerDelegate Methods
extension EditorVC {
    
    /* UIImagePickerDelegate methods */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        imageView.image = image
        
        /* Enable share & cancel buttons once image is returned */
        shareButton.enabled = canSave()
        saveButton.enabled = canSave()
        cancelButton.enabled = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}