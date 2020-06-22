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
        layer.masksToBounds = false
        
        layer.shadowRadius = cornerRadius
        
//        layer.shadowColor = UIColor { traitCollection in
//            traitCollection.userInterfaceStyle == .light ? .lightGray : .clear
//        }.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2.0)
//        layer.shadowOpacity = 0.6
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
}
