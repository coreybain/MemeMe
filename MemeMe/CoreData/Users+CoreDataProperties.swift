//
//  Users+CoreDataProperties.swift
//  MemeMe
//
//  Created by Corey Baines on 16/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Users {

    @NSManaged var auth: String?
    @NSManaged var uid: String?
    @NSManaged var username: String?
    @NSManaged var tagLine: String?
    @NSManaged var memes: NSSet?

}
