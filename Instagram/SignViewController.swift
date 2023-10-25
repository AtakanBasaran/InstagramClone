//
//  ViewController.swift
//  Instagram
//
//  Created by Atakan Başaran on 13.09.2023.
//

import UIKit
import Firebase

class SignViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light //always light mode use
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func SignInButton(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authdataresult, error in
                
                if error != nil {
                    self.ErrorMessage(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error Please Try Again!") //Hata alırsak firebaseden gelen mesajı göster
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        } else {
            ErrorMessage(titleInput: "Error!", messageInput: "Please Enter Email and Password!")
        }    
    }
    
    
    @IBAction func SignUpButton(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authdataresult, error in
                if error != nil {
                    self.ErrorMessage(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error, Please Try Again!")
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        } else {
            ErrorMessage(titleInput: "Error!", messageInput: "Please Enter Email and Password")
        }
    }
    
    
    func ErrorMessage(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}

