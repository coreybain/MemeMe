//
//  DataService.swift
//  MemeMe
//
//  Created by Corey Baines on 2/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import Firebase
import CoreData

class DataService {
    
    static let shared = DataService()
    
    static func ds() -> DataService {
        return shared
    }
    
    
    
    //MARK: - Variables
    var memeDict: [Meme] = []
    var fontAttribute: FontAttribute!
    var downloadedMeme: Meme?
    var memeCounter = 0
    var memeDictCounter = 0
    var uploading:Bool = false
    
    // MARK: - Firebase URLS
    var ref = FIRDatabase.database().reference()
    let storage = FIRStorage.storage()
    let storageRef = FIRStorage.storage().referenceForURL("gs://mememe-8c8f3.appspot.com")
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    //MARK: - Login/SignUp Function
    func logSignIn(username:String, password:String, completed:() -> ()) {
        
    }
    
    //MARK: - Check the username of users
    func checkUsername(username:String, complete:Bool -> ()) {
        let firstUser:String = username.stringByReplacingOccurrencesOfString("@", withString: "_")
        let finalUser:String = username.stringByReplacingOccurrencesOfString(".", withString: "+")
        ref.child("usernames").child(finalUser).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if snapshot.exists() {
                complete(true)
            } else {
                complete(false)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Login for Udactiy instructor ***** REMOVE BEFORE APP STORE UPLOAD *******
    func udacityLogin(complete:DownloadComplete) {
        
        loginUser(udacityEmail, password: udacityPassword) { 
            complete()
        }
    }
    
    //MARK: - Log in user after checks are done
    func loginUser(username:String, password:String, complete:DownloadComplete) {
        FIRAuth.auth()?.signInWithEmail(username, password: password) { (user, error) in
            if user?.uid != nil {
                self.downloadUserMemes((user?.uid)!, complete: { (user, meme) in
                    self.managedObjectContext?.performBlock {
                        _ = Users.saveUser(user.userID, username: user.username, auth: user.auth, tagLine: user.tagLine, inManagedObjectContext: self.managedObjectContext!)
                        if meme != nil {
                            _ = Memes.shared.saveDownloadedMeme(meme!, inManagedObjectContext: self.managedObjectContext!)
                        }
                    }
                    print("YAY")
                    complete()
                })
            }
        }
    }
    
    //MARK: -- Download User details and Memes
    func downloadUserMemes(userID:String, complete:(user:User, meme:[Meme]?) -> ()) {
        ref.child("users").child(userID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if snapshot.exists() {
                let username = snapshot.value!["username"] as! String
                var tagLine = ""
                if snapshot.value!["tagLine"] as! String != "" {
                    tagLine = snapshot.value!["tagLine"] as! String
                }
                let auth = snapshot.value!["auth"] as! String
                let mainUser = User.init(username: username, userID: userID, tagLine: tagLine, auth: auth)
                
                self.downloadMeme((FIRAuth.auth()?.currentUser?.uid)!, shared: false) { (meme) in
                    complete(user: mainUser, meme: meme)
                }
            } else {
                let alert = UIAlertController(title: "Problems...", message: "For some reason we couldnt pull up your account, you will need to create a new one.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        MemeMain.memeShared().presentMemeMeInNewWindow()
                    })
                }))
                let user = FIRAuth.auth()?.currentUser
                Memes.shared.deleteMemes((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: self.managedObjectContext!)
                Users.deleteUsers((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: self.managedObjectContext!)
                DataService.ds().removeAccount(user!, complete: { (complete) in
                    if complete {
                        user?.deleteWithCompletion { error in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                MemeMain.memeShared().presentMemeMeInNewWindow()
                            }
                        }
                    } else {
                        print("error")
                    }
                })
                dispatch_async(dispatch_get_main_queue(), {UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                })
            }
        })
    }
    
    //MARK: - setup user entry in database
    func setupUser(username:String, userID:FIRUser, complete:DownloadComplete) {
        let user = userID.uid
        let userDatabase = ["username":username, "auth":"default", "tagLine":"Trying out MemeMe"]
        let mainUser = User.init(username: userID.email!, userID: user, tagLine: "Trying out MemeMe", auth: "default")
        self.managedObjectContext?.performBlock {
            _ = Users.saveUser(mainUser.userID, username: mainUser.username, auth: mainUser.auth, tagLine: mainUser.tagLine, inManagedObjectContext: self.managedObjectContext!)
        }
        ref.child("users").child(user).setValue(userDatabase, withCompletionBlock: { (err, database) in
            if err == nil {
                print(database.description())
                complete()
            }
        })
    }
    
    //MARK: - Add username to check list on firebase
    func addUsernameToList(username:String) {
        
        let firstUser:String = username.stringByReplacingOccurrencesOfString("@", withString: "_")
        let finalUser:String = username.stringByReplacingOccurrencesOfString(".", withString: "+")
        
        ref.child("usernames").child(finalUser).setValue(finalUser)
    }
    
    //MARK: - Sign user up to MemeMe
    func signUpUser(username:String, password:String, complete:Bool -> ()) {
        FIRAuth.auth()?.createUserWithEmail(username, password: password) { (user, error) in
            if (user != nil) {
                self.addUsernameToList(username)
                self.setupUser(username, userID: user!, complete: {
                    complete(true)
                })
            } else {
                complete(false)
            }
        }
    }
    
    
    //MARK: -- Prepare Meme for upload -------
    func prepareMemeForUpload(meme:Meme, memeName:String, complete:DownloadComplete) {
        
        // Local file you want to upload
        let memeImageData:NSURL = NSURL(fileURLWithPath: "\(MemeFunctions.fileInDocumentsDirectory("meme-\(memeName)"))")
        let memeRef = storageRef.child("meme-\(memeName)")
        
        //Get UserID of the user uploading the photo
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        //Image total size
        let imageSize = MemeFunctions.sizeForLocalFilePath(MemeFunctions.fileInDocumentsDirectory("meme-\(memeName)"))
        
        // Create the file metadata
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //FONT ATTRIBUTES
        let fontSize:String = "\(meme.fontAttribute.fontSize)"
        let fontName:String = "\(meme.fontAttribute.fontName)"
        let fontColor = meme.fontAttribute.fontColor.htmlRGBaColor
        print(fontColor)
        let borderColor = meme.fontAttribute.borderColor.htmlRGBaColor
        
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            
            var imageDetails:NSDictionary?
            if meme.longitude != 0.0 {
                imageDetails = ["fontAttributes":["fontSize":fontSize, "fontName":fontName, "fontColor":fontColor, "borderColor":borderColor],"topLabel":meme.topLabel, "bottomLabel":meme.bottomLabel, "savedImage":"saved-\(memeName)", "savedMeme": "meme-\(memeName)", "memeImage":"\(memeRef)", "userID":"\(userID)", "latitude":meme.latitude, "longitude":meme.longitude, "privacyLabel":meme.privacyLabel]
            } else {
                imageDetails = ["fontAttributes":["fontSize":fontSize, "fontName":fontName, "fontColor":fontColor, "borderColor":borderColor],"topLabel":meme.topLabel, "bottomLabel":meme.bottomLabel, "savedImage":"saved-\(memeName).jpg", "savedMeme": "meme-\(memeName).jpg", "memeImage":"\(memeRef)", "userID":"\(userID)", "latitude":0.0, "longitude":0.0, "privacyLabel":meme.privacyLabel]
            }
        
            if meme.memeID == "" {
                self.ref.child("memes").childByAutoId().setValue(imageDetails) { (err, database) in
                    print(database.key)
                    let key = database.key
                    self.ref.child("users").child(userID).child("memes").child(key).setValue(key, withCompletionBlock: { (err, database) in
                        if err == nil {
                            // This is where the connection to core Data will go
                            self.uploadMeme(memeRef, meme:memeImageData, metadata:metadata, imageSize:imageSize, memeDetails: imageDetails!)
                            self.managedObjectContext?.performBlock {
                                Memes.ms().saveMemeLocal(meme, key: key, memeName: memeName, inManagedObjectContext: self.managedObjectContext!)
                                complete()
                            }
                        }
                    })
                    if err != nil {
                        print(err.debugDescription)
                    }
                }
            } else {
                let memeID = meme.memeID
                print(memeID)
                self.ref.child("memes").child(memeID).updateChildValues(imageDetails as! [NSObject : AnyObject]) { (err, database) in
                    print(database.key)
                    let key = database.key
                    if err == nil {
                        self.uploadMeme(memeRef, meme:memeImageData, metadata:metadata, imageSize:imageSize, memeDetails: imageDetails!)
                        self.managedObjectContext?.performBlock {
                            Memes.ms().saveMemeLocal(meme, key: key, memeName: memeName, inManagedObjectContext: self.managedObjectContext!)
                            complete()
                        }
                    } else {
                        print(err?.localizedDescription)
                    }
                }
                //self.uploadMeme(memeRef, meme:memeImageData, metadata:metadata, imageSize:imageSize, memeDetails: imageDetails)
                //complete()
                /*self.ref.child("memes").child(meme.memeID).setValue(imageDetails) { (err, database) in
                    if (err == nil) {
                        self.uploadMeme(memeRef, meme:memeImageData, metadata:metadata, imageSize:imageSize, memeDetails: imageDetails)
                    } else {
                        print(err)
                    }
                }*/
            }
        }

    }
    
    
    
    
    //MARK: - Upload Meme
    func uploadMeme(memeRef:FIRStorageReference, meme:NSURL, metadata: FIRStorageMetadata, imageSize:UInt64, memeDetails:NSDictionary) {
        
        
        
        let uploadMemeTask = memeRef.putFile(meme, metadata: metadata)
        uploadMemeTask.observeStatus(.Progress) { snapshot in
            // Upload reported progress
            if let progress = snapshot.progress {
                
                var fileInfo = [NSObject:AnyObject]()
                
                
            let percentComplete = 100.0 * (Double(progress.completedUnitCount) / Double(imageSize))
                fileInfo["progress"] = "Uploading \(Int(percentComplete))%"
                
                print("\(Int(percentComplete))%")
                let defaultCenter = NSNotificationCenter.defaultCenter()
                defaultCenter.postNotificationName("uploadProgressNotification",
                                                   object: nil,
                                                   userInfo: fileInfo)
            
            }
        }
        
        // Success uploading image
        uploadMemeTask.observeStatus(.Success) { snapshot in
            // Upload completed successfully
            // Set savedImageUpsated to true
            print("SUCCESS")
            var fileInfo = [NSObject:AnyObject]()
            fileInfo["progress"] = "Recent Memes"
            let defaultCenter = NSNotificationCenter.defaultCenter()
            defaultCenter.postNotificationName("uploadProgressNotificationSuccess",
                                               object: nil,
                                               userInfo: fileInfo)
            
        }
        
        // Errors only occur in the "Failure" case
        uploadMemeTask.observeStatus(.Failure) { snapshot in
            guard let storageError = snapshot.error else { return }
            guard let errorCode = FIRStorageErrorCode(rawValue: storageError.code) else { return }
            switch errorCode {
            case .ObjectNotFound:
                // File doesn't exist
                print("error")
            case .Unauthorized:
                // User doesn't have permission to access file
                print("error")
            case .Cancelled:
                // User canceled the upload
                print("error")
            case .Unknown:
                // Unknown error occurred, inspect the server response
                print("error")
            default:
                print("error")
                
            }
        }
    
    }
    
    func deleteOnlineMeme (meme:Meme) {
        ref.child("memes").child(meme.memeID).removeValue()
    }
    
    func updatePrivacyLabel(memeID:String, privacyLabel:Bool) {
        if privacyLabel {
            ref.child("memes").child(memeID).child("privacyLabel").setValue("Private")
        } else {
            ref.child("memes").child(memeID).child("privacyLabel").setValue("Public")
        }
    }
    
    
}