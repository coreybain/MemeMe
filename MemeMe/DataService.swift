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
        FIRAuth.auth()?.signInWithEmail(udacityEmail, password: udacityPassword) { (fireUser, error) in
            if let user = fireUser?.uid {
                self.managedObjectContext?.performBlock {
                    _ = Users.saveUser(user, username: udacityEmail, auth: nil, inManagedObjectContext: self.managedObjectContext!)
                }
                self.setupUser(udacityEmail, userID: fireUser!, complete: {
                    print("YAY")
                    complete()
                })
            }
        }
    }
    
    //MARK: - Log in user after checks are done
    func loginUser(username:String, password:String, complete:DownloadComplete) {
        FIRAuth.auth()?.signInWithEmail(username, password: password) { (user, error) in
            if user?.uid != nil {
                self.managedObjectContext?.performBlock {
                    _ = Users.saveUser((user?.uid)!, username: username, auth: nil, inManagedObjectContext: self.managedObjectContext!)
                }
                print("YAY")
                complete()
            }
        }
    }
    
    //MARK: - setup user entry in database
    func setupUser(username:String, userID:FIRUser, complete:DownloadComplete) {
        let user = userID.uid
        let userDatabase = ["username":username, "auth":"default"]
        ref.child("users").child(user).setValue(userDatabase, withCompletionBlock: { (err, database) in
            if err == nil {
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
                self.managedObjectContext?.performBlock {
                    Users.saveUser((user?.uid)!, username: username, auth: "default", inManagedObjectContext: self.managedObjectContext!)
                }
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
    func prepareMemeForUpload(meme:Meme, uploadName:String, imageName:String, complete:DownloadComplete) {
        
        // Local file you want to upload
        let memeImageData:NSURL = NSURL(fileURLWithPath: "\(MemeFunctions.fileInDocumentsDirectory("meme-\(imageName)"))")
        let memeRef = storageRef.child("meme-\(imageName)")
        
        //Image total size
        let imageSize = MemeFunctions.sizeForLocalFilePath(MemeFunctions.fileInDocumentsDirectory("meme-\(imageName)"))
        
        // Create the file metadata
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //FONT ATTRIBUTES
        let fontSize:String = "\(meme.fontAttribute.fontSize)"
        let fontName:String = "\(meme.fontAttribute.fontName)"
        let fontColor = meme.fontAttribute.fontColor.htmlRGBaColor
        print(fontColor)
        let borderColor = meme.fontAttribute.borderColor.htmlRGBaColor
        
        var imageDetails = ["fontAttributes":["fontSize":fontSize, "fontName":fontName, "fontColor":fontColor, "borderColor":borderColor],"topLabel":meme.topLabel, "bottomLabel":meme.bottomLabel, "savedImage":"saved-\(imageName)", "savedMeme": "meme-\(uploadName)", "memeImage":"\(memeRef)"]
        print(imageDetails.description)
        
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            if meme.memeID == "" {
                self.ref.child("memes").childByAutoId().setValue(imageDetails) { (err, database) in
                    let test = database.key
                    self.ref.child("users").child(userID).child("memes").child(test).setValue(test, withCompletionBlock: { (err, database) in
                        if err == nil {
                            // This is where the connection to core Data will go
                            self.uploadMeme(memeRef, meme:memeImageData, metadata:metadata, imageSize:imageSize, memeDetails: imageDetails)
                            self.managedObjectContext?.performBlock {
                                Memes.ms().saveMemeLocal(meme, key: test, memeImage: uploadName, originalImage: imageName, inManagedObjectContext: self.managedObjectContext!)
                                complete()
                            }
                        }
                    })
                }
            } else {
                let memeID = meme.memeID
                self.ref.child("memes").child(memeID).updateChildValues(imageDetails as [NSObject : AnyObject]) { (err, database) in
                    if err == nil {
                        self.uploadMeme(memeRef, meme:memeImageData, metadata:metadata, imageSize:imageSize, memeDetails: imageDetails)
                        complete()
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
                defaultCenter.postNotificationName("DownloadProgressNotification",
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
            defaultCenter.postNotificationName("DownloadProgressNotification",
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
    
    
    
}