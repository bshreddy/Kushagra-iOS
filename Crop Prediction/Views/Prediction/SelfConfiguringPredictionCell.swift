//
//  SelfConfiguringCell.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 02/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation

protocol SelfConfiguringPredictionCell {
    static var reuseIdentifier: String { get }
    func configure(with recent: Recent, for indexPath: IndexPath)
    func deconfigure()
}
