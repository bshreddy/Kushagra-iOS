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
    
    static let imageDidChange =  Notification.Name("predictionImageDidChange")
    
    private static var classes: [Kind: [String]] = {
        let classes = Bundle.main.decode([String: [String]].self, from: "Classes.json")
        return [Kind.crop: classes[Kind.crop.rawValue]!,
                Kind.disease: classes[Kind.disease.rawValue]!]
    }()
    
    private static let URLs = [Kind.crop: ServerURL.appendingPathComponent("crop"),
                               .disease: ServerURL.appendingPathComponent("disease")]
    
    var image: UIImage? {
        didSet {
            NotificationCenter.default.post(name: Prediction.imageDidChange, object: self)
        }
    }
    private(set) var predictedIdx: Int
    private(set) var confidences: [Float]
    private(set) var kind: Kind
    
    var predictedClass: String {
        Prediction.classes[kind]![predictedIdx]
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
        self.predictedIdx = predicted_idx
        self.confidences = confidences
        self.kind = kind
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.predictedIdx = try container.decode(Int.self, forKey: .predicted_idx)
        self.confidences = try container.decode([Float].self, forKey: .confidences)
        self.kind = Kind(rawValue: try container.decode(String.self, forKey: .kind))!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(predictedIdx, forKey: .predicted_idx)
        try container.encode(confidences, forKey: .confidences)
        try container.encode(kind.rawValue, forKey: .kind)
    }
    
    static func predict(kindOf kind: Kind, from image: UIImage, withCompletion completionHandler: @escaping (_ prediction: Prediction?) -> Void) {
        let filename = "cropimage.png"
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: URLs[kind]!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"img\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown Error")
                completionHandler(nil)
                return
            }
            
            let prediction = try? JSONDecoder().decode(Prediction.self, from: data)
            prediction?.image = image
            completionHandler(prediction)
        }.resume()
    }
    
}
