//
//  DetailCard.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 23/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

class DetailCard: CardCell, SelfConfiguringPredictionCell {
    static var reuseIdentifier: String = "CardCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    func configure(with recent: Recent, for indexPath: IndexPath) {
        
    }
    
    func deconfigure() {
        
    }
    
    
}
