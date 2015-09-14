//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Chris Archibald on 9/12/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreData

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    
    var pin: Pin!
    
    var imagesLoaded = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Passes in the vaule of that was selected on the Map View Page
        setMapLocation(pin.latitude, longitude: pin.longitude)
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    /***** Core Data *****/
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    /***** Configure Cell *****/
    
    func configureCell(cell: PhotoCell, photo: Photo, indexPath: NSIndexPath) {
        var image = UIImage()
        
        if let localImage = photo.image {
            image = localImage
        } else {
            //Download the image from flickr
            let task = Client.sharedInstance().taskForImage(photo.photoUrl, completionHandler: {(imageData, downloadError) -> Void in
                if let data = imageData {
                    let image = UIImage(data: data)
                    photo.image = image
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        cell.imageActivity.stopAnimating()
                        cell.image.image = image
                        self.imagesLoaded = self.imagesLoaded + 1
                        var numberOfImages = (self.fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo).numberOfObjects
                        
                        if self.imagesLoaded == numberOfImages {
                            self.collectionButton.enabled = true
                        }
                    }
                }
            })
        }
        
        cell.image.image = image
        self.collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    /***** Collection View *****/
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let CellIdentifier = "PhotoCell"
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        configureCell(cell, photo: photo, indexPath: indexPath)
        
        return cell
    }
    
    
    /***** Map Function *****/
    
    //Set the location of the map to the selected Pin from the Map View Page
    func setMapLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        //Set zoom level to .005 which is close enough to see a few blocks
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        
        let newPin = MKPointAnnotation()
        newPin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        mapView.addAnnotation(newPin)
        mapView.mapType = MKMapType.Hybrid
        mapView.setRegion(region, animated: true)
    }
    
}
