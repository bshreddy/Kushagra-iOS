//
//  MasterViewController.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 01/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseStorage
import CoreLocation

class MasterViewController: UICollectionViewController {
    
//    MARK: Class Variables
    private var imagePicker: UIImagePickerController!
    private var spinner: UIActivityIndicatorView!
    private var refreshControl: UIRefreshControl!
    private var locationManager: CLLocationManager?
    
    var mode: Prediction.Kind!
    var onlyBookmarked = false
    
    var user: User?
    var authUI: FUIAuth!
    var authStateHandle: AuthStateDidChangeListenerHandle?
    var detailsRef: CollectionReference?
    var recentsRef: CollectionReference?
    var recentImagesRef: StorageReference?
    
//    MARK: Model Variables
    var recents = [Recent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMode()
        setupFirebase()
        setupLocation()
        setupRefreshControl()
        setupSpinner()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if onlyBookmarked {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close".localized, style: .plain,
                                                               target: self, action: #selector(cancelTapped(_:)))
        }
        
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(RecentCell.self, forCellWithReuseIdentifier: RecentCell.reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addAuthObserver), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAuthObserver), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    fileprivate func setMode() {
        if onlyBookmarked {
            navigationItem.rightBarButtonItem = .none
            navigationItem.title = "Bookmarks".localized
            return
        }
        
        switch tabBarController?.selectedIndex {
        case 0:
            mode = .crop
            navigationItem.title = "Your Crops".localized
        case 1:
            mode = .disease
            navigationItem.title = "Crop Diseases".localized
        default:
            break
        }
    }
    
    fileprivate func setupFirebase() {
        authUI = (UIApplication.shared.delegate as! AppDelegate).authUI
        detailsRef = (UIApplication.shared.delegate as! AppDelegate).firestore.collection("details")
        
        addAuthObserver()
    }
    
    fileprivate func setupLocation() {
        locationManager = CLLocationManager()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
        
        locationManager?.delegate = self
    }
    
    fileprivate func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
    }
    
    fileprivate func setupSpinner() {
        spinner = UIActivityIndicatorView.default
        spinner.constraintToCenter(of: splitViewController?.view ?? view)
    }
    
    fileprivate func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            var width = NSCollectionLayoutDimension.fractionalWidth(1)
            var height = NSCollectionLayoutDimension.fractionalWidth(0.625)
            
