//
//  ViewController.swift
//  Instagram
//
//  Created by Atakan Başaran on 13.09.2023.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    

    @IBAction func SignInButton(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" { //email ve password boş kalmasın
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authdataresult, error in
                
                if error != nil {
                    self.ErrorMessage(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error Please Try Again!") //Hata alırsak firebaseden gelen mesajı göster
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil) //closureların içinde self kullanmalıyız, hata almazsak performsegue yap, dışarda kullansaydık hatadan bağımsız diğer VCye geçicektik
                }
            }
        } else {
            ErrorMessage(titleInput: "Error!", messageInput: "Please Enter Email and Password!")
        }    
    }
    
    
    @IBAction func SignUpButton(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authdataresult, error in //Firebase üzerinden kullanıcı oluşturma, bunu asenkronize şeklinde yapıyoruz sunucudan veri çektiğimiz için, sunucu hata veriyo ya da üyelik oluşturuyo ama cevabın ne zaman gelceğini bilmiyoruz o yüzden bu işlemler cod hızından yavaş olacağı için asenkron yapıyoruz ki arayüz kitlenmesin, kullanıcı işlemlerini yapmaya devam etsin bi yandan ise sunucudan cevap gelince ne yapacığımızı bilebilelim, completion -> tamamlanınca napayım
                if error != nil {
                    self.ErrorMessage(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error, Please Try Again!") //closureların içinde self kullanmalıyız, error?.localizedDescription -> Kullanıcın anlayabilceği dilden gelen firebasein yolladığı hata mesajı, error?.localizedDescription ?? "Error! Please Try Again" -> eğer ilk kısım nil olursa ikinci kısmı yaz default olarak ekstra güvenlik
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        } else {
            ErrorMessage(titleInput: "Error!", messageInput: "Please Enter Email and Password")
        }
    }
    
    
    func ErrorMessage(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert) //alert oluştur, fonksiyonunda init yazılan kısmında ne yazıldıysa onu göstersin
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil) //ok butonu çıksın uyarıdan çıkması için
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil) //completion: nil -> tamamlanınca bi şey yapma, self kullanmamızın sebebi ilerde kullanıcağımız closurelarda karışıklık olmaması için
    }
    
    
    
}

