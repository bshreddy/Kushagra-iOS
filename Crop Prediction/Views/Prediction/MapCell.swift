//
//  MapCell.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 02/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit
import MapKit

class MapCell: CardCell, SelfConfiguringCell {

//    MARK: Class Variables
    static let resueIdentifier = "MapCell"
    
//    MARK: UI Variables
    let mapView = MKMapView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mapView.layer.cornerRadius = cornerRadius
        mapView.clipsToBounds = true
        mapView.isUserInteractionEnabled = false
        mapView.mapType = .hybrid
        mapView.pointOfInterestFilter = .none
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsCompass = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    func configure(with recent: Recent) {
        guard let location = recent.location else {
            return
        }
        
        mapView.setRegion(
            MKCoordinateRegion(center: location.clLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500),
            animated: true)
    }
    
    func deconfigure() {
        
    }
    
    
}
