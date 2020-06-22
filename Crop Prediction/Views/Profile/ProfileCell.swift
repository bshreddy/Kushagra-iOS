//
//  ProfileCell.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 22/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit
import FirebaseUI

class ProfileCell: UICollectionViewCell, SelfConfiguringProfileCell {
    
    static var reuseIdentifier: String = "ProfileCell"
    
    typealias Identifier = ProfileViewController.Identifier
    
    private let cellTexts: [Identifier: String] = [.bookmarksCell: "Bookmarks",
                                                   .serverAddrCell: "Server Address",
                                                   .settingsCell: "Settings",
                                                   .helpCell: "Help",
                                                   .tellCell: "Tell a Friend",
                                                   .signOutCell: "Sign Out"]
    private let cellIcons: [Identifier: String] = [.userCell: "person.crop.circle",
                                                   .bookmarksCell: "bookmark.fill",
                                                   .serverAddrCell: "antenna.radiowaves.left.and.right",
                                                   .settingsCell: "gear",
                                                   .helpCell: "info.circle.fill",
                                                   .tellCell: "heart.circle.fill",
                                                   .signOutCell: "arrow.uturn.left.circle.fill"]
    private let cellIconsTint: [Identifier: UIColor] = [.bookmarksCell: .systemBlue,
                                                        .serverAddrCell: .systemGreen,
                                                        .settingsCell: .systemGray,
                                                        .helpCell: .systemTeal,
                                                        .tellCell: .systemPink,
                                                        .signOutCell: .systemRed]
    
    var iconView = UIImageView()
    var title = UILabel()
    var subtitle = UILabel()
    var separator = UIView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconView.image = nil
        iconView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        title.font = UIFont.preferredFont(forTextStyle: .body)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .label
        
        let stackView = UIStackView(arrangedSubviews: [iconView, title])
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
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    func configure(for user: User?, with identifier: Identifier) {
        if let _ = user {
            title.text = cellTexts[identifier]!
            iconView.image = UIImage(systemName: cellIcons[identifier]!)
            iconView.tintColor = cellIconsTint[identifier]!
            separator.isHidden = false
        } else {
            title.text = nil
            iconView.image = nil
            iconView.tintColor = nil
            separator.isHidden = true
        }
    }
    
    func deconfigure() {
    }
    
}
