//
//  MapViewController.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 22/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: Location!
    var hidden = false
    var isDoneLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
        
        mapView.delegate = self
        mapView.set(location: location, 500)
        mapView.mapType = .hybrid
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        
        let tapRecog = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapRecog.numberOfTapsRequired = 1
        tapRecog.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(tapRecog)
        
        isDoneLoading = true
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if(!hidden && isDoneLoading) {
            tapped()
        }
    }
    
    @objc func tapped() {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.navigationController?.navigationBar.isHidden.toggle()
            self.navigationController?.navigationController?.navigationBar.isHidden.toggle()
            self.tabBarController?.tabBar.isHidden.toggle()
            self.view.backgroundColor = (self.hidden) ? .systemBackground : .black
            self.hidden.toggle()
        })
    }
    
}
