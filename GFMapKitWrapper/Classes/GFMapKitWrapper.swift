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
    var regionSize = 100.0
    var cameraPitch = 30.0 // camera pitch
    var cameraAltitude = 100.0 // camera altitude
    var pinColor = UIColor.red // color for MKPinAnnotationView
    var requestAlwaysPermission = false // request the always permission instead of when in use
    var transportType:MKDirectionsTransportType = .automobile // default transport type
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
        super.init()
        self.mapView = mapView
        self.mapView?.delegate = self
    }
    
    /* init without a view
     * a MKMapView is created and can be retrieved by
     * calling getMapView to add the view programmatically */
    public override init() {
        super.init()
        self.mapView = MKMapView()
        self.mapView?.delegate = self
    }
    
    /* set the default configuration */
    public func setConfiguration(_ configuration:GFMapKitWrapperConfiguration) {
        self.configuration = configuration
        mapView?.camera = MKMapCamera()
        mapView?.camera.pitch = CGFloat(configuration.cameraPitch)
        mapView?.camera.altitude = configuration.cameraAltitude
        mapView?.delegate = self
    }
    
    /* use this function to get the mapView and add
     * to the view hierarchy programmatically */
    public func getMapView() -> MKMapView? {
        return self.mapView
    }
    
    /* center the map on the coordinate specified by latitude and longitude */
    public func centerMapOnPoint(latitude:Double, longitude:Double) {
        let coordinate = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
        centerMapOnCoordinate(coordinate: coordinate)
    }
    
    /* center the map on the address specified */
    public func centerMapOnAddress(address:String) {
        locationManager.getCoordinate(forAddress: address) { (coordinate) in
            if let coordinate = coordinate {
                self.centerMapOnCoordinate(coordinate: coordinate)
            }
        }
    }
    
    /* center the map on current user location, need CL permission */
    public func centerMapOnCurrentLocation() {
        locationManager.getCurrentLocation { (success, coordinate) in
            if success {
                if let coordinate = coordinate {
                    self.centerMapOnCoordinate(coordinate: coordinate)
                }
            }
        }
    }
    
    /* draw the route between the addresses specified
     * and center the map on the starting address */
    public func showRoute(fromAddress:String, toAddress:String) {
        locationManager.getCoordinates(forAddresses: [fromAddress, toAddress]) { (coordinates) in
            if coordinates.count == 2 {
                if  let fromCoordinate = coordinates[0]["coordinate"] as? CLLocationCoordinate2D,
                    let toCoordinate = coordinates[1]["coordinate"]  as? CLLocationCoordinate2D {
                    self.drawRoute(fromCoordinate: fromCoordinate, toCoordinate: toCoordinate)
                    self.centerMapOnCoordinate(coordinate: fromCoordinate)
                }
            }
        }
    }
    
    /* draw the route between current user location and the address */
    public func showRouteFromCurrentLocation(toAddress:String) {
        locationManager.getCurrentLocation { (success, coordinate) in
            if success {
                if let coordinate = coordinate {
                    self.locationManager.getCoordinate(forAddress: toAddress, completionHandler: { (addressCoordinate) in
                        if let addressCoordinate = addressCoordinate {
                            self.drawRoute(fromCoordinate: coordinate, toCoordinate: addressCoordinate)
                        }
                    })
                }
            }
        }
    }
    
    /* draw the route between current user location and the coordinate specified */
    public func showRouteFromCurrentLocation(toLatitude:Double, longigute:Double) {
        
    }
    
    /* draw a line between current user location and the address */
    public func showLineFromCurrentLocation(toAddress:String) {
        
    }
    
    /* add an annotation */
    public func addAnnotation(annotation:GFMapKitAnnotation) {
        
    }
}

// MARK: Private functions

extension GFMapKitWrapper {
    private func centerMapOnCoordinate(coordinate:CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, self.configuration.regionSize, self.configuration.regionSize)
        mapView?.region = region
    }
    
    private func drawLine(fromCoordinate:CLLocationCoordinate2D, toCoordinate:CLLocationCoordinate2D) {
        let coordinates = [fromCoordinate, toCoordinate]
        let polyline = MKPolyline(coordinates: coordinates, count: 2)
        mapView?.add(polyline, level: MKOverlayLevel(rawValue: 0)!)
    }
    
    private func drawRoute(fromCoordinate:CLLocationCoordinate2D, toCoordinate:CLLocationCoordinate2D) {
        let startItem = MKMapItem(placemark: MKPlacemark(coordinate: fromCoordinate))
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: toCoordinate))
        let request = MKDirectionsRequest()
        request.source = startItem
        request.destination = destinationItem
        request.transportType = configuration.transportType
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let response = response {
                let routes = response.routes
                if let route = routes.first {
                    for step in route.steps {
                        self.mapView?.add(step.polyline, level: MKOverlayLevel(rawValue: 0)!)
                    }
                }
            }
        }
    }
}

// MARK: MKMapViewDelegate

extension GFMapKitWrapper : MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRendered = MKPolylineRenderer(polyline: polyline)
            polylineRendered.strokeColor = configuration.lineColor
            polylineRendered.lineWidth = 3.0
            return polylineRendered
        }
        return MKOverlayRenderer(overlay: overlay) // default renderer
    }
}
