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

/* struct to add an annotation to the map
 * if latitude and longitude are set we use them
 * otherwise the address needs to be set
 * we try to resolve it and eventually add the annotation
 */
public struct GFMapKitWrapperAnnotation {
    public var title:String?
    public var subtitle:String?
    public var latitude:Double?
    public var longitude:Double?
    public var address:String?
    
    public init() {
        
    }
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
        locationManager.getCurrentLocation { (success, coordinate) in
            if success {
                if let coordinate = coordinate {
                    let destCoordinate = CLLocationCoordinate2D(latitude: toLatitude, longitude: longigute)
                    self.drawRoute(fromCoordinate: coordinate, toCoordinate: destCoordinate)
                }
            }
        }
    }
    
    /* draw a line between current user location and the address */
    public func showLineFromCurrentLocation(toAddress:String) {
        locationManager.getCurrentLocation { (success, coordinate) in
            if success {
                if let coordinate = coordinate {
                    self.locationManager.getCoordinate(forAddress: toAddress, completionHandler: { (addressCoordinate) in
                        if let addressCoordinate = addressCoordinate {
                            self.drawLine(fromCoordinate: coordinate, toCoordinate: addressCoordinate)
                        }
                    })
                }
            }
        }
    }
    
    /* add an annotation */
    public func addAnnotation(annotation:GFMapKitWrapperAnnotation) {
        if let _ = annotation.latitude, let _ = annotation.longitude {
            let gfAnnotation = GFMapKitAnnotation(annotation: annotation)
            self.mapView?.addAnnotation(gfAnnotation)
        }
        else { // if we don't have coordinate we need the address
            guard let address = annotation.address else {
                return
            }
            locationManager.getCoordinate(forAddress: address) { (coordinate) in
                if let coordinate = coordinate {
                    var validAnnotation = annotation
                    validAnnotation.latitude = coordinate.latitude
                    validAnnotation.longitude = coordinate.longitude
                    let gfAnnotation = GFMapKitAnnotation(annotation: validAnnotation)
                    self.mapView?.addAnnotation(gfAnnotation)
                }
            }
        }
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
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? GFMapKitAnnotation else {
            return nil // only support custom annotation class
        }
        let identifier = annotation.identifier
        var annotationView:MKPinAnnotationView?
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            annotationView = dequeuedView
        }
        else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView?.tintColor = configuration.pinColor
        annotationView?.pinTintColor = configuration.pinColor
        annotationView?.canShowCallout = true
        return annotationView
    }
}
