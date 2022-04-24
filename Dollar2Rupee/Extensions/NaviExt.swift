//
//  NaviExt.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 9/6/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

extension NavigationVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.04, 0.04)
        let userLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        
        request.naturalLanguageQuery = "money"
        request.region = mapView.region
        let activeSearch = MKLocalSearch(request: request)
        activeSearch.start { (response, error) in
            
            guard let response = response else {
                return
            }
            
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                annotation.subtitle = "Currency Exchange"
                
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
        
    }
}
