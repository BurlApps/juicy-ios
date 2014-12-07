//
//  Location.swift
//  Juicy
//
//  Created by Brian Vallelunga on 9/25/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

protocol LocationDelegate {
    func locationFound(location: CLPlacemark)
}

class Location: NSObject, CLLocationManagerDelegate {
    
    // MARK: Instance Variables
    var delegate: LocationDelegate!
    
    // MARK: Private Instance Variables
    private var locationManager: CLLocationManager!
    
    // MARK: Initializer
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        if (self.locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization"))) {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: Instance Methods
    func startUpdating() {
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: CoreLocation Methods
    // This delegate is called when the app successfully finds your current location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.stopUpdating()
        
        var geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(locations.last as CLLocation, completionHandler: { (placeMarks: [AnyObject]!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if placeMarks != nil && !placeMarks.isEmpty {
                    self.delegate.locationFound(placeMarks[0] as CLPlacemark)
                } else if error != nil {
                    println(error)
                }
            })
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFinishDeferredUpdatesWithError error: NSError!) {
        self.stopUpdating()
        println(error)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        self.stopUpdating()
        println(error)
    }
}