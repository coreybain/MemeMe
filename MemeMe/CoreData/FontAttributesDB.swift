//
//  FontAttributes.swift
//  MemeMe
//
//  Created by Corey Baines on 7/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import CoreData

@objc(FontAttributes)
class FontAttributes: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    class func saveFontAttributes(meme:Meme, inManagedObjectContext context: NSManagedObjectContext) {
        
        //FONT ATTRIBUTES
        let fontSize:String = "\(meme.fontAttribute.fontSize)"
        let fontName:String = "\(meme.fontAttribute.fontName)"
        let fontColor = meme.fontAttribute.fontColor.htmlRGBaColor
        print(fontColor)
        let borderColor = meme.fontAttribute.borderColor.htmlRGBaColor
        
    }
    
}
