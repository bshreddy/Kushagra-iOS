//
//  ProfileViewController.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 01/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ProfileViewController: UICollectionViewController {
    
    enum Identifier: Int {
        case userCell
        case bookmarksCell
        case serverAddrCell
        case settingsCell
        case helpCell
        case tellCell
        case signOutCell
    }
    
    private let defaultCell = UITableViewCell() //(style: .default, reuseIdentifier: defaultCellIdentifier)
    private var identifiers: [[Identifier]] = [[.userCell],
                                               [.bookmarksCell],
                                               [.settingsCell],
                                               [.helpCell, .tellCell],
                                               [.signOutCell]]
    var cells: [Identifier: (UICollectionViewCell & SelfConfiguringProfileCell).Type] = [.userCell: UserProfileCell.self]
    
    var user: User?
    var authUI: FUIAuth!
    var authStateHandle: AuthStateDidChangeListenerHandle?

    @IBOutlet weak var signOutBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            identifiers[2].insert(.serverAddrCell, at: 0)
        #endif
        
        authUI = (UIApplication.shared.delegate as! AppDelegate).authUI
        addAuthObserver()
        
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.register(UserProfileCell.self, forCellWithReuseIdentifier: UserProfileCell.reuseIdentifier)
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addAuthObserver), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAuthObserver), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            var itemHeight = NSCollectionLayoutDimension.absolute(44)
            var groupHeight = NSCollectionLayoutDimension.estimated(88)
            
            if(self.identifiers[sectionIndex][0] == .userCell) {
                itemHeight = .absolute(88)
                groupHeight = .absolute(88)
            }
            
            var padding: CGFloat = 10
            
            if layoutEnvironment.traitCollection.horizontalSizeClass == layoutEnvironment.traitCollection.verticalSizeClass {
                padding = NSCollectionLayoutDimension.fractionalWidth(0.3).dimension
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: itemHeight)
            let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: groupHeight)
            let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [layoutItem])
            layoutGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: padding)
            
            let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
            return layoutSection
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 30
        layout.configuration = config
        
        return layout
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        if let _ = user {
            try? authUI.signOut()
        } else {
            self.present(self.authUI.authViewController(), animated: true)
        }
    }
    
    @objc func addAuthObserver() {
        guard authStateHandle == nil else { return }
        print("\(Date()) \(URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent).\(#function)")
        
        authStateHandle = authUI.auth?.addStateDidChangeListener { [unowned self] (auth, user) in
            if let user = user {
                self.user = user
            } else {
                self.user = nil
                self.present(self.authUI.authViewController(), animated: true)
            }
            
            self.collectionView.reloadData()
            
            self.signOutBtn.title = (user == nil) ? "Sign In" : "Sign Out"
            self.signOutBtn.tintColor = (user == nil) ? .systemBlue : .systemRed
        }
    }
    
    @objc func removeAuthObserver() {
        if let _ = authStateHandle {
            print("\(Date()) \(URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent).\(#function)")
            
            authUI.auth?.removeStateDidChangeListener(authStateHandle!)
            authStateHandle = nil
        }
    }
    
}

extension ProfileViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        identifiers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return identifiers[section].count
        5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: (indexPath.section == 0) ? UserProfileCell.reuseIdentifier: ProfileCell.reuseIdentifier, for: indexPath) as! SelfConfiguringProfileCell
        
        cell.configure(for: user, with: identifiers[indexPath])
        
        return cell as! UICollectionViewCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! SelfConfiguringProfileCell).deconfigure()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        animate(cell: collectionView.cellForItem(at: indexPath))
        
        switch identifiers[indexPath] {
        case .bookmarksCell:
             break
//            let vc = UIStoryboard(name: "Prediction", bundle: .main).instantiateViewController(withIdentifier: "HomeView") as! HomeViewController
//            vc.onlyBookmarked = true
//            navigationController?.pushViewController(vc, animated: true)
            
        case .serverAddrCell:
            let alert = UIAlertController(title: "Server Address",
                                          message: "Enter address of AI Inference Server",
                                          preferredStyle: .alert)
            alert.addTextField() { textField in
                textField.text = ServerURL.absoluteString
                textField.textContentType = .URL
            }
            alert.addAction(UIAlertAction(title: "Save", style: .default) {_ in
                ServerURL = URL(string: alert.textFields!.first!.text!)!
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
            
        case .settingsCell:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        
        case .helpCell:
            break
//            performSegue(withIdentifier: "Show Help", sender: indexPath)
            
        case .tellCell:
            let message = "Hey,\n\nCrop Prediction App is an AI-powered, intuitive app that I use to identify my crops, " +
                "crop diseases and get solutions.\n\nGet it for free at <App store URL>"
            let shareController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            
            if let popoverController = shareController.popoverPresentationController {
                popoverController.sourceView = collectionView.cellForItem(at: indexPath)
            }
            
            self.present(shareController, animated: true)
            
        case .signOutCell:
            signOutTapped(indexPath)
            
        default:
            break
        }
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
