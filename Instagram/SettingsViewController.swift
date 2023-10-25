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
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toVC", sender: nil) //return sign in page
        } catch {
            print("Error!")
        }
    }
    
    
    
   

}
