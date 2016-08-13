//
//  Memes+CoreDataProperties.swift
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

extension Memes {

    @NSManaged var bottomLabel: String?
    @NSManaged var memeImage: String?
    @NSManaged var savedImage: String?
    @NSManaged var savedMeme: String?
    @NSManaged var topLabel: String?
    @NSManaged var memeID: String?
    @NSManaged var userID: String?
    @NSManaged var users: Users?
    @NSManaged var fontAttributesDB: FontAttributesDB?

}
