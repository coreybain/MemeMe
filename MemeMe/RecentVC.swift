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

class RecentVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: - Outlets
    @IBOutlet weak var recentTableView: UITableView!
    @IBOutlet weak var recentCollectionView: UICollectionView!
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    
    //MARK: - Variables
    var memeDict:[Meme] = []
    var savedReload:Bool = false
    var isEditingMeme:Bool = false
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    //MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        recentCollectionView.allowsMultipleSelection = true
        recentCollectionView.hidden = true
        recentTableView.hidden = false
        downloadRecentMemes()
        //Memes.shared.deleteMemes((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: managedObjectContext!)
       // Users.deleteUsers((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: managedObjectContext!)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if savedReload {
            // ready for receiving notification
            let defaultCenter = NSNotificationCenter.defaultCenter()
            defaultCenter.addObserver(self,
                                      selector: #selector(RecentVC.handleCompleteDownload(_:)),
                                      name: "DownloadProgressNotification",
                                      object: nil)
            downloadRecentMemes()
            savedReload = false
        }
        if isUdacityFirstApp {
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
        
        managedObjectContext?.performBlock {
            if let memeDictRaw = Memes.ms().loadMemeLocal((FIRAuth.auth()?.currentUser?.uid)!, inManagedObjectContext: self.managedObjectContext!) {
                self.memeDict.removeAll()
                self.memeDict = memeDictRaw
                print(memeDictRaw.count)
                self.recentTableView.reloadData()
            }
        }
        
        /*
        DataService.ds().downloadRecents { (meme) in
            print("DOWNLOADED")
            print(meme.count)
            self.memeDict = meme
            self.recentTableView.reloadData()
            self.recentCollectionView.reloadData()
        }
         */
        
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
        cell.recentImage.image = meme.memedImage
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
            navigationController!.pushViewController(detailVC, animated: true)
        }
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