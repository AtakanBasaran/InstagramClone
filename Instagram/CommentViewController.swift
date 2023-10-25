//
//  CommentViewController.swift
//  Instagram
//
//  Created by Atakan Başaran on 19.10.2023.
//

import UIKit
import Firebase

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var postCommentText: UITextField!
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let firestoreDatabase = Firestore.firestore()
    var comments = [[String: Any]]()
    var postID = String()
    var commentPost = [[String: Any]]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        print("postID: \(postID)")
        print("comments: \(comments)")
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let user = comments[indexPath.row]["user"] as? String, let comment = comments[indexPath.row]["comment"] as? String {
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.text = "\(user) \n\(comment)"
        }
        return cell
    }


    @IBAction func shareButton(_ sender: Any) {
        
        guard let email = Auth.auth().currentUser?.email else {return}
        
        if postCommentText.text != "" && postID != "" {
            let newComment = Comment(text: self.postCommentText.text!, user: email)

            firestoreDatabase.collection("Post").document(postID).getDocument { document, error in
                if error == nil {
                    if let document = document, document.exists {
                        self.commentPost = document.data()?["PostComment"] as? [[String: Any]] ?? []
                        
                        let commentData : [String: Any] = [
                            "comment" : newComment.text,
                            "user": newComment.user
                        ]
                        self.commentPost.append(commentData)
                        
                        if let postComment = ["PostComment": self.commentPost] as? [String : Any] {
                            self.firestoreDatabase.collection("Post").document(self.postID).setData(postComment, merge: true)
                        }
                        self.comments = self.commentPost
                        self.tableView.reloadData()
                    } else {
                        print("no document")
                    }
                    
                } else {
                    print("document could not fetched")
                }
                
            }
        } else {
            self.errorMessage(title: "Error!", message: "Comment cannot be empty!")
        }
    }
    

    
    func errorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    
}
