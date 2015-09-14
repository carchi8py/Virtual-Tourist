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

class PhotoViewController: UIViewController {
    var pin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Passes in the vaule of that was selected on the Map View Page
        setMapLocation(pin.latitude, longitude: pin.longitude)
    }
    
    /***** Core Data *****/
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
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
