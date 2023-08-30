//
//  RoundTextField.swift
//  Tinsnapook
//
//  Created by Juan Gabriel Gomila Salas on 10/7/17.
//  Copyright © 2017 Frogames. All rights reserved.
//

import UIKit

@IBDesignable
class RoundTextField: UITextField {
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = (cornerRadius > 0)
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var bgColor: UIColor? {
        didSet {
            backgroundColor = bgColor
        }
    }
    
    
    @IBInspectable var placeHolderColor: UIColor? {
        didSet {
            let rawString = attributedPlaceholder?.string != nil ? attributedPlaceholder!.string : ""
            let att = NSAttributedString(string:rawString, attributes: [.foregroundColor: placeHolderColor as Any])
            attributedPlaceholder = att
            
        }
    }

}
