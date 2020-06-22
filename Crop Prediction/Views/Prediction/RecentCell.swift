//
//  RecentCell.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 02/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

class RecentCell: CardCell, SelfConfiguringPredictionCell {
    
//    MARK: Class Constants
    static let reuseIdentifier = "RecentCell"
    
//    MARK: Class Variables
    var recent: Recent?
    var bookmark: Bool {
        set {
//            recent?.bookmarked = newValue
            bookmarkBtn.setImage((newValue) ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
        }
        get {
            recent?.bookmarked ?? false
        }
    }
    
//    MARK: UI Variables
    let title = UILabel()
    let subtitle = UILabel()
    let imageView = UIImageView()
    let bookmarkBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .cardBackground
        
        title.font = UIFont.preferredFont(forTextStyle: .title2)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .label
        
        subtitle.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.textColor = .label
        
        bookmarkBtn.tintColor = .label
        bookmarkBtn.addTarget(self, action: #selector(bookmarkBtnTapped), for: .touchUpInside)
        bookmarkBtn.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blurView.layer.cornerRadius = cornerRadius
        blurView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        blurView.layer.masksToBounds = true
        blurView.contentView.addSubview(title)
        blurView.contentView.addSubview(subtitle)
        blurView.contentView.addSubview(bookmarkBtn)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            title.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 8),
            title.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 12),
            title.trailingAnchor.constraint(greaterThanOrEqualTo: bookmarkBtn.trailingAnchor, constant: -8),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant:4),
            subtitle.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -8),
            subtitle.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 14),
            subtitle.trailingAnchor.constraint(greaterThanOrEqualTo: bookmarkBtn.trailingAnchor, constant: -8),
            bookmarkBtn.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),
            bookmarkBtn.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -12),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    func configure(with recent: Recent, for indexPath: IndexPath) {
        self.recent = recent
        
        title.text = recent.prediction.predictedName
        subtitle.text = recent.location?.description
        imageView.image = recent.prediction.image ?? recent.prediction.defaultImage
        bookmark = recent.bookmarked
        bookmarkBtn.setImage((recent.bookmarked) ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bookmarkDidChange), name: Recent.bookmarkDidChange, object: recent)
        NotificationCenter.default.addObserver(self, selector: #selector(imageDidChange), name: Prediction.imageDidChange, object: recent.prediction)
        NotificationCenter.default.addObserver(self, selector: #selector(addressDidChange), name: Location.addressDidChange, object: recent.location)
    }
    
    func deconfigure() {
        NotificationCenter.default.removeObserver(self, name: Recent.bookmarkDidChange, object: recent)
        NotificationCenter.default.removeObserver(self, name: Prediction.imageDidChange, object: recent?.prediction)
        NotificationCenter.default.removeObserver(self, name: Location.addressDidChange, object: recent?.location)
    }
    
    @objc func bookmarkDidChange() {
        bookmarkBtn.setImage((recent!.bookmarked) ?
            UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
    }
    
    @objc func imageDidChange() {
        imageView.image = recent?.prediction.image ?? recent?.prediction.defaultImage
    }
    
    @objc func addressDidChange() {
        subtitle.text = recent!.location?.description
    }
    
    @objc func bookmarkBtnTapped() {
        recent?.toggleBookmark()
    }
    
}
