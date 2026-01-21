//
//  Post.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 1/15/26.
//

import Foundation

struct Post {
    let id: String
    let username: String
    let imageURL: String
    let caption: String
    var likeCount: Int
    var isLiked: Bool

    init?(id: String, dictionary: [String: Any]) {
        guard let username = dictionary["username"] as? String,
              let imageURL = dictionary["imageURL"] as? String,
              let caption = dictionary["caption"] as? String,
              let likeCount = dictionary["likeCount"] as? Int else {
            return nil
        }

        self.id = id
        self.username = username
        self.imageURL = imageURL
        self.caption = caption
        self.likeCount = likeCount
        self.isLiked = false
    }
}

