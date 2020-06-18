//
//  MediumTextCell.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 03/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

class MediumTextCell: UICollectionViewCell {
    
//    static var reuseIdentifier: String { "PredictionTextCell" }
    
//    MARK: UI Variables
    var title = UILabel()
    var subtitle = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var separator = UIView(frame: .zero)
        separator.backgroundColor = .quaternaryLabel
        
        title.font = UIFont.preferredFont(forTextStyle: .body)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .label
        
        subtitle.font = UIFont.preferredFont(forTextStyle: .body)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.textColor = .secondaryLabel
        
        let stackView = UIStackView(arrangedSubviews: [title, subtitle])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    func configure(with recent: Recent, for indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            title.text = "\(recent.prediction.kind.rawValue.capitalized) Name: "
            subtitle.text = recent.prediction.predictedName
        case 1:
            title.text = "Latitude: "
            subtitle.text = recent.location?.latString ?? "N/A"
        case 2:
            title.text = "Logitude: "
            subtitle.text = recent.location?.longString ?? "N/A"
        case 3:
            title.text = "Altitude: "
            subtitle.text = recent.location?.altString ?? "N/A"
        case 4:
            title.text = "Address: "
            subtitle.text = recent.location?.address ?? "N/A"
        default:
            title.text = "N/A"
            subtitle.text = "N/A"
        }
    }
    
    func deconfigure() {
        
    }
    
}

class PredictionTextCell: MediumTextCell, SelfConfiguringCell {
    
    static var reuseIdentifier: String { "PredictionTextCell" }
    
}


class DetailsTextCell: MediumTextCell, SelfConfiguringCell {
    
    static var reuseIdentifier: String { "DetailsTextCell" }
    
}
