//
//  ViewController.swift
//  GFMapKitWrapper
//
//  Created by gualtierofrigerio on 01/08/2019.
//  Copyright (c) 2019 gualtierofrigerio. All rights reserved.
//

import UIKit
import GFMapKitWrapper
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let wrapper = GFMapKitWrapper(mapView: mapView)
        //wrapper.centerMapOnPoint(latitude: 45.4697645, longitude: 9.1349959)
        //wrapper.centerMapOnAddress(address: "Piazza Duomo, Milano")
        //wrapper.centerMapOnCurrentLocation()
        //wrapper.showRouteFromCurrentLocation(toAddress: "Piazza Duomo, Milano")
        //wrapper.showRoute(fromAddress: "Piazza Duomo, Milano", toAddress: "Piazza Lodi, Milano")
        var annotation = GFMapKitWrapperAnnotation()
        annotation.title = "title"
        annotation.subtitle = "subtitle"
        annotation.address = "Piazza Duomo, Milano"
        wrapper.addAnnotation(annotation: annotation)
        wrapper.centerMapOnAddress(address: "Piazza Duomo, Milano")
        //wrapper.showLineFromCurrentLocation(toAddress: "Piazza Duomo, Milano")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

