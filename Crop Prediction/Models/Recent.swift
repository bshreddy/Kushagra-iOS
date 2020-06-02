//
//  Recent.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 02/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation

class Recent: Codable {
    
    static let bookmarkDidChange =  Notification.Name("recentBookmarkDidChange")
    
    var id: ID?
    var prediction: Prediction
    var bookmarked: Bool {
        didSet {
            NotificationCenter.default.post(name: Recent.bookmarkDidChange, object: self)
        }
    }
    var createdAt: Date
    var location: Location?
    
    enum CodingKeys: String, CodingKey {
        case prediction = "pred"
        case createdAt = "crtdAt"
        case bookmarked = "bkmrkd"
        case location = "loc"
    }
    
    init(_ prediction: Prediction, bookmarked: Bool = false, location: Location? = nil) {
        self.prediction = prediction
        self.bookmarked = bookmarked
        self.createdAt = Date()
        self.location = location
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        prediction = try container.decode(Prediction.self, forKey: .prediction)
        bookmarked = try container.decode(Bool.self, forKey: .bookmarked)
        createdAt = Date(timeIntervalSince1970: try container.decode(Double.self, forKey: .createdAt))
        location = try? container.decode(Location.self, forKey: .location)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(prediction, forKey: .prediction)
        try container.encode(bookmarked, forKey: .bookmarked)
        try container.encode(createdAt.timeIntervalSince1970, forKey: .createdAt)
        try container.encode(location, forKey: .location)
    }
    
}

typealias ID = String
