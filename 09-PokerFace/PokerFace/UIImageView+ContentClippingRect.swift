//
//  UIImageView+ContentClippingRect.swift
//  PokerFace
//
//  Created by Juan Gabriel Gomila Salas on 7/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit

extension UIImageView {
    
    var contentClippingRect: CGRect {
        guard let image = image, contentMode == .scaleAspectFit else { return bounds }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        guard imageWidth > 0 && imageHeight > 0 else { return bounds}
        
        let scale: CGFloat
        if imageWidth > imageHeight {
            scale = bounds.size.width / imageWidth
        } else {
            scale = bounds.size.height / imageHeight
        }
        
        let clippingSize = CGSize(width: imageWidth * scale, height: imageHeight * scale)
        let x = (bounds.size.width - clippingSize.width) / 2.0
        let y = (bounds.size.height - clippingSize.height) / 2.0
        
        return CGRect(origin: CGPoint(x:x, y:y), size: clippingSize)
    }
    

    
}
