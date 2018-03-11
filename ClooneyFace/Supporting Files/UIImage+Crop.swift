//
//  UIImage+Crop.swift
//  ClooneyFace
//
//  Created by Hanief on 10/03/2018.
//  Copyright © 2018 Ruminant Ablutionist. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func crop(rect: CGRect) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef)
        
        return cropped
    }
}

extension CIImage {
    func convertToUIImage() -> UIImage? {
        let context = CIContext(options: nil)
        
        return UIImage(cgImage: context.createCGImage(self, from: self.extent)!)
    }
}
