//
//  LoginViewController.swift
//  ChatBox
//
//  Created by Edward Muya on 04/02/2018.
//  Copyright © 2018 com.einmuya. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var senderNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if senderNameTextField?.text != "" {
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
            })
        } else {
            alertMessage(title: "Chat Alert!", message: "Please enter your chat username")
        }
    }
    
    // Setup chat parameters
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navigationViewController = segue.destination as! UINavigationController
        let chatViewController = navigationViewController.viewControllers.first as! ChatViewController
        
        chatViewController.senderName = senderNameTextField?.text
    }
    
}
