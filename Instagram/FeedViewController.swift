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
    
    
    var postSeries = [Post]() //Oluşturduğum post classı elemanlarını tutucağım bir dizi oluşturdum
    var documentIDs = [String]() //Document IDlerin olduğu bir string dizisi oluşturduk
    var selectedPostID = String()
    var inputArray : [KingfisherSource] = []
    var PostComments = [String]()

    
    let firestoreDatabase = Firestore.firestore()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.delegate = self
        TableView.dataSource = self
        TableView.separatorColor = .purple
        firebaseGetData()
        
        overrideUserInterfaceStyle = .light
    }
    
    
    
    func firebaseGetData(){
         
        
        //firestoreDatabase.collection("Post").whereField(<#T##field: String##String#>, isEqualTo: <#T##Any#>) ->Post collectionumuzda hangi fieldi seçebileceğimizi filtreliyebiliyoruz
            
        firestoreDatabase.collection("Post").order(by: "Date", descending: true) //istediğimiz gibi orderlayabiliyoruz.
            .addSnapshotListener { snapShot, error in //Post adında oluşturduğum collectiona ulaşıyorum, addSnapshotListener -> dökümanda olduğu gibi bu func ile FireStore Database e yüklediğim dataları çekicem
                    
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if snapShot?.isEmpty != true && snapShot != nil { // SnapShot boş değil ise, == false da olurdu, nil olmayıp içinde döküman olmayabilir, döküman olupda nil olcağını sanmıyorum, her türlü optional olduğu için && snapShot != nil ile sağlama aldık
                    
                    self.postSeries.removeAll(keepingCapacity: false)
                    self.documentIDs.removeAll(keepingCapacity: false)
                    self.inputArray.removeAll(keepingCapacity: false)
                    
                    
                    for document in snapShot!.documents { //snapShot!.documents ile eklediğimiz documenların dizisini alıyoruz for döngüsü ile tek tek alıcaz. Documenler kaydettiğimiz dictionary yapısı
                        let documentID = document.documentID //ihtiyacımız yok ama tek tek documen IDleri çekmek istiyosak bunu kullanabiliriz
                        self.documentIDs.append(documentID) //Firestoredan çektiğimiz documentIDleri diziye ekledik
                        
                        if let imageURLArray = document.get("ImageUrlArray") as? [String] { //seçtiğimiz fiedları çekiyoruz, databese kaydederken dictionary şeklinde kaydettiğimzi ve içinde farklı typler olduğu için any diye kaydetmiştik şimdi bize any optional geldiği için onu kendi türüne cast etmeliyiz, Eğer imageUrlyi string olarak alabilirsek imageSeriese ekle
                            if let comment = document.get("Comment") as? String { //Hepsini almaya çalış bi tane hata olursa çalışmaz ve bizim amacımız bu eksik veri göstermek istemiyoruz
                                if let email = document.get("Email") as? String {
                                    if let likes = document.get("Likes") as? Int {
                                        let post = Post(email: email, comment: comment, ImageUrlArray: imageURLArray, likes: likes)
                                        self.postSeries.append(post) //4 tane ayrı dizi yerine tek elemenala hallettik oluşturduğumuz class sayesinde
                                    }
                                   
                                }
                            }

                        }
                    }
                    
                    self.TableView.reloadData() //Yeni veri geldiğinde table viewi güncelle
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postSeries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell //Cell -> prototype cellimiz identifier atadık, as! FeedCell -> Oluşturduğumuz FeedCell clasına cast ettik ki orda ne yapabilceğimizi ayarlıyalım burda gösterelim
        cell.emailText.text = postSeries[indexPath.row].email //Databasedeki documenları sırayla geziyor ve herbirinin mailini yazıyor indexPath.row ile
        cell.commentText.text = postSeries[indexPath.row].comment
        cell.LikeText.text = String(postSeries[indexPath.row].likes)
        cell.documentIdLabel.text = documentIDs[indexPath.row] //Like butonuna bastığımızda hangi fotonun IDsini aldığımızı buraya atıyoruz
        cell.loadLikeState(postID: cell.documentIdLabel.text!, email: Auth.auth().currentUser!.email!)
        
        
        
        if postSeries[indexPath.row].email != Auth.auth().currentUser?.email {
            cell.ButtonDelete.isHidden = true
        } else {
            cell.ButtonDelete.isHidden = false
        }
        
        
        
        
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
        
        cell.commentButtonAction = {
            
            let postID = self.documentIDs[indexPath.row]
            if postID != "" {
                self.firestoreDatabase.collection("Post").document(postID).getDocument { document, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        if let document = document, document.exists {
                            self.PostComments = document.data()?["PostComment"] as? [String] ?? []
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
        return 333 // Set a fixed height
    }


    
    

}
