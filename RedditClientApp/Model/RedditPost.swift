//
//  RedditPost.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import Foundation

struct RedditResponse: Codable {
    let data: RedditData
}

struct RedditData: Codable {
    let children: [RedditChild]
}

struct RedditChild: Codable {
    let data: RedditPostData
}
// This function is the base struct for the posts.
struct RedditPostData: Codable {
    let imageURL: String
    let title: String
    let description: String
    let permalink: String
    let isOver18: Bool
    let subreddit: String?
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "thumbnail"
        case title
        case description = "selftext"
        case permalink
        case isOver18 = "over_18"
        case subreddit
        case id
    }
    
    init(imageURL: String, title: String, description: String, permalink: String, isOver18: Bool, subreddit: String?, id: String) {
        self.imageURL = imageURL
        self.title = title
        self.description = description
        self.permalink = permalink
        self.isOver18 = isOver18
        self.subreddit = subreddit
        self.id = id
    }
}

