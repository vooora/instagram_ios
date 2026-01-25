//
//  Reel.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 1/15/26.
//

import Foundation

struct Reel: Codable {
    let reelId: String
    let userName: String
    let userImage: String?
    let reelVideo: String
    let likeCount: Int
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case reelId = "reel_id"
        case userName = "user_name"
        case userImage = "user_image"
        case reelVideo = "reel_video"
        case likeCount = "like_count"
        case likedByUser = "liked_by_user"
    }
}

struct ReelsResponse: Codable {
    let reels: [Reel]
}
