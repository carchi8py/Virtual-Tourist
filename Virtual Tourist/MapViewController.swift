//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Chris Archibald on 9/9/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // The Map view object
    @IBOutlet weak var mapView: MKMapView!
    
    //Default to restore map location when app is reopened
    let defaults = NSUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let currentLatitude = self.defaults.valueForKey("currentLatitude") as? Double {
            let currentLongitude: Double = self.defaults.valueForKey("currentLongitude") as! Double
            let currentLatDelta: Double = self.defaults.valueForKey("currentLatDelta") as! Double
            let currentLongDelta: Double = self.defaults.valueForKey("currentLongDelta") as! Double
            
            let centerCoordinate = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
            let span = MKCoordinateSpan(latitudeDelta: currentLatDelta, longitudeDelta: currentLongDelta)
            let currentRegion = MKCoordinateRegionMake(centerCoordinate, span)
            println("restore")
            
            self.mapView.setRegion(currentRegion, animated: false)
        }
    }
    
    //Map View Methods from MKMapViewDeleate
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        self.defaults.setValue(self.mapView.region.center.latitude, forKeyPath: "currentLatitude")
        self.defaults.setValue(self.mapView.region.center.longitude, forKeyPath: "currentLongitude")
        self.defaults.setValue(self.mapView.region.span.latitudeDelta, forKeyPath: "currentLatDelta")
        self.defaults.setValue(self.mapView.region.span.longitudeDelta, forKeyPath: "currentLongDelta")
        println("Saved")
    }
}