//            For non-plus iPhones in landscape and for bookmarks
            if (layoutEnvironment.traitCollection.verticalSizeClass == .compact && layoutEnvironment.traitCollection.horizontalSizeClass == .compact)
                || (self.onlyBookmarked && layoutEnvironment.traitCollection.horizontalSizeClass == .regular) {
                width = .fractionalWidth(0.5)
                height = .fractionalWidth(0.3125)
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: .fractionalHeight(1))
            
            let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
            layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            
            let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height)
            let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
            
            let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
            layoutSection.interGroupSpacing = 20
            layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 16, trailing: 0)
            
            return layoutSection
        }
        
        return layout
    }
    
    @objc func cancelTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func addAuthObserver() {
        guard authStateHandle == nil else { return }
        print("\(Date()) \(URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent).\(#function)")
        
        authStateHandle = authUI.auth?.addStateDidChangeListener { [unowned self] (auth, user) in
            self.user = user
            
            if let user = user {
                self.recentsRef = (UIApplication.shared.delegate as! AppDelegate).firestore.collection("users").document(user.uid).collection("recents")
                self.recentImagesRef = Storage.storage().reference(withPath: "images")
            } else {
                self.recentsRef = nil
                self.recentImagesRef = nil
            }
            
            self.loadData()
        }
    }

    @objc func removeAuthObserver() {
        if let _ = authStateHandle {
            print("\(Date()) \(URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent).\(#function)")
            
            authUI.auth?.removeStateDidChangeListener(authStateHandle!)
            authStateHandle = nil
        }
    }
    
    @objc func loadData() {
//        recents = Bundle.main.decode([Recent].self, from: "TestData.json").filter { $0.prediction.kind == self.mode }
        guard let _ = user, let recentRef = recentsRef else {
            recents.removeAll()
            collectionView.reloadData()
            return
        }
        
        if !refreshControl.isRefreshing {
            spinner.startAnimating()
        }
        
        let query = (onlyBookmarked) ?
            recentRef.whereField(Recent.CodingKeys.bookmarked.rawValue, isEqualTo: true) :
            recentRef.whereField(FieldPath([Recent.CodingKeys.prediction.rawValue, Prediction.CodingKeys.kind.rawValue]), isEqualTo: mode.rawValue)
        
        query.order(by: Recent.CodingKeys.createdAt.rawValue, descending: true)
        .getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                showErrorDialog(message: error?.localizedDescription ?? "An Unknown Error Occurred".localized, presentingVC: self)
                return
            }
            
            var recents = [Recent]()
            
            for document in snapshot.documents {
                let id = document.documentID
                
                if let data = try? JSONSerialization.data(withJSONObject: document.data()),
                    let recent = try? JSONDecoder().decode(Recent.self, from: data) {
                    recent.id = id
                    recents.append(recent)
                } else {
                    showErrorDialog(message: "Unable to Read Data.\nError while Parsing Data".localized, presentingVC: self)
                }
            }
            
            self.recents = recents
            self.collectionView.reloadSections(IndexSet(integer: 0))
                
            self.spinner.stopAnimating()
            self.refreshControl.endRefreshing()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Show Detail":
            let destVC = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            destVC.delegate = self
            destVC.recent = sender as! Recent
            destVC.mode = destVC.recent.prediction.kind
            destVC.onlyBookmarked = onlyBookmarked
        
        case "New Detection":
            let destVC = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            destVC.delegate = self
            destVC.recent = sender as! Recent
            destVC.mode = mode
            destVC.isNew = true
            
        default:
            break
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let actionSheet = UIAlertController(title: "Select an Option".localized, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Camera".localized, style: .default) { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true)
            })

            actionSheet.addAction(UIAlertAction(title: "Photo Library".localized, style: .default) { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true)
            })

            actionSheet.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
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
        return recents.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCell.reuseIdentifier, for: indexPath) as! RecentCell
        let recent = recents[indexPath.row]
        
        recent.loadImage(user: user!, recentImagesRef: recentImagesRef!)
        cell.configure(with: recent, for: indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! RecentCell).deconfigure()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Detail", sender: recents[indexPath.row])
    }
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let recent = self.recents[indexPath.row]
            var children = [UIAction]()
            
            for action in ActionCell.actions {
                var title = action.rawValue.localized
                var attributes = UIMenuElement.Attributes()
                var iconName = ActionCell.actionIcons[action]!
                    
                if action == .bookmark {
                    title = "\((recent.bookmarked) ? "Remove from" : "Add to") Bookmarks".localized
                    iconName = "\(ActionCell.actionIcons[action]!)\(((recent.bookmarked) ? ".fill" : ""))"
                } else if action == .delete {
                    attributes = .destructive
                }
                
                children.append(UIAction(title: title, image: UIImage(systemName: iconName),
                                         attributes: attributes, handler: { _ in self.performed(action: action, on: recent) }))
            }
            
            return UIMenu(title: "Available Actions".localized, children: children)
        }
    }
    
}

extension MasterViewController: DetailViewControllerDelegate {
    
