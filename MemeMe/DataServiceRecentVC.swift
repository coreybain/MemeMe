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
    
    func downloadMeme(userID:String, shared:Bool, complete:[Meme]? -> ()) {
        if shared {
            // This is where the app will download Shared memes (in the shared section)
            self.ref.child("memes").observeEventType(.Value, withBlock: { [unowned self] (memeSnapshot) in
                if memeSnapshot.exists() {
                    self.memeDict.removeAll()
                    self.memeCounter = 0
                    self.memeDictCounter = 0
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
                                            self.storageRef.child("\(savedMeme)").dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                                                if (error != nil) {
                                                    print(error?.localizedDescription)
                                                    self.memeDictCounter += 1
                                                    print(self.memeDictCounter)
                                                    print(self.memeCounter)
                                                    if self.memeCounter == self.memeDictCounter {
                                                        self.memeCounter = 0
                                                        self.memeDictCounter = 0
                                                        if self.memeDict.count == 0 {
                                                            complete(nil)
                                                        } else {
                                                            complete(self.memeDict)
                                                        }
                                                    }
                                                } else {
                                                    if privacyLabel == "Public" {
                                                        let memeCell:Meme?
                                                        if memeLatitude != 0.0 {
                                                            memeCell = Meme(topLabel: top, bottomLabel: bottom, memedImageData: data!, fontAttributer: self.fontAttribute, memeID: nil, latitude:memeLatitude, longitude:memeLongitude, privacyLabel: privacyLabel)
                                                        } else {
                                                            memeCell = Meme(topLabel: top, bottomLabel: bottom, memedImageData: data!, fontAttributer: self.fontAttribute, memeID: nil, latitude:0.0, longitude:0.0, privacyLabel: privacyLabel)
                                                        }
                                                        self.memeDict.append(memeCell!)
                                                        print(self.memeCounter)
                                                        print(self.memeDict.count)
                                                        self.memeDictCounter += 1
                                                        if self.memeCounter == self.memeDictCounter {
                                                            self.memeCounter = 0
                                                            self.memeDictCounter = 0
                                                            complete(self.memeDict)
                                                        }
                                                    } else {
                                                        self.memeDictCounter += 1
                                                        if self.memeCounter == self.memeDictCounter {
                                                            self.memeCounter = 0
                                                            self.memeDictCounter = 0
                                                            if self.memeDict.count == 0 {
                                                                complete(nil)
                                                            } else {
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
                    }
                } else {
                    complete(nil)
                }
            })
        } else {
            //This is where the app will download the recent images posted by the current user (if there signing into a new device)
            
            ref.child("users").child(userID).child("memes").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if snapshot.exists() {
                    if Int(snapshot.childrenCount) > self.memeDict.count {
                        for snap in snapshot.children {
                            self.ref.child("memes").child(snap.key!).observeSingleEventOfType(.Value, withBlock: { (memeSnapshot) in
                                self.memeCounter = Int(snapshot.childrenCount)
                                if memeSnapshot.exists() {
                                    self.fontAttribute = FontAttribute()
                                    let bottom = memeSnapshot.value!["bottomLabel"] as! String
                                    let top = memeSnapshot.value!["topLabel"] as! String
                                    let latitude = memeSnapshot.value!["latitude"] as? Double
                                    let longitude = memeSnapshot.value!["longitude"] as? Double
                                    let privacyLabel = memeSnapshot.value!["privacyLabel"] as! String
                                    let attributes = memeSnapshot.value!["fontAttributes"] as! NSDictionary
                                    let savedMeme = memeSnapshot.value!["savedMeme"] as! String
                                    print(savedMeme)
                                    if let borderColor = attributes.valueForKey("borderColor") {
                                        if let fontColor = attributes.valueForKey("fontColor") {
                                            if let fontName = attributes.valueForKey("fontName") {
                                                if let fontSize = attributes.valueForKey("fontSize")  {
                                                    if self.setFontAttributes(fontSize as! String, fontName: fontName as! String, fontColor: fontColor as! String, borderColor: borderColor as! String) {
                                                            self.storageRef.child("\(savedMeme).jpg").dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                                                                if (error != nil) {
                                                                    print(error?.localizedDescription)
                                                                    // Uh-oh, an error occurred!
                                                                    self.memeCounter += 1
                                                                } else {
                                                                    let memeCell:Meme?
                                                                    
                                                                    if latitude != nil && latitude != 0.0 {
                                                                        memeCell = Meme(topLabel: top, bottomLabel: bottom, savedImage: nil, savedMeme: savedMeme, memedImage: nil, memedImageData: data!, fontAttributer: self.fontAttribute, memeID: nil, memedImageString: savedMeme, savedImageString: nil, latitude: latitude!, longitude: longitude!, privacyLabel: privacyLabel)
                                                                    } else {
                                                                        memeCell = Meme(topLabel: top, bottomLabel: bottom, savedImage: nil, savedMeme: savedMeme, memedImage: nil, memedImageData: data!, fontAttributer: self.fontAttribute, memeID: nil, memedImageString: savedMeme, savedImageString: nil, latitude: 0.0, longitude: 0.0, privacyLabel: privacyLabel)
                                                                    }
                                                                    
                                                                    self.memeDict.append(memeCell!)
                                                                    print("\(self.memeCounter) + \(self.memeDict.count)")
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
                        }
                    }
                } else {
                    print("ERROR SNAPSHOT DOES NOT EXIST")
                    complete(nil)
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