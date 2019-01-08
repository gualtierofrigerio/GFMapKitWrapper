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
        let wrapper = GFMapKitWrapper(mapView: mapView)
        //wrapper.centerMapOnPoint(latitude: 45.000, longitude: 50.000)
        //wrapper.centerMapOnAddress(address: "Infinite Loop 1, Cupertino")
        wrapper.centerMapOnCurrentLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