    func save(recent: Recent) {
        let prediction = recent.prediction
        let image = prediction.image!
        var errorOccurred = false
        
        guard let user = user,
            let data = try? JSONEncoder().encode(recent),
            let dataDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let imgData = image.pngData(),
            let doc = recentsRef?.document() else {
//                Show User Error
            print("An error occurred while saving")
            return
        }
        
        spinner.startAnimating()
        
        let dispatchGroup = DispatchGroup()
        
        let id = doc.documentID
        let imageName = "\(prediction.predictedClass)/\(user.uid)-\(id).png"
        let imgRef = recentImagesRef?.child(imageName)
        
        dispatchGroup.enter()
        imgRef?.putData(imgData, metadata: nil) { metadata, error in
            if metadata == nil {
                print(error?.localizedDescription ?? "An Unknown Error Occurred")
                errorOccurred = true
            }
            
            dispatchGroup.leave()
        }
        
        do {
            try FileManager.default.createDirectory(at: Recent.picturesDirectory.appendingPathComponent(prediction.predictedClass),
                                                    withIntermediateDirectories: true, attributes: nil)
            FileManager.default.createFile(atPath: Recent.picturesDirectory.appendingPathComponent(imageName).path, contents: imgData, attributes: nil)
        } catch {
            print(error.localizedDescription)
            errorOccurred = true
        }
        
        dispatchGroup.enter()
        doc.setData(dataDict) { error in
            if let error = error {
                print(error.localizedDescription)
                errorOccurred = true
            } else {
                recent.id = id
                self.recents.insert(recent, at: 0)
                self.collectionView.reloadData()
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if(errorOccurred) {
                showErrorDialog(message: "Unable to Save for some unknown reason".localized, presentingVC: self)
            }
            
            self.spinner.stopAnimating()
        }
    }
    
    func performed(action: ActionCell.Action, on recent: Recent) {
        switch action {
        case .bookmark:
            recent.toggleBookmark()
        
        case .exportToPDF:
            exportToPDF(recent: recent)
        
        case .saveImageToPhotos:
            saveImageToPhotos(recent: recent)
        
        case .saveMapToPhotos:
            saveMapToPhotos(recent: recent)
        
        case .delete:
            delete(recent: recent)
        
        default:
            break
        }
    }
    
    func getDetails(for prediction: Prediction, withCompletion completionHandler: @escaping (([String:String]) -> Void)) {
        detailsRef?.document(prediction.predictedClass).getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            print(snapshot.data())
//            JSONSerialization
        }
    }
    
    func exportToPDF(recent: Recent) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ReportViewController") as! ReportViewController
        vc.data = (recent: recent, cropDetails: nil)
        
        if(splitViewController?.isDetailsVisible ?? false) {
            self.present(UINavigationController(rootViewController: vc), animated: true)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func saveImageToPhotos(recent: Recent) {
        if let image = recent.prediction.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            recent.loadImage(user: user!, recentImagesRef: recentImagesRef!) { image in
                guard let image = image else {
//                TODO: Show User error message
                    print("An Unknown Error Occurred")
                    return
                }
                
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
    
    func saveMapToPhotos(recent: Recent) {
        spinner.startAnimating()
        
        if let location = recent.location {
            location.getMapAsImage { snapshot, error in
                self.spinner.stopAnimating()
                
                if let image = snapshot?.image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                } else {
//                    TODO: Show user error message
                    print(error?.localizedDescription ?? "An Unknown Error Occurred")
                }
            }
        }
    }
    
    func delete(recent: Recent) {
        guard let user = user,
            let id = recent.id,
            let doc = recentsRef?.document(id),
            let index = recents.firstIndex(where: {$0.id == recent.id}) else {
                showErrorDialog(message: "Unable to Delete for some unknown reason".localized, presentingVC: self)
            return
        }
        
        spinner.startAnimating()
        
        doc.delete { error in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
            
            if error != nil {
                showErrorDialog(message: "Unable to Delete for some unknown reason".localized, presentingVC: self)
                return
            } else {
                do {
                    let imageName = "\(recent.prediction.predictedClass)/\(user.uid)-\(id).png"
                    try FileManager.default.removeItem(at: Recent.picturesDirectory.appendingPathComponent(imageName))
                } catch {
                    print(error.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    self.recents.remove(at: index)
                    self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                }
            }
        }
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            showErrorDialog(message: error.localizedDescription, presentingVC: self)
        }
    }
    
}

// MARK: UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension MasterViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true)
        
        spinner.startAnimating()
        
        let image = info[.originalImage] as! UIImage
        let location = locationManager?.location
        
        Prediction.predict(kindOf: mode, from: image) { prediction in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }

            guard let prediction = prediction else {
                print("An Unknown Error Occurred")
                return
            }

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "New Detection", sender: Recent(prediction, location: Location(location)))
            }
        }
        
//        self.performSegue(withIdentifier: "New Detection", sender: nil)
    }
    
}

// MARK: CLLocationManagerDelegate
extension MasterViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            locationManager?.requestWhenInUseAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
    }
    
}
