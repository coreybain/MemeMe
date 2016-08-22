//
//  DataServiceDelete.swift
//  MemeMe
//
//  Created by Corey Baines on 21/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import Firebase

extension DataService {
    
    //MARK: -- Remove Account and delete all data
    
    func removeAccount(user:FIRUser, complete:Bool -> ()) {
        ref.child("users").child(user.uid).child("memes").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if snapshot.exists() {
                for snap in snapshot.children {
                    self.ref.child("memes").child(snap.key!).removeValue()
                }
                self.ref.child("users").child(user.uid).removeValue()
                complete(true)
            } else {
                self.ref.child("users").child(user.uid).removeValue()
                complete(true)
            }
        })
    }
}