//
//  ReportRenderer.swift
//  Kushagra
//
//  Created by Sai Hemanth Bheemreddy on 22/06/20.
//  Copyright © 2020 Sai Hemanth Bheemreddy. All rights reserved.
//

import Foundation
import UIKit
import PDFKit
import WebKit

class ReportRenderer: UIPrintPageRenderer {
    
    fileprivate static let htmlTemplatePath = Bundle.main.path(forResource: "report", ofType: "html")!
    static let size = CGSize(width: 595, height: 842)
    static let pageFrame = CGRect(origin: .zero, size: size)
    
    override init() {
        super.init()
        
        self.setValue(ReportRenderer.pageFrame, forKey: "paperRect")
        self.setValue(ReportRenderer.pageFrame.insetBy(dx: 10, dy: 10), forKey: "printableRect")
    }
    
    fileprivate static func getMapImage(_ location: Location?) -> UIImage? {
        guard let location = location else { return nil}
        
        let semaphore = DispatchSemaphore(value: 0)
        var mapImage: UIImage? = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            location.getMapAsImage { snapshot, error in
                mapImage = snapshot?.image
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        
        return mapImage
    }
    
    static func renderHTML(_ recent: Recent, _ cropDetails: CropDetails?, withCompletion completionHandler: @escaping (_ html: String) -> Void){
        do {
            let prediction = recent.prediction
            let location = recent.location
            
            let cropImage = recent.prediction.image ?? UIImage(named: recent.prediction.predictedClass) ?? UIImage(named: "cotton")!
            
            var HTMLContent = try String(contentsOfFile: ReportRenderer.htmlTemplatePath)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CROP_IMAGE#",
                                                           with: "data:image/png;base64,\(cropImage.pngData()!.base64EncodedString())")
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NAME#", with: prediction.predictedName)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LAT#", with: location?.latString ?? "N/A")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LONG#", with: location?.longString ?? "N/A")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ALT#", with: location?.altString ?? "N/A")
            
            if let cropDetails = cropDetails {
                let detailsString = cropDetails.getInfoCellData()
                    .map { "<dt>\($0.title)</dt><dd>\($0.subtitle ?? "N/A")</dd>" }.joined(separator: "\n")
                HTMLContent = HTMLContent.replacingOccurrences(of: "#CROP_DETAILS#", with: detailsString)
            } else {
                HTMLContent = HTMLContent.replacingOccurrences(of: "#CROP_DETAILS#", with: "<h2>Details are Not Available</h2>")
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DATE#", with: dateFormatter.string(from: Date()))
            
            if let location = location {
                location.getMapAsImage { snapshot, error in
                    let mapImage = snapshot?.image ?? UIImage(named: "default-map")!
                    
                    HTMLContent = HTMLContent.replacingOccurrences(of: "#MAP_IMAGE#",
                                                                   with: "data:image/png;base64,\(mapImage.pngData()!.base64EncodedString())")
                    
                    completionHandler(HTMLContent)
                }
            } else {
                let mapImage = UIImage(named: "default-map")!
                HTMLContent = HTMLContent.replacingOccurrences(of: "#MAP_IMAGE#",
                                                               with: "data:image/png;base64,\(mapImage.pngData()!.base64EncodedString())")
                completionHandler(HTMLContent)
            }
            
        } catch {
            print("Error while rendering PDF")
        }
    }
    
    static func renderPDF(webView: WKWebView) -> PDFDocument? {
        let reportRenderer = ReportRenderer()
        let printFormatter = webView.viewPrintFormatter()
            
        reportRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        let data = NSMutableData()

        UIGraphicsBeginPDFContextToData(data, ReportRenderer.pageFrame, nil)
        UIGraphicsBeginPDFPage()
        reportRenderer.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())

        reportRenderer.drawFooterForPage(at: 0, in: UIGraphicsGetPDFContextBounds())
        UIGraphicsEndPDFContext()
            
        return PDFDocument(data: data as Data)
    }
    
}
