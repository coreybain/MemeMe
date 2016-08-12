//
//  FontAttributes+CoreDataProperties.swift
//  MemeMe
//
//  Created by Corey Baines on 7/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FontAttributesDB {

    @NSManaged var borderColor: String?
    @NSManaged var fontColor: String?
    @NSManaged var fontName: String?
    @NSManaged var fontSize: String?
    @NSManaged var memeID: String?
    @NSManaged var memes: Memes?

}
