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
            // If the user was found return the user
            return userEntry
        } else if let userEntry = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: context) as? Users {
            userEntry.uid = userID
            userEntry.username = username
            userEntry.auth = auth
            //userEntry.tagLine = ""
            return userEntry
        }
        
        return nil
    }
    
    class func loadUser(userID:String, inManagedObjectContext context: NSManagedObjectContext) -> Users? {
        
        let request = NSFetchRequest(entityName: "Users")
        request.predicate = NSPredicate(format: "uid = %@", userID)
        
        if let userEntry = (try? context.executeFetchRequest(request))?.first as? Users {
            return userEntry
        }
        
        return nil
    }
    
    class func deleteUsers(userID:String, inManagedObjectContext context: NSManagedObjectContext) {
        
        let request = NSFetchRequest(entityName: "Users")
        
        
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
    }

}
