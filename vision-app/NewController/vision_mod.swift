//
//  vision_mod.swift
//  vision-app
//
//  Created by Jennifer Vilanda Hasler on 9/11/2560 BE.
//  Copyright © 2560 Jennifer Vilanda Hasler. All rights reserved.
//

import Foundation
import Vision
import UIKit
import TesseractOCR

class vision_mod: NSObject {
    
    override init() {
        
    }
    
    func mixImage(top_image:UIImage, bottom_image:UIImage, top_image_point:CGPoint=CGPoint.zero, isHaveBackground:Bool = true)-> UIImage{
        let bottomImage = bottom_image//self.Camera_Image_View.image
        let newSize = bottomImage.size // set this to what you need
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        if(isHaveBackground==true){
            bottomImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        }
        top_image.draw(in: CGRect(origin: top_image_point, size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
    }
    
}

class Text_Detector: vision_mod, G8TesseractDelegate {
    
    var havBackground:Bool = true;
    init(isDisplayBackground:Bool) {
        havBackground = isDisplayBackground
    }
    lazy internal var tesseract: G8Tesseract = {
        let _tesseract = G8Tesseract(language: "eng")
        _tesseract?.delegate = self
        //_tesseract?.charWhitelist
        //_tesseract?.charBlacklist
        return _tesseract!
    }()
    
   
    func textDetect(dectect_image:UIImage, display_image_view:UIImageView)->UIImage{
        let handler:VNImageRequestHandler = VNImageRequestHandler.init(cgImage: (dectect_image.cgImage)!)
        var result_img:UIImage = UIImage.init();
        
        let request:VNDetectTextRectanglesRequest = VNDetectTextRectanglesRequest.init(completionHandler: { (request, error) in
            if( (error) != nil){
                print("Got Error In Run Text Dectect Request");
                
            }else{
                result_img = self.mixImage(top_image: self.drawRectangleForTextDectect(image: display_image_view.image!,results: request.results as! [VNTextObservation]), bottom_image: dectect_image)
                print(result_img.accessibilityElementCount())

            }
        })
        request.reportCharacterBoxes = true
        do {
            try handler.perform([request])
            return result_img;
            print("Successful Run Text Dectect Request");
        } catch {
            return result_img;
        }
    }
    
    func drawRectangleForTextDectect(image: UIImage, results:Array<VNTextObservation>) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        var t:CGAffineTransform = CGAffineTransform.identity;
        t = t.scaledBy( x: image.size.width, y: -image.size.height);
        t = t.translatedBy(x: 0, y: -1 );
        
        
        
        let img = renderer.image { ctx in
            for item in results {
                let TextObservation:VNTextObservation = item
                ctx.cgContext.setFillColor(UIColor.clear.cgColor)
                ctx.cgContext.setStrokeColor(UIColor.green.cgColor)
                ctx.cgContext.setLineWidth(2)
                ctx.cgContext.addRect(item.boundingBox.applying(t))
                ctx.cgContext.drawPath(using: .fillStroke)
                
//                for item_2 in TextObservation.characterBoxes!{
//                    let RectangleObservation:VNRectangleObservation = item_2
//                    ctx.cgContext.setFillColor(UIColor.clear.cgColor)
//                    ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
//                    ctx.cgContext.setLineWidth(2)
//                    ctx.cgContext.addRect(RectangleObservation.boundingBox.applying(t))
//                    ctx.cgContext.drawPath(using: .fillStroke)
//
//                }
            }
            
        }
        
        return img
        
    }
    
    
}






