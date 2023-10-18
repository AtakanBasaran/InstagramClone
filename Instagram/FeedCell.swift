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
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func LikeButton(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        let postID = documentIdLabel.text!
        
        // Check if the post is liked or not based on UserDefaults
        let isLiked = defaults.array(forKey: "likedPosts") as? [String] ?? []
        let liked = isLiked.contains(postID)
        
        if liked {
            sender.setImage(UIImage(named: "heartempty"), for: .normal)
            sender.isSelected = false
            removeFromLikedPosts(postID)
            updateLikeCount(increment: -1)
        } else {
            sender.setImage(UIImage(named: "heart12"), for: .normal)
            sender.isSelected = true
            addToLikedPosts(postID)
            updateLikeCount(increment: 1)
        }
        sender.tintColor = .white
    }

    
    func removeFromLikedPosts(_ postID: String) {
        var likedPosts = UserDefaults.standard.array(forKey: "likedPosts") as? [String] ?? []
        likedPosts.removeAll { $0 == postID }
        UserDefaults.standard.set(likedPosts, forKey: "likedPosts")
        }
    
    
    func addToLikedPosts(_ postID: String) {
        var likedPosts = UserDefaults.standard.array(forKey: "likedPosts") as? [String] ?? []
        likedPosts.append(postID)
        UserDefaults.standard.set(likedPosts, forKey: "likedPosts")
        }
    
    func updateLikeCount(increment: Int) {
        let fireStoreDatabase = Firestore.firestore()
        if let likeCount = Int(LikeText.text!) {
            let newLikeCount = likeCount + increment
            let likeStore = ["Likes": newLikeCount] as [String: Any]
            fireStoreDatabase.collection("Post").document(documentIdLabel.text!).setData(likeStore, merge: true)
            LikeText.text = String(newLikeCount)
            }
        }
    
    func loadLikeState() {
        let defaults = UserDefaults.standard
        let postID = documentIdLabel.text!

        if let likedPosts = defaults.array(forKey: "likedPosts") as? [String], likedPosts.contains(postID) {
            ButtonLike.isSelected = true
            ButtonLike.setImage(UIImage(named: "heart12"), for: .normal)
            ButtonLike.tintColor = .white
        } else {
            ButtonLike.isSelected = false
            ButtonLike.setImage(UIImage(named: "heartempty"), for: .normal)
            ButtonLike.tintColor = .white
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
