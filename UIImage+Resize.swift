//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Gustavo Quenca on 09/06/18.
//  Copyright © 2018 Quenca. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    // This method first calculates how big the image should be in order to fit inside the bounds rectangle. It uses the “aspect fit” approach to keep the aspect ratio intact
    func resized(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
    }
}
