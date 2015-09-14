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
    
    var currentIndex: NSIndexPath?
    var changes = [(NSFetchedResultsChangeType, NSIndexPath)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Passes in the vaule of that was selected on the Map View Page
        setMapLocation(pin.latitude, longitude: pin.longitude)
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        println("Did we hit error")
        super.viewWillAppear(animated)
        println("After super")
        println("before pin")
        println(pin)
        println("after pin")
        println(pin.photos)
        println("after photos")
        print(pin.photos.isEmpty)
        print("blabla")
        
        if pin.photos.isEmpty {
            println("Here")
            Client.sharedInstance().count = 0
            self.collectionButton.enabled = false
            getImages()
        }
    }
    
    /***** Core Data *****/
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoTitle", ascending: true)]
        //fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    /***** Collection Delegate Flow functions *****/
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //Changing the size of the cell depending on the width of the device
        let imageDimension = self.view.frame.size.width / 3.33
        return CGSizeMake(imageDimension, imageDimension)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        //Setting the left and right inset for cells
        let leftRightInset = self.view.frame.size.width / 57.0
        println(leftRightInset)
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
    
    /***** Collection Delegate functions *****/
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        changes = []
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            changes.append((.Insert, newIndexPath!))
        case .Delete:
            changes.append((.Delete, indexPath!))
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({ () -> Void in
            for (type, index) in self.changes {
                switch type {
                case .Insert:
                    self.collectionView.insertItemsAtIndexPaths([index])
                case .Delete:
                    self.collectionView.deleteItemsAtIndexPaths([index])
                default:
                    continue
                }
            }
            }, completion: { completed -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionButton.enabled = true
                })
        })
    }
    
    /***** Configure Cell *****/
    
    func configureCell(cell: PhotoCell, photo: Photo, indexPath: NSIndexPath) {
        var image = UIImage()
        
        if let localImage = photo.image {
            image = localImage
        } else {
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
        
        println("number Of Cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let CellIdentifier = "PhotoCell"
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        configureCell(cell, photo: photo, indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentIndex = indexPath
        var alertControllerForDeletingPhoto: UIAlertController
        
        alertControllerForDeletingPhoto = UIAlertController(title: "This photo will be deleted from the album.", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertControllerForDeletingPhoto.addAction(UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Destructive, handler: deletePhoto))
        alertControllerForDeletingPhoto.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alertControllerForDeletingPhoto, animated: true, completion: nil)
    }
    
    /***** Getting images from Flickr *****/
    
    func getImages() {
        println("Error here")
        let latitude = pin.latitude
        let longitude = pin.longitude
        
        Client.sharedInstance().getImageFromFlicker(latitude, longitude: longitude) {
            (success, dictionary, errorString) -> Void in
            
            if success {
                let photosDictionary = dictionary!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var photos = photosDictionary.map() { ( dictionary: [String: AnyObject]) -> Photo in
                        let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                        photo.pin = self.pin
                        CoreDataStackManager.sharedInstance().saveContext()
                        return photo
                    }
                })
            } else {
                var alert = UIAlertController(title: "Failed to get images", message: "Was unable to get images from Flickr", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    /***** Helper Function *****/
    
    func deletePhoto(sender: UIAlertAction!) -> Void {
        let index = currentIndex
        
        let photo = self.fetchedResultsController.objectAtIndexPath(index!) as! Photo
        Client.Caches.imageCache.clearImage(photo.photoID)
        self.sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
        self.collectionView.reloadData()
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
