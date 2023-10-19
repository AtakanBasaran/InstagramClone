//
//  FeedCell.swift
//  Instagram
//
//  Created by Atakan Başaran on 14.09.2023.
//

import UIKit
import FirebaseFirestore
import Firebase


class FeedCell: UITableViewCell { //Table view içinde yaptığımız prototypeı yönetmek için yeni bir VC açar gibi yeni dosya açtık
    
    @IBOutlet weak var ButtonLike: UIButton!
    @IBOutlet weak var ButtonDelete: UIButton!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var commentText: UILabel!    
    @IBOutlet weak var LikeText: UILabel!
    @IBOutlet weak var documentIdLabel: UILabel! //hidden yaptık user documentIDleri göremicek ama biz indexPath.row ile her fotonun IDsine erişicez
    
    let firestoreDatabase = Firestore.firestore()

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func LikeButton(_ sender: UIButton) {
        
        let postID = documentIdLabel.text!
        guard let email = Auth.auth().currentUser?.email  else {return}
        
        let postRef = firestoreDatabase.collection("Post").document(postID)
        postRef.getDocument{ document, error in
            
            if error == nil {
                if let document = document, document.exists {
                    var likedBy = document.data()?["LikedBy"] as? [String] ?? []
                    
                    if likedBy.contains(email) {
                        likedBy.removeAll {$0 == email}
                        self.ButtonLike.isSelected = false
                        self.ButtonLike.setImage(UIImage(named: "heartempty"), for: .normal)
                        self.ButtonLike.tintColor = .white
                        self.updateLikeCount(increment: -1)
                        
                    } else {
                        likedBy.append(email)
                        self.ButtonLike.isSelected = true
                        self.ButtonLike.setImage(UIImage(named: "heart12"), for: .normal)
                        self.ButtonLike.tintColor = .white
                        self.updateLikeCount(increment: 1)
                    }
                    postRef.updateData(["LikedBy": likedBy])
                } else {
                    print("no document")
                }
            }
        }
    }

    
    
    func updateLikeCount(increment: Int) {
        if let likeCount = Int(LikeText.text!) {
            let newLikeCount = likeCount + increment
            let likeStore = ["Likes": newLikeCount] as [String: Any]
            firestoreDatabase.collection("Post").document(documentIdLabel.text!).setData(likeStore, merge: true)
            LikeText.text = String(newLikeCount)
            }
        }
    
    func loadLikeState(postID: String, email: String) {
        
        let postRef = firestoreDatabase.collection("Post").document(postID)
        postRef.getDocument{ document, error in
            
            if error == nil {
                if let document = document, document.exists {
                    var likedBy = document.data()?["LikedBy"] as? [String] ?? []
                    
                    if likedBy.contains(email) {
                        self.ButtonLike.isSelected = true
                        self.ButtonLike.setImage(UIImage(named: "heart12"), for: .normal)
                        self.ButtonLike.tintColor = .white
                        
                    } else {
                        self.ButtonLike.isSelected = false
                        self.ButtonLike.setImage(UIImage(named: "heartempty"), for: .normal)
                        self.ButtonLike.tintColor = .white
                    }
                } else {
                    print("no document")
                }
            }
        }
        
    }

    
    @IBAction func CommentButton(_ sender: Any) {
    }
    
    
    @IBAction func deleteButton(_ sender: Any) {
        
        let fireStoreDatabase = Firestore.firestore()
        
        fireStoreDatabase.collection("Post").document(documentIdLabel.text!).delete { error in
            if error != nil {
                print("Error")
            }
        }
    }
    
    
    

}
