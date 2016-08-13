//
//  MemeDetailVC.swift
//  MemeMe
//
//  Created by Corey Baines on 7/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailVC: UIViewController {
    
    //MARK: -- Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme?
    
    //# -- MARK: Lifecycle Methods:
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Unwrap meme and set the image view to the memed image */
        if let meme = meme {
            imageView.image = meme.memedImage
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - App Functions
    
    /* Set the editmeme when opening the meme editor */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueEditorVC" {
            let editVC = segue.destinationViewController as! EditorVC
            editVC.meme = meme
            
            editVC.editingMeme = true
        }
    }
    
    //MARK: - Actions
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("EditorVC")
        let editorVC = object as! EditorVC
        editorVC.meme = self.meme
        editorVC.editingMeme = true
        presentViewController(editorVC, animated: true, completion: nil)
    }
}