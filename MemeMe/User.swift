//
//  User.swift
//  MemeMe
//
//  Created by Corey Baines on 16/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class User {
    
    //MARK: - Variables
    
    var _userID:String?
    var _auth:String?
    var _tagLine:String?
    var _username:String?
    
    var userID:String {
        get {
            if _userID == nil {
                _userID = ""
            }
            return _userID!
        }
    }
    
    var auth:String {
        get {
            if _auth == nil {
                _auth = ""
            }
            return _auth!
        }
    }
    
    var tagLine:String {
        get {
            if _tagLine == nil {
                _tagLine = ""
            }
            return _tagLine!
        }
    }
    
    var username:String {
        get {
            if _username == nil {
                _username = ""
            }
            return _username!
        }
    }
    
    init(username:String, userID:String, tagLine:String?, auth:String) {
        _userID = userID
        _username = username
        _auth = auth
        _tagLine = tagLine
    }
}
