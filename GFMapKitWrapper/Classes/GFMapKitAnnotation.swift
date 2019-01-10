//
//  GFMapAnnotation.swift
//  GFMapKitWrapper
//
//  Created by Gualtiero Frigerio on 10/01/2019.
//

import Foundation
import MapKit

/*
 * Custom class for making an annotation with the info
 * contained into the GFMapKitWrapperAnnotation struct
 * We expect to have valid coordinates
 */

class GFMapKitAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var identifier = "GFMapKitAnnotation"
    var subtitle: String?
    var title:String?
    
    init(coordinate:CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    init(annotation:GFMapKitWrapperAnnotation) {
        let latitude = annotation.latitude ?? 0.0
        let longitude = annotation.longitude ?? 0.0
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = annotation.title
        self.subtitle = annotation.subtitle
    }
}
