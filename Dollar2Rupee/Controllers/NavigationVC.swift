//
//  NavigationVC.swift
//  Dollar2Rupee
//
//  Created by Ankersani on 9/6/18.
//  Copyright © 2018 Ankersani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NavigationVC: UIViewController {

    let manager  = CLLocationManager()
    let request  = MKLocalSearchRequest()
    let mainView = ShadowView()
    lazy var mapView: MKMapView = {
       let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 14
        return view
    }()
    
    fileprivate func setupVIew(){
        view.addSubview(mainView)
        mainView.addSubview(mapView)
        
        mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mainView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        mainView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        mainView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
        mapView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
    }
    
    fileprivate func setupNavBar(){
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(named: "background")
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.darkGray, .font: UIFont(name: "AppleSDGothicNeo-Light", size: 35) ?? UIFont.systemFont(ofSize: 35)]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray,.font: UIFont(name: "AppleSDGothicNeo-Light", size: 20) ?? UIFont.systemFont(ofSize: 20)]
        navigationController?.navigationBar.tintColor = UIColor(named: "system")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupVIew()
        setupNavBar()
        manager.delegate = self
        manager.desiredAccuracy =   kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

}
