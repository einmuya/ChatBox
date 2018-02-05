//
//  ViewController.swift
//  ChatBox
//
//  Created by Edward Muya on 04/02/2018.
//  Copyright © 2018 com.einmuya. All rights reserved.
//

import UIKit

extension UIViewController {
    // alert message
    func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
