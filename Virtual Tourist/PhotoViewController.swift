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
        super.viewWillAppear(animated)
        
        //Show nav bar
        navigationController?.navigationBarHidden = false
        
        if pin.photos.isEmpty {
            Client.sharedInstance().count = 0
            collectionButton.enabled = false
            getImages()
        }
    }
    
    //When the New Collection button is push, delete old image, and grab new
    //ones from flickr
    @IBAction func collectionButtonTouched(sender: UIBarButtonItem) {
        imagesLoaded = 0
        collectionButton.enabled = false
        if let photos = fetchedResultsController.fetchedObjects as? [Photo] {
            for photo in photos {
                Client.Caches.imageCache.clearImage(photo.photoID)
                sharedContext.deleteObject(photo)
            }
        }
        getImages()
    }
    /***** Core Data *****/
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoTitle", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    /***** Collection Delegate Flow functions *****/
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //Changing the size of the cell depending on the width of the device
        let imageDimension = view.frame.size.width / 3.33
        return CGSizeMake(imageDimension, imageDimension)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        //Setting the left and right inset for cells
        let leftRightInset = view.frame.size.width / 57.0
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
                    //self.collectionView.insertItemsAtIndexPaths([index])
                    self.collectionView.reloadItemsAtIndexPaths([index])
                case .Delete:
                    //self.collectionView.deleteItemsAtIndexPaths([index])
                    self.collectionView.reloadItemsAtIndexPaths([index])
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
                        cell.setOurImage(image!)
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
        //collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    /***** Collection View *****/
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
    
        let expectedPics:Int = 24
            if (expectedPics > sectionInfo.numberOfObjects)
            {
                //collectionView.reloadData()
                return expectedPics
        }
        //collectionView.reloadData()
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let CellIdentifier = "PhotoCell"
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! PhotoCell
        cell.removeImage()
        
        let fetchedNumber = self.fetchedResultsController.fetchedObjects!.count
        if (fetchedNumber >= indexPath.row + 1 ) {
            let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            
            configureCell(cell, photo: photo, indexPath: indexPath)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentIndex = indexPath
        var alertControllerForDeletingPhoto: UIAlertController
        
        alertControllerForDeletingPhoto = UIAlertController(title: "This photo will be deleted from the album.", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertControllerForDeletingPhoto.addAction(UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Destructive, handler: deletePhoto))
        alertControllerForDeletingPhoto.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alertControllerForDeletingPhoto, animated: true, completion: nil)
    }
    
    /***** Getting images from Flickr *****/
    
    func getPhotos(dictionary: [[String: AnyObject]]?) {
        let photosDictionary = dictionary!
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var photos = photosDictionary.map() { ( dictionary: [String: AnyObject]) -> Photo in
                let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                photo.pin = self.pin
                CoreDataStackManager.sharedInstance().saveContext()
                return photo
            }
        })
    }
    
    // Start with a bound box of 0.001 by 0.001 and keep zooming out by a factor of 10 until
    // We get to a bound box of 1 by 1. If we can't find 24 picture at a 1 by 1 level return
    // an error to the user
    func getImages() {
        let latitude = pin.latitude
        let longitude = pin.longitude
        
        Client.sharedInstance().getImageFromFlicker(latitude, longitude: longitude, boxSize: 0.001) {
            (success, dictionary, errorString) -> Void in
            
            if success {
                self.getPhotos(dictionary)
            } else {
                Client.sharedInstance().getImageFromFlicker(latitude, longitude: longitude, boxSize: 0.01) {
                    (success, dictionary, errorString) -> Void in
                    
                    if success {
                        self.getPhotos(dictionary)
                    } else {
                        Client.sharedInstance().getImageFromFlicker(latitude, longitude: longitude, boxSize: 0.1) {
                            (success, dictionary, errorString) -> Void in
                            
                            if success {
                                self.getPhotos(dictionary)
                            } else {
                                Client.sharedInstance().getImageFromFlicker(latitude, longitude: longitude, boxSize: 1.0) {
                                    (success, dictionary, errorString) -> Void in
                                    
                                    if success {
                                        self.getPhotos(dictionary)
                                    } else {
                                        var alert = UIAlertController(title: "Failed to get images", message: "Was unable to get images from Flickr", preferredStyle: UIAlertControllerStyle.Alert)
                                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /***** Helper Function *****/
    
    func deletePhoto(sender: UIAlertAction!) -> Void {
        let index = currentIndex
        
        let photo = fetchedResultsController.objectAtIndexPath(index!) as! Photo
        Client.Caches.imageCache.clearImage(photo.photoID)
        sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
        collectionView.reloadData()
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
