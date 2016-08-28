//
//  Memes.swift
//  MemeMe
//
//  Created by Corey Baines on 7/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import Firebase
import CoreData
import CoreLocation

@objc(Memes)
class Memes: NSManagedObject {
    
    static let shared = Memes()
    
    static func ms() -> Memes {
        return shared
    }
    
    //MARK: - Variables
    var fontAttribute: FontAttribute!
    var memeDict: [Meme] = []


    //MARK: SaveMeme Function -- This function saves memes in core data
    func saveMemeLocal(meme:Meme, key:String, memeName:String, inManagedObjectContext context: NSManagedObjectContext) {
        
        
        let request = NSFetchRequest(entityName: "Memes")
        request.predicate = NSPredicate(format: "memeID == %@", key)
        if ((try? context.executeFetchRequest(request))?.first as? Memes) != nil {
            deleteSpecificMeme(key, inManagedObjectContext: context)
        }
        if let savedMemes = NSEntityDescription.insertNewObjectForEntityForName("Memes", inManagedObjectContext: context) as? Memes {
            // created a new tweet in the database
            // load it up with information from the Twitter.Tweet ...
            print(meme.longitude)
            print(meme.latitude)
            savedMemes.memeID = key
            savedMemes.bottomLabel = meme.bottomLabel
            savedMemes.topLabel = meme.topLabel
            print("\(memeName).jpg")
            savedMemes.memeImage = "meme-\(memeName).jpg"
            savedMemes.savedImage = "saved-\(memeName).jpg"
            savedMemes.longitude = meme.longitude
            savedMemes.latitude = meme.latitude
            savedMemes.privacyLabel = meme.privacyLabel
            savedMemes.userID = (FIRAuth.auth()?.currentUser?.uid)!
            savedMemes.fontAttributesDB = FontAttributesDB.saveFontAttributes(meme, key:key, inManagedObjectContext: context)
            savedMemes.users = Users.saveUser((FIRAuth.auth()?.currentUser?.uid)!, username: nil, auth: nil, tagLine: nil, inManagedObjectContext: context)
            do {
                try savedMemes.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }
    
    //MARK: SaveDownloaded Function -- This function saves memes in core data that have been downloaded from Firebase
    func saveDownloadedMeme(memes:[Meme], inManagedObjectContext context: NSManagedObjectContext) {
        
        for meme in memes {
            print(meme.memedImageString)
            print(meme.savedImageString)
            if let savedMeme = NSEntityDescription.insertNewObjectForEntityForName("Memes", inManagedObjectContext: context) as? Memes {
                savedMeme.memeID = meme.memeID
                savedMeme.bottomLabel = meme.bottomLabel
                savedMeme.topLabel = meme.topLabel
                savedMeme.memeImage = "\(meme.memedImageString)"
                savedMeme.savedImage = "\(meme.savedImageString)"
                savedMeme.longitude = meme.longitude
                savedMeme.latitude = meme.latitude
                savedMeme.memedImageData = meme.memedImageData
                savedMeme.privacyLabel = meme.privacyLabel
                savedMeme.userID = (FIRAuth.auth()?.currentUser?.uid)!
                savedMeme.fontAttributesDB = FontAttributesDB.saveFontAttributes(meme, key:meme.memeID, inManagedObjectContext: context)
                savedMeme.users = Users.saveUser((FIRAuth.auth()?.currentUser?.uid)!, username: nil, auth: nil, tagLine: nil, inManagedObjectContext: context)
                do {
                    try savedMeme.managedObjectContext?.save()
                } catch {
                    let saveError = error as NSError
                    print(saveError)
                }
            }
        }
    }
    
    //MARK: Update Memes privacy label -- hide or show in global share
    func updatePrivacy(memeID:String, privateLabel:Bool, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest(entityName: "Memes")
        request.predicate = NSPredicate(format: "memeID == %@", memeID)
        
        if let savedMeme = (try? context.executeFetchRequest(request))?.first as? Memes {
            if privateLabel {
                savedMeme.privacyLabel = "Private"
            } else {
                savedMeme.privacyLabel = "Public"
            }
            do {
                try savedMeme.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }
    
    //MARK: LoadMemes Function -- This function loads memes from core data
    func loadMemeLocal(userID:String, inManagedObjectContext context: NSManagedObjectContext) -> [Meme]? {
        memeDict.removeAll()
        let request = NSFetchRequest(entityName: "Memes")
        print(userID)
        request.predicate = NSPredicate(format: "userID == %@", userID)
        
        if let results = (try? context.executeFetchRequest(request)) {
            for meme in results {
                
                let topLabel = meme.valueForKey("topLabel") as! String
                let bottomLabel = meme.valueForKey("bottomLabel") as! String
                let memeID = meme.valueForKey("memeID") as! String
                let longitude = meme.valueForKey("longitude") as! Double
                let latitude = meme.valueForKey("latitude") as! Double
                let privacyLabel = meme.valueForKey("privacyLabel") as! String
                    
                    if editableMeme(meme) {
                        
                        if let localFont = FontAttributesDB.loadFontAttributes(memeID, inManagedObjectContext: context) {
                            let fontSize = localFont.fontSize
                            let fontName = localFont.fontName
                            let fontColor = localFont.fontColor
                            let borderColor = localFont.borderColor
                            self.fontAttribute = FontAttribute()
                            
                            let savedImage = meme.valueForKey("savedImage") as! String
                            print(savedImage)
                            let memeImage = meme.valueForKey("memeImage") as! String
                            print(memeImage)
                            
                            
                            
                            
                            if let savedImageFile = MemeFunctions.loadImageFromPath(MemeFunctions.fileInDocumentsDirectory(savedImage)) {
                                print("YESY")
                                if let memeImagefile = MemeFunctions.loadImageFromPath(MemeFunctions.fileInDocumentsDirectory(memeImage)) {
                                    print("HELLLOOOOO STAR")
                                    let memeCell:Meme?
                                    if (longitude as? Double)! == 0.0 {
                                        memeCell = Meme(topLabel: topLabel, bottomLabel: bottomLabel, savedImage: savedImageFile, savedMeme: memeImage, memedImage: memeImagefile, memedImageData: nil, fontAttributer: self.fontAttribute, memeID: memeID, memedImageString: nil, savedImageString: nil, latitude: (latitude as? Double)!, longitude: (longitude as? Double)!, privacyLabel: privacyLabel)
                                    } else {
                                        memeCell = Meme(topLabel: topLabel, bottomLabel: bottomLabel, savedImage: savedImageFile, savedMeme: memeImage, memedImage: memeImagefile, memedImageData: nil, fontAttributer: self.fontAttribute, memeID: memeID, memedImageString: nil, savedImageString: nil, latitude: 0.0, longitude: 0.0, privacyLabel: privacyLabel)
                                    }
                                    self.memeDict.append(memeCell!)
                                }
                            }
                        }
                    } else {
                        let memeData = meme.valueForKey("memedImageData") as! NSData
                        let memeCell:Meme?
                        if (longitude as? Double)! == 0.0 {
                            memeCell = Meme(topLabel: topLabel, bottomLabel: bottomLabel, savedImage: nil, savedMeme: nil, memedImage: nil, memedImageData: memeData, fontAttributer: nil, memeID: memeID, memedImageString: nil, savedImageString: nil, latitude: (latitude as? Double)!, longitude: (longitude as? Double)!, privacyLabel: privacyLabel)
                        } else {
                            print(topLabel)
                            print(bottomLabel)
                            print(memeData)
                            print(memeID)
                            print(privacyLabel)
                            memeCell = Meme(topLabel: topLabel, bottomLabel: bottomLabel, savedImage: nil, savedMeme: nil, memedImage: nil, memedImageData: memeData, fontAttributer: nil, memeID: memeID, memedImageString: nil, savedImageString: nil, latitude: 0.0, longitude: 0.0, privacyLabel: privacyLabel)
                        }
                        self.memeDict.append(memeCell!)
                    }
                }
            memeDict = memeDict.reverse()
            return memeDict
        }
        return nil
    }
    
    func editableMeme(meme:AnyObject) -> Bool {
        if meme.valueForKey("memedImageData") != nil {
            return false
        } else {
            return true
        }
    }
    
    func deleteSpecificMeme(memeID:String, inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest(entityName: "Memes")
        request.predicate = NSPredicate(format: "memeID == %@", memeID)
        if var savedMeme = (try? context.executeFetchRequest(request)) {
            
            var objectForDeletion: NSManagedObject!
            
            for objectForDeletion: AnyObject in savedMeme
            {
                context.deleteObject(objectForDeletion as! NSManagedObject)
            }
            
            savedMeme.removeAll(keepCapacity: false)
            
            do {
                try context.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
        
    }
    
    //MARK: DELETE Function -- This DELETEs memes hahahaha
    func deleteMemes(userID:String, inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest(entityName: "Memes")
        let fontRequest = NSFetchRequest(entityName: "FontAttributesDB")

        
        if var results = (try? context.executeFetchRequest(request)) {
            
            var bas: NSManagedObject!
            
            for bas: AnyObject in results
            {
                context.deleteObject(bas as! NSManagedObject)
            }
            
            results.removeAll(keepCapacity: false)
            
            do {
                try context.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
        
        if var results = (try? context.executeFetchRequest(fontRequest)) {
            
            var bas: NSManagedObject!
            
            for bas: AnyObject in results
            {
                context.deleteObject(bas as! NSManagedObject)
            }
            
            results.removeAll(keepCapacity: false)
            
            do {
                try context.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
        
    }
}
