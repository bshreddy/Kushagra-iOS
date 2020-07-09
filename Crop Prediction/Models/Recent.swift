//
//  Recent.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 02/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation
import UIKit
import Firebase
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
    var createdAt: Date
    var location: Location?
    var details: Details?
    private(set) var bookmarked: Bool {
        didSet {
            NotificationCenter.default.post(name: Recent.bookmarkDidChange, object: self)
        }
    }
    private(set) lazy var infoList: [InfoCardCellData] = {
        updateInfoList()
    }()
    
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
        guard let user = (UIApplication.shared.delegate as! AppDelegate).authUI.auth?.currentUser,
            let id = id else {
            return
        }
        
        let recentsRef = (UIApplication.shared.delegate as! AppDelegate).firestore.collection("users").document(user.uid).collection("recents")
        bookmarked.toggle()
        
        recentsRef.document(id).updateData(["bkmrkd": bookmarked]) { error in
            if error != nil {
                print(error?.localizedDescription ?? "Unknown Error")
                
                DispatchQueue.main.async {
                    self.bookmarked.toggle()
                }
            }
        }
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
    
    func updateInfoList() -> [InfoCardCellData] {
        var list = [InfoCardCellData(title: "Name", subtitle: prediction.predictedName),
                    InfoCardCellData(title: "Latitude", subtitle: location?.latString),
                    InfoCardCellData(title: "Longitude", subtitle: location?.longString),
                    InfoCardCellData(title: "Altitude", subtitle: location?.altString),
                    InfoCardCellData(title: "Address", subtitle: location?.address)]
        
        if(prediction.kind == .crop) {
            list.insert(InfoCardCellData(title: "Conf",
                                         subtitle: String(format: "%.3f", prediction.confidences[prediction.predictedIdx] * 100) + " %"),
                        at: 1)
        }
        
        if let details = details {
            if prediction.kind == .crop {
                list.append(contentsOf: (details as! CropDetails).getInfoCellData())
            } else {
                list.append(contentsOf: (details as! DiseaseDetails).getInfoCellData())
            }
        }
        
        return list
    }
    
    func getDetails(withCompletion completionHandler: @escaping ((Recent) -> Void)) {
        if let _ = details {
            completionHandler(self)
            return
        }
        
        if(prediction.kind == .crop) {
            getDetails(for: CropDetails.self ,withCompletion: completionHandler)
        } else {
            getDetails(for: DiseaseDetails.self ,withCompletion: completionHandler)
        }
    }
    
    private func getDetails<T: Details>(for kind: T.Type, withCompletion completionHandler: @escaping ((Recent) -> Void)) {
        let detailsRef = (UIApplication.shared.delegate as! AppDelegate).firestore.collection("details")
        
        detailsRef.document(prediction.predictedClass).getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            if let dataDict = snapshot.data(),
                let data = try? JSONSerialization.data(withJSONObject: dataDict, options: []),
                let details = try? JSONDecoder().decode(T.self, from: data) {
                
                self.details = details
                self.infoList = self.updateInfoList()
                
                completionHandler(self)
            }
        }
    }
    
}

typealias ID = String
