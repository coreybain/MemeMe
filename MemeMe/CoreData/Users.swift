//
//  Users.swift
//  MemeMe
//
//  Created by Corey Baines on 7/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import CoreData

@objc(Users)
class Users: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    class func saveUser(userID:String, username:String?, auth:String?, inManagedObjectContext context: NSManagedObjectContext) -> Users? {
        
        let request = NSFetchRequest(entityName: "Users")
        request.predicate = NSPredicate(format: "uid = %@", userID)
        
        if let userEntry = (try? context.executeFetchRequest(request))?.first as? Users {
            // found this tweet in the database, return it ...
            return userEntry
        } else if let userEntry = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: context) as? Users {
            userEntry.uid = userID
            userEntry.username = username
            userEntry.auth = auth
            return userEntry
        }
        
        return nil
    }
}
