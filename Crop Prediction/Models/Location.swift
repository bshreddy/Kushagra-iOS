//
//  Location.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 02/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation
import CoreLocation

class Location: Codable, CustomStringConvertible {
    
    enum CodingKeys: String, CodingKey {
        case lat, long, altitude
    }
    
    var lat: Double
    var long: Double
    var altitude: Double
    private(set) var address: String?
    
    var description: String {
        "\(latString), \(longString), \(altString)"
    }
    
    var latString: String {
        String(format: "%.3f˚ \((lat.sign.rawValue == 0) ? "N" : "S")", lat.magnitude)
    }
    
    var longString: String {
        String(format: "%.3f˚ \((long.sign.rawValue == 0) ? "E" : "W")", long.magnitude)
    }
    
    var altString: String {
        String(format: "%.2f m MSE", altitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(latitude: lat, longitude: long)
    }
    
    init(_ lat: Double, _ long: Double, _ altitude: Double) {
        self.lat = lat
        self.long = long
        self.altitude = altitude
    }
    
    init(_ location: CLLocation) {
        self.lat = Double(location.coordinate.latitude)
        self.long = Double(location.coordinate.longitude)
        self.altitude = Double(location.altitude)
    }
    
    init?(_ location: CLLocation?) {
        guard let location = location else {
            return nil
        }
        
        self.lat = Double(location.coordinate.latitude)
        self.long = Double(location.coordinate.longitude)
        self.altitude = Double(location.altitude)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        lat = try container.decode(Double.self, forKey: .lat)
        long = try container.decode(Double.self, forKey: .long)
        altitude = try container.decode(Double.self, forKey: .altitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(lat, forKey: .lat)
        try container.encode(long, forKey: .long)
        try container.encode(altitude, forKey: .altitude)
    }
    
}
