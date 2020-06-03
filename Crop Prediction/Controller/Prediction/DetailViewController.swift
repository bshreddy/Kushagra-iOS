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
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
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
            collectionView.register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
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
            switch self.cells[sectionIndex].reuseIdentifier {
            case ImageCell.reuseIdentifier:
                return self.createImageLayout(layoutEnvironment)
            case MapCell.reuseIdentifier:
                return self.createMapLayout(layoutEnvironment)
            default:
                fatalError("Invalid reuseIdentifier")
            }
        }
        
        return layout
    }
    
    func createImageLayout(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var width = NSCollectionLayoutDimension.fractionalWidth(1)
        var height = NSCollectionLayoutDimension.fractionalWidth(0.625)
        
//        if layoutEnvironment.traitCollection.horizontalSizeClass == layoutEnvironment.traitCollection.verticalSizeClass {
//            width = NSCollectionLayoutDimension.fractionalWidth(0.6)
//            height = NSCollectionLayoutDimension.fractionalWidth(0.375)
//        }
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        return layoutSection
    }
    
    func createMapLayout(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var width = NSCollectionLayoutDimension.fractionalWidth(1)
        var height = NSCollectionLayoutDimension.fractionalWidth(1)
        
//        if layoutEnvironment.traitCollection.horizontalSizeClass == layoutEnvironment.traitCollection.verticalSizeClass {
//            width = NSCollectionLayoutDimension.fractionalWidth(0.4)
//            height = NSCollectionLayoutDimension.fractionalWidth(0.4)
//        }
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        return layoutSection
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
        cells.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch cells[section].reuseIdentifier {
        default:
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cells[indexPath.section].reuseIdentifier, for: indexPath) as! SelfConfiguringCell
        
        cell.configure(with: recent)
        
        return cell as! UICollectionViewCell
    }
    
}
