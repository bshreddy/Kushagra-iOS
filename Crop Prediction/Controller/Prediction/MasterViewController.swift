//
//  MasterViewController.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 01/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

class MasterViewController: UICollectionViewController {
    
//    MARK: Class Variables
    private var imagePicker: UIImagePickerController!
    var mode: Prediction.Kind!
    var onlyBookmarked = false
    
//    MARK: Model Variables
    var recents: [Recent]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMode()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(RecentCell.self, forCellWithReuseIdentifier: RecentCell.reuseIdentifier)
        
        loadData()
    }
    
    fileprivate func setMode() {
        if onlyBookmarked {
            navigationItem.rightBarButtonItem = .none
            navigationItem.title = "Bookmarks"
            return
        }
        
        switch tabBarController?.selectedIndex {
        case 0:
            mode = .crop
            navigationItem.title = "Your Crops"
        case 1:
            mode = .disease
            navigationItem.title = "Crop Diseases"
        default:
            break
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            var width = NSCollectionLayoutDimension.fractionalWidth(1)
            var height = NSCollectionLayoutDimension.fractionalWidth(0.625)
            
//            For non-plus iPhones in landscape
            if layoutEnvironment.traitCollection.verticalSizeClass == .compact && layoutEnvironment.traitCollection.horizontalSizeClass == .compact {
                width = .fractionalWidth(0.5)
                height = .fractionalWidth(0.3125)
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: .fractionalHeight(1))
            
            let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
//            layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            
            let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height)
            let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
            
            let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
            layoutSection.interGroupSpacing = 20
            layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 16, trailing: 10)
            
            return layoutSection
        }
        
        return layout
    }
    
    func loadData() {
        recents = Bundle.main.decode([Recent].self, from: "TestData.json").filter { $0.prediction.kind == self.mode }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Show Detail":
            let destVC = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            destVC.recent = sender as! Recent
            
        default:
            break
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let actionSheet = UIAlertController(title: "Select an Option", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true)
            })

            actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true)
            })

            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(actionSheet, animated: true)
        } else {
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
    }
    
}

extension MasterViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  recents.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCell.reuseIdentifier, for: indexPath) as! RecentCell
        let recent = recents[indexPath.row]
        
        cell.configure(with: recent, for: indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! RecentCell).deconfigure()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Detail", sender: recents[indexPath])
    }
    
}

extension MasterViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true)
        
//        spinner.startAnimating()
        
//        let image = info[.originalImage] as! UIImage
//        let location = locationManager?.location
        
//        Prediction.predict(kindOf: mode, from: image) { prediction in
//            DispatchQueue.main.async {
//                self.spinner.stopAnimating()
//            }
//
//            guard let prediction = prediction else {
//                print("Unknown Error Occurred")
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "New Detection", sender: Recent(prediction, location: Location(location)))
//            }
//        }
        
        self.performSegue(withIdentifier: "New Detection", sender: nil)
    }
    
}
