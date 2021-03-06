//
//  Meme.swift
//  MemeMe
//
//  Created by Corey Baines on 2/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

struct Meme {
    
    //MARK: - Variables
    
    var _topLabel:String?
    var _bottomLabel:String?
    var _savedMeme:String?
    var _memeID:String?
    var _savedImageString: String!
    var _memedImageString: String!
    var _savedImage: UIImage!
    var _memedImage: UIImage!
    var _memedImageData: NSData!
    var _latitude: Double!
    var _longitude: Double!
    var _privacyLabel: String!
    var fontAttribute: FontAttribute!
    
    var topLabel:String {
        get {
            if _topLabel == nil {
                return ""
            }
            return _topLabel!
        }
    }
    
    var bottomLabel:String {
        get {
            if _bottomLabel == nil {
                return ""
            }
            return _bottomLabel!
        }
    }
    
    var savedMeme:String {
        get {
            if _savedMeme == nil {
                return ""
            }
            return _savedMeme!
        }
    }
    
    var memeID:String {
        get {
            if _memeID == nil {
                return ""
            }
            return _memeID!
        }
    }
    
    var savedImageString:String {
        get {
            if _savedImageString == nil {
                return ""
            }
            return _savedImageString!
        }
    }
    
    var memedImageString:String {
        get {
            if _memedImageString == nil {
                return ""
            }
            return _memedImageString!
        }
    }
    
    var savedImage:UIImage {
        get {
            return _savedImage
        }
    }
    
    var memedImage:UIImage {
        get {
            return _memedImage
        }
    }
    
    var memedImageData:NSData {
        get {
            return _memedImageData
        }
    }
    
    var latitude:Double {
        get {
            return _latitude
        }
    }
    
    var longitude:Double {
        get {
            return _longitude
        }
    }
    
    var privacyLabel:String {
        get {
            return _privacyLabel
        }
    }
    
    init(topLabel:String?, bottomLabel:String?, savedImage:UIImage?, savedMeme:String?, memedImage:UIImage?, memedImageData:NSData?, fontAttributer:FontAttribute?, memeID:String?, memedImageString:String?, savedImageString:String?, latitude:Double, longitude:Double, privacyLabel:String) {
        _topLabel = topLabel
        _bottomLabel = bottomLabel
        _savedImage = savedImage
        _memedImage = memedImage
        fontAttribute = fontAttributer
        _savedMeme = savedMeme
        _memeID = memeID
        _savedImageString = savedImageString
        _memedImageString = memedImageString
        _latitude = latitude
        _longitude = longitude
        _privacyLabel = privacyLabel
        _memedImageData = memedImageData
    }
    
    init(topLabel:String?, bottomLabel:String?, memedImageData:NSData, fontAttributer:FontAttribute, memeID:String?, latitude:Double, longitude:Double, privacyLabel:String) {
        _topLabel = topLabel
        _bottomLabel = bottomLabel
        _memedImageData = memedImageData
        fontAttribute = fontAttributer
        _memeID = memeID
        _latitude = latitude
        _longitude = longitude
        _privacyLabel = privacyLabel
    }
}

struct MemeFunctions {
    
    // Add meme to local database before uploading it to firebase
    static func saveMeme(meme:Meme, memeID:String?, complete:DownloadComplete) {
        print(meme)
        let user = FIRAuth.auth()?.currentUser?.uid
        var fileName:String = ""
        if memeID == "" || memeID == nil { 
            fileName = "\(user!)-\(MemeMain.memeShared().randomStringWithLength(10))"
            
        } else {
            print(meme.savedMeme)
            let firstPass = meme.savedMeme.stringByReplacingOccurrencesOfString("meme-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            print(firstPass)
            fileName = firstPass.stringByReplacingOccurrencesOfString(".jpg", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        print(fileName)
        let memeImage = meme.memedImage
        let originalImage = meme.savedImage
        
        print(fileName)
        saveImage(memeImage, path: fileInDocumentsDirectory("meme-\(fileName)"))
        saveImage(originalImage, path: fileInDocumentsDirectory("saved-\(fileName)"))
        
        DataService.ds().prepareMemeForUpload(meme, memeName: fileName) {
            //GO HERE
            print("finished")
            complete()
        }
    }
    
    static func saveImage (image: UIImage, path: String ) -> Bool{
        
        //let pngImageData = UIImagePNGRepresentation(image)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        let result = imageData!.writeToFile(path, atomically: true)
        
        return result
        
    }
    
    static func getMemeStorage() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    static func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = getMemeStorage().URLByAppendingPathComponent(filename)
        return fileURL.path!
        
    }
    
    static func sizeForLocalFilePath(filePath:String) -> UInt64 {
        do {
            let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
            if let fileSize = fileAttributes[NSFileSize]  {
                return (fileSize as! NSNumber).unsignedLongLongValue
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
    static func loadImageFromPath(path: String) -> UIImage? {
        
        let image = UIImage(contentsOfFile: path)
        
        if image == nil {
            
            print("missing image at: \(path)")
        }
        print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
        
    }
}


// Font attributes for MemeMe Labels
struct FontAttribute {
    var fontSize: CGFloat = 40.0
    var fontName = "HelveticaNeue-CondensedBlack"
    var fontColor = UIColor.whiteColor()
    var borderColor = UIColor.blackColor()
}



