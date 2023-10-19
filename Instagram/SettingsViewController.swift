//
//  SettingsViewController.swift
//  Instagram
//
//  Created by Atakan Başaran on 13.09.2023.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var userLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLabel.text = Auth.auth().currentUser?.email
        overrideUserInterfaceStyle = .light


    }
    
    @IBAction func LogOutButton(_ sender: Any) {
        
        do {
            try Auth.auth().signOut() //İlk fonksiyonu yazarken throw gördük bu hata göster demek ve do catch yöntemiyle yap demek, sign out functionu
            performSegue(withIdentifier: "toVC", sender: nil) //Çıkış yaptıktan sonra sign ekranına dön
        } catch {
            print("Error!")
        }
    }
    
    
    
   

}
