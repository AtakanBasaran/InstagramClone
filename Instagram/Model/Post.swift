//
//  Post.swift
//  Instagram
//
//  Created by Atakan Başaran on 14.09.2023.
//

import Foundation

//Models for post and comment

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
