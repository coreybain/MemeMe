//
//  SharedVC.swift
//  MemeMe
//
//  Created by Corey Baines on 2/8/16.
//  Copyright © 2016 Corey Baines. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class SharedVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapkit: MKMapView!
    @IBOutlet weak var maptoggle: UIBarButtonItem!
    
    //MARK: - Variables
    var memeDict:[Meme] = []
    var isEditingMeme:Bool = false
    
    // Supporting var for location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
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
    
    
    //MARK: - App Functions
    
    // Download the recent memes by other users to display on the screen
    func downloadSharedMemes() {
        DataService.ds().downloadShared { [unowned self] (meme) in
            print("DOWNLOADED")
            print(meme.count)
            self.memeDict = meme
            if !self.collectionView.hidden {
                self.collectionView.reloadData()
            } else {
                self.memeLocations()
            }
        }
        
    }
    
    func viewToggle() {
        if collectionView.hidden {
            collectionView.hidden = false
            mapkit.hidden = true
            maptoggle.image = UIImage(named: "mapPin")
            self.collectionView.reloadData()
        } else {
            collectionView.hidden = true
            mapkit.hidden = false
            maptoggle.image = UIImage(named: "collection")
            //Center map on the users locations
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
            mapkit.showsUserLocation = true

        }
    }
    
    //MARK: -- Map Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
            self.mapkit.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
        }
        
    }
    
    func memeLocations() {
        for memes in memeDict {
            let annotation = MKPointAnnotation()
            annotation.title = "\(memes.topLabel)... \(memes.bottomLabel)"
            annotation.coordinate = CLLocationCoordinate2D(latitude: memes.latitude, longitude: memes.longitude)
            mapkit.addAnnotation(annotation)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error... \(error.localizedDescription)")
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

    @IBAction func mapButtonPressed(sender: AnyObject) {
        viewToggle()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! SharedCollectionViewCell
        let meme = memeDict[indexPath.row]
        cell.sharedCollectionImage.image = UIImage(data: meme.memedImageData)!
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if !isEditingMeme {
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailVC")
            let detailVC = object as! MemeDetailVC
            detailVC.editButton.enabled = false
            detailVC.shared = true
            
            /* Pass the data from the selected row to the detail view and present it */
            detailVC.meme = memeDict[indexPath.row]
            navigationController!.pushViewController(detailVC, animated: true)
        }
        
    }
    
}
