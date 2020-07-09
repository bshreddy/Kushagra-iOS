//
//  UserProfileCell.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 22/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit
import Firebase

class UserProfileCell: UICollectionViewCell, SelfConfiguringProfileCell {
    
    static var reuseIdentifier: String = "UserProfileCell"
    
    let userDP = UIImageView()
    let username = UILabel()
    let email = UILabel()
    var stackView: UIStackView!
    var userDPWidth, stackViewLeadingConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        userDP.tintColor = .userDPColor
        userDP.contentMode = .scaleAspectFill
        userDP.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userDP)
        
        username.font = UIFont.preferredFont(forTextStyle: .headline)
        username.textColor = .label
        
        email.font = UIFont.preferredFont(forTextStyle: .subheadline)
        email.textColor = .label
        
        stackView = UIStackView(arrangedSubviews: [username, email])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        userDPWidth = userDP.widthAnchor.constraint(equalToConstant: 72)
        stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: userDP.trailingAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            userDP.heightAnchor.constraint(equalToConstant: 72),
            userDPWidth,
            userDP.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userDP.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackViewLeadingConstraint,
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    func configure(for user: User?, with identifier: ProfileViewController.Identifier) {
        userDP.layer.cornerRadius = userDP.layer.frame.height / 2
        userDP.layer.masksToBounds = true
        
        if let user = user {
            self.username.text = user.displayName
            self.email.text = user.email
            stackView.alignment = .leading
            userDPWidth.constant = 72
            stackViewLeadingConstraint.constant = 16
            
            self.userDP.image = UIImage(systemName: "person.crop.circle")
            
            if let photoURL = user.photoURL {
                URLSession.shared.dataTask(with: photoURL) { data, response, error in
                    guard let data = data else {
                        print(error?.localizedDescription ?? "Unknown Error")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.userDP.image = UIImage(data: data)
                    }
                }.resume()
            }
        } else {
            self.username.text = "Please Sign In to check your Profile".localized
            self.email.text = "Tap the \"Sign In\" button to sign-in".localized
            stackView.alignment = .center
            self.userDP.image = nil
            userDPWidth.constant = 0
            stackViewLeadingConstraint.constant = 0
        }
    }
    
    func deconfigure() {
        
    }
    
}
