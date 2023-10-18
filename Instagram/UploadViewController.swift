//
//  UploadViewController.swift
//  Instagram
//
//  Created by Atakan Başaran on 13.09.2023.
//

import UIKit
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import ImageSlideshow

class UploadViewController: UIViewController, PHPickerViewControllerDelegate{
    
    @IBOutlet weak var CommentTextField: UITextField!
    @IBOutlet weak var ButtonUpload: UIButton!
    
    var imageArray = [UIImage]()
    var imageUrlArray = [String]()
    var inputSources: [InputSource] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ButtonUpload.isEnabled = false
        
        let gestureRecognizerKey = UITapGestureRecognizer(target: self, action: #selector(CloseKeyboard))
        view.addGestureRecognizer(gestureRecognizerKey)
    }
    
    @objc func CloseKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func UploadButton(_ sender: Any) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")
        let dispatchGroup = DispatchGroup()

        
        for image in imageArray {
            if let dataImage = image.jpegData(compressionQuality: 0.5) {
                let uuid = UUID().uuidString
                let imageRef = mediaFolder.child("\(uuid).jpg")

                dispatchGroup.enter()

                imageRef.putData(dataImage, metadata: nil) { _, error in
                    if error == nil {
                        imageRef.downloadURL { url, error in
                            if error == nil, let imageUrl = url?.absoluteString {
                                print(imageUrl)
                                self.imageUrlArray.append(imageUrl)
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            // This block will be called when all asynchronous tasks are completed
            print(self.imageUrlArray.count)

            // Continue with Firestore upload
            self.uploadToFirestore()
        }
    }

    func uploadToFirestore() {
        let firestoreDatabase = Firestore.firestore()
        let firestorePost = ["ImageUrlArray": self.imageUrlArray, "Comment": self.CommentTextField.text, "Email": Auth.auth().currentUser!.email, "Date": FieldValue.serverTimestamp(), "Likes": 0] as [String: Any]

        firestoreDatabase.collection("Post").addDocument(data: firestorePost) { error in
            if error != nil {
                self.ErrorMessage(titleIn: "Error!", messageIn: error?.localizedDescription ?? "Error!, Try Again Later")
            } else {
                self.imageUrlArray.removeAll(keepingCapacity: false)
                self.imageArray.removeAll(keepingCapacity: false)
                self.inputSources.removeAll(keepingCapacity: false)
                self.CommentTextField.text = ""
                self.ButtonUpload.isEnabled = false
                self.tabBarController?.selectedIndex = 0
                
            }
        }
    }

    
    func ErrorMessage(titleIn: String, messageIn: String) {
        let alert = UIAlertController(title: titleIn, message: messageIn, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectImageButton(_ sender: Any) {
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true)

    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true, completion: nil)
        ButtonUpload.isEnabled = true

        let dispatchGroup = DispatchGroup()
        

        imageArray.removeAll(keepingCapacity: false)
        inputSources.removeAll(keepingCapacity: false)
        
        for result in results {
            dispatchGroup.enter()

            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                defer {
                    dispatchGroup.leave()
                }

                if let error = error {
                    self.ErrorMessage(titleIn: "Error!", messageIn: error.localizedDescription)
                } else {
                    if let image = object as? UIImage {
                        self.imageArray.append(image)
                        let inputSource = ImageSource(image: image)
                        self.inputSources.append(inputSource)
                    }
                }
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            // This block will be called when all asynchronous tasks are completed

            let imageSlideShow = ImageSlideshow(frame: CGRect(x: self.view.frame.width * 0.5 - self.view.frame.width * 0.35, y: self.view.frame.height * 0.08, width: self.view.frame.width * 0.7, height: self.view.frame.height * 0.3))
            imageSlideShow.backgroundColor = UIColor.white

            let pageIndicator = UIPageControl()
            pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
            pageIndicator.pageIndicatorTintColor = UIColor.black
            imageSlideShow.pageIndicator = pageIndicator
            
            
            imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
            imageSlideShow.setImageInputs(self.inputSources)
            self.view.addSubview(imageSlideShow)
            
        }
    }
    
    
    
    




    
  
   
    
    
}
