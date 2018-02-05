//
//  ButtonRadius.swift
//  ChatBox
//
//  Created by Edward Muya on 05/02/2018.
//  Copyright © 2018 com.einmuya. All rights reserved.
//

import UIKit

class ButtonRadius: UIButton {
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
}
