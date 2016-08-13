//
//  FontAttributes.swift
//  MemeMe
//
//  Created by Corey Baines on 7/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import CoreData

@objc(FontAttributesDB)
class FontAttributesDB: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    class func saveFontAttributes(meme:Meme, key:String, inManagedObjectContext context: NSManagedObjectContext) -> FontAttributesDB? {
        
        let request = NSFetchRequest(entityName: "FontAttributesDB")
        request.predicate = NSPredicate(format: "memeID == %@", key)
        
        //FONT ATTRIBUTES
        let fontSize:String = "\(meme.fontAttribute.fontSize)"
        let fontName:String = "\(meme.fontAttribute.fontName)"
        let fontColor = meme.fontAttribute.fontColor.htmlRGBaColor
        print(fontColor)
        let borderColor = meme.fontAttribute.borderColor.htmlRGBaColor
        

        if let fontAttributesDB = (try? context.executeFetchRequest(request))?.first as? FontAttributesDB {
            return fontAttributesDB
        } else if let fontAttributesDB = NSEntityDescription.insertNewObjectForEntityForName("FontAttributesDB", inManagedObjectContext: context) as? FontAttributesDB {
            fontAttributesDB.memeID = key
            fontAttributesDB.fontSize = fontSize
            fontAttributesDB.fontName = fontName
            fontAttributesDB.fontColor = fontColor
            fontAttributesDB.borderColor = borderColor
            do {
                try fontAttributesDB.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
            return fontAttributesDB
        }
        return nil
        
    }
    
    
    
    class func loadFontAttributes(key:String, inManagedObjectContext context: NSManagedObjectContext) -> FontAttributesDB? {
        
        let request = NSFetchRequest(entityName: "FontAttributesDB")
        print(key)
        request.predicate = NSPredicate(format: "memeID == %@", key)
        
        if let fontAttributesDB = (try? context.executeFetchRequest(request))?.first as? FontAttributesDB {
            print(fontAttributesDB.valueForKey("fontColor"))
            return fontAttributesDB
        }
        return nil
        
    }
    
}
