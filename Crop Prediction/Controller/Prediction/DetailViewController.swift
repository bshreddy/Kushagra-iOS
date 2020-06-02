//
//  DetailViewController.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 01/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

class DetailViewController: UICollectionViewController {
    
//    MARK: Class Variables
    var isPresentedModelly = false
    var mode: Prediction.Kind {
        recent.prediction.kind
    }
    
//    MARK: Model Variables
    var recent: Recent!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(Date()) \(URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent).\(#function)")
        
        if isPresentedModelly {
            navigationItem.title = "New \(mode.rawValue.capitalized) Detection"
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        } else {
            navigationItem.title = "\(mode.rawValue.capitalized) Details"
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                                style: .plain, target: self, action: #selector(optionsTapped))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func cancelTapped() {
        
    }
    
    @objc func saveTapped() {
        
    }
    
    @objc func optionsTapped() {
        
    }
    
}
