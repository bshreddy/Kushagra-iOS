//
//  ImageViewController.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 22/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var zoomed = false
    var hidden = false
    
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        
        let tapRecog = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapRecog.numberOfTapsRequired = 1
        tapRecog.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tapRecog)
        
        let doubleTapRecog = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapRecog.numberOfTapsRequired = 2
        doubleTapRecog.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecog)
        
        tapRecog.require(toFail: doubleTapRecog)
        
        scrollView.delegate = self
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.contentSize = image.size
        scrollView.contentSize = image.size
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if(!hidden) {
            tapped()
        }
    }
    
    @objc func tapped() {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.navigationController?.navigationBar.isHidden.toggle()
            self.navigationController?.navigationController?.navigationBar.isHidden.toggle()
            self.tabBarController?.tabBar.isHidden.toggle()
            self.view.backgroundColor = (self.hidden) ? .systemBackground : .black
            self.hidden.toggle()
       })
    }
    
    @objc func doubleTapped() {
        if(!hidden) {
            tapped()
        }
        
        scrollView.setZoomScale((zoomed) ? scrollView.minimumZoomScale : scrollView.maximumZoomScale, animated: true)
        zoomed.toggle()
    }
    
}
