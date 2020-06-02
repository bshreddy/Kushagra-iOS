//
//  Prediction.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 02/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation
import UIKit

var ServerURL: URL {
    get {
        var serverURL = URL(string: "http://localhost:8000")!
        
        let defaults = UserDefaults.standard
        if let url = defaults.url(forKey: "ServerURL") {
            serverURL = url
        } else {
            defaults.set(serverURL, forKey: "ServerURL")
        }
        
        return serverURL
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "ServerURL")
    }
}

class Prediction: Codable, CustomStringConvertible {
    
    enum Kind: String {
        case crop
        case disease
    }
    
    enum CodingKeys: String, CodingKey {
        case predicted_idx = "pred"
        case confidences = "cnf"
        case kind = "kind"
    }
    
    private static var classes: [Kind: [String]] = {
        let classes = Bundle.main.decode([String: [String]].self, from: "Classes.json")
        return [Kind.crop: classes[Kind.crop.rawValue]!,
                Kind.disease: classes[Kind.disease.rawValue]!]
    }()
    
    private static let URLs = [Kind.crop: ServerURL.appendingPathComponent("crop"),
                               .disease: ServerURL.appendingPathComponent("disease")]
    
    var image: UIImage?
    private(set) var predicted_idx: Int
    private(set) var confidences: [Float]
    private(set) var kind: Kind
    
    var predictedClass: String {
        Prediction.classes[kind]![predicted_idx]
    }
    
    var predictedName: String {
        predictedClass.capitalized
    }
    
    var defaultImage: UIImage {
        UIImage(named: predictedClass) ?? UIImage(named: "default-image")!
    }
    
    var description: String {
        predictedName
    }
    
    init(_ image: UIImage? = nil, _ predicted_idx: Int, _ confidences: [Float], _ kind: Kind) {
        self.image = image
        self.predicted_idx = predicted_idx
        self.confidences = confidences
        self.kind = kind
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.predicted_idx = try container.decode(Int.self, forKey: .predicted_idx)
        self.confidences = try container.decode([Float].self, forKey: .confidences)
        self.kind = Kind(rawValue: try container.decode(String.self, forKey: .kind))!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(predicted_idx, forKey: .predicted_idx)
        try container.encode(confidences, forKey: .confidences)
        try container.encode(kind.rawValue, forKey: .kind)
    }
    
}
