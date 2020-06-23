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
    var imageViewWidth: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.image = nil
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        title.font = UIFont.preferredFont(forTextStyle: .body)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .secondaryLabel
        contentView.addSubview(title)
        
        subtitle.font = UIFont.preferredFont(forTextStyle: .body)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.textColor = .label
        subtitle.numberOfLines = 0
        subtitle.adjustsFontSizeToFitWidth = false
        subtitle.lineBreakMode = .byTruncatingTail
        
        contentView.addSubview(subtitle)
        
        separator.backgroundColor = .quaternaryLabel
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        
        imageViewWidth = imageView.widthAnchor.constraint(equalToConstant: 24)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            imageView.heightAnchor.constraint(equalToConstant: 24), imageViewWidth,
            
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            title.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            
            subtitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            subtitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            subtitle.leadingAnchor.constraint(greaterThanOrEqualTo: title.trailingAnchor, constant: 10),
            subtitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
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
        imageViewWidth.constant = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    func configure(with recent: Recent, for indexPath: IndexPath) {
        title.text = "\(recent.infoList[indexPath.row].title.localized): "
        subtitle.text = recent.infoList[indexPath.row].subtitle?.localized ?? "N/A"
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
        title.text = ActionCell.actions[indexPath.row].rawValue.localized
        title.textColor = .systemBlue
        imageView.tintColor = .systemBlue
        
        imageView.image = UIImage(systemName: iconName)
        
        switch ActionCell.actions[indexPath.row] {
        case .bookmark:
            title.text = "\((recent.bookmarked) ? "Remove from" : "Add to") Bookmarks".localized
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
