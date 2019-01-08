//
//  GFMapKitWrapper.swift
//  GFMapKitWrapper
//
//  Created by Gualtiero Frigerio on 08/01/2019.
//

import Foundation
import MapKit

/* struct containing configuration parameters
 * such as pin color, viewing angle, region color etc */
public struct GFMapKitWrapperConfiguration {
    var lineColor = UIColor.green // stroke color for polylines
    var regionInnerColor = UIColor.blue // fill color for a region
    var regionOuterColor = UIColor.blue // stroke color for a region
    var cameraPitch = 30.0 // camera pitch
    var cameraAltitude = 1000.0 // camera altitude
    var pinColor = UIColor.red // color for MKPinAnnotationView
    var requestAlwaysPermission = false // request the always permission instead of when in use
}

public struct GFMapKitAnnotation {
    var title:String?
    var subtitle:String?
    var latitude:Double?
    var longitude:Double?
}

/*
 * Wrapper class for using MapKit
 * It is possible to center the map on a particular point or address
 * add annotations and show routes.
 * To be able to use CoreLocation is necessary to set the privacy
 * text in the app's plist
 */

public class GFMapKitWrapper : NSObject {
    
    private let locationManager = GFLocationManager()
    private var mapView:MKMapView?
    private var configuration = GFMapKitWrapperConfiguration()
    
    /* init providing a view */
    public init(mapView:MKMapView) {
        self.mapView = mapView
    }
    
    /* init without a view
     * a MKMapView is created and can be retrieved by
     * calling getMapView to add the view programmatically */
    public override init() {
        self.mapView = MKMapView()
    }
    
    /* set the default configuration */
    public func setConfiguration(_ configuration:GFMapKitWrapperConfiguration) {
        self.configuration = configuration
    }
    
    /* use this function to get the mapView and add
     * to the view hierarchy programmatically */
    public func getMapView() -> MKMapView? {
        return self.mapView
    }
    
    /* center the map on the coordinate specified by latitude and longitude */
    public func centerMapOnPoint(latitude:Double, longitude:Double) {
        let coordinate = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
        mapView?.centerCoordinate = coordinate
    }
    
    /* center the map on the address specified */
    public func centerMapOnAddress(address:String) {
        
    }
    
    /* center the map on current user location, need CL permission */
    public func centerMapOnCurrentLocation() {
        locationManager.getCurrentLocation { (success, coordinate) in
            if success {
                if let coordinate = coordinate {
                    self.mapView?.centerCoordinate = coordinate
                }
            }
        }
    }
    
    /* draw the route between the addresses specified */
    public func showRoute(fromAddress:String, toAddress:String) {
        
    }
    
    /* draw the route between current user location and the address */
    public func showRouteFromCurrentLocation(toAddress:String) {
        
    }
    
    /* draw the route between current user location and the coordinate specified */
    public func showRouteFromCurrentLocation(toLatitude:Double, longigute:Double) {
        
    }
    
    /* add an annotation */
    public func addAnnotation(annotation:GFMapKitAnnotation) {
        
    }
}

extension GFMapKitWrapper : MKMapViewDelegate {
    
}
