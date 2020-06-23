//
//  DetailViewController.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 01/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate: NSObject {
    func save(recent: Recent)
    func performed(action: ActionCell.Action, on recent: Recent)
    func getDetails(for prediction: Prediction, withCompletion completionHandler: @escaping (([String:String]) -> Void))
}

class DetailViewController: UICollectionViewController {
    
    enum Identifier: String {
        case imageCell = "Image Cell"
        case infoCell = "Info Cell"
        case mapCell = "Map Cell"
        case actionCell = "Action Cell"
    }
    
//    MARK: Class Variables
    weak var delegate: DetailViewControllerDelegate?
    var isNew = false
    var onlyBookmarked = false
    var mode: Prediction.Kind!
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    var identifiers: [Identifier] = [.imageCell, .infoCell, .mapCell]
    var cells: [Identifier: (UICollectionViewCell & SelfConfiguringPredictionCell).Type] = [.imageCell: ImageCell.self,
                                                                                            .infoCell: DetailsTextCell.self,
                                                                                            .mapCell: MapCell.self,
                                                                                            .actionCell: ActionCell.self]
    
//    MARK: Model Variables
    var recent: Recent!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isNew {
            navigationItem.title = "New \(mode.rawValue.capitalized) Detection".localized
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close".localized, style: .plain,
                                                               target: self, action: #selector(cancelTapped(_:)))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized, style: .plain,
                                                                target: self, action: #selector(saveTapped))
        } else {
            identifiers.append(.actionCell)
            navigationItem.title = "\(mode.rawValue.capitalized) Details".localized
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                                style: .plain, target: self, action: #selector(optionsTapped(_:)))
            if onlyBookmarked {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close".localized, style: .plain,
                                                                   target: self, action: #selector(cancelTapped(_:)))
            }
        }
        
        collectionView.collectionViewLayout = createLayout()
        
