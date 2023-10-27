//
//  FeedViewController.swift
//  Instagram
//
//  Created by Atakan Başaran on 13.09.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore
import ImageSlideshow
import ImageSlideshowKingfisher


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    
    
    var postSeries = [Post]()
    var documentIDs = [String]()
    var selectedPostID = String()
    var inputArray : [KingfisherSource] = []
    var PostComments = [[String : Any]]()

    
    let firestoreDatabase = Firestore.firestore()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.delegate = self
        TableView.dataSource = self
        TableView.separatorColor = .purple
        firebaseGetData()
        
        overrideUserInterfaceStyle = .light
    }
    
    
    //fetching post data from firebase
    func firebaseGetData(){
            
        firestoreDatabase.collection("Post").order(by: "Date", descending: true)
            .addSnapshotListener { snapShot, error in
                
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if snapShot?.isEmpty != true && snapShot != nil {
                    
                    //to not show same posts more than 1
                    self.postSeries.removeAll(keepingCapacity: false)
                    self.documentIDs.removeAll(keepingCapacity: false)
                    self.inputArray.removeAll(keepingCapacity: false)
                    
                    
                    for document in snapShot!.documents {
                        let documentID = document.documentID
                        self.documentIDs.append(documentID)
                        
                        if let imageURLArray = document.get("ImageUrlArray") as? [String] {
                            if let comment = document.get("Comment") as? String {
                                if let email = document.get("Email") as? String {
                                    if let likes = document.get("Likes") as? Int {
                                        let post = Post(email: email, comment: comment, ImageUrlArray: imageURLArray, likes: likes)
                                        self.postSeries.append(post)
                                    }
                                   
                                }
                            }

                        }
                    }
                    
                    self.TableView.reloadData()
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postSeries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.emailText.text = postSeries[indexPath.row].email
        cell.commentText.text = postSeries[indexPath.row].comment
        cell.LikeText.text = String(postSeries[indexPath.row].likes)
        cell.documentIdLabel.text = documentIDs[indexPath.row]
        cell.loadLikeState(postID: cell.documentIdLabel.text!, email: Auth.auth().currentUser!.email!) //initial state for the like button
        
        //Delete button
        if postSeries[indexPath.row].email != Auth.auth().currentUser?.email {
            cell.ButtonDelete.isHidden = true
        } else {
            cell.ButtonDelete.isHidden = false
        }
        
        //Image slide show arrangements
        let imageSlideShow = ImageSlideshow(frame: CGRect(x: cell.contentView.bounds.width / 150 , y: cell.contentView.frame.height * 0.2, width: cell.contentView.frame.width , height: cell.contentView.bounds.height * 0.6 ))
        imageSlideShow.backgroundColor = UIColor.white

        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.black
        pageIndicator.pageIndicatorTintColor = UIColor.white
        imageSlideShow.pageIndicator = pageIndicator

        imageSlideShow.contentScaleMode = .scaleAspectFit
        
        inputArray.removeAll(keepingCapacity: false)
        
        for imageUrl in postSeries[indexPath.row].ImageUrlArray  {
            if let kingfisherSource = KingfisherSource(urlString: imageUrl) {
                    inputArray.append(kingfisherSource)
                }
        }
                
        imageSlideShow.setImageInputs(inputArray)
        cell.contentView.addSubview(imageSlideShow)
        
        NSLayoutConstraint.activate([
                imageSlideShow.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                imageSlideShow.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                imageSlideShow.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                imageSlideShow.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
        
        //Comment algorithm
        cell.commentButtonAction = {
            
            let postID = self.documentIDs[indexPath.row]
            if postID != "" {
                self.firestoreDatabase.collection("Post").document(postID).getDocument { document, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        if let document = document, document.exists {
                            self.PostComments = document.data()?["PostComment"] as? [[String: Any]] ?? []
                            self.selectedPostID = postID
                            print("PostComments: \(self.PostComments)")
                            self.performSegue(withIdentifier: "toCommentVC", sender: nil)
                        } else {
                            print("document does not exist")
                        }
                    }
                }
            } else {
                print("postID error")
            }
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentVC" {
            let destinationVC = segue.destination as! CommentViewController
            destinationVC.comments = PostComments
            destinationVC.postID = selectedPostID
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 333 // Set a fixed height for post cell
    }


    
    

}
