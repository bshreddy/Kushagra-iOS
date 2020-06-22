//
//  SelfConfiguringProfileCell.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 22/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation
import FirebaseUI

protocol SelfConfiguringProfileCell {
    static var reuseIdentifier: String { get }
    func configure(for user: User?, with identifier: ProfileViewController.Identifier)
    func deconfigure()
}
