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
    func exportToPDF(recent: Recent)
    func saveImageToPhotos(recent: Recent)
    func saveMapToPhotos(recent: Recent)
    func delete(recent: Recent)
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
    var isPresentedModelly = false
    var mode: Prediction.Kind!
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    var identifiers: [Identifier] = [.imageCell, .infoCell, .mapCell, .actionCell]
    var cells: [Identifier: (UICollectionViewCell & SelfConfiguringPredictionCell).Type] = [.imageCell: ImageCell.self,
                                                                                            .infoCell: DetailsTextCell.self,
                                                                                            .mapCell: MapCell.self,
                                                                                            .actionCell: ActionCell.self]
    
//    MARK: Model Variables
    var recent: Recent!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isPresentedModelly {
            navigationItem.title = "New \(mode.rawValue.capitalized) Detection"
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped(_:)))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        } else {
            navigationItem.title = "\(mode.rawValue.capitalized) Details"
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                                style: .plain, target: self, action: #selector(optionsTapped(_:)))
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
        let alertController = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            self.saveTapped()
        })
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
            alertController.dismiss(animated: true)
            self.dismiss(animated: true)
        })
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel))
        
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
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        for action in ActionCell.actions {
            var title = action.rawValue
            var style = UIAlertAction.Style.default
                
            if action == .bookmark {
                title = "\((recent.bookmarked) ? "Remove from" : "Add to") Bookmarks"
            } else if action == .delete {
                style = .destructive
            }
            
            alertController.addAction(UIAlertAction(title: title,
                                                    style: style,
                                                    handler: { _ in self.action(performed: action)}))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
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
        if(splitViewController?.isDetailsVisible ?? false) {
            navigationController?.navigationController?.popViewController(animated: true)
        } else {
            splitViewController?.showDetailViewController(storyboard!.instantiateViewController(identifier: "Empty Detail"), sender: self)
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
        
        return cell as! UICollectionViewCell
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("\(Date()) \(URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent).\(#function)")
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        switch identifiers[indexPath.section] {
        case .actionCell:
            animate(cell: cell)
            action(performed: ActionCell.actions[indexPath.row])
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
    
    func action(performed action: ActionCell.Action) {
        switch action {
        case .bookmark:
            recent.toggleBookmark()
        
        case .exportToPDF:
            delegate?.exportToPDF(recent: recent)
        
        case .saveImageToPhotos:
            delegate?.saveImageToPhotos(recent: recent)
        
        case .saveMapToPhotos:
            delegate?.saveMapToPhotos(recent: recent)
        
        case .delete:
            dismissView()
            delegate?.delete(recent: recent)
        
        default:
            break
        }
    }
    
}
