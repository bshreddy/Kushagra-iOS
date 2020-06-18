//
//  CardCell.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 02/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    let cornerRadius: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .cardBackground
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
}
