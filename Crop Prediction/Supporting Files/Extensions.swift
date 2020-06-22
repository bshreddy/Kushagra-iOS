//
//  Extensions.swift
//  Crop Prediction
//
//  Created by Sai Hemanth Bheemreddy on 05/04/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation
import UIKit

func showErrorDialog(title: String = "An Error Occurred", message: String, presentingVC vc: UIViewController) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        vc.present(alert, animated: true)
    }
}

extension String {
    
    init?(format: String, _ double: Double?) {
        guard let double = double else {
            return nil
        }
        
        self.init(format: format, double)
    }
    
}

extension Bundle {
    
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in Bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from Bundle")
        }
        
        guard let obj = try? JSONDecoder().decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from Bundle")
        }
        
        return obj
    }
    
}

extension Array where Element: Collection, Element.Index == Int {
    
    subscript(_ indexPath: IndexPath) -> Element.Iterator.Element {
        self[indexPath.section][indexPath.row]
    }
    
}

extension UIActivityIndicatorView {
    
    static var `default`: UIActivityIndicatorView = {
        var spinner: UIActivityIndicatorView
        
        if #available(iOS 13.0, *) {
            spinner = UIActivityIndicatorView(style: .large)
        } else {
            spinner = UIActivityIndicatorView(style: .whiteLarge)
        }
        
        spinner.color = UIColor.white
        spinner.backgroundColor = .spinnerBackground
        spinner.hidesWhenStopped = true
        spinner.layer.cornerRadius = 20
        spinner.layer.masksToBounds = true
        
        return spinner
    }()
    
    func constraintToCenter(of view: UIView) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: 72).isActive = true
        heightAnchor.constraint(equalToConstant: 72).isActive = true
    }
    
}

extension UIColor {
    
    static var defaultTableViewBackground = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
    static var defaultCellViewBackground = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
    
    static var cardBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                (trait.userInterfaceStyle == .light) ? .white : defaultCellViewBackground
            })
        } else {
            return .white
        }
    }
    
    static var tableViewBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                (trait.userInterfaceStyle == .light) ?
                    defaultTableViewBackground : .black
            })
        } else {
            return defaultTableViewBackground
        }
    }
    
    static var listCellSelectedBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                (trait.userInterfaceStyle == .light) ?
                    UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1) : UIColor(red: 0.23, green: 0.23, blue: 0.24, alpha: 1)
            })
        } else {
            return UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1)
        }
    }
    
    static var tableViewCellBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                (trait.userInterfaceStyle == .light) ?
                .white : defaultCellViewBackground
            })
        } else {
            return .white
        }
    }
    
    static var userDPColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                (trait.userInterfaceStyle == .light) ? .black : .white
            })
        } else {
            return .black
        }
    }
    
    static var spinnerBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: { trait in
                (trait.userInterfaceStyle == .light) ? UIColor(red: 0, green: 0, blue: 0, alpha: 0.8) : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
            })
        } else {
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        }
    }
    
}

extension FileManager {
    
    func clearTempDirectory() {
        do {
            if let tempDir = Recent.reportTempDirectory {
                let tempFiles = try contentsOfDirectory(atPath: tempDir.path)
                
                try tempFiles.forEach { filePath in
                    try removeItem(at: tempDir.appendingPathComponent(filePath))
                }
            }
        } catch {
            print(error)
        }
    }
    
}

extension UICollectionViewCell {
    
    func getImageAspect(for rect: CGSize?, min minVal: Float = 0, max maxVal: Float = Float.infinity, default defVal: Float = 0.5) -> CGFloat {
        if let rect = rect {
            return CGFloat(max(min((rect.height) / (rect.width), CGFloat(maxVal)), CGFloat(minVal)))
        }
        
        return CGFloat(defVal)
    }
    
}

extension UISplitViewController {
    
    var isDetailsVisible: Bool {
        viewControllers.count == 2
    }
    
}
