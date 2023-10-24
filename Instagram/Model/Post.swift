//
//  Post.swift
//  Instagram
//
//  Created by Atakan Başaran on 14.09.2023.
//

import Foundation

//Comment, imageUrl ve email için tek tek series oluşturup tek tek eklemek yerine class oluşturup tekte eklemem daha iyi bir yöntem -> Object oriented programming

struct Post {
    
    var email: String
    var comment: String
    var ImageUrlArray: [String]
    var likes : Int

}

struct Comment {
    
    var text: String
    var user: String
    
}
