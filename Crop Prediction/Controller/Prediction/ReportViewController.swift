//
//  ReportViewController.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 22/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import UIKit
import PDFKit
import WebKit

class ReportViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var exportBtn: UIBarButtonItem!
    private var spinner: UIActivityIndicatorView!
    
    var data: (recent: Recent, cropDetails: CropDetails?)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSpinner()
        
        webView.backgroundColor = .tableViewBackground
        webView.navigationDelegate = self
        
        pdfView.autoScales = true
        
        if(splitViewController?.isDetailsVisible ?? false) {
            pdfView.maxScaleFactor = 4.0
            pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        spinner.startAnimating()
        
        ReportRenderer.renderHTML(data.recent, data.cropDetails) { html in
            DispatchQueue.main.async {
                self.webView.loadHTMLString(html, baseURL: nil)
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func exportBtnTapped(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-mm-yyyy_HH-mm"
        if let fileURL = Recent.reportTempDirectory?.appendingPathComponent("Report--\(dateFormatter.string(from: Date())).pdf"),
            let document = pdfView.document {
            FileManager.default.createFile(atPath: fileURL.path, contents: document.dataRepresentation(), attributes: nil)

            let shareController = UIActivityViewController(activityItems: [fileURL],
                                                           applicationActivities: nil)
            
            if let popoverController = shareController.popoverPresentationController {
                popoverController.barButtonItem = sender
            }
            
            self.present(shareController, animated: true)
        } else {
//            TODO: Show user report
            print("Error while displaying report")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        exportBtn.isEnabled = true
        spinner.stopAnimating()
        
        pdfView.document = ReportRenderer.renderPDF(webView: webView)
    }
    
    fileprivate func setupSpinner() {
        spinner = UIActivityIndicatorView.default
        spinner.constraintToCenter(of: view)
    }
    
}
