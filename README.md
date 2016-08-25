The MemeMe app for the Udacity iOS Developer course.

[![Build Status](https://travis-ci.org/Alamofire/Alamofire.svg)](https://travis-ci.org/Alamofire/Alamofire)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Alamofire.svg)](https://img.shields.io/cocoapods/v/Alamofire.svg)
[![Twitter](https://img.shields.io/badge/twitter-@SpiritDevs-blue.svg?style=flat)](http://twitter.com/Spiritdevsaus)
[![Facebook](https://img.shields.io/badge/facebook-SpiritDevs-green.svg?style=flat)](https://www.facebook.com/SpiritDevs)
[![Website](https://img.shields.io/badge/website-SpiritDevs-red.svg?style=flat)](http://www.spiritDevs.com/)

## MemeMe Introduciton

The MemeMe app for the Udacity iOS Developer course which is linked to Firebase and Core Data for database sync. This allows users to sync there data across device and share Memes and there memes locations with other users.

This includes a lot more features that the original submission app and has a variable to change between V1 and V2 of the app.

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
