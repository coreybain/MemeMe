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

class Meme {
    
    //MARK: - Variables
    
    var _topLabel:String?
    var _bottomLabel:String?
    var _savedMeme:String?
    var _memeID:String?
    var _savedImage: UIImage!
    var _memedImage: UIImage!
    var fontAttribute: FontAttribute!
    
    var topLabel:String {
        get {
            if _topLabel == nil {
                _topLabel = ""
            }
            return _topLabel!
        }
    }
    
    var bottomLabel:String {
        get {
            if _bottomLabel == nil {
                _bottomLabel = ""
            }
            return _bottomLabel!
        }
    }
    
    var savedMeme:String {
        get {
            if _savedMeme == nil {
                _savedMeme = ""
            }
            return _savedMeme!
        }
    }
    
    var memeID:String {
        get {
            if _memeID == nil {
                _memeID = ""
            }
            return _memeID!
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
    
    init(topLabel:String?, bottomLabel:String?, savedImage:UIImage, savedMeme:String?, memedImage:UIImage, fontAttributer:FontAttribute, memeID:String?) {
        _topLabel = topLabel
        _bottomLabel = bottomLabel
        _savedImage = savedImage
        _memedImage = memedImage
        fontAttribute = fontAttributer
        _savedMeme = savedMeme
        _memeID = memeID
    }
}

struct MemeFunctions {
    
    // Add meme to local database before uploading it to firebase
    static func saveMeme(meme:Meme, complete:DownloadComplete) {
        
        let user = FIRAuth.auth()?.currentUser?.uid
        let fileName:String  = "\(user!)-\(MemeMain.memeShared().randomStringWithLength(10))"
        let imageName:String = "\(fileName).jpg"
        
        let memeImage = meme.memedImage
        let originalImage = meme.savedImage
        
        saveImage(memeImage, path: fileInDocumentsDirectory("meme-\(imageName)"))
        saveImage(originalImage, path: fileInDocumentsDirectory("saved-\(imageName)"))
        
        DataService.ds().prepareMemeForUpload(meme, uploadName: fileName, imageName: imageName) {
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



