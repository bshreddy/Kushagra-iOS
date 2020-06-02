//
//  DetailViewController.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 01/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

class DetailViewController: UICollectionViewController {
    
    enum Identifier: String {
        case imageCell = "Image Cell"
        case infoCell = "Info Cell"
        case mapCell = "Map Cell"
        case actionCell = "Action Cell"
    }
    
//    MARK: Class Variables
    var isPresentedModelly = false
    var mode: Prediction.Kind {
        recent.prediction.kind
    }
    
    var cells: [(UICollectionViewCell & SelfConfiguringCell).Type] = [ImageCell.self, MapCell.self]
    
//    MARK: Model Variables
    var recent: Recent!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        collectionView.collectionViewLayout = createLayout()
        
        for cell in cells {
            collectionView.register(cell, forCellWithReuseIdentifier: cell.resueIdentifier)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let imageLayoutItem = self.createImageLayoutItem(layoutEnvironment)
            let mapLayoutItem = self.createMapLayoutItem(layoutEnvironment)
            
            let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [imageLayoutItem, mapLayoutItem])
            
            let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
            layoutSection.interGroupSpacing = 20
            
            return layoutSection
        }
        
        return layout
    }
    
    func createImageLayoutItem(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        var width = NSCollectionLayoutDimension.fractionalWidth(1)
        var height = NSCollectionLayoutDimension.fractionalWidth(0.625)
                    
//        For iPads and non-plus iPhones in landscape
        if layoutEnvironment.traitCollection.verticalSizeClass == layoutEnvironment.traitCollection.horizontalSizeClass {
            width = .fractionalWidth(0.6)
            height = .fractionalWidth(0.375)
        }
        
        let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        return layoutItem
    }
    
    func createMapLayoutItem(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
            var width = NSCollectionLayoutDimension.fractionalWidth(1)
            var height = NSCollectionLayoutDimension.fractionalWidth(1)
                        
    //        For iPads and non-plus iPhones in landscape
            if layoutEnvironment.traitCollection.verticalSizeClass == layoutEnvironment.traitCollection.horizontalSizeClass {
                width = .fractionalWidth(0.4)
                height = .fractionalWidth(0.4)
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
            
            let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
            layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            
            return layoutItem
        }
    
    @objc func cancelTapped() {
        
    }
    
    @objc func saveTapped() {
        
    }
    
    @objc func optionsTapped() {
        
    }
    
}

extension DetailViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cells.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cells[indexPath].resueIdentifier, for: indexPath) as! SelfConfiguringCell
        
        cell.configure(with: recent)
        
        return cell as! UICollectionViewCell
    }
    
}
