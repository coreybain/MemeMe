//
//  DataServiceRecentVC.swift
//  MemeMe
//
//  Created by Corey Baines on 4/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import Firebase

extension DataService {
    
    //MARK: - Download the recent memes for the USERID
    
    func downloadRecents(complete:[Meme]? -> ()) {
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            ref.child("users").child(userID).child("memes").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if snapshot.exists() {
                    if Int(snapshot.childrenCount) > self.memeDict.count {
                        for snap in snapshot.children {
                            print(snap.key!)
                            self.ref.child("memes").child(snap.key!).observeSingleEventOfType(.Value, withBlock: { (memeSnapshot) in
                                print(memeSnapshot.value)
                                self.memeCounter = Int(snapshot.childrenCount)
                                print(self.memeDict.count)
                                print(self.memeCounter)
                                if memeSnapshot.exists() {
                                    self.fontAttribute = FontAttribute()
                                    let bottom = memeSnapshot.value!["bottomLabel"] as! String
                                    let top = memeSnapshot.value!["topLabel"] as! String
                                    let savedMeme = memeSnapshot.value!["savedMeme"] as! String
                                    let memeImage = memeSnapshot.value!["memeImage"] as! String
                                    let savedImage = memeSnapshot.value!["savedImage"] as! String
                                    let latitude = memeSnapshot.value!["latitude"] as? Double
                                    let longitude = memeSnapshot.value!["longitude"] as? Double
                                    let privacyLabel = memeSnapshot.value!["privacyLabel"] as! String
                                    let attributes = memeSnapshot.value!["fontAttributes"] as! NSDictionary
                                    if let borderColor = attributes.valueForKey("borderColor") {
                                        if let fontColor = attributes.valueForKey("fontColor") {
                                            if let fontName = attributes.valueForKey("fontName") {
                                                if let fontSize = attributes.valueForKey("fontSize")  {
                                                    if self.setFontAttributes(fontSize as! String, fontName: fontName as! String, fontColor: fontColor as! String, borderColor: borderColor as! String) {
                                                        print(savedImage)
                                                        print(memeImage)
                                                        print(savedMeme)
                                                        if let savedImageFile = MemeFunctions.loadImageFromPath(MemeFunctions.fileInDocumentsDirectory("\(savedImage)")) {
                                                            if let memeImage = MemeFunctions.loadImageFromPath(MemeFunctions.fileInDocumentsDirectory("\(savedMeme).jpg")) {
                                                                let memeCell:Meme?
                                                                
                                                                if latitude != nil && latitude != 0.0 {
                                                                    memeCell = Meme(topLabel: top, bottomLabel: bottom, savedImage: savedImageFile, savedMeme: savedMeme, memedImage: memeImage, fontAttributer: self.fontAttribute, memeID: nil, memedImageString: savedMeme, savedImageString: savedImage, latitude: latitude!, longitude: longitude!, privacyLabel: privacyLabel)
                                                                } else {
                                                                    memeCell = Meme(topLabel: top, bottomLabel: bottom, savedImage: savedImageFile, savedMeme: savedMeme, memedImage: memeImage, fontAttributer: self.fontAttribute, memeID: nil, memedImageString: savedMeme, savedImageString: savedImage, latitude: 0.0, longitude: 0.0, privacyLabel: privacyLabel)
                                                                }
                                                                
                                                                self.memeDict.append(memeCell!)
                                                                if self.memeCounter == self.memeDict.count {
                                                                    complete(self.memeDict)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            })
                           // print(self.memeDict.count)
                        }
                    }
                } else {
                    print("ERROR SNAPSHOT DOES NOT EXIST")
                    complete(nil)
                }
                
                
                }
            )}
        }
    
    func downloadShared(complete:[Meme] -> ()) {
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            self.ref.child("memes").observeEventType(.Value, withBlock: { [unowned self] (memeSnapshot) in
                if memeSnapshot.exists() {
                    self.memeDict.removeAll()
                    self.memeCounter = 0
                    for memeCount in memeSnapshot.children where (memeCount.value!["userID"] as! String != userID) {
                        self.memeCounter += 1
                    }
                    for memes in memeSnapshot.children where (memes.value!["userID"] as! String != userID){
                        self.fontAttribute = FontAttribute()
                        let bottom = memes.value!["bottomLabel"] as! String
                        let top = memes.value!["topLabel"] as! String
                        let savedMeme = memes.value!["savedMeme"] as! String
                        let privacyLabel = memes.value!["privacyLabel"] as! String
                        let memeLatitude = memes.value!["latitude"] as! Double
                        let memeLongitude = memes.value!["longitude"] as! Double
                        let attributes = memes.value!["fontAttributes"] as! NSDictionary
                        if let borderColor = attributes.valueForKey("borderColor") {
                            if let fontColor = attributes.valueForKey("fontColor") {
                                if let fontName = attributes.valueForKey("fontName") {
                                    if let fontSize = attributes.valueForKey("fontSize")  {
                                        if self.setFontAttributes(fontSize as! String, fontName: fontName as! String, fontColor: fontColor as! String, borderColor: borderColor as! String) {
                                            self.storageRef.child("\(savedMeme).jpg").dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                                                if (error != nil) {
                                                    // Uh-oh, an error occurred!
                                                } else {
                                                    let memeCell:Meme?
                                                    if memeLatitude != 0.0 {
                                                        memeCell = Meme(topLabel: top, bottomLabel: bottom, memedImageData: data!, fontAttributer: self.fontAttribute, memeID: nil, latitude:memeLatitude, longitude:memeLongitude, privacyLabel: privacyLabel)
                                                    } else {
                                                        memeCell = Meme(topLabel: top, bottomLabel: bottom, memedImageData: data!, fontAttributer: self.fontAttribute, memeID: nil, latitude:0.0, longitude:0.0, privacyLabel: privacyLabel)
                                                    }
                                                    self.memeDict.append(memeCell!)
                                                    print(self.memeCounter)
                                                    print(self.memeDict.count)
                                                    if self.memeCounter == self.memeDict.count {
                                                        self.memeCounter = 0
                                                        complete(self.memeDict)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func setFontAttributes(fontSize:String, fontName:String, fontColor:String, borderColor:String) -> Bool {
        if CGFloat((fontSize as NSString).floatValue) != 0.0 {
            self.fontAttribute = FontAttribute()
            let fontSizeOriginal = CGFloat((fontSize as NSString).floatValue)
            fontAttribute.fontName = fontName
            fontAttribute.fontSize = fontSizeOriginal
            print(fontColor)
            if let fontColorOriginal = UIColor(hexString: fontColor) {
                fontAttribute.fontColor = fontColorOriginal
                if let borderColorOriginal = UIColor(hexString: borderColor) {
                    fontAttribute.borderColor = borderColorOriginal
                    return true
                }
            }
           // fontAttributes.fontColor
        }
        return false
    }
    
    
}