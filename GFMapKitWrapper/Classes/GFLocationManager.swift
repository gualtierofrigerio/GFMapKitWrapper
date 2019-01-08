//
//  GFLocationManager.swift
//  GFMapKitWrapper
//
//  Created by Gualtiero Frigerio on 08/01/2019.
//

import Foundation
import CoreLocation

/*
 * CLLocationManager wrapper
 * Handles all CL calls and implements the CLLocationManagerDelegate
 */

class GFLocationManager : NSObject {
    let locationManager = CLLocationManager()
    var requestAlwaysAuthorization = false
    var updateLocationCompletion:((Bool, CLLocationCoordinate2D?) ->Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func isLocationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func getCurrentLocation(completion:@escaping (Bool, CLLocationCoordinate2D?) -> Void) {
        updateLocationCompletion = completion
        let status = CLLocationManager.authorizationStatus()
        if CLLocationManager.locationServicesEnabled() == false || (status != .authorizedAlways && status != .authorizedWhenInUse) {
            requestLocationAuthorization()
        }
        else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func requestLocationAuthorization() {
        if requestAlwaysAuthorization {
            locationManager.requestAlwaysAuthorization()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension GFLocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            if let completion = self.updateLocationCompletion {
                completion(true, location.coordinate)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if updateLocationCompletion != nil {
                locationManager.startUpdatingLocation()
            }
        }
        else {
            if let completion = updateLocationCompletion {
                completion(false, nil)
            }
        }
    }
}
