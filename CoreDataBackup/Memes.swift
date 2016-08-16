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

@objc(Memes)
class Memes: NSManagedObject {
    
    static let shared = Memes()
    
    static func ms() -> Memes {
        return shared
    }
    
    //MARK: - Variables
    var fontAttribute: FontAttribute!
    var memeDict: [Meme] = []

// Insert code here to add functionality to your managed object subclass
    
    func saveMemeLocal(meme:Meme, key:String, memeImage:String, originalImage:String, inManagedObjectContext context: NSManagedObjectContext) {
        
        if let savedMeme = NSEntityDescription.insertNewObjectForEntityForName("Memes", inManagedObjectContext: context) as? Memes {
            // created a new tweet in the database
            // load it up with information from the Twitter.Tweet ...
            savedMeme.memeID = key
            savedMeme.bottomLabel = meme.bottomLabel
            savedMeme.topLabel = meme.topLabel
            savedMeme.memeImage = memeImage
            savedMeme.savedImage = originalImage
            savedMeme.userID = (FIRAuth.auth()?.currentUser?.uid)!
            savedMeme.fontAttributesDB = FontAttributesDB.saveFontAttributes(meme, key:key, inManagedObjectContext: context)
            savedMeme.users = Users.saveUser((FIRAuth.auth()?.currentUser?.uid)!, username: nil, auth: nil, inManagedObjectContext: context)
            do {
                try savedMeme.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }
    
    func updateMeme(meme:Meme, memeID:String, inManagedObjectContext context: NSManagedObjectContext) {
        let request = NSFetchRequest(entityName: "Memes")
        request.predicate = NSPredicate(format: "memeID == %@", memeID)
        
        let user = FIRAuth.auth()?.currentUser?.uid
        let fileName:String  = "\(user!)-\(MemeMain.memeShared().randomStringWithLength(10))"
        let imageName:String = "\(fileName).jpg"
        
        if let savedMeme = (try? context.executeFetchRequest(request))?.first as? Memes {
            savedMeme.bottomLabel = meme.bottomLabel
            savedMeme.topLabel = meme.topLabel
            savedMeme.memeImage = fileName
            savedMeme.savedImage = imageName
            savedMeme.fontAttributesDB = FontAttributesDB.saveFontAttributes(meme, key:memeID, inManagedObjectContext: context)
            do {
                try savedMeme.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }
    
    func loadMemeLocal(userID:String, inManagedObjectContext context: NSManagedObjectContext) -> [Meme]? {
        memeDict.removeAll()
        let request = NSFetchRequest(entityName: "Memes")
        print(userID)
        request.predicate = NSPredicate(format: "userID == %@", userID)
        
        if let results = (try? context.executeFetchRequest(request)) {
            print(results)
            for meme in results {
                if let top = meme.valueForKey("topLabel") {
                    if let bottom = meme.valueForKey("bottomLabel") {
                        if let memeID = meme.valueForKey("memeID") {
                            if let memeImage = meme.valueForKey("memeImage") {
                                if let savedImage = meme.valueForKey("savedImage") {
                                    if let localFont = FontAttributesDB.loadFontAttributes(memeID as! String, inManagedObjectContext: context) {
                                        print(localFont)
                                        print(localFont.fontColor)
                                        if let fontSize = localFont.fontSize {
                                            if let fontName = localFont.fontName {
                                                if let fontColor = localFont.fontColor {
                                                    if let borderColor = localFont.borderColor {
                                                        print("SAVED IMAGE::: \(savedImage)")
                                                        print("MEMED IMAGE::: \(memeImage)")
                                                        self.fontAttribute = FontAttribute()
                                                        if DataService.ds().setFontAttributes(fontSize, fontName: fontName, fontColor: fontColor, borderColor: borderColor) {
                                                            print("YES")
                                                            if let savedImageFile = MemeFunctions.loadImageFromPath(MemeFunctions.fileInDocumentsDirectory("saved-\(savedImage)")) {
                                                                print("YESY")
                                                               if let memeImagefile = MemeFunctions.loadImageFromPath(MemeFunctions.fileInDocumentsDirectory("meme-\(memeImage).jpg")) {
                                                                    print("HELLLOOOOO STAR")
                                                                let memeCell = Meme(topLabel: top as? String, bottomLabel: bottom as? String, savedImage: savedImageFile, savedMeme: memeImage as? String, memedImage: memeImagefile, fontAttributer: self.fontAttribute, memeID: memeID as! String)
                                                                self.memeDict.append(memeCell)                                               }
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
                }
            }
            memeDict = memeDict.reverse()
            return memeDict
        }
        return nil
    }
    
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