        for cell in cells {
            collectionView.register(cell.value, forCellWithReuseIdentifier: cell.value.reuseIdentifier)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bookmarkDidChange), name: Recent.bookmarkDidChange, object: recent)
        NotificationCenter.default.addObserver(self, selector: #selector(addressDidChange), name: Location.addressDidChange, object: recent.location)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        delegate?.getDetails(for: recent.prediction) { details in
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Recent.bookmarkDidChange, object: recent)
        NotificationCenter.default.removeObserver(self, name: Location.addressDidChange, object: recent?.location)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            switch self.identifiers[sectionIndex] {
            case .infoCell, .actionCell:
                return self.createListLayout(layoutEnvironment)
            case .mapCell:
                return self.createDefaultLayout(withAspectRatio: 1, for: layoutEnvironment)
            default:
                return self.createDefaultLayout(withAspectRatio: 0.625, for: layoutEnvironment)
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 30
        layout.configuration = config
        
        return layout
    }
    
    func createDefaultLayout(withAspectRatio aspectRatio: Double, for layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let width = NSCollectionLayoutDimension.fractionalWidth(1)
        var height = NSCollectionLayoutDimension.fractionalWidth(CGFloat(aspectRatio))
        var padding: CGFloat = 10
        
        if layoutEnvironment.traitCollection.horizontalSizeClass == layoutEnvironment.traitCollection.verticalSizeClass {
            height = NSCollectionLayoutDimension.fractionalWidth(CGFloat(0.6 * aspectRatio))
            padding = NSCollectionLayoutDimension.fractionalWidth(0.2).dimension
        }
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [layoutItem])
        layoutGroup.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: padding, bottom: 0, trailing: padding)
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        
        return layoutSection
    }
    
    func createListLayout(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var width: CGFloat = 0.85
        var padding: CGFloat = 10
        var itemPadding: CGFloat = 5
        
        if layoutEnvironment.traitCollection.horizontalSizeClass == layoutEnvironment.traitCollection.verticalSizeClass {
            width = 0.51
            padding = NSCollectionLayoutDimension.fractionalWidth(0.245).dimension
            itemPadding = 15
        }
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: itemPadding, bottom: 0, trailing: itemPadding)
        
        let groupWidth = layoutEnvironment.container.contentSize.width * width
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(groupWidth), heightDimension: .absolute(220))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        let sectionSideInset = (layoutEnvironment.container.contentSize.width - groupWidth) / 2
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sectionSideInset, bottom: 0, trailing: sectionSideInset)
        layoutSection.orthogonalScrollingBehavior = .groupPaging
        //        layoutSection.decorationItems = [NSCollectionLayoutDecorationItem.background(elementKind: "Card Background")]
        
        return layoutSection
    }
    
    @objc func cancelTapped(_ sender: UIBarButtonItem) {
        if onlyBookmarked {
            self.dismiss(animated: true)
        }
        
        let alertController = UIAlertController(title: "Are you sure?".localized, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Save".localized, style: .default) { _ in
            self.saveTapped()
        })
        alertController.addAction(UIAlertAction(title: "Discard".localized, style: .destructive) { _ in
            alertController.dismiss(animated: true)
            self.dismiss(animated: true)
        })
        alertController.addAction(UIAlertAction(title: "Close".localized, style: .cancel))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        self.present(alertController, animated: true)
    }
    
    @objc func saveTapped() {
        self.dismiss(animated: true)
        delegate?.save(recent: recent)
    }
    
    @objc func optionsTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Options".localized, message: nil, preferredStyle: .actionSheet)
        for action in ActionCell.actions {
            var title = action.rawValue.localized
            var style = UIAlertAction.Style.default
                
            if action == .bookmark {
                title = "\((recent.bookmarked) ? "Remove from" : "Add to") Bookmarks".localized
            } else if action == .delete {
                style = .destructive
            }
            
            alertController.addAction(UIAlertAction(title: title,
                                                    style: style,
                                                    handler: { _ in
                                                        if(action == .delete) { self.dismissView() }
                                                        self.delegate?.performed(action: action, on: self.recent)
                                                        
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        self.present(alertController, animated: true)
    }
    
    func reload(cellAtIndexPath indexPath: IndexPath?) {
        guard let indexPath = indexPath,
            let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            cell.alpha = 0
        }) { (completed) in
            (cell as? SelfConfiguringPredictionCell)?.configure(with: self.recent, for: indexPath)
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                cell.alpha = 1
            })
        }
    }
    
    @objc func bookmarkDidChange() {
        guard let section = identifiers.firstIndex(of: .actionCell),
            let row = ActionCell.actions.firstIndex(of: .bookmark)  else {
            return
        }
        
        reload(cellAtIndexPath: IndexPath(row: row, section: section))
    }
    
    @objc func addressDidChange() {
        guard let section = identifiers.firstIndex(of: .infoCell)  else {
            return
        }
        
        reload(cellAtIndexPath: IndexPath(row: 4, section: section))
    }
    
    func dismissView() {
        print("\(Date()) \(URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent).\(#function)")
        if(splitViewController?.isDetailsVisible ?? false) {
            splitViewController?.showDetailViewController(storyboard!.instantiateViewController(identifier: "Empty Detail"), sender: self)
        } else {
            navigationController?.navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Show Image":
            let destVC = segue.destination as! ImageViewController
            destVC.image = recent.prediction.image!
        
        case "Show Map":
            let destVC = segue.destination as! MapViewController
            destVC.location = recent.location!
            
        default:
            break
        }
    }
    
}

extension DetailViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        identifiers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch identifiers[section] {
        case .infoCell:
            return 5
        case .actionCell:
            return ActionCell.actions.count
        default:
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cells[identifiers[indexPath.section]]!.reuseIdentifier,
                                                      for: indexPath) as! SelfConfiguringPredictionCell
        
        cell.configure(with: recent, for: indexPath)
        
        switch identifiers[indexPath.section] {
        case .mapCell:
            (cell as! MapCell).mapView.isUserInteractionEnabled = splitViewController?.isDetailsVisible ?? false
        default:
            break
        }
        
        return cell as! UICollectionViewCell
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        switch identifiers[indexPath.section] {
        case .imageCell:
            if(!(splitViewController?.isDetailsVisible ?? false)) {
                performSegue(withIdentifier: "Show Image", sender: indexPath)
            }
            
        case .mapCell:
            if(!(splitViewController?.isDetailsVisible ?? false)) {
                performSegue(withIdentifier: "Show Map", sender: indexPath)
            }
            
        case .actionCell:
            animate(cell: cell)
            if(ActionCell.actions[indexPath.row] == .delete) {
                print("\(Date()) \(URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent).\(#function)")
                dismissView()
                
            }
            delegate?.performed(action: ActionCell.actions[indexPath.row], on: recent)
        default:
            break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! SelfConfiguringPredictionCell).deconfigure()
    }
    
    func animate(cell: UICollectionViewCell?) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            cell?.backgroundColor = .listCellSelectedBackground
        }) { (completed) in
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                cell?.backgroundColor = .systemBackground
            })
        }
    }
    
}
