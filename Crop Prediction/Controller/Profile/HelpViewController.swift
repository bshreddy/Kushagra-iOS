//
//  HelpViewController.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 22/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit
import WebKit

class HelpViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    private var spinner: UIActivityIndicatorView!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        spinner = UIActivityIndicatorView.default
        spinner.constraintToCenter(of: view)
        cancelBtn.title = "Cancel".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        spinner.startAnimating()
        webView.load(URLRequest(url:URL(string:"https://firebasestorage.googleapis.com/v0/b/rurathon-cvr-2019.appspot.com/o/docs%2Findex.html?alt=media&token=de3d6e96-6c80-4ddc-a900-ca2a7033be30")!))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
