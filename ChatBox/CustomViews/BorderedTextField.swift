//
//  BorderedTextField.swift
//  ChatBox
//
//  Created by Edward Muya on 05/02/2018.
//  Copyright © 2018 com.einmuya. All rights reserved.
//

import UIKit

class BorderedTextField: UITextField {
    override func awakeFromNib() {
        // cursor blink color
        self.tintColor = .white
        
        self.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedStringKey.foregroundColor: UIColor.cbWhite])
    }
    
    override func draw(_ rect: CGRect) {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
