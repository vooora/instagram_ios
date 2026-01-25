//
//  FeedPost.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 1/15/26.
//

import Foundation

struct FeedPost: Codable {
    let postId: String
    let userName: String
    let userImage: String?
    let postImage: String
    let likeCount: Int
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userName = "user_name"
        case userImage = "user_image"
        case postImage = "post_image"
        case likeCount = "like_count"
        case likedByUser = "liked_by_user"
    }
}
