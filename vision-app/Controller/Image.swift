//
//  Image.swift
//  vision-app
//
//  Created by Jennifer Vilanda Hasler on 9/5/2560 BE.
//  Copyright © 2560 Jennifer Vilanda Hasler. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


extension CALayer {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            self.render(in: rendererContext.cgContext)
        }
    }
}

extension CIImage {
    func toImage() -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(self, from: self.extent)!
        return cgImage.toImage()
    }
}

extension CGImage {
    func toImage(orientation: UIImageOrientation? = nil) -> UIImage
    {
        let image = UIImage(cgImage: self, scale: UIScreen.main.scale, orientation: .right)
        return image
    }
}


