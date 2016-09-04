//
//  RecentVC.swift
//  MemeMe
//
//  Created by Corey Baines on 1/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase
import BRYXBanner

class RecentVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: - Outlets
    @IBOutlet weak var recentTableView: UITableView!
    @IBOutlet weak var recentCollectionView: UICollectionView!
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    
    //MARK: - Variables
    var memeDict:[Meme] = []
    var isEditingMeme:Bool = false
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    let defaultCenter = NSNotificationCenter.defaultCenter()
    
    //MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        recentCollectionView.allowsMultipleSelection = true
        recentCollectionView.hidden = true
        recentTableView.hidden = false
        NSUserDefaults.standardUserDefaults().removeObjectForKey("firstRun")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "locationOn")
        NSUserDefaults.standardUserDefaults().synchronize()
        downloadRecentMemes()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("firstRun")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startNotifications()
        if !NSUserDefaults.standardUserDefaults().boolForKey("fullVersion") {
            if let tabBarController = self.tabBarController {
                let indexToRemove = 1
                print(tabBarController.viewControllers?.count)
                if tabBarController.viewControllers?.count == 3 {
                    if indexToRemove < tabBarController.viewControllers?.count {
                        var viewControllers = tabBarController.viewControllers
                        viewControllers?.removeAtIndex(indexToRemove)
                        tabBarController.viewControllers = viewControllers
                    }
                }
            }
        }
        if NSUserDefaults.standardUserDefaults().boolForKey("reload") {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "reload")
            NSUserDefaults.standardUserDefaults().synchronize()
            downloadRecentMemes()
        }
    }
    
    //MARK: - App Functions
    func viewToggle() {
        if recentCollectionView.hidden {
            recentCollectionView.hidden = false
            recentTableView.hidden = true
            toggleButton.image = UIImage(named: "collection")
            self.recentCollectionView.reloadData()
        } else {
            recentCollectionView.hidden = true
            recentTableView.hidden = false
            toggleButton.image = UIImage(named: "table")
            self.recentTableView.reloadData()
        }
    }
    
    // Download the recent memes for the logged in user to display on the screen
    func downloadRecentMemes() {
        LoadingView.startSpinning(view)
        managedObjectContext?.performBlock {
            if let memeDictRaw = Memes.ms().loadMemeLocal((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: self.managedObjectContext!) {
                self.memeDict.removeAll()
                self.memeDict = memeDictRaw
                print(memeDictRaw.count)
                if !self.recentTableView.hidden {
                    dispatch_async(dispatch_get_main_queue(), {
                        LoadingView.stopSpinning()
                    })
                    self.recentTableView.reloadData()
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        LoadingView.stopSpinning()
                    })
                    self.recentCollectionView.reloadData()
                }
            } else {
                
                DataService.ds().downloadMeme((FIRAuth.auth()?.currentUser?.uid)!, shared: false) { (meme) in
                    print("DOWNLOADED")
                    if meme != nil {
                        print(meme!.count)
                        self.memeDict = meme!
                        
                        if !self.recentTableView.hidden {
                            dispatch_async(dispatch_get_main_queue(), {
                                LoadingView.stopSpinning()
                            })
                            self.recentTableView.reloadData()
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                LoadingView.stopSpinning()
                            })
                            self.recentCollectionView.reloadData()
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            LoadingView.stopSpinning()
                        })
                    }
                }
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func toggleButtonPressed(sender: AnyObject) {
        viewToggle()
    }
    @IBAction func newMemeButtonPressed(sender: AnyObject) {
        //Bypass editor and go directly to editor
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("EditorVC")
        let editorVC = object as! EditorVC
        presentViewController(editorVC, animated: true, completion: {
            editorVC.cancelButton.enabled = true
            editorVC.saveButton.enabled = false
            editorVC.recentVC = self
        })
    }
    
    //MARK: Notification Observers 
    func startNotifications() {
        defaultCenter.addObserver(self, selector: #selector(RecentVC.uploadStatus(_:)), name: "uploadProgressNotification", object: nil)
        defaultCenter.addObserver(self, selector: #selector(RecentVC.uploadComplete(_:)), name: "uploadProgressNotificationSuccess", object: nil)
    }
    
    func uploadStatus(notification: NSNotification) {
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        
        // if notification received, change label value 0% - 100%
        let progress = tmp["progress"] as! String!
        
        let banner = Banner(title: "Upload Status", subtitle: "Upload at: \(progress)", image: UIImage(named: "spiritdevs"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
    }
    
    func uploadComplete(notification: NSNotification) {
        
        let banner = Banner(title: "Upload Status", subtitle: "Upload successful", image: UIImage(named: "spiritdevs"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
    }
    
    func handleCompleteDownload(notification: NSNotification) {
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        
        // if notification received, change label value
        let progress = tmp["progress"] as! String!
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                self.navigationController?.navigationBar.topItem?.title = progress
            }
        }
    }
}

//MARK: - UITableView Lifecycle
extension RecentVC {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memeDict.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as! RecentTableViewCell
        let meme = memeDict[indexPath.row]
        if meme.bottomLabel != "" && meme.topLabel != "" {
            cell.recentNameLabel.text = "\(meme.topLabel)... \(meme.bottomLabel)"
        } else if meme.topLabel != "" {
            cell.recentNameLabel.text = "\(meme.topLabel)"
        } else {
            cell.recentNameLabel.text = "\(meme.bottomLabel)"
        }
        cell.recentPrivacyLabel.text = meme.privacyLabel
        if meme.savedMeme != "" {
            cell.recentImage.image = meme.memedImage
        } else {
            cell.recentImage.image = UIImage(data: meme.memedImageData)!
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !recentTableView.editing {
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailVC")
            let detailVC = object as! MemeDetailVC
            
            /* Pass the data from the selected row to the detail view and present it */
            detailVC.meme = memeDict[indexPath.row]
            if memeDict[indexPath.row].savedMeme == "" {
                detailVC.editButton.enabled = false
            }
            navigationController!.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { action, index in
            DataService.ds().deleteOnlineMeme(self.memeDict[indexPath.row])
            self.managedObjectContext?.performBlock {
                Memes.ms().deleteSpecificMeme(self.memeDict[indexPath.row].memeID, inManagedObjectContext: self.managedObjectContext!)
                tableView.beginUpdates()
                self.memeDict.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.endUpdates()
            }
        }
        delete.backgroundColor = UIColor.redColor()
        
        var privatePublic: UITableViewRowAction!
        
        if memeDict[indexPath.row].privacyLabel == "Public" {
            privatePublic = UITableViewRowAction(style: .Normal, title: "Private") { action, index in
                Memes.ms().updatePrivacy(self.memeDict[indexPath.row].memeID, privateLabel: true, inManagedObjectContext: self.managedObjectContext!)
                DataService.ds().updatePrivacyLabel(self.memeDict[indexPath.row].memeID, privacyLabel: true)
                tableView.beginUpdates()
                self.downloadRecentMemes()
                tableView.endUpdates()
            }
        } else {
            privatePublic = UITableViewRowAction(style: .Normal, title: "Public") { action, index in
                Memes.ms().updatePrivacy(self.memeDict[indexPath.row].memeID, privateLabel: false, inManagedObjectContext: self.managedObjectContext!)
                DataService.ds().updatePrivacyLabel(self.memeDict[indexPath.row].memeID, privacyLabel: false)
                tableView.beginUpdates()
                self.downloadRecentMemes()
                tableView.endUpdates()
            }
        }
        privatePublic.backgroundColor = UIColor.blueColor()
        
        return [delete, privatePublic]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
}

//MARK: - UICollectionView Lifecycle
extension RecentVC {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memeDict.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! RecentCollectionViewCell
        let meme = memeDict[indexPath.row]
        cell.recentCollectionImage.image = meme.memedImage
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if !isEditingMeme {
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailVC")
            let detailVC = object as! MemeDetailVC
            
            /* Pass the data from the selected row to the detail view and present it */
            detailVC.meme = memeDict[indexPath.row]
            navigationController!.pushViewController(detailVC, animated: true)
        }
    }
    
}