//
//  Constaints.swift
//  MemeMe
//
//  Created by Corey Baines on 1/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit


/// UDACITY SETTINGS //////////////////
//
//
var isUdacityApp:Bool = true
var isUdacityFirstApp:Bool = false
var udacityEmail:String = "udacity@spiritdevs.com"
var udacityPassword:String = "udacityMemeMe"
//
//
///////////////////////////////////////


typealias DownloadComplete = () -> ()
typealias DownloadError = (NSError)->()

// Color for text fields when error happens
let TEXT_ERROR_COLOR = UIColor(red: 254.0/255.0, green: 86.0/255.0, blue: 64.0/255.0, alpha: 1.0)

