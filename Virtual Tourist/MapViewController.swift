//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Chris Archibald on 9/9/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    // The Map view object
    @IBOutlet weak var mapView: MKMapView!
    
    //Default to restore map location when app is reopened
    let defaults = NSUserDefaults()
    
    var pins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make view delegate the map
        self.mapView.delegate = self
        
        //Fetch all pins
        pins = fetchAllPins()
        
        //Add pins to map
        addAllPinsToMap()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongTapMap:")
        longPress.delegate = self
        longPress.numberOfTapsRequired = 0
        longPress.minimumPressDuration = 0.4
        mapView.addGestureRecognizer(longPress)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        //Restore the map to the last location saved by regionDidChange
        if let currentLatitude = self.defaults.valueForKey("currentLatitude") as? Double {
            let currentLongitude: Double = self.defaults.valueForKey("currentLongitude") as! Double
            let currentLatDelta: Double = self.defaults.valueForKey("currentLatDelta") as! Double
            let currentLongDelta: Double = self.defaults.valueForKey("currentLongDelta") as! Double
            
            let centerCoordinate = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
            let span = MKCoordinateSpan(latitudeDelta: currentLatDelta, longitudeDelta: currentLongDelta)
            let currentRegion = MKCoordinateRegionMake(centerCoordinate, span)
            println("restore")
            
            //Add pins to map
            addAllPinsToMap()
            
            self.mapView.setRegion(currentRegion, animated: false)
        }
    }
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    //Pin Functions
    func addAllPinsToMap() {
        println("Placing pins on map")
        println(pins)
        for pin in pins {
            var newPin = MKPointAnnotation()
            newPin.coordinate.latitude = pin.latitude
            newPin.coordinate.longitude = pin.longitude
            mapView.addAnnotation(newPin)
        }
    }
    
    func fetchAllPins() -> [Pin] {
        let error: NSErrorPointer = nil
        //create the fetch request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        if error != nil {
            println("WE have an error \(error)")
            return [Pin]()
        }
        println("We have pins")
        return results as! [Pin]
    }
    
    
    //Map View Methods from MKMapViewDeleate
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        self.defaults.setValue(self.mapView.region.center.latitude, forKeyPath: "currentLatitude")
        self.defaults.setValue(self.mapView.region.center.longitude, forKeyPath: "currentLongitude")
        self.defaults.setValue(self.mapView.region.span.latitudeDelta, forKeyPath: "currentLatDelta")
        self.defaults.setValue(self.mapView.region.span.longitudeDelta, forKeyPath: "currentLongDelta")
        println("Saved")
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var newPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin1")
        newPin.animatesDrop = true
        
        return newPin
    }
    
    // Long Press Methods for UIGestureRecognizerDelegate
    
    func didLongTapMap(gestureRecognizer: UIGestureRecognizer) {
        //Get the spot that was tapped.
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        if gestureRecognizer.state != .Ended {
            return
        }
        
        let dictionary: [String: AnyObject] = [
            Pin.Keys.Latitude: touchMapCoordinate.latitude,
            Pin.Keys.Longitude: touchMapCoordinate.longitude
        ]
        
        //Create the pin to be added
        let pinToBeAdded = Pin(dictionary: dictionary, context: self.sharedContext)
        
        self.pins.append(pinToBeAdded)
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        //Add the pin to mapView
        var dropPin = MKPointAnnotation()
        dropPin.coordinate.latitude = pinToBeAdded.latitude
        dropPin.coordinate.longitude = pinToBeAdded.longitude
        mapView.addAnnotation(dropPin)
    }
}

