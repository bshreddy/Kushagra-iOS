//
//  MediumTextCell.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 03/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

class ListCell: UICollectionViewCell {
    
//    static var reuseIdentifier: String { "PredictionTextCell" }
    
//    MARK: UI Variables
    var imageView = UIImageView()
    var title = UILabel()
    var subtitle = UILabel()
    var separator = UIView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.image = nil
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        title.font = UIFont.preferredFont(forTextStyle: .body)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .secondaryLabel
        
        subtitle.font = UIFont.preferredFont(forTextStyle: .body)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.textColor = .label
        
        let stackView = UIStackView(arrangedSubviews: [imageView, title, subtitle])
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        separator.backgroundColor = .quaternaryLabel
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
}

class DetailsTextCell: ListCell, SelfConfiguringPredictionCell {
    
    static var reuseIdentifier: String { "PredictionTextCell" }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.isHidden = true
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


class ActionCell: ListCell, SelfConfiguringPredictionCell {
    
    static var reuseIdentifier: String { "DetailsTextCell" }
    var recent: Recent?
    
    enum Action: String {
        case bookmark = "Bookmark"
        case exportToPDF = "Export to PDF"
        case saveImageToPhotos = "Save Image to Photos"
        case saveMapToPhotos = "Save Map To Photos"
        case delete = "Delete"
    }
    
    static var actions: [Action] = [.bookmark, .exportToPDF, .saveImageToPhotos, .saveMapToPhotos, .delete]
    static var actionIcons: [Action: String] = [.bookmark: "bookmark",
                                                .exportToPDF: "doc.richtext",
                                                .saveImageToPhotos: "photo",
                                                .saveMapToPhotos: "map.fill",
                                                .delete: "trash.fill"]
    
    func configure(with recent: Recent, for indexPath: IndexPath) {
        let iconName = ActionCell.actionIcons[ActionCell.actions[indexPath.row]]!
        title.text = ActionCell.actions[indexPath.row].rawValue
        title.textColor = .systemBlue
        imageView.tintColor = .systemBlue
        
        imageView.image = UIImage(systemName: iconName)
        
        switch ActionCell.actions[indexPath.row] {
        case .bookmark:
            title.text = "\((recent.bookmarked) ? "Remove from" : "Add to") Bookmarks"
            imageView.image = UIImage(systemName: "\(iconName)\((recent.bookmarked) ? ".fill" : "")")
            
        case .delete:
            title.textColor = .systemRed
            imageView.tintColor = .systemRed
        default:
            break
        }
    }
    
    func deconfigure() {
    }
    
}
