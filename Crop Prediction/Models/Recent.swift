//
//  Recent.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 02/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import FirebaseStorage

class Recent: Codable {
    
    static let bookmarkDidChange =  Notification.Name("recentBookmarkDidChange")
    
    static let reportTempDirectory: URL? = {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("com.project.CropPrediction", isDirectory: true)
            .appendingPathComponent("reports", isDirectory: true)
        
        do {
            if !FileManager.default.fileExists(atPath: tempDir.path) {
                try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            }
        
            return tempDir
        } catch {
            print(error)
        }
        
        return nil
    }()
    static let picturesDirectory: URL = {
        let picDir = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("com.project.CropPrediction", isDirectory: true)
            .appendingPathComponent("recents", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: picDir.path) {
            try? FileManager.default.createDirectory(at: picDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        return picDir
    }()
    
    var id: ID?
    var prediction: Prediction
    var bookmarked: Bool {
        didSet {
            NotificationCenter.default.post(name: Recent.bookmarkDidChange, object: self)
        }
    }
    var createdAt: Date
    var location: Location?
//    var details: CropDetails?
    
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
    
    func toggleBookmark() {
        bookmarked.toggle()
    }
    
    func loadImage(user: User, recentImagesRef: StorageReference,
                   withCompletion completionHandler: @escaping ((_ image: UIImage?) -> Void) = { _ in }) {
        let imgName = "\(prediction.predictedClass)/\(user.uid)-\(id!).png"
        let imgURL = Recent.picturesDirectory.appendingPathComponent(imgName)
            
        if let image = UIImage(contentsOfFile: imgURL.path) {
            self.prediction.image = image
            completionHandler(image)
        } else {
            recentImagesRef.child(imgName).write(toFile: imgURL) { url, error in
                guard error == nil, let url = url, let data = try? Data(contentsOf: url) else {
                    print(error?.localizedDescription ?? "Error While Reading Image")
                    completionHandler(nil)
                    return
                }
                let image = UIImage(data: data)
                self.prediction.image = image
                completionHandler(image)
            }
        }
    }
    
}

typealias ID = String
