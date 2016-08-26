The MemeMe app for the Udacity iOS Developer course.

[![Build Status](https://img.shields.io/badge/Build-Working-blue.svg?style=flat)]()
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Alamofire.svg)](https://img.shields.io/cocoapods/v/Alamofire.svg)
[![Twitter](https://img.shields.io/badge/twitter-@SpiritDevs-blue.svg?style=flat)](http://twitter.com/Spiritdevsaus)
[![Facebook](https://img.shields.io/badge/facebook-SpiritDevs-green.svg?style=flat)](https://www.facebook.com/SpiritDevs)
[![Website](https://img.shields.io/badge/website-SpiritDevs-red.svg?style=flat)](http://www.spiritDevs.com/)

## MemeMe Introduciton

This is the MemeMe app from the [Udacity iOS Developer](https://www.udacity.com/course/ios-developer-nanodegree--nd003) course including both 'Version 1' and 'Version 2' of the app.

The SpiritDevs version of MemeMe however working on Firebase and Core data to keep user data synced across device and give MemeMe a social aspect by allowing uses to she other users memes and where they were taken on a map.

## Technologies Used

- Core Data -- Used to store users data locally for quick app response times
- SnapKit -- Used to display app loading screen and make write UI code easier 
- Firebase -- Used to store users data and memes on the server and to enable the social features of the app
- Facebook SDK -- Used to login to the app using Facebook
- Cocoapods -- Used to install plugins into the MemeMe app
- Touch ID -- Used to secure the MemeMe app, if Touch ID not available it used a pin code
- Alamofire -- Used to download and upload files outside of Firebase (easier to read and use than built in iOS networking)
- MVC design -- Keep code simple ;)
 

## Installation

> **Embedded frameworks require a minimum deployment target of iOS 8 or OS X Mavericks (10.9).**
>
> MemeMe requires Cocoapods including firebase, while this will usually work on most system without need for reinstallation of the pods if there are issuing during the building of the app please follow the below steps.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build the Cocoapods inside MemeMe.

Once Cocoapods have been installed onto your system, run the following command:

```bash
$ pod install
```

## Features

### Version 1

- [x] creating a meme
- [x] saving that meme
- [x] sharing that meme
- [x] uploading that meme to the firebase server
- [x] uploading it to the core data server on the device
- [x] setting with biometrics 
- [x] delete the entire account
- [x] log out
- [x] delete all local data and redownload from firebase
- [x] login/signup form which either creates new accounts or download all the details of the existing account from firebase to core data.
- [x] your memes in a collection view
- [x] your memes in a table view

### Version 2

- [x] Meme editor
- [x] different fonts and colours
- [x] shared memes in a collection view
- [x] shared memes displayed on a map in relations to where you are

## License

MemeMe is released under the MIT license. See LICENSE for details.
