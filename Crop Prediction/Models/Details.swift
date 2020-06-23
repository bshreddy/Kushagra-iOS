//
//  Details.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 24/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation

protocol Details: Decodable {
    func getInfoCellData() -> [InfoCardCellData]
}

struct CropDetails: Details {
    
    var type: String?
    var techniquesUsed: String?
    var varieties: String?
    var temp: String?
    var rainfall: String?
    var soil: String?
    var majorProducers: [String]?
    var highestProducer: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case techniquesUsed = "tech"
        case varieties = "vrts"
        case temp = "temp"
        case rainfall = "rain"
        case soil = "soil"
        case majorProducers = "prdcrs"
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try? container.decode(String.self, forKey: .type)
        techniquesUsed = try? container.decode(String.self, forKey: .techniquesUsed)
        varieties = try? container.decode(String.self, forKey: .varieties)
        temp = try? container.decode(String.self, forKey: .temp)
        rainfall = try? container.decode(String.self, forKey: .rainfall)
        soil = try? container.decode(String.self, forKey: .soil)
        majorProducers = try? container.decode([String].self, forKey: .majorProducers)
        highestProducer = majorProducers?.first
    }
    
    func getInfoCellData() -> [InfoCardCellData] {
        [InfoCardCellData(title: "Type", subtitle: type),
         InfoCardCellData(title: "Techniques Used", subtitle: techniquesUsed),
         InfoCardCellData(title: "Varieties", subtitle: varieties),
         InfoCardCellData(title: "Temp", subtitle: temp),
         InfoCardCellData(title: "Rainfall", subtitle: rainfall),
         InfoCardCellData(title: "Soil Type", subtitle: soil),
         InfoCardCellData(title: "Highest Producer", subtitle: highestProducer),
         InfoCardCellData(title: "Major Producers", subtitle: majorProducers?.joined(separator: ", "))]
    }
    
}

struct DiseaseDetails: Details {
    
    func getInfoCellData() -> [InfoCardCellData] {
        return [InfoCardCellData]()
    }
}

