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

class EditorVC: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: - Outlets
    // TOP BAR
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
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
    
    //MARK: - Variables
    var meme: Meme?
    var fontAttributer: FontAttribute!
    var imagePickerController: UIImagePickerController!
    var editingMeme:Bool = false
    var memeImage: UIImage!
    weak var recentVC : RecentVC?
    var activeTextField: UITextField?
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    //MARK: - App Lifecycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if simulator or camera not working disable camera button
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        // Setup View based on version
        UIToggle()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotification()
        //subscribeToShakeNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        subscribeToKeyboardNotification()
        //subscribeToShakeNotifications()
        
    }
    
    // Hide status bar from editor view
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: - App Functions
    func UIToggle() {
        let memeLabelArray = [topLabel, bottomLabel]
        
        if isUdacityFirstApp {
            fontButton.enabled = false
            colorButton.enabled = false
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
        dismissViewControllerAnimated(true, completion: nil)
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
            
            let meme = Meme(topLabel: topLabel.text, bottomLabel: bottomLabel.text, savedImage: imageView.image!, savedMeme: nil, memedImage: compileMeme(), fontAttributer: fontAttributer, memeID: nil)
            
            if editingMeme {
                if let meme = self.meme {
                    self.managedObjectContext?.performBlock {
                        Memes.ms().updateMeme(meme, memeID: meme.memeID, inManagedObjectContext: self.managedObjectContext!)
                    }
                    MemeFunctions.saveMeme(meme, complete: { 
                        self.recentVC?.savedReload = true
                        self.recentVC?.navigationController?.navigationBar.topItem?.title = "Uploading 0%"
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            } else {
                // Upload meme to server
                MemeFunctions.saveMeme(meme, complete: { 
                    print("upload complete and working")
                    
                    // this set the bool for saved reload to true so the tableview is reloaded on save
                    self.recentVC?.savedReload = true
                    self.recentVC?.navigationController?.navigationBar.topItem?.title = "Uploading 0%"
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            
        } else {
            alertUser("Problem Saving", message: "The meme is missing the following: ", actions: [UIAlertAction(title: "Ok", style: .Default, handler: nil)])
        }
    }
}

//MARK: - Shake to reset while editing meme
extension EditorVC {
    
    // Respond the the shake notification
    func alertForReset() {
        let ac = UIAlertController(title: "Reset?", message: "Are you sure you want to reset the font size and type?", preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Reset", style: .Default, handler: { Void in
            /* Reset to default values and update the Meme's font */
            self.setFontAttributeDefaults(40.0, fontName: "HelveticaNeue-CondensedBlack", fontColor: UIColor.whiteColor())
            self.updateMemeFont()
        })
        
        /* Alert user with reset and cancel actions */
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(resetAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
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
        /* slide the view up when keyboard appears, using notifications */
        if activeTextField == bottomLabel && view.frame.origin.y == 0.0 {
            
            bottomLabel.frame.origin.y = -getKeyboardHeight(notification)
            saveButton.enabled = false
            
        }
    }
    
    //Push bottom label down on keyboard hide
    func keyboardWillHide(notification: NSNotification) {
        bottomLabel.frame.origin.y = 0 // FIX UP
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