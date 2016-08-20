//
//  SharedVC.swift
//  MemeMe
//
//  Created by Corey Baines on 2/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit

class SharedVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Variables
    var memeDict:[Meme] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Search Bar to allow users to search through memes as catalog grows
        //
        //let searchBar = UISearchBar()
        //searchBar.sizeToFit()
        //navigationItem.titleView = searchBar
        //
        
        //Download the memes to display to user
        downloadSharedMemes()
    }
    
    // Download the recent memes by other users to display on the screen
    func downloadSharedMemes() {
        DataService.ds().downloadShared { (meme) in
            print("DOWNLOADED")
            print(meme.count)
            self.memeDict = meme
            self.collectionView.reloadData()
        }
        
    }
    
    
    //MARK: - Actions
    
    @IBAction func newMemeButtonPressed(sender: AnyObject) {
        //Bypass editor and go directly to editor
        let editorObject: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("EditorVC")
        let recentObject: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("RecentVC")
        let editorVC = editorObject as! EditorVC
        let recentVC = recentObject as! RecentVC
        presentViewController(editorVC, animated: true, completion: {
            editorVC.cancelButton.enabled = true
            editorVC.saveButton.enabled = false
            editorVC.recentVC = recentVC
        })
    }

    
}

//MARK: - UICollectionView Lifecycle
extension SharedVC {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memeDict.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! RecentCollectionViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
}
